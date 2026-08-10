"""Краудсорсинг: приём вопросов с собеседований.

Главное, что здесь проверяется, — присланное не попадает в банк. Всё остальное
(дубли, лимит, неизвестный раздел) вторично: ошибка в них портит очередь
модерации, ошибка в первом портит контент, который видят пользователи.
"""

import os
import uuid

import pytest
from httpx import AsyncClient
from sqlalchemy import func, select

from app.core.config import get_settings
from app.core.enums import ReportStatus
from app.db.models.question import Question
from app.db.models.report import QuestionReport
from app.db.session import get_session_factory
from app.seed.questions import seed_questions
from app.seed.taxonomy import seed_taxonomy
from app.services.reports import DAILY_LIMIT, MIN_TITLE_LENGTH, fingerprint

pytestmark = [
    pytest.mark.integration,
    pytest.mark.skipif(
        os.getenv("RUN_INTEGRATION_TESTS") != "1",
        reason="нужны поднятые Postgres и Redis",
    ),
]

SPECIALIZATION = "backend_python"
TITLE = "Чем отличается процесс от потока и когда что выбирать?"


@pytest.fixture
async def content(clean_db: None) -> None:
    await seed_taxonomy(get_settings().taxonomy_file)
    await seed_questions()


@pytest.fixture
async def auth_headers(content: None, client: AsyncClient) -> dict[str, str]:
    email = f"report-{uuid.uuid4().hex[:8]}@example.com"
    response = await client.post(
        "/api/v1/auth/register", json={"email": email, "password": "very-secret-1"}
    )
    assert response.status_code == 201, response.text
    return {"Authorization": f"Bearer {response.json()['access_token']}"}


async def send(
    client: AsyncClient, headers: dict[str, str], **overrides: object
) -> tuple[int, dict]:
    payload: dict[str, object] = {"specialization_id": SPECIALIZATION, "title": TITLE}
    payload.update(overrides)
    response = await client.post("/api/v1/questions/report", headers=headers, json=payload)
    return response.status_code, response.json()


async def _count(model: type) -> int:
    async with get_session_factory()() as session:
        return int((await session.execute(select(func.count()).select_from(model))).scalar_one())


async def test_report_is_saved_with_new_status(
    client: AsyncClient, auth_headers: dict[str, str]
) -> None:
    status_code, body = await send(client, auth_headers, topic_code="language", company="Яндекс")

    assert status_code == 201, body
    assert body["status"] == ReportStatus.NEW
    assert body["is_duplicate"] is False
    assert body["topic_code"] == "language"
    assert await _count(QuestionReport) == 1


async def test_report_does_not_enter_question_bank(
    client: AsyncClient, auth_headers: dict[str, str]
) -> None:
    """Приёмка §8.1: присланное публикует человек, а не эндпоинт."""
    before = await _count(Question)

    status_code, _ = await send(client, auth_headers)

    assert status_code == 201
    assert await _count(Question) == before


async def test_repeated_submission_returns_same_report(
    client: AsyncClient, auth_headers: dict[str, str]
) -> None:
    _, first = await send(client, auth_headers)

    # Другой регистр и пунктуация — тот же вопрос.
    status_code, second = await send(client, auth_headers, title=TITLE.upper().replace("?", ""))

    assert status_code == 201
    assert second["is_duplicate"] is True
    assert second["id"] == first["id"]
    assert await _count(QuestionReport) == 1


async def test_unknown_topic_is_dropped_not_rejected(
    client: AsyncClient, auth_headers: dict[str, str]
) -> None:
    """Формулировку теряем только через труп: неверный раздел просто отбрасываем."""
    status_code, body = await send(client, auth_headers, topic_code="no_such_topic")

    assert status_code == 201, body
    assert body["topic_code"] is None


async def test_topic_of_another_specialization_is_dropped(
    client: AsyncClient, auth_headers: dict[str, str]
) -> None:
    # event_loop есть у backend_python, но раздел gc_and_memory — из другого стека.
    status_code, body = await send(client, auth_headers, topic_code="change_detection")

    assert status_code == 201, body
    assert body["topic_code"] is None


async def test_short_title_is_rejected(client: AsyncClient, auth_headers: dict[str, str]) -> None:
    status_code, _ = await send(client, auth_headers, title="про GIL")

    assert status_code == 422
    assert await _count(QuestionReport) == 0


async def test_unknown_specialization_is_rejected(
    client: AsyncClient, auth_headers: dict[str, str]
) -> None:
    status_code, _ = await send(client, auth_headers, specialization_id="backend_cobol")

    assert status_code == 404
    assert await _count(QuestionReport) == 0


async def test_daily_limit_stops_the_flood(
    client: AsyncClient, auth_headers: dict[str, str]
) -> None:
    for index in range(DAILY_LIMIT):
        status_code, body = await send(client, auth_headers, title=f"{TITLE} вариант {index}")
        assert status_code == 201, body

    status_code, body = await send(client, auth_headers, title=f"{TITLE} последний")

    assert status_code == 422, body
    assert await _count(QuestionReport) == DAILY_LIMIT


async def test_report_requires_authentication(client: AsyncClient, content: None) -> None:
    response = await client.post(
        "/api/v1/questions/report",
        json={"specialization_id": SPECIALIZATION, "title": TITLE},
    )

    assert response.status_code == 401


def test_fingerprint_ignores_case_punctuation_and_spacing() -> None:
    assert fingerprint("Что такое GIL?") == fingerprint("  что   такое gil ")
    assert fingerprint("Что такое GIL?") != fingerprint("Что такое GC?")


def test_min_title_length_is_shared_with_schema() -> None:
    """Схема и сервис должны отбивать одну и ту же границу, иначе 500 вместо 422."""
    from app.schemas.report import QuestionReportRequest

    field = QuestionReportRequest.model_fields["title"]
    constraints = [getattr(item, "min_length", None) for item in field.metadata]

    assert MIN_TITLE_LENGTH in constraints
