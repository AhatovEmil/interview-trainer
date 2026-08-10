"""Регистрация, вход и обновление токенов."""

from __future__ import annotations

from dataclasses import asdict

from fastapi import APIRouter, Request, status

from app.core import rate_limit
from app.core.deps import SessionDep
from app.db.redis import get_redis
from app.schemas.auth import LoginRequest, RefreshRequest, RegisterRequest, TokenResponse
from app.services.auth import AuthService, issue_tokens

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/register", response_model=TokenResponse, status_code=status.HTTP_201_CREATED)
async def register(
    payload: RegisterRequest, session: SessionDep, request: Request
) -> TokenResponse:
    await rate_limit.check(
        get_redis(), "register", rate_limit.client_key(request), rate_limit.REGISTER
    )
    user = await AuthService(session).register(payload.email, payload.password)
    await session.commit()
    return TokenResponse(**asdict(issue_tokens(user.id)))


@router.post("/login", response_model=TokenResponse)
async def login(payload: LoginRequest, session: SessionDep, request: Request) -> TokenResponse:
    # Ограничиваем и по адресу, и по почте: первое ловит перебор паролей к
    # разным аккаунтам, второе — распределённый перебор к одному.
    await rate_limit.check(
        get_redis(), "login:ip", rate_limit.client_key(request), rate_limit.LOGIN
    )
    await rate_limit.check(get_redis(), "login:email", payload.email.lower(), rate_limit.LOGIN)
    user = await AuthService(session).authenticate(payload.email, payload.password)
    await session.commit()
    return TokenResponse(**asdict(issue_tokens(user.id)))


@router.post("/refresh", response_model=TokenResponse)
async def refresh(payload: RefreshRequest, session: SessionDep) -> TokenResponse:
    tokens = await AuthService(session).refresh(payload.refresh_token)
    return TokenResponse(**asdict(tokens))
