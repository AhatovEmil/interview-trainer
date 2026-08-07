# Interview Trainer

Тренажёр для подготовки к техническим собеседованиям в IT: банк вопросов, оценка уровня по темам
(Elo), интервальные повторения (SM-2) и персональный план перед собеседованием.

Спецификация продукта и доменная модель — в [CLAUDE.md](CLAUDE.md).

## Запуск в три команды

```bash
cp .env.example .env
```

```bash
docker compose up -d --build
```

```bash
curl http://localhost:8000/health
```

Поднимутся четыре сервиса: `api` (FastAPI, порт 8000), `postgres` (16), `redis` (7) и `nginx`
(порт 8080, проксирует на api). На старте `api` применяются миграции Alembic и загружается
таксономия из `content/taxonomy.yaml` — сид идемпотентен, повторный запуск ничего не портит.

> Если на машине уже занят порт 5432 (например, локально установленным Postgres), поменяй
> `POSTGRES_PORT` в `.env` — иначе подключение с хоста уедет в чужую базу.

| Адрес                              | Что это                                  |
| ---------------------------------- | ---------------------------------------- |
| http://localhost:8000/health         | liveness, всегда 200 если процесс жив    |
| http://localhost:8000/health/ready   | readiness, 200 / 503 по Postgres и Redis |
| http://localhost:8000/api/v1/taxonomy | дерево профессий, специализаций и тем   |
| http://localhost:8000/docs           | OpenAPI (выключен в production)          |
| http://localhost:8080/health         | то же самое через nginx                  |

Остановить: `docker compose down`, вместе с данными: `docker compose down -v`.

## Разработка без Docker

```bash
python -m venv backend/.venv
backend/.venv/Scripts/activate      # Linux/macOS: source backend/.venv/bin/activate
pip install -e "backend[dev]"
```

Запуск тестов, линтера и типов из каталога `backend`:

```bash
pytest
```

```bash
ruff check . && ruff format --check .
```

```bash
mypy app
```

Юнит-тесты не требуют БД. Интеграционные (`-m integration`) проверяют живые Postgres и Redis и
запускаются только с `RUN_INTEGRATION_TESTS=1`:

```bash
docker compose up -d postgres redis
```

```bash
RUN_INTEGRATION_TESTS=1 pytest -m integration
```

## Миграции

```bash
alembic revision --autogenerate -m "описание"
```

```bash
alembic upgrade head
```

`create_all` не используется — схема меняется только через Alembic.

## Контент

Таксономия и банк вопросов лежат в `/content` как YAML и грузятся в базу сидом:

```bash
python -m app.seed.taxonomy
```

YAML — источник истины: сид приводит базу в соответствие с файлом (добавляет, обновляет и
удаляет лишнее) и не создаёт дублей при повторном запуске. Битый файл роняет загрузку с
указанием строки и причины, до похода в базу.

## Структура

```
/backend
  /app
    /api        роутеры (health вне версии, остальное под /api/v1)
    /core       конфиг и общие зависимости
    /db         движок, сессии, базовый класс моделей, Redis
    /schemas    Pydantic-схемы ответов
    /services   бизнес-логика
    /seed       загрузчики YAML
    main.py
  /migrations   Alembic
  /tests
/content        taxonomy.yaml и банк вопросов (этапы 1–2)
/mobile         Flutter-приложение (этап 4)
/docker         Dockerfile и конфиг nginx
docker-compose.yml
```

## Статус

Этапы 0 (каркас) и 1 (таксономия) завершены. Дальше по плану из CLAUDE.md §6: контент →
выдача и рейтинги → мобильное приложение → офлайн → план перед собесом.
