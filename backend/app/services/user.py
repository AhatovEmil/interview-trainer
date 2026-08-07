"""Профиль пользователя: выбор специализации и самооценка грейда."""

from __future__ import annotations

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import InvalidInputError, NotFoundError
from app.db.models.taxonomy import Specialization
from app.db.models.user import User, UserSpecialization


class UserService:
    def __init__(self, session: AsyncSession) -> None:
        self._session = session

    async def set_specialization(
        self,
        user: User,
        specialization_id: str,
        self_assessed_grade: int,
        is_primary: bool,
    ) -> UserSpecialization:
        specialization = await self._session.get(Specialization, specialization_id)
        if specialization is None:
            raise NotFoundError(f"специализация {specialization_id!r} не найдена")
        if not specialization.is_active:
            raise InvalidInputError(
                f"специализация {specialization_id!r} пока недоступна — «скоро»"
            )

        profile = await self._session.get(UserSpecialization, (user.id, specialization_id))
        if profile is None:
            profile = UserSpecialization(
                user_id=user.id,
                specialization_id=specialization_id,
                self_assessed_grade=self_assessed_grade,
                is_primary=is_primary,
            )
            self._session.add(profile)
        else:
            profile.self_assessed_grade = self_assessed_grade
            profile.is_primary = is_primary

        if is_primary:
            await self._reset_other_primaries(user, specialization_id)

        await self._session.flush()
        return profile

    async def list_specializations(self, user: User) -> list[UserSpecialization]:
        rows = await self._session.scalars(
            select(UserSpecialization)
            .where(UserSpecialization.user_id == user.id)
            .order_by(UserSpecialization.specialization_id)
        )
        return list(rows)

    async def _reset_other_primaries(self, user: User, keep: str) -> None:
        """Основная специализация ровно одна, прогресс по остальным сохраняется."""
        others = await self._session.scalars(
            select(UserSpecialization).where(
                UserSpecialization.user_id == user.id,
                UserSpecialization.specialization_id != keep,
                UserSpecialization.is_primary.is_(True),
            )
        )
        for row in others:
            row.is_primary = False
