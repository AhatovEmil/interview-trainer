"""Корневой роутер /api/v1."""

from __future__ import annotations

from fastapi import APIRouter

from app.api.v1 import taxonomy

api_router = APIRouter()
api_router.include_router(taxonomy.router)
