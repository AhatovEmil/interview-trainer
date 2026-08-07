"""Точка входа FastAPI-приложения."""

from __future__ import annotations

import logging
from collections.abc import AsyncIterator
from contextlib import asynccontextmanager

from fastapi import FastAPI

from app import __version__
from app.api.errors import register_error_handlers
from app.api.health import router as health_router
from app.api.v1.router import api_router
from app.core.config import Settings, get_settings
from app.db.redis import close_redis
from app.db.session import dispose_engine

logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncIterator[None]:
    settings: Settings = get_settings()
    logger.info("starting %s (env=%s)", settings.app_name, settings.environment)
    yield
    await dispose_engine()
    await close_redis()
    logger.info("stopped %s", settings.app_name)


def create_app() -> FastAPI:
    settings = get_settings()
    logging.basicConfig(level=settings.log_level.upper())

    app = FastAPI(
        title="Interview Trainer API",
        version=__version__,
        docs_url="/docs" if not settings.is_production else None,
        redoc_url=None,
        openapi_url="/openapi.json" if not settings.is_production else None,
        lifespan=lifespan,
    )
    register_error_handlers(app)
    app.include_router(health_router)
    app.include_router(api_router, prefix=settings.api_v1_prefix)
    return app


app = create_app()
