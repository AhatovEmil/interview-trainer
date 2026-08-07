"""Общие зависимости FastAPI."""

from __future__ import annotations

from typing import Annotated

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import TokenError, TokenType, decode_token
from app.db.models.user import User
from app.db.session import get_session

bearer_scheme = HTTPBearer(auto_error=False)

SessionDep = Annotated[AsyncSession, Depends(get_session)]


async def get_current_user(
    session: SessionDep,
    credentials: Annotated[HTTPAuthorizationCredentials | None, Depends(bearer_scheme)],
) -> User:
    if credentials is None:
        raise _unauthorized("нужен заголовок Authorization: Bearer <token>")

    try:
        payload = decode_token(credentials.credentials, TokenType.ACCESS)
    except TokenError as exc:
        raise _unauthorized(str(exc)) from exc

    user = await session.get(User, payload.subject)
    if user is None or not user.is_active:
        raise _unauthorized("пользователь недоступен")

    return user


CurrentUser = Annotated[User, Depends(get_current_user)]


def _unauthorized(detail: str) -> HTTPException:
    return HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail=detail,
        headers={"WWW-Authenticate": "Bearer"},
    )
