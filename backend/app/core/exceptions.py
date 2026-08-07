"""Доменные исключения.

Сервисный слой не знает про HTTP: он поднимает эти ошибки, а обработчик в main.py
переводит их в коды ответа.
"""

from __future__ import annotations


class DomainError(Exception):
    """Базовая ошибка предметной области."""

    def __init__(self, message: str) -> None:
        super().__init__(message)
        self.message = message


class NotFoundError(DomainError):
    """Объект не найден."""


class ConflictError(DomainError):
    """Нарушено уникальное ограничение или состояние не позволяет операцию."""


class InvalidInputError(DomainError):
    """Входные данные не проходят доменную проверку."""


class AuthenticationError(DomainError):
    """Неверные учётные данные или недействительный токен."""


class PremiumRequiredError(DomainError):
    """Фича доступна только на платном тарифе."""
