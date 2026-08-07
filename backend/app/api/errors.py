"""Перевод доменных ошибок в HTTP. Сервисный слой про коды ответа не знает."""

from __future__ import annotations

from fastapi import FastAPI, Request, status
from fastapi.responses import JSONResponse

from app.core.exceptions import (
    AuthenticationError,
    ConflictError,
    DomainError,
    InvalidInputError,
    NotFoundError,
    PremiumRequiredError,
)

_STATUS_BY_ERROR: dict[type[DomainError], int] = {
    NotFoundError: status.HTTP_404_NOT_FOUND,
    ConflictError: status.HTTP_409_CONFLICT,
    InvalidInputError: status.HTTP_422_UNPROCESSABLE_CONTENT,
    AuthenticationError: status.HTTP_401_UNAUTHORIZED,
    PremiumRequiredError: status.HTTP_402_PAYMENT_REQUIRED,
}


def register_error_handlers(app: FastAPI) -> None:
    @app.exception_handler(DomainError)
    async def handle_domain_error(_: Request, exc: DomainError) -> JSONResponse:
        status_code = _STATUS_BY_ERROR.get(type(exc), status.HTTP_400_BAD_REQUEST)
        headers = {"WWW-Authenticate": "Bearer"} if isinstance(exc, AuthenticationError) else None
        return JSONResponse(
            status_code=status_code,
            content={"detail": exc.message},
            headers=headers,
        )
