"""Регистрация, вход и обновление токенов."""

from __future__ import annotations

import uuid
from dataclasses import dataclass

from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import AuthenticationError, ConflictError
from app.core.security import (
    TokenError,
    TokenType,
    create_token,
    decode_token,
    hash_password,
    needs_rehash,
    verify_password,
)
from app.db.models.user import User


@dataclass(frozen=True, slots=True)
class TokenPair:
    access_token: str
    refresh_token: str
    token_type: str = "bearer"


class AuthService:
    def __init__(self, session: AsyncSession) -> None:
        self._session = session

    async def register(self, email: str, password: str) -> User:
        user = User(
            id=uuid.uuid4(),
            email=email.strip().lower(),
            password_hash=hash_password(password),
            specializations=[],
        )
        self._session.add(user)
        try:
            await self._session.flush()
        except IntegrityError as exc:
            await self._session.rollback()
            raise ConflictError("пользователь с такой почтой уже зарегистрирован") from exc
        return user

    async def authenticate(self, email: str, password: str) -> User:
        user = await self._session.scalar(select(User).where(User.email == email.strip().lower()))

        # Проверяем пароль даже для несуществующей почты: иначе по времени ответа
        # можно перебирать существующих пользователей.
        password_hash = user.password_hash if user else _DUMMY_HASH
        matched = verify_password(password, password_hash)

        if user is None or not matched:
            raise AuthenticationError("неверная почта или пароль")
        if not user.is_active:
            raise AuthenticationError("учётная запись отключена")

        if needs_rehash(user.password_hash):
            user.password_hash = hash_password(password)

        return user

    async def refresh(self, refresh_token: str) -> TokenPair:
        try:
            payload = decode_token(refresh_token, TokenType.REFRESH)
        except TokenError as exc:
            raise AuthenticationError(str(exc)) from exc

        user = await self._session.get(User, payload.subject)
        if user is None or not user.is_active:
            raise AuthenticationError("пользователь недоступен")

        return issue_tokens(user.id)


def issue_tokens(user_id: uuid.UUID) -> TokenPair:
    return TokenPair(
        access_token=create_token(user_id, TokenType.ACCESS),
        refresh_token=create_token(user_id, TokenType.REFRESH),
    )


# Хеш заведомо неиспользуемого пароля: нужен только чтобы уравнять время ответа.
_DUMMY_HASH = hash_password("dummy-password-for-constant-time-check")
