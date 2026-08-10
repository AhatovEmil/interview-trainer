"""Ограничение частоты запросов к аутентификации.

Вход и регистрация — единственные ручки, доступные без токена, и потому
единственные, куда можно долбиться перебором. Без ограничения открытый в
интернет сервис за ночь получает и подбор паролей, и тысячи мусорных
аккаунтов.

Счётчики живут в Redis, а не в памяти процесса: при нескольких экземплярах
приложения счётчик в памяти означает лимит, умноженный на их число.
"""

from __future__ import annotations

from dataclasses import dataclass

from fastapi import Request
from redis.asyncio import Redis

from app.core.exceptions import DomainError


class RateLimitedError(DomainError):
    """Слишком часто. Обработчик переводит это в 429."""

    def __init__(self, message: str, retry_after: int) -> None:
        super().__init__(message)
        self.retry_after = retry_after


@dataclass(frozen=True, slots=True)
class Limit:
    """Сколько попыток за какое окно."""

    attempts: int
    window_seconds: int


# Вход: человек ошибается в пароле два-три раза, не двадцать. Регистрация реже:
# больше пяти аккаунтов с одного адреса за час — это не человек.
LOGIN = Limit(attempts=10, window_seconds=300)
REGISTER = Limit(attempts=5, window_seconds=3600)


def client_key(request: Request) -> str:
    """Адрес клиента с поправкой на обратный прокси.

    За nginx каждый запрос приходит с адреса прокси, и без учёта заголовка
    ограничение считало бы всех пользователей за одного — то есть блокировало
    бы всех разом. Берём первый адрес цепочки: его подставляет наш прокси.
    """
    forwarded = request.headers.get("x-forwarded-for")
    if forwarded:
        return forwarded.split(",")[0].strip()
    return request.client.host if request.client else "unknown"


async def check(redis: Redis, scope: str, identity: str, limit: Limit) -> None:
    """Увеличивает счётчик и бросает исключение, если попыток слишком много."""
    key = f"ratelimit:{scope}:{identity}"
    used = int(await redis.incr(key))
    if used == 1:
        # Срок жизни ставим только при создании: иначе непрерывный поток
        # запросов продлевал бы окно бесконечно, и лимит не сбрасывался бы.
        await redis.expire(key, limit.window_seconds)

    if used > limit.attempts:
        ttl = int(await redis.ttl(key))
        retry_after = ttl if ttl > 0 else limit.window_seconds
        raise RateLimitedError(
            f"слишком много попыток, повторите через {retry_after} с",
            retry_after=retry_after,
        )
