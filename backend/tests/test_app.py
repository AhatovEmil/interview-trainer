import pytest
from fastapi import FastAPI
from pydantic import ValidationError

from app.core.config import MIN_SECRET_BYTES, Settings, get_settings


def test_settings_read_from_environment(monkeypatch) -> None:
    monkeypatch.setenv("APP_NAME", "custom-name")
    monkeypatch.setenv("DATABASE_URL", "postgresql+asyncpg://u:p@db:5432/x")

    settings = Settings(_env_file=None)

    assert settings.app_name == "custom-name"
    # PostgresDsn — мультихостовый URL, хост достаём через hosts().
    assert settings.database_url.hosts()[0]["host"] == "db"
    assert settings.database_url.scheme == "postgresql+asyncpg"


def test_v1_prefix_is_mounted(app: FastAPI) -> None:
    prefix = get_settings().api_v1_prefix

    assert prefix == "/api/v1"
    assert app.openapi()["paths"].keys() >= {"/health", "/health/ready"}


def _production(monkeypatch, secret: str | None) -> Settings:
    monkeypatch.setenv("ENVIRONMENT", "production")
    if secret is not None:
        monkeypatch.setenv("SECRET_KEY", secret)
    return Settings(_env_file=None)


def test_production_rejects_default_secret(monkeypatch) -> None:
    with pytest.raises(ValidationError, match="SECRET_KEY обязана быть задана"):
        _production(monkeypatch, None)


def test_production_rejects_short_secret(monkeypatch) -> None:
    with pytest.raises(ValidationError, match="короче 32 байт"):
        _production(monkeypatch, "a" * (MIN_SECRET_BYTES - 1))


def test_production_accepts_long_secret(monkeypatch) -> None:
    settings = _production(monkeypatch, "b" * MIN_SECRET_BYTES)

    assert settings.is_production
    assert settings.secret_key.get_secret_value() == "b" * MIN_SECRET_BYTES


def test_short_secret_is_fine_outside_production(monkeypatch) -> None:
    """Локальной разработке длинный ключ ни к чему — проверка только для прода."""
    monkeypatch.setenv("ENVIRONMENT", "local")
    monkeypatch.setenv("SECRET_KEY", "short")

    assert Settings(_env_file=None).secret_key.get_secret_value() == "short"
