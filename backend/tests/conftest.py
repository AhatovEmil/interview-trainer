import asyncio
import os
from collections.abc import AsyncIterator, Iterator
from pathlib import Path

import pytest
from alembic import command
from alembic.config import Config
from fastapi import FastAPI
from httpx import ASGITransport, AsyncClient
from sqlalchemy import text
from sqlalchemy.ext.asyncio import create_async_engine

from app.core.config import get_settings
from app.db.redis import close_redis, get_redis
from app.db.session import dispose_engine, get_engine, get_session_factory
from app.main import create_app

BACKEND_DIR = Path(__file__).resolve().parents[1]


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


# --- Интеграционные тесты: отдельная база, схема накатывается Alembic -------------


@pytest.fixture(scope="session")
def integration_db() -> Iterator[str]:
    """Создаёт базу <db>_test, накатывает миграции и переключает на неё настройки.

    Отдельная база, а не рабочая: тесты чистят таблицы, ронять сид никто не должен.
    """
    if os.getenv("RUN_INTEGRATION_TESTS") != "1":
        pytest.skip("нужны поднятые Postgres и Redis (RUN_INTEGRATION_TESTS=1)")

    source_url = str(get_settings().database_url)
    base, _, database = source_url.rpartition("/")
    test_database = f"{database}_test"
    test_url = f"{base}/{test_database}"

    asyncio.run(_recreate_database(f"{base}/postgres", test_database))

    previous = os.environ.get("DATABASE_URL")
    os.environ["DATABASE_URL"] = test_url
    _clear_caches()

    config = Config(str(BACKEND_DIR / "alembic.ini"))
    config.set_main_option("script_location", str(BACKEND_DIR / "migrations"))
    command.upgrade(config, "head")

    yield test_url

    if previous is None:
        os.environ.pop("DATABASE_URL", None)
    else:
        os.environ["DATABASE_URL"] = previous
    _clear_caches()


@pytest.fixture
async def clean_db(integration_db: str) -> AsyncIterator[None]:
    """Пустые таблицы таксономии перед каждым тестом."""
    await _truncate()
    yield


TRUNCATED_TABLES = (
    "professions",
    "specializations",
    "topics",
    "subtopics",
    "topic_weights",
    "questions",
    "question_options",
    "question_specializations",
)


async def _truncate() -> None:
    async with get_session_factory()() as session:
        await session.execute(text(f"TRUNCATE {', '.join(TRUNCATED_TABLES)} CASCADE"))
        await session.commit()


async def _recreate_database(admin_url: str, database: str) -> None:
    engine = create_async_engine(admin_url, isolation_level="AUTOCOMMIT")
    try:
        async with engine.connect() as connection:
            await connection.execute(text(f'DROP DATABASE IF EXISTS "{database}" WITH (FORCE)'))
            await connection.execute(text(f'CREATE DATABASE "{database}"'))
    finally:
        await engine.dispose()


def _clear_caches() -> None:
    get_settings.cache_clear()
    get_engine.cache_clear()
    get_session_factory.cache_clear()
