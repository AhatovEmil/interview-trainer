from collections.abc import AsyncIterator

import pytest
from fastapi import FastAPI
from httpx import ASGITransport, AsyncClient

from app.db.redis import close_redis, get_redis
from app.db.session import dispose_engine, get_engine, get_session_factory
from app.main import create_app


@pytest.fixture(autouse=True)
async def reset_connection_pools() -> AsyncIterator[None]:
    """Движок и Redis-клиент кешируются на процесс, а у каждого теста свой event loop.

    Без сброса соединения из предыдущего теста остаются в уже закрытом лупе.
    """
    yield
    await dispose_engine()
    await close_redis()
    get_engine.cache_clear()
    get_session_factory.cache_clear()
    get_redis.cache_clear()


@pytest.fixture
def app() -> FastAPI:
    return create_app()


@pytest.fixture
async def client(app: FastAPI) -> AsyncIterator[AsyncClient]:
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        yield ac
