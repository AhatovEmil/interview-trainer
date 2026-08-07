"""Сценарии плана подготовки: создание и «что делать сегодня»."""

from __future__ import annotations

from dataclasses import dataclass
from datetime import UTC, date, datetime

from sqlalchemy import select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import InvalidInputError, NotFoundError, PremiumRequiredError
from app.db.models.plan import StudyPlan, StudyPlanDay
from app.db.models.question import Question, question_specializations
from app.db.models.taxonomy import Topic, TopicWeight
from app.db.models.user import ReviewState, User, UserAnswer, UserSpecialization, UserTopicRating
from app.services import rating as elo
from app.services.planner import (
    DEFAULT_DAILY_CAPACITY,
    PlanError,
    TopicPriority,
    build_plan,
    plan_days,
)


@dataclass(frozen=True, slots=True)
class TodayPlan:
    plan: StudyPlan
    day: StudyPlanDay
    due_reviews: int
    new_questions: list[Question]
    completed_today: int

    @property
    def total_target(self) -> int:
        return self.due_reviews + len(self.new_questions)

    @property
    def days_left(self) -> int:
        return (self.plan.interview_date - self.day.day).days


class PlanService:
    """Персональный план — платная фича, флаг проверяется здесь, а не в роутере."""

    def __init__(self, session: AsyncSession) -> None:
        self._session = session

    async def create(
        self,
        user: User,
        specialization_id: str,
        interview_date: date,
        daily_capacity: int = DEFAULT_DAILY_CAPACITY,
        today: date | None = None,
    ) -> StudyPlan:
        self._require_premium(user)
        profile = await self._require_profile(user, specialization_id)
        current_day = today or datetime.now(UTC).date()

        try:
            days = plan_days(current_day, interview_date)
            priorities = await self._topic_priorities(
                user, specialization_id, profile.self_assessed_grade
            )
            schedule = build_plan(priorities, days, daily_capacity)
        except PlanError as exc:
            raise InvalidInputError(str(exc)) from exc

        await self._deactivate_previous(user, specialization_id)

        plan = StudyPlan(
            user_id=user.id,
            specialization_id=specialization_id,
            interview_date=interview_date,
            target_grade=profile.self_assessed_grade,
            daily_capacity=daily_capacity,
            is_active=True,
            days=[
                StudyPlanDay(
                    day_index=item.day_index,
                    day=item.day,
                    topic_codes=list(item.topics),
                    new_questions=item.new_questions,
                    review_only=item.review_only,
                )
                for item in schedule
            ],
        )
        self._session.add(plan)
        await self._session.flush()
        return plan

    async def today(
        self,
        user: User,
        specialization_id: str,
        today: date | None = None,
    ) -> TodayPlan:
        self._require_premium(user)
        plan = await self._active_plan(user, specialization_id)
        current_day = today or datetime.now(UTC).date()

        day = self._day_for(plan, current_day)
        due_reviews = await self._count_due_reviews(user, specialization_id)
        completed = await self._count_answers_on(user, specialization_id, current_day)

        # Повторения имеют приоритет: новыми вопросами добираем остаток нормы.
        capacity_left = max(0, day.new_questions - due_reviews)
        new_questions = (
            []
            if day.review_only or capacity_left == 0
            else await self._pick_new_questions(user, specialization_id, day, capacity_left)
        )

        return TodayPlan(
            plan=plan,
            day=day,
            due_reviews=due_reviews,
            new_questions=new_questions,
            completed_today=completed,
        )

    @staticmethod
    def _require_premium(user: User) -> None:
        if not user.is_premium:
            raise PremiumRequiredError("персональный план доступен на платном тарифе")

    @staticmethod
    def _day_for(plan: StudyPlan, current_day: date) -> StudyPlanDay:
        for day in plan.days:
            if day.day == current_day:
                return day
        if current_day >= plan.interview_date:
            raise NotFoundError("собеседование уже прошло — создайте новый план")
        raise NotFoundError("на сегодня в плане нет дня")

    async def _require_profile(self, user: User, specialization_id: str) -> UserSpecialization:
        profile = await self._session.get(UserSpecialization, (user.id, specialization_id))
        if profile is None:
            raise NotFoundError(f"специализация {specialization_id!r} не выбрана в профиле")
        return profile

    async def _active_plan(self, user: User, specialization_id: str) -> StudyPlan:
        plan = await self._session.scalar(
            select(StudyPlan)
            .where(
                StudyPlan.user_id == user.id,
                StudyPlan.specialization_id == specialization_id,
                StudyPlan.is_active.is_(True),
            )
            .order_by(StudyPlan.created_at.desc())
            .limit(1)
        )
        if plan is None:
            raise NotFoundError("активного плана нет — создайте его через POST /api/v1/plan")
        return plan

    async def _deactivate_previous(self, user: User, specialization_id: str) -> None:
        await self._session.execute(
            update(StudyPlan)
            .where(
                StudyPlan.user_id == user.id,
                StudyPlan.specialization_id == specialization_id,
                StudyPlan.is_active.is_(True),
            )
            .values(is_active=False)
        )

    async def _topic_priorities(
        self, user: User, specialization_id: str, target_grade: int
    ) -> list[TopicPriority]:
        weights = (
            await self._session.execute(
                select(Topic.code, TopicWeight.weight)
                .join(TopicWeight, TopicWeight.topic_id == Topic.id)
                .where(
                    Topic.specialization_id == specialization_id,
                    TopicWeight.grade == target_grade,
                )
            )
        ).all()

        rating_rows = (
            await self._session.execute(
                select(UserTopicRating.topic_code, UserTopicRating.rating).where(
                    UserTopicRating.user_id == user.id,
                    UserTopicRating.specialization_id == specialization_id,
                )
            )
        ).all()
        ratings: dict[str, float] = {code: rating for code, rating in rating_rows}

        return [
            TopicPriority(
                topic_code=code,
                weight=weight,
                rating=ratings.get(code, elo.START_RATING),
            )
            for code, weight in weights
        ]

    async def _count_due_reviews(self, user: User, specialization_id: str) -> int:
        now = datetime.now(UTC)
        rows = await self._session.execute(
            select(ReviewState.question_id)
            .join(
                question_specializations,
                question_specializations.c.question_id == ReviewState.question_id,
            )
            .where(
                ReviewState.user_id == user.id,
                ReviewState.due_at <= now,
                question_specializations.c.specialization_id == specialization_id,
            )
        )
        return len(rows.all())

    async def _count_answers_on(self, user: User, specialization_id: str, current_day: date) -> int:
        rows = await self._session.execute(
            select(UserAnswer.id).where(
                UserAnswer.user_id == user.id,
                UserAnswer.specialization_id == specialization_id,
                UserAnswer.answered_at
                >= datetime(current_day.year, current_day.month, current_day.day, tzinfo=UTC),
            )
        )
        return len(rows.all())

    async def _pick_new_questions(
        self,
        user: User,
        specialization_id: str,
        day: StudyPlanDay,
        limit: int,
    ) -> list[Question]:
        answered = select(UserAnswer.question_id).where(UserAnswer.user_id == user.id)

        statement = (
            select(Question)
            .join(
                question_specializations,
                question_specializations.c.question_id == Question.id,
            )
            .where(
                question_specializations.c.specialization_id == specialization_id,
                Question.topic_code.in_(day.topic_codes),
                Question.min_grade <= day.plan.target_grade,
                Question.max_grade >= day.plan.target_grade,
                Question.id.not_in(answered),
            )
            .order_by(Question.frequency.desc(), Question.slug)
            .limit(limit)
        )
        return list(await self._session.scalars(statement))
