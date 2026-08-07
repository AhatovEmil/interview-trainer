"""Схемы ответов health-эндпоинтов. ORM-модели в ответах API не используются."""

from __future__ import annotations

from pydantic import BaseModel, Field


class HealthResponse(BaseModel):
    status: str = Field(examples=["ok"])
    app: str
    version: str
    environment: str


class ComponentHealth(BaseModel):
    name: str = Field(examples=["postgres"])
    ok: bool
    detail: str | None = None


class ReadinessResponse(BaseModel):
    status: str = Field(examples=["ready", "degraded"])
    components: list[ComponentHealth]
