from fastapi import FastAPI

from app.core.config import Settings, get_settings


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
