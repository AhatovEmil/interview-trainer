"""Список вопросов: что решено, чем закончилась последняя попытка, открытие вручную."""

import os
import uuid

import pytest
from httpx import AsyncClient

from app.core.config import get_settings
from app.core.grades import GRADE_INTERN, GRADE_MIDDLE
from app.seed.questions import seed_questions
from app.seed.taxonomy import seed_taxonomy

pytestmark = [
    pytest.mark.integration,
    pytest.mark.skipif(
        os.getenv("RUN_INTEGRATION_TESTS") != "1",
        reason="нужны поднятые Postgres и Redis",
    ),
]

SPECIALIZATION = "backend_python"


@pytest.fixture
async def content(clean_db: None) -> None:
    await seed_taxonomy(get_settings().taxonomy_file)
    await seed_questions()


@pytest.fixture
async def auth_headers(content: None, client: AsyncClient) -> dict[str, str]:
    email = f"list-{uuid.uuid4().hex[:8]}@example.com"
    response = await client.post(
        "/api/v1/auth/register", json={"email": email, "password": "very-secret-1"}
    )
    assert response.status_code == 201, response.text
    return {"Authorization": f"Bearer {response.json()['access_token']}"}


async def set_profile(client: AsyncClient, headers: dict[str, str], grade: int) -> None:
    response = await client.patch(
        "/api/v1/me",
        headers=headers,
        json={
            "specialization_id": SPECIALIZATION,
            "self_assessed_grade": grade,
            "is_primary": True,
        },
    )
    assert response.status_code == 200, response.text


async def fetch_list(client: AsyncClient, headers: dict[str, str]) -> dict:
    response = await client.get(
        f"/api/v1/practice/questions?specialization={SPECIALIZATION}", headers=headers
    )
    assert response.status_code == 200, response.text
    return response.json()


async def answer(
    client: AsyncClient,
    headers: dict[str, str],
    question: dict,
    *,
    correct: bool,
) -> dict:
    """Отвечает на вопрос, открыв его по id — как из списка."""
    detail = await client.get(
        f"/api/v1/practice/questions/{question['id']}?specialization={SPECIALIZATION}",
        headers=headers,
    )
    assert detail.status_code == 200, detail.text
    full = detail.json()["question"]

    payload: dict = {
        "submission_id": str(uuid.uuid4()),
        "question_id": question["id"],
        "specialization_id": SPECIALIZATION,
    }
    if full["options"]:
        payload["selected_options"] = [full["options"][0]["code"]]
    else:
        payload["self_assessment"] = 5 if correct else 0

    response = await client.post("/api/v1/practice/answer", headers=headers, json=payload)
    assert response.status_code == 200, response.text
    return response.json()


async def test_list_requires_profile(client: AsyncClient, auth_headers: dict[str, str]) -> None:
    response = await client.get(
        f"/api/v1/practice/questions?specialization={SPECIALIZATION}", headers=auth_headers
    )

    assert response.status_code == 404


async def test_fresh_list_is_all_unanswered(
    client: AsyncClient, auth_headers: dict[str, str]
) -> None:
    await set_profile(client, auth_headers, GRADE_MIDDLE)

    body = await fetch_list(client, auth_headers)

    assert body["total"] == 30
    assert body["answered"] == 0
    assert all(item["status"] == "unanswered" for item in body["items"])
    # Разбора и правильных ответов в списке нет: он не должен быть шпаргалкой.
    for item in body["items"]:
        assert "answer_short" not in item
        assert "options" not in item


async def test_list_shows_topic_titles_not_codes(
    client: AsyncClient, auth_headers: dict[str, str]
) -> None:
    await set_profile(client, auth_headers, GRADE_MIDDLE)

    body = await fetch_list(client, auth_headers)

    for item in body["items"]:
        assert item["topic_title"]
        assert item["topic_title"] != item["topic_code"]


async def test_answer_marks_status_and_counters(
    client: AsyncClient, auth_headers: dict[str, str]
) -> None:
    await set_profile(client, auth_headers, GRADE_MIDDLE)
    before = await fetch_list(client, auth_headers)
    target = next(item for item in before["items"] if item["type"] == "open_answer")

    await answer(client, auth_headers, target, correct=True)
    after = await fetch_list(client, auth_headers)

    updated = next(item for item in after["items"] if item["id"] == target["id"])
    assert updated["status"] == "correct"
    assert updated["answers_count"] == 1
    assert updated["last_answered_at"] is not None
    assert updated["due_at"] is not None
    assert after["answered"] == 1
    assert after["correct"] == 1


async def test_status_reflects_last_attempt_not_best(
    client: AsyncClient, auth_headers: dict[str, str]
) -> None:
    """Список показывает текущее положение дел, иначе забытое выглядело бы освоенным."""
    await set_profile(client, auth_headers, GRADE_MIDDLE)
    listing = await fetch_list(client, auth_headers)
    target = next(item for item in listing["items"] if item["type"] == "open_answer")

    await answer(client, auth_headers, target, correct=True)
    await answer(client, auth_headers, target, correct=False)

    after = await fetch_list(client, auth_headers)
    updated = next(item for item in after["items"] if item["id"] == target["id"])

    assert updated["status"] == "wrong"
    assert updated["answers_count"] == 2
    assert after["correct"] == 0
    assert after["wrong"] == 1


async def test_out_of_grade_questions_are_listed_but_marked(
    client: AsyncClient, auth_headers: dict[str, str]
) -> None:
    """Вопросы вне грейда видно, но помечено, что в выдачу они не попадут."""
    await set_profile(client, auth_headers, GRADE_INTERN)

    body = await fetch_list(client, auth_headers)

    assert body["total"] == 30
    assert any(not item["in_grade_range"] for item in body["items"])


async def test_question_opens_by_id_even_out_of_grade(
    client: AsyncClient, auth_headers: dict[str, str]
) -> None:
    """Открытый вручную вопрос выдаётся независимо от адаптивного отбора."""
    await set_profile(client, auth_headers, GRADE_INTERN)
    body = await fetch_list(client, auth_headers)
    out_of_range = next(item for item in body["items"] if not item["in_grade_range"])

    response = await client.get(
        f"/api/v1/practice/questions/{out_of_range['id']}?specialization={SPECIALIZATION}",
        headers=auth_headers,
    )

    assert response.status_code == 200
    assert response.json()["question"]["id"] == out_of_range["id"]


async def test_unknown_question_id_is_not_found(
    client: AsyncClient, auth_headers: dict[str, str]
) -> None:
    await set_profile(client, auth_headers, GRADE_MIDDLE)

    response = await client.get(
        f"/api/v1/practice/questions/{uuid.uuid4()}?specialization={SPECIALIZATION}",
        headers=auth_headers,
    )

    assert response.status_code == 404


async def test_list_requires_auth(client: AsyncClient) -> None:
    response = await client.get(f"/api/v1/practice/questions?specialization={SPECIALIZATION}")

    assert response.status_code in (401, 403)
