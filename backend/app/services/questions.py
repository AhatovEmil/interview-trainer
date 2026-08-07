"""Синхронизация банка вопросов из YAML.

Сид трогает только вопросы с `source=seed`: присланное пользователями (`crowdsourced`)
живёт в базе и из файлов не управляется.
"""

from __future__ import annotations

import uuid
from dataclasses import dataclass, field

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.core.enums import QuestionSource
from app.db.models.question import Question, QuestionOption, difficulty_from_peak_grade
from app.db.models.taxonomy import Specialization
from app.seed.question_schema import QuestionIn
from app.services.taxonomy import EntityStats


@dataclass(slots=True)
class QuestionSyncReport:
    questions: EntityStats = field(default_factory=EntityStats)
    options: EntityStats = field(default_factory=EntityStats)
    links: EntityStats = field(default_factory=EntityStats)

    @property
    def has_changes(self) -> bool:
        return any(
            stats.created or stats.updated or stats.deleted
            for stats in (self.questions, self.options, self.links)
        )

    def as_lines(self) -> list[str]:
        return [
            f"вопросы:   {self.questions}",
            f"варианты:  {self.options}",
            f"связи:     {self.links}",
        ]


class QuestionService:
    def __init__(self, session: AsyncSession) -> None:
        self._session = session

    async def sync(self, incoming: list[QuestionIn]) -> QuestionSyncReport:
        """Привести seed-вопросы в базе в соответствие со списком из YAML."""
        report = QuestionSyncReport()
        existing = await self._existing_seed_questions()

        for payload in incoming:
            current = existing.pop(payload.uuid, None)
            is_new = current is None

            if current is None:
                # Сид никогда не помечает вопрос проверенным: это делает человек
                # (CLAUDE.md §8.1). При обновлении флаг не трогаем.
                # Коллекции задаются явно: иначе обращение к ним в async-сессии
                # уйдёт в ленивую подгрузку и упадёт с MissingGreenlet.
                current = Question(
                    id=payload.uuid,
                    slug=payload.slug,
                    is_verified=False,
                    specializations=[],
                    options=[],
                )
                self._session.add(current)

            changed = self._apply_fields(current, payload)
            if is_new:
                report.questions.created += 1
            elif changed:
                report.questions.updated += 1

            await self._session.flush()
            await self._sync_specializations(current, payload, report)
            await self._sync_options(current, payload, report)

        for stale in existing.values():
            await self._session.delete(stale)
            report.questions.deleted += 1

        await self._session.flush()
        return report

    async def _existing_seed_questions(self) -> dict[uuid.UUID, Question]:
        result = await self._session.scalars(
            select(Question)
            .where(Question.source == QuestionSource.SEED)
            .options(selectinload(Question.options), selectinload(Question.specializations))
        )
        return {row.id: row for row in result}

    def _apply_fields(self, row: Question, payload: QuestionIn) -> bool:
        min_grade, peak_grade, max_grade = payload.grades()
        difficulty = payload.difficulty_rating or difficulty_from_peak_grade(peak_grade)

        values: dict[str, object] = {
            "slug": payload.slug,
            "topic_code": payload.topic,
            "subtopic_code": payload.subtopic,
            "min_grade": min_grade,
            "peak_grade": peak_grade,
            "max_grade": max_grade,
            "difficulty_rating": difficulty,
            "frequency": payload.frequency,
            "type": payload.type,
            "title": payload.title,
            "answer_short": payload.answer_short,
            "answer_detailed": payload.answer_detailed,
            "common_mistakes": payload.common_mistakes,
            "follow_ups": payload.follow_ups,
            "company_tags": payload.company_tags,
            "source": payload.source,
        }

        changed = False
        for name, value in values.items():
            if getattr(row, name, None) != value:
                setattr(row, name, value)
                changed = True
        return changed

    async def _sync_specializations(
        self, row: Question, payload: QuestionIn, report: QuestionSyncReport
    ) -> None:
        wanted = set(payload.specializations)
        current = {specialization.id for specialization in row.specializations}
        if wanted == current:
            return

        specializations = list(
            await self._session.scalars(select(Specialization).where(Specialization.id.in_(wanted)))
        )
        found = {specialization.id for specialization in specializations}
        missing = wanted - found
        if missing:
            raise ValueError(
                f"вопрос {payload.slug!r}: специализаций нет в базе: {', '.join(sorted(missing))}; "
                "сначала загрузите таксономию"
            )

        row.specializations = specializations
        report.links.created += len(wanted - current)
        report.links.deleted += len(current - wanted)

    async def _sync_options(
        self, row: Question, payload: QuestionIn, report: QuestionSyncReport
    ) -> None:
        existing = {option.code: option for option in row.options}

        for order, option in enumerate(payload.options):
            current = existing.pop(option.code, None)
            if current is None:
                self._session.add(
                    QuestionOption(
                        question_id=row.id,
                        code=option.code,
                        text=option.text,
                        is_correct=option.is_correct,
                        sort_order=order,
                    )
                )
                report.options.created += 1
                continue

            changed = False
            for name, value in (
                ("text", option.text),
                ("is_correct", option.is_correct),
                ("sort_order", order),
            ):
                if getattr(current, name) != value:
                    setattr(current, name, value)
                    changed = True
            if changed:
                report.options.updated += 1

        for stale in existing.values():
            await self._session.delete(stale)
            report.options.deleted += 1
