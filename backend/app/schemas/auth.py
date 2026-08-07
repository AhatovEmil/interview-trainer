"""Схемы регистрации и входа."""

from __future__ import annotations

from typing import Annotated

from pydantic import BaseModel, EmailStr, Field, StringConstraints

# Минимум 8 символов — компромисс между безопасностью и мобильным вводом.
Password = Annotated[str, StringConstraints(min_length=8, max_length=128)]


class RegisterRequest(BaseModel):
    email: EmailStr
    password: Password


class LoginRequest(BaseModel):
    email: EmailStr
    password: Password


class RefreshRequest(BaseModel):
    refresh_token: str = Field(min_length=1)


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
