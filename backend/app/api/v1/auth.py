"""Регистрация, вход и обновление токенов."""

from __future__ import annotations

from dataclasses import asdict

from fastapi import APIRouter, status

from app.core.deps import SessionDep
from app.schemas.auth import LoginRequest, RefreshRequest, RegisterRequest, TokenResponse
from app.services.auth import AuthService, issue_tokens

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/register", response_model=TokenResponse, status_code=status.HTTP_201_CREATED)
async def register(payload: RegisterRequest, session: SessionDep) -> TokenResponse:
    user = await AuthService(session).register(payload.email, payload.password)
    await session.commit()
    return TokenResponse(**asdict(issue_tokens(user.id)))


@router.post("/login", response_model=TokenResponse)
async def login(payload: LoginRequest, session: SessionDep) -> TokenResponse:
    user = await AuthService(session).authenticate(payload.email, payload.password)
    await session.commit()
    return TokenResponse(**asdict(issue_tokens(user.id)))


@router.post("/refresh", response_model=TokenResponse)
async def refresh(payload: RefreshRequest, session: SessionDep) -> TokenResponse:
    tokens = await AuthService(session).refresh(payload.refresh_token)
    return TokenResponse(**asdict(tokens))
