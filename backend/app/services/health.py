"""Сервис проверки готовности зависимостей. Роутер только отдаёт результат."""

from __future__ import annotations

from dataclasses import dataclass

from redis.asyncio import Redis
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker

from app.db.redis import get_redis
from app.db.session import get_session_factory


@dataclass(frozen=True, slots=True)
class ComponentStatus:
    name: str
    ok: bool
    detail: str | None = None


class HealthService:
    """Проверяет доступность Postgres и Redis."""

    def __init__(
        self,
        session_factory: async_sessionmaker[AsyncSession] | None = None,
        redis: Redis | None = None,
    ) -> None:
        self._session_factory = session_factory
        self._redis = redis

    async def check_database(self) -> ComponentStatus:
        factory = self._session_factory or get_session_factory()
        try:
            async with factory() as session:
                await session.execute(text("SELECT 1"))
        except Exception as exc:  # readiness не должен падать: отдаём текст ошибки
            return ComponentStatus(name="postgres", ok=False, detail=_short(exc))
        return ComponentStatus(name="postgres", ok=True)

    async def check_redis(self) -> ComponentStatus:
        client = self._redis or get_redis()
        try:
            await client.ping()
        except Exception as exc:
            return ComponentStatus(name="redis", ok=False, detail=_short(exc))
        return ComponentStatus(name="redis", ok=True)

    async def check_all(self) -> list[ComponentStatus]:
        return [await self.check_database(), await self.check_redis()]


def _short(exc: Exception) -> str:
    """Короткое описание ошибки: полный traceback наружу не отдаём."""
    message = str(exc).strip().splitlines()
    text_ = message[0] if message else exc.__class__.__name__
    return text_[:200]


def get_health_service() -> HealthService:
    """FastAPI-зависимость. В тестах подменяется через dependency_overrides."""
    return HealthService()
