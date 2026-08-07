"""Выдача вопросов, приём ответов и статистика по темам."""

from __future__ import annotations

import uuid
from dataclasses import dataclass
from datetime import UTC, datetime

from sqlalchemy import Select, func, select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.core.exceptions import ConflictError, InvalidInputError, NotFoundError
from app.db.models.question import Question, question_specializations
from app.db.models.taxonomy import Topic, TopicWeight
from app.db.models.user import (
    ReviewState,
    User,
    UserAnswer,
    UserSpecialization,
    UserTopicRating,
)
from app.services import rating as elo
from app.services.scheduler import ReviewScheduler, ReviewSnapshot, get_scheduler

# Сколько кандидатов поднимаем в память для ранжирования. Банк вопросов на
# специализацию небольшой; когда он вырастет, ранжирование уедет в SQL.
CANDIDATE_LIMIT = 200


@dataclass(frozen=True, slots=True)
class NextQuestion:
    question: Question
    is_review: bool
    due_at: datetime | None


@dataclass(frozen=True, slots=True)
class AnswerSubmission:
    submission_id: uuid.UUID
    question_id: uuid.UUID
    specialization_id: str
    selected_options: list[str]
    free_text: str | None
    self_assessment: int | None


@dataclass(frozen=True, slots=True)
class AnswerResult:
    question: Question
    score: float
    quality: int
    rating_before: float
    rating_after: float
    difficulty_before: int
    difficulty_after: int
    next_review_at: datetime
    is_duplicate: bool

    @property
    def rating_delta(self) -> float:
        return self.rating_after - self.rating_before

    @property
    def grade(self) -> int:
        return elo.grade_from_rating(self.rating_after)


@dataclass(frozen=True, slots=True)
class TopicStats:
    topic_code: str
    title: str
    rating: float
    grade: int
    answers_count: int
    weight: float


@dataclass(frozen=True, slots=True)
class SpecializationStats:
    specialization_id: str
    answers_count: int
    topics: list[TopicStats]
    overall_rating: float | None
    overall_grade: int | None
    locked_reason: str | None

    @property
    def is_estimate_available(self) -> bool:
        return self.overall_grade is not None


class PracticeService:
    """Сценарии тренировки. Транспорт (HTTP) сюда не проникает."""

    def __init__(self, session: AsyncSession, scheduler: ReviewScheduler | None = None) -> None:
        self._session = session
        self._scheduler = scheduler or get_scheduler()

    # --- выдача -----------------------------------------------------------------

    async def next_question(self, user: User, specialization_id: str) -> NextQuestion:
        profile = await self._require_profile(user, specialization_id)
        grade = await self.effective_grade(user, profile)

        due = await self._next_due_question(user, specialization_id)
        if due is not None:
            return due

        question = await self._next_new_question(user, specialization_id, grade)
        if question is None:
            raise NotFoundError(
                "вопросы для вашего грейда в этой специализации закончились — "
                "вернитесь позже за повторениями"
            )
        return NextQuestion(question=question, is_review=False, due_at=None)

    async def _next_due_question(self, user: User, specialization_id: str) -> NextQuestion | None:
        """Повторения из SRS имеют приоритет над новыми вопросами."""
        now = datetime.now(UTC)
        statement = (
            select(Question, ReviewState.due_at)
            .join(ReviewState, ReviewState.question_id == Question.id)
            .join(
                question_specializations,
                question_specializations.c.question_id == Question.id,
            )
            .where(
                ReviewState.user_id == user.id,
                ReviewState.due_at <= now,
                question_specializations.c.specialization_id == specialization_id,
            )
            .order_by(ReviewState.due_at, Question.slug)
            .options(selectinload(Question.options))
            .limit(1)
        )
        row = (await self._session.execute(statement)).first()
        if row is None:
            return None

        question, due_at = row
        return NextQuestion(question=question, is_review=True, due_at=due_at)

    async def _next_new_question(
        self, user: User, specialization_id: str, grade: int
    ) -> Question | None:
        answered = select(UserAnswer.question_id).where(UserAnswer.user_id == user.id)

        statement: Select[tuple[Question]] = (
            select(Question)
            .join(
                question_specializations,
                question_specializations.c.question_id == Question.id,
            )
            .where(
                question_specializations.c.specialization_id == specialization_id,
                # Вопрос вне грейда пользователя не выдаётся вовсе (CLAUDE.md §3.4).
                Question.min_grade <= grade,
                Question.max_grade >= grade,
                Question.id.not_in(answered),
            )
            .options(selectinload(Question.options))
            .limit(CANDIDATE_LIMIT)
        )
        candidates = list(await self._session.scalars(statement))
        if not candidates:
            return None

        weights = await self._topic_weights(specialization_id, grade)
        ratings = await self._topic_ratings(user, specialization_id)

        return max(
            candidates,
            key=lambda question: (
                self._priority(question, grade, weights, ratings),
                question.slug,
            ),
        )

    @staticmethod
    def _priority(
        question: Question,
        grade: int,
        weights: dict[str, float],
        ratings: dict[str, float],
    ) -> float:
        """Чем важнее тема, слабее пользователь и ближе peak_grade — тем выше приоритет."""
        weight = weights.get(question.topic_code, 0.1)
        gap = 1.0 - elo.normalized_rating(ratings.get(question.topic_code, elo.START_RATING))
        proximity = 1.0 / (1.0 + abs(question.peak_grade - grade))
        frequency = question.frequency / 5.0
        return weight * gap * proximity * frequency

    # --- приём ответа -----------------------------------------------------------

    async def submit_answer(self, user: User, submission: AnswerSubmission) -> AnswerResult:
        existing = await self._find_submission(user, submission.submission_id)
        if existing is not None:
            return await self._replay(existing)

        profile = await self._require_profile(user, submission.specialization_id)
        question = await self._require_question(submission.question_id)

        score, quality = self._evaluate(question, submission)
        topic_rating = await self._get_or_create_rating(
            user, submission.specialization_id, question.topic_code
        )

        update = elo.apply_elo(
            user_rating=topic_rating.rating,
            question_rating=question.difficulty_rating,
            score=score,
            answers_on_topic=topic_rating.answers_count,
        )

        snapshot = await self._review_snapshot(user, question.id)
        scheduled = self._scheduler.review(snapshot, quality=quality, now=datetime.now(UTC))
        assert scheduled.due_at is not None  # планировщик всегда проставляет срок

        answer = UserAnswer(
            id=uuid.uuid4(),
            user_id=user.id,
            question_id=question.id,
            specialization_id=submission.specialization_id,
            topic_code=question.topic_code,
            submission_id=submission.submission_id,
            selected_options=submission.selected_options,
            free_text=submission.free_text,
            score=score,
            quality=quality,
            rating_before=update.user_rating_before,
            rating_after=update.user_rating_after,
            difficulty_before=update.question_rating_before,
            difficulty_after=update.question_rating_after,
        )
        self._session.add(answer)

        topic_rating.rating = update.user_rating_after
        topic_rating.answers_count += 1
        question.difficulty_rating = update.question_rating_after
        profile.answers_count += 1
        await self._save_review_state(user, question.id, scheduled)

        try:
            await self._session.flush()
        except IntegrityError as exc:
            # Гонка двух одновременных отправок с одним submission_id.
            await self._session.rollback()
            raise ConflictError("ответ с таким submission_id уже принят") from exc

        return AnswerResult(
            question=question,
            score=score,
            quality=quality,
            rating_before=update.user_rating_before,
            rating_after=update.user_rating_after,
            difficulty_before=update.question_rating_before,
            difficulty_after=update.question_rating_after,
            next_review_at=scheduled.due_at,
            is_duplicate=False,
        )

    async def _replay(self, answer: UserAnswer) -> AnswerResult:
        """Повторная отправка того же ответа возвращает сохранённый результат."""
        question = await self._require_question(answer.question_id)
        state = await self._session.get(ReviewState, (answer.user_id, answer.question_id))
        return AnswerResult(
            question=question,
            score=answer.score,
            quality=answer.quality,
            rating_before=answer.rating_before,
            rating_after=answer.rating_after,
            difficulty_before=answer.difficulty_before,
            difficulty_after=answer.difficulty_after,
            next_review_at=state.due_at if state else answer.answered_at,
            is_duplicate=True,
        )

    @staticmethod
    def _evaluate(question: Question, submission: AnswerSubmission) -> tuple[float, int]:
        """Вернуть Elo-очки и качество 0–5 для планировщика."""
        if question.type.has_options:
            if not submission.selected_options:
                raise InvalidInputError("для этого вопроса нужно выбрать вариант ответа")

            known = {option.code for option in question.options}
            unknown = set(submission.selected_options) - known
            if unknown:
                raise InvalidInputError(f"неизвестные варианты: {', '.join(sorted(unknown))}")

            correct = {option.code for option in question.options if option.is_correct}
            selected = set(submission.selected_options)

            if selected == correct:
                score = elo.SCORE_CORRECT
            elif selected & correct and not selected - correct:
                # Часть верных без ошибочных — засчитываем как частичный ответ.
                score = elo.SCORE_PARTIAL
            else:
                score = elo.SCORE_WRONG
            return score, elo.quality_from_score(score)

        if submission.self_assessment is None:
            raise InvalidInputError("для развёрнутого вопроса нужна самооценка ответа от 0 до 5")
        quality = submission.self_assessment
        return elo.score_from_quality(quality), quality

    # --- статистика -------------------------------------------------------------

    async def stats(self, user: User, specialization_id: str) -> SpecializationStats:
        profile = await self._require_profile(user, specialization_id)
        grade = profile.self_assessed_grade

        weights = await self._topic_weights(specialization_id, grade)
        titles = await self._topic_titles(specialization_id)
        rows = list(
            await self._session.scalars(
                select(UserTopicRating).where(
                    UserTopicRating.user_id == user.id,
                    UserTopicRating.specialization_id == specialization_id,
                )
            )
        )

        topics = [
            TopicStats(
                topic_code=row.topic_code,
                title=titles.get(row.topic_code, row.topic_code),
                rating=row.rating,
                grade=elo.grade_from_rating(row.rating),
                answers_count=row.answers_count,
                weight=weights.get(row.topic_code, 0.0),
            )
            for row in sorted(rows, key=lambda item: item.topic_code)
        ]

        locked_reason = self._estimate_lock(user, profile)
        if locked_reason is not None:
            return SpecializationStats(
                specialization_id=specialization_id,
                answers_count=profile.answers_count,
                topics=topics,
                overall_rating=None,
                overall_grade=None,
                locked_reason=locked_reason,
            )

        overall = elo.overall_rating({row.topic_code: row.rating for row in rows}, weights)
        return SpecializationStats(
            specialization_id=specialization_id,
            answers_count=profile.answers_count,
            topics=topics,
            overall_rating=overall,
            overall_grade=elo.grade_from_rating(overall) if overall is not None else None,
            locked_reason=None,
        )

    @staticmethod
    def _estimate_lock(user: User, profile: UserSpecialization) -> str | None:
        """Почему оценка уровня недоступна. Платность проверяется здесь, а не в роутере."""
        if profile.answers_count < elo.MIN_ANSWERS_FOR_ESTIMATE:
            return "not_enough_data"
        if not user.is_premium:
            return "premium_required"
        return None

    async def effective_grade(self, user: User, profile: UserSpecialization) -> int:
        """Грейд для выдачи: измеренный, если данных хватает, иначе самооценка."""
        if profile.answers_count < elo.MIN_ANSWERS_FOR_ESTIMATE:
            return profile.self_assessed_grade

        weights = await self._topic_weights(profile.specialization_id, profile.self_assessed_grade)
        ratings = await self._topic_ratings(user, profile.specialization_id)
        overall = elo.overall_rating(ratings, weights)
        if overall is None:
            return profile.self_assessed_grade
        return elo.grade_from_rating(overall)

    # --- вспомогательное --------------------------------------------------------

    async def _require_profile(self, user: User, specialization_id: str) -> UserSpecialization:
        profile = await self._session.get(UserSpecialization, (user.id, specialization_id))
        if profile is None:
            raise NotFoundError(
                f"специализация {specialization_id!r} не выбрана в профиле; "
                "сначала укажите её через PATCH /api/v1/me"
            )
        return profile

    async def _require_question(self, question_id: uuid.UUID) -> Question:
        question = await self._session.get(
            Question, question_id, options=[selectinload(Question.options)]
        )
        if question is None:
            raise NotFoundError("вопрос не найден")
        return question

    async def _find_submission(self, user: User, submission_id: uuid.UUID) -> UserAnswer | None:
        result: UserAnswer | None = await self._session.scalar(
            select(UserAnswer).where(
                UserAnswer.user_id == user.id,
                UserAnswer.submission_id == submission_id,
            )
        )
        return result

    async def _get_or_create_rating(
        self, user: User, specialization_id: str, topic_code: str
    ) -> UserTopicRating:
        key = (user.id, specialization_id, topic_code)
        existing = await self._session.get(UserTopicRating, key)
        if existing is not None:
            return existing

        created = UserTopicRating(
            user_id=user.id,
            specialization_id=specialization_id,
            topic_code=topic_code,
            rating=elo.START_RATING,
            answers_count=0,
        )
        self._session.add(created)
        await self._session.flush()
        return created

    async def _review_snapshot(self, user: User, question_id: uuid.UUID) -> ReviewSnapshot:
        state = await self._session.get(ReviewState, (user.id, question_id))
        if state is None:
            return ReviewSnapshot()
        return ReviewSnapshot(
            easiness_factor=state.easiness_factor,
            repetitions=state.repetitions,
            interval_days=state.interval_days,
            due_at=state.due_at,
        )

    async def _save_review_state(
        self, user: User, question_id: uuid.UUID, snapshot: ReviewSnapshot
    ) -> None:
        assert snapshot.due_at is not None
        now = datetime.now(UTC)
        state = await self._session.get(ReviewState, (user.id, question_id))
        if state is None:
            state = ReviewState(user_id=user.id, question_id=question_id)
            self._session.add(state)

        state.easiness_factor = snapshot.easiness_factor
        state.repetitions = snapshot.repetitions
        state.interval_days = snapshot.interval_days
        state.due_at = snapshot.due_at
        state.last_reviewed_at = now

    async def _topic_weights(self, specialization_id: str, grade: int) -> dict[str, float]:
        rows = (
            await self._session.execute(
                select(Topic.code, TopicWeight.weight)
                .join(TopicWeight, TopicWeight.topic_id == Topic.id)
                .where(Topic.specialization_id == specialization_id, TopicWeight.grade == grade)
            )
        ).all()
        return {code: weight for code, weight in rows}

    async def _topic_titles(self, specialization_id: str) -> dict[str, str]:
        rows = (
            await self._session.execute(
                select(Topic.code, Topic.title).where(Topic.specialization_id == specialization_id)
            )
        ).all()
        return {code: title for code, title in rows}

    async def _topic_ratings(self, user: User, specialization_id: str) -> dict[str, float]:
        rows = (
            await self._session.execute(
                select(UserTopicRating.topic_code, UserTopicRating.rating).where(
                    UserTopicRating.user_id == user.id,
                    UserTopicRating.specialization_id == specialization_id,
                )
            )
        ).all()
        return {code: rating for code, rating in rows}

    async def answered_count(self, user: User, specialization_id: str) -> int:
        return int(
            (
                await self._session.execute(
                    select(func.count())
                    .select_from(UserAnswer)
                    .where(
                        UserAnswer.user_id == user.id,
                        UserAnswer.specialization_id == specialization_id,
                    )
                )
            ).scalar_one()
        )
