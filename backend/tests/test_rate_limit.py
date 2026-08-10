"""Ограничение частоты на входе и регистрации.

Это единственные ручки, доступные без токена. Открытый в интернет сервис без
ограничения за ночь получает и подбор паролей, и тысячи мусорных аккаунтов.
"""

import os
import uuid

import pytest
from fastapi import Request
from httpx import AsyncClient

from app.core.rate_limit import LOGIN, REGISTER, Limit, RateLimitedError, check, client_key
from app.db.redis import get_redis

pytestmark = [
    pytest.mark.integration,
    pytest.mark.skipif(
        os.getenv("RUN_INTEGRATION_TESTS") != "1",
        reason="нужны поднятые Postgres и Redis",
    ),
]

PASSWORD = "very-secret-1"


def _request(headers: list[tuple[bytes, bytes]], host: str = "10.0.0.1") -> Request:
    return Request(
        {
            "type": "http",
            "headers": headers,
            "client": (host, 12345),
        }
    )


def test_client_key_prefers_forwarded_address() -> None:
    """За прокси адрес клиента приходит заголовком.

    Без этого ограничение считало бы всех пользователей за одного и
    блокировало бы всех разом при первом же переборе.
    """
    request = _request([(b"x-forwarded-for", b"203.0.113.7, 10.0.0.5")])

    assert client_key(request) == "203.0.113.7"


def test_client_key_falls_back_to_peer_address() -> None:
    assert client_key(_request([])) == "10.0.0.1"


async def test_counter_blocks_after_limit() -> None:
    limit = Limit(attempts=3, window_seconds=60)
    identity = f"test-{uuid.uuid4().hex[:8]}"
    redis = get_redis()

    for _ in range(limit.attempts):
        await check(redis, "unit", identity, limit)

    with pytest.raises(RateLimitedError) as excinfo:
        await check(redis, "unit", identity, limit)

    assert excinfo.value.retry_after > 0


async def test_counters_are_independent_per_identity() -> None:
    limit = Limit(attempts=1, window_seconds=60)
    redis = get_redis()
    first = f"test-{uuid.uuid4().hex[:8]}"
    second = f"test-{uuid.uuid4().hex[:8]}"

    await check(redis, "unit", first, limit)
    with pytest.raises(RateLimitedError):
        await check(redis, "unit", first, limit)

    # Блокировка одного не должна задевать другого.
    await check(redis, "unit", second, limit)


async def test_login_blocks_password_guessing(client: AsyncClient, clean_db: None) -> None:
    email = f"brute-{uuid.uuid4().hex[:8]}@example.com"
    registered = await client.post(
        "/api/v1/auth/register", json={"email": email, "password": PASSWORD}
    )
    assert registered.status_code == 201, registered.text

    statuses: list[int] = []
    for _ in range(LOGIN.attempts + 2):
        response = await client.post(
            "/api/v1/auth/login", json={"email": email, "password": "wrong-password"}
        )
        statuses.append(response.status_code)

    assert 429 in statuses, "перебор пароля не был остановлен"
    blocked = next(code for code in statuses if code == 429)
    assert blocked == 429

    last = await client.post(
        "/api/v1/auth/login", json={"email": email, "password": "wrong-password"}
    )
    assert last.status_code == 429
    assert int(last.headers["retry-after"]) > 0


async def test_registration_flood_is_stopped(client: AsyncClient, clean_db: None) -> None:
    statuses: list[int] = []
    for _ in range(REGISTER.attempts + 2):
        response = await client.post(
            "/api/v1/auth/register",
            json={"email": f"flood-{uuid.uuid4().hex[:8]}@example.com", "password": PASSWORD},
        )
        statuses.append(response.status_code)

    assert statuses.count(201) <= REGISTER.attempts
    assert statuses[-1] == 429
