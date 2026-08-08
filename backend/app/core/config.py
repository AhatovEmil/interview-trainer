"""Конфигурация приложения. Значения приходят только из переменных окружения."""

from __future__ import annotations

from functools import lru_cache
from pathlib import Path
from typing import Literal, Self

from pydantic import Field, PostgresDsn, RedisDsn, SecretStr, model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict

# backend/app/core/config.py → корень репозитория
_REPO_ROOT = Path(__file__).resolve().parents[3]
_DEFAULT_CONTENT_DIR = _REPO_ROOT / "content"
# Длина блока SHA-256: ключ короче не добавляет стойкости HMAC.
MIN_SECRET_BYTES = 32
# Дотягивает до MIN_SECRET_BYTES, иначе PyJWT сыплет предупреждениями в каждом тесте.
_DEV_SECRET = "dev-secret-change-me-before-deploy"


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

    # Значение по умолчанию годится только для локальной разработки:
    # в проде SECRET_KEY обязателен и проверяется на старте.
    secret_key: SecretStr = Field(default=SecretStr(_DEV_SECRET))
    access_token_ttl_minutes: int = Field(default=30, ge=1)
    refresh_token_ttl_days: int = Field(default=30, ge=1)

    @model_validator(mode="after")
    def check_production_secrets(self) -> Self:
        if not self.is_production:
            return self

        secret = self.secret_key.get_secret_value()
        if secret == _DEV_SECRET:
            raise ValueError("в production переменная SECRET_KEY обязана быть задана")
        # HMAC-SHA256 берёт ключ короче длины хеша как есть: 8 символов остаются
        # восемью символами энтропии, сколько бы раундов ни было сверху.
        if len(secret.encode()) < MIN_SECRET_BYTES:
            raise ValueError(
                f"SECRET_KEY короче {MIN_SECRET_BYTES} байт — этого мало для HMAC-SHA256; "
                'сгенерируйте: python -c "import secrets; print(secrets.token_urlsafe(48))"'
            )
        return self

    @property
    def is_production(self) -> bool:
        return self.environment == "production"

    @property
    def taxonomy_file(self) -> Path:
        return self.content_dir / "taxonomy.yaml"

    @property
    def questions_dir(self) -> Path:
        return self.content_dir / "questions"


@lru_cache(maxsize=1)
def get_settings() -> Settings:
    """Настройки читаются один раз за процесс."""
    return Settings()
