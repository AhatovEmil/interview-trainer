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
from app.core.rate_limit import RateLimitedError

_STATUS_BY_ERROR: dict[type[DomainError], int] = {
    NotFoundError: status.HTTP_404_NOT_FOUND,
    ConflictError: status.HTTP_409_CONFLICT,
    InvalidInputError: status.HTTP_422_UNPROCESSABLE_CONTENT,
    AuthenticationError: status.HTTP_401_UNAUTHORIZED,
    PremiumRequiredError: status.HTTP_402_PAYMENT_REQUIRED,
    RateLimitedError: status.HTTP_429_TOO_MANY_REQUESTS,
}


def register_error_handlers(app: FastAPI) -> None:
    @app.exception_handler(DomainError)
    async def handle_domain_error(_: Request, exc: DomainError) -> JSONResponse:
        status_code = _STATUS_BY_ERROR.get(type(exc), status.HTTP_400_BAD_REQUEST)
        headers: dict[str, str] = {}
        if isinstance(exc, AuthenticationError):
            headers["WWW-Authenticate"] = "Bearer"
        if isinstance(exc, RateLimitedError):
            # Клиенту нужно знать, когда повторять: без этого он либо ждёт
            # наугад, либо продолжает долбиться и остаётся заблокированным.
            headers["Retry-After"] = str(exc.retry_after)
        return JSONResponse(
            status_code=status_code,
            content={"detail": exc.message},
            headers=headers or None,
        )
