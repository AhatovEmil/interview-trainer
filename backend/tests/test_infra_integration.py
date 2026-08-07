"""Проверки живых Postgres и Redis.

Запускаются только при RUN_INTEGRATION_TESTS=1 (внутри docker compose или локально
с поднятыми сервисами), чтобы `pytest` на чистой машине оставался зелёным.
"""

import os

import pytest
from httpx import AsyncClient

from app.services.health import HealthService

pytestmark = [
    pytest.mark.integration,
    pytest.mark.skipif(
        os.getenv("RUN_INTEGRATION_TESTS") != "1",
        reason="нужны поднятые Postgres и Redis",
    ),
]


async def test_database_is_reachable() -> None:
    status = await HealthService().check_database()

    assert status.ok, status.detail


async def test_redis_is_reachable() -> None:
    status = await HealthService().check_redis()

    assert status.ok, status.detail


async def test_readiness_endpoint_is_ready(client: AsyncClient) -> None:
    response = await client.get("/health/ready")

    assert response.status_code == 200
    assert response.json()["status"] == "ready"
