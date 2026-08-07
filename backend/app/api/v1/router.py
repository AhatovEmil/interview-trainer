"""Корневой роутер /api/v1."""

from __future__ import annotations

from fastapi import APIRouter

from app.api.v1 import auth, me, plan, practice, taxonomy

api_router = APIRouter()
api_router.include_router(auth.router)
api_router.include_router(taxonomy.router)
api_router.include_router(me.router)
api_router.include_router(practice.router)
api_router.include_router(plan.router)
