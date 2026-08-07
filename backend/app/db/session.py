"""Асинхронный движок и фабрика сессий SQLAlchemy."""

from __future__ import annotations

from collections.abc import AsyncIterator
from functools import lru_cache

from sqlalchemy.ext.asyncio import (
    AsyncEngine,
    AsyncSession,
    async_sessionmaker,
    create_async_engine,
)

from app.core.config import get_settings


@lru_cache(maxsize=1)
def get_engine() -> AsyncEngine:
    """Движок создаётся лениво: импорт модуля не должен трогать сеть."""
    settings = get_settings()
    return create_async_engine(
        str(settings.database_url),
        echo=settings.debug,
        pool_pre_ping=True,
        pool_size=settings.db_pool_size,
        max_overflow=settings.db_max_overflow,
    )


@lru_cache(maxsize=1)
def get_session_factory() -> async_sessionmaker[AsyncSession]:
    return async_sessionmaker(get_engine(), expire_on_commit=False, autoflush=False)


async def get_session() -> AsyncIterator[AsyncSession]:
    """FastAPI-зависимость: сессия на запрос."""
    async with get_session_factory()() as session:
        yield session


async def dispose_engine() -> None:
    """Закрыть пул соединений при остановке приложения."""
    if get_engine.cache_info().currsize:
        await get_engine().dispose()
