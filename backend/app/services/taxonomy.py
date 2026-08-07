"""Синхронизация таксономии из YAML и чтение дерева.

YAML — источник истины: то, чего в нём нет, из БД удаляется. Пока таксономия ни с чем
не связана, это безопасно; когда появятся вопросы и прогресс пользователей, удаление
разделов нужно будет заменить на пометку `is_archived`.
"""

from __future__ import annotations

from dataclasses import dataclass, field

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models.taxonomy import Profession, Specialization, Subtopic, Topic, TopicWeight
from app.seed.schema import TaxonomyFile, TopicIn


@dataclass(slots=True)
class EntityStats:
    created: int = 0
    updated: int = 0
    deleted: int = 0

    def __str__(self) -> str:
        return f"+{self.created} ~{self.updated} -{self.deleted}"


@dataclass(slots=True)
class SyncReport:
    professions: EntityStats = field(default_factory=EntityStats)
    specializations: EntityStats = field(default_factory=EntityStats)
    topics: EntityStats = field(default_factory=EntityStats)
    subtopics: EntityStats = field(default_factory=EntityStats)
    weights: EntityStats = field(default_factory=EntityStats)

    @property
    def has_changes(self) -> bool:
        return any(
            stats.created or stats.updated or stats.deleted
            for stats in (
                self.professions,
                self.specializations,
                self.topics,
                self.subtopics,
                self.weights,
            )
        )

    def as_lines(self) -> list[str]:
        return [
            f"профессии:      {self.professions}",
            f"специализации:  {self.specializations}",
            f"разделы:        {self.topics}",
            f"темы:           {self.subtopics}",
            f"веса:           {self.weights}",
        ]


class TaxonomyService:
    def __init__(self, session: AsyncSession) -> None:
        self._session = session

    async def sync(self, payload: TaxonomyFile) -> SyncReport:
        """Привести БД в соответствие с YAML. Повторный запуск ничего не меняет."""
        report = SyncReport()
        await self._sync_professions(payload, report)
        await self._session.flush()
        await self._sync_specializations(payload, report)
        await self._session.flush()
        await self._sync_topics(payload, report)
        await self._session.flush()
        return report

    async def get_tree(self) -> list[Profession]:
        """Полное дерево профессий со специализациями и темами."""
        result = await self._session.execute(select(Profession).order_by(Profession.sort_order))
        return list(result.scalars().all())

    async def _sync_professions(self, payload: TaxonomyFile, report: SyncReport) -> None:
        existing = {row.id: row for row in (await self._session.scalars(select(Profession)))}

        for order, incoming in enumerate(payload.professions):
            current = existing.pop(incoming.id, None)
            if current is None:
                self._session.add(
                    Profession(id=incoming.id, title=incoming.title, sort_order=order)
                )
                report.professions.created += 1
            elif _apply(current, title=incoming.title, sort_order=order):
                report.professions.updated += 1

        for stale in existing.values():
            await self._session.delete(stale)
            report.professions.deleted += 1

    async def _sync_specializations(self, payload: TaxonomyFile, report: SyncReport) -> None:
        existing = {row.id: row for row in (await self._session.scalars(select(Specialization)))}

        for profession in payload.professions:
            for order, incoming in enumerate(profession.specializations):
                current = existing.pop(incoming.id, None)
                if current is None:
                    self._session.add(
                        Specialization(
                            id=incoming.id,
                            profession_id=profession.id,
                            title=incoming.title,
                            is_active=incoming.is_active,
                            sort_order=order,
                        )
                    )
                    report.specializations.created += 1
                elif _apply(
                    current,
                    profession_id=profession.id,
                    title=incoming.title,
                    is_active=incoming.is_active,
                    sort_order=order,
                ):
                    report.specializations.updated += 1

        for stale in existing.values():
            await self._session.delete(stale)
            report.specializations.deleted += 1

    async def _sync_topics(self, payload: TaxonomyFile, report: SyncReport) -> None:
        existing = {
            (row.specialization_id, row.code): row
            for row in (await self._session.scalars(select(Topic)))
        }

        for specialization_id, topics in payload.topics.items():
            for order, incoming in enumerate(topics):
                current = existing.pop((specialization_id, incoming.code), None)
                if current is None:
                    current = Topic(
                        specialization_id=specialization_id,
                        code=incoming.code,
                        title=incoming.title,
                        sort_order=order,
                    )
                    self._session.add(current)
                    await self._session.flush()
                    report.topics.created += 1
                elif _apply(current, title=incoming.title, sort_order=order):
                    report.topics.updated += 1

                await self._sync_subtopics(current, incoming, report)
                await self._sync_weights(current, incoming, report)

        for stale in existing.values():
            await self._session.delete(stale)
            report.topics.deleted += 1

    async def _sync_subtopics(self, topic: Topic, incoming: TopicIn, report: SyncReport) -> None:
        existing = {
            row.code: row
            for row in (
                await self._session.scalars(select(Subtopic).where(Subtopic.topic_id == topic.id))
            )
        }

        for order, subtopic in enumerate(incoming.subtopics):
            current = existing.pop(subtopic.code, None)
            if current is None:
                self._session.add(
                    Subtopic(
                        topic_id=topic.id,
                        code=subtopic.code,
                        title=subtopic.title,
                        sort_order=order,
                    )
                )
                report.subtopics.created += 1
            elif _apply(current, title=subtopic.title, sort_order=order):
                report.subtopics.updated += 1

        for stale in existing.values():
            await self._session.delete(stale)
            report.subtopics.deleted += 1

    async def _sync_weights(self, topic: Topic, incoming: TopicIn, report: SyncReport) -> None:
        existing = {
            row.grade: row
            for row in (
                await self._session.scalars(
                    select(TopicWeight).where(TopicWeight.topic_id == topic.id)
                )
            )
        }

        for grade, weight in incoming.weights_by_grade().items():
            current = existing.pop(grade, None)
            if current is None:
                self._session.add(TopicWeight(topic_id=topic.id, grade=grade, weight=weight))
                report.weights.created += 1
            elif _apply(current, weight=weight):
                report.weights.updated += 1

        for stale in existing.values():
            await self._session.delete(stale)
            report.weights.deleted += 1


def _apply(row: object, **values: object) -> bool:
    """Записать поля, вернуть True если что-то реально изменилось."""
    changed = False
    for name, value in values.items():
        if getattr(row, name) != value:
            setattr(row, name, value)
            changed = True
    return changed
