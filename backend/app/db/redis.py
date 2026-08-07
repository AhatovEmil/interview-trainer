"""Клиент Redis. На этапе 0 используется только для проверки готовности."""

from __future__ import annotations

from functools import lru_cache

from redis.asyncio import Redis

from app.core.config import get_settings


@lru_cache(maxsize=1)
def get_redis() -> Redis:
    """Клиент создаётся лениво, соединение — при первой команде."""
    return Redis.from_url(str(get_settings().redis_url), decode_responses=True)


async def close_redis() -> None:
    if get_redis.cache_info().currsize:
        await get_redis().aclose()
