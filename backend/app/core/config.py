"""Конфигурация приложения. Значения приходят только из переменных окружения."""

from __future__ import annotations

from functools import lru_cache
from typing import Literal

from pydantic import Field, PostgresDsn, RedisDsn
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
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

    @property
    def is_production(self) -> bool:
        return self.environment == "production"


@lru_cache(maxsize=1)
def get_settings() -> Settings:
    """Настройки читаются один раз за процесс."""
    return Settings()
