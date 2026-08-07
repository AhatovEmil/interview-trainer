"""Health-эндпоинты. Живут вне /api/v1: их дёргают Docker и балансировщик."""

from __future__ import annotations

from typing import Annotated

from fastapi import APIRouter, Depends, Response, status

from app import __version__
from app.core.config import Settings, get_settings
from app.schemas.health import ComponentHealth, HealthResponse, ReadinessResponse
from app.services.health import HealthService, get_health_service

router = APIRouter(tags=["health"])


@router.get("/health", response_model=HealthResponse, summary="Liveness")
async def health(settings: Annotated[Settings, Depends(get_settings)]) -> HealthResponse:
    """Процесс жив. Внешние зависимости не проверяются."""
    return HealthResponse(
        status="ok",
        app=settings.app_name,
        version=__version__,
        environment=settings.environment,
    )


@router.get("/health/ready", response_model=ReadinessResponse, summary="Readiness")
async def readiness(
    response: Response,
    service: Annotated[HealthService, Depends(get_health_service)],
) -> ReadinessResponse:
    """Готовность принимать трафик: доступны ли Postgres и Redis."""
    components = await service.check_all()
    ready = all(component.ok for component in components)
    if not ready:
        response.status_code = status.HTTP_503_SERVICE_UNAVAILABLE
    return ReadinessResponse(
        status="ready" if ready else "degraded",
        components=[
            ComponentHealth(name=item.name, ok=item.ok, detail=item.detail) for item in components
        ],
    )
