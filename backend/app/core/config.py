"""Конфигурация приложения. Значения приходят только из переменных окружения."""

from __future__ import annotations

from functools import lru_cache
from pathlib import Path
from typing import Literal

from pydantic import Field, PostgresDsn, RedisDsn
from pydantic_settings import BaseSettings, SettingsConfigDict

# backend/app/core/config.py → корень репозитория
_REPO_ROOT = Path(__file__).resolve().parents[3]
_DEFAULT_CONTENT_DIR = _REPO_ROOT / "content"


class Settings(BaseSettings):
    # .env лежит в корне репозитория и нужен только для запусков вне Docker:
    # в контейнере его нет, все значения приходят переменными окружения.
    model_config = SettingsConfigDict(
        env_file=(_REPO_ROOT / ".env", ".env"),
        env_file_encoding="utf-8",
        extra="ignore",
        case_sensitive=False,
    )

    app_name: str = "interview-trainer-api"
    environment: Literal["local", "test", "staging", "production"] = "local"
    debug: bool = False
    log_level: str = "INFO"

    api_v1_prefix: str = "/api/v1"

    database_url: PostgresDsn = Field(
        default=PostgresDsn("postgresql+asyncpg://trainer:trainer@localhost:5432/trainer"),
    )
    db_pool_size: int = 5
    db_max_overflow: int = 10

    redis_url: RedisDsn = Field(default=RedisDsn("redis://localhost:6379/0"))

    # Контент (таксономия, банк вопросов) лежит вне кода и грузится YAML-сидом.
    content_dir: Path = Field(default=_DEFAULT_CONTENT_DIR)

    @property
    def is_production(self) -> bool:
        return self.environment == "production"

    @property
    def taxonomy_file(self) -> Path:
        return self.content_dir / "taxonomy.yaml"


@lru_cache(maxsize=1)
def get_settings() -> Settings:
    """Настройки читаются один раз за процесс."""
    return Settings()
