"""Пароли и JWT. Ни одного обращения к БД: только криптография и токены."""

from __future__ import annotations

import uuid
from dataclasses import dataclass
from datetime import UTC, datetime, timedelta
from enum import StrEnum
from typing import Any, Final

import jwt
from argon2 import PasswordHasher
from argon2.exceptions import InvalidHashError, VerifyMismatchError

from app.core.config import get_settings

_hasher = PasswordHasher()

ALGORITHM: Final = "HS256"


class TokenType(StrEnum):
    ACCESS = "access"
    REFRESH = "refresh"


class TokenError(Exception):
    """Токен просрочен, повреждён или не того типа."""


@dataclass(frozen=True, slots=True)
class TokenPayload:
    subject: uuid.UUID
    token_type: TokenType
    jti: uuid.UUID
    expires_at: datetime


def hash_password(password: str) -> str:
    return _hasher.hash(password)


def verify_password(password: str, password_hash: str) -> bool:
    try:
        return _hasher.verify(password_hash, password)
    except (VerifyMismatchError, InvalidHashError):
        return False


def needs_rehash(password_hash: str) -> bool:
    """Параметры argon2 со временем ужесточаются — хеш стоит пересчитать при входе."""
    try:
        return _hasher.check_needs_rehash(password_hash)
    except InvalidHashError:
        return True


def create_token(subject: uuid.UUID, token_type: TokenType) -> str:
    settings = get_settings()
    lifetime = (
        timedelta(minutes=settings.access_token_ttl_minutes)
        if token_type is TokenType.ACCESS
        else timedelta(days=settings.refresh_token_ttl_days)
    )
    issued_at = datetime.now(UTC)
    payload: dict[str, Any] = {
        "sub": str(subject),
        "type": token_type.value,
        "jti": str(uuid.uuid4()),
        "iat": issued_at,
        "exp": issued_at + lifetime,
    }
    return jwt.encode(payload, settings.secret_key.get_secret_value(), algorithm=ALGORITHM)


def decode_token(token: str, expected_type: TokenType) -> TokenPayload:
    settings = get_settings()
    try:
        # Алгоритм задаётся здесь, а не берётся из заголовка токена: иначе
        # клиент сможет подсунуть alg=none.
        raw = jwt.decode(
            token,
            settings.secret_key.get_secret_value(),
            algorithms=[ALGORITHM],
            options={"require": ["exp", "sub", "type", "jti"]},
        )
    except jwt.ExpiredSignatureError as exc:
        raise TokenError("срок действия токена истёк") from exc
    except jwt.InvalidTokenError as exc:
        raise TokenError("токен недействителен") from exc

    if raw["type"] != expected_type.value:
        raise TokenError(f"ожидался токен типа {expected_type.value}, получен {raw['type']}")

    try:
        subject = uuid.UUID(raw["sub"])
        jti = uuid.UUID(raw["jti"])
    except (ValueError, TypeError) as exc:
        raise TokenError("токен повреждён") from exc

    return TokenPayload(
        subject=subject,
        token_type=expected_type,
        jti=jti,
        expires_at=datetime.fromtimestamp(raw["exp"], tz=UTC),
    )
