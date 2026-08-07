# syntax=docker/dockerfile:1
FROM python:3.12-slim AS base

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

WORKDIR /code

# Слой зависимостей отдельно от кода: правки в app не переустанавливают пакеты.
COPY backend/pyproject.toml ./
COPY backend/app/__init__.py ./app/__init__.py
RUN pip install --no-cache-dir ".[dev]"

COPY backend/ ./

RUN useradd --create-home --uid 1000 appuser && chown -R appuser:appuser /code
USER appuser

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
