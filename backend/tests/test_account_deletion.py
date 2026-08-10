"""Удаление аккаунта.

Магазины требуют от приложения с регистрацией удаление изнутри приложения, и
удаление должно быть настоящим. Здесь проверяется именно это: после вызова в
базе не остаётся ни пользователя, ни его следов в связанных таблицах.
"""

import os
import uuid

import pytest
from httpx import AsyncClient
from sqlalchemy import func, select

from app.core.config import get_settings
from app.core.grades import GRADE_MIDDLE
from app.db.models.question import Question
from app.db.models.report import QuestionReport
from app.db.models.user import ReviewState, User, UserAnswer, UserSpecialization, UserTopicRating
from app.db.session import get_session_factory
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
PASSWORD = "very-secret-1"


@pytest.fixture
async def content(clean_db: None) -> None:
    await seed_taxonomy(get_settings().taxonomy_file)
    await seed_questions()


async def register(client: AsyncClient, email: str) -> dict[str, str]:
    response = await client.post(
        "/api/v1/auth/register", json={"email": email, "password": PASSWORD}
    )
    assert response.status_code == 201, response.text
    return {"Authorization": f"Bearer {response.json()['access_token']}"}


async def make_active_user(client: AsyncClient, email: str) -> dict[str, str]:
    """Пользователь, наследивший во всех связанных таблицах."""
    headers = await register(client, email)

    profile = await client.patch(
        "/api/v1/me",
        headers=headers,
        json={
            "specialization_id": SPECIALIZATION,
            "self_assessed_grade": GRADE_MIDDLE,
            "is_primary": True,
        },
    )
    assert profile.status_code == 200, profile.text

    question = (
        await client.get(f"/api/v1/practice/next?specialization={SPECIALIZATION}", headers=headers)
    ).json()["question"]
    answer = await client.post(
        "/api/v1/practice/answer",
        headers=headers,
        json={
            "submission_id": str(uuid.uuid4()),
            "question_id": question["id"],
            "specialization_id": SPECIALIZATION,
            "self_assessment": 4,
        },
    )
    assert answer.status_code == 200, answer.text

    report = await client.post(
        "/api/v1/questions/report",
        headers=headers,
        json={
            "specialization_id": SPECIALIZATION,
            "title": "Что спросили на собеседовании про устройство словаря?",
        },
    )
    assert report.status_code == 201, report.text
    return headers


async def _count(model: type) -> int:
    async with get_session_factory()() as session:
        return int((await session.execute(select(func.count()).select_from(model))).scalar_one())


async def test_deletion_removes_user_and_all_traces(client: AsyncClient, content: None) -> None:
    headers = await make_active_user(client, f"del-{uuid.uuid4().hex[:8]}@example.com")

    # До удаления следы есть во всех связанных таблицах.
    assert await _count(User) == 1
    assert await _count(UserSpecialization) == 1
    assert await _count(UserAnswer) == 1
    assert await _count(UserTopicRating) == 1
    assert await _count(ReviewState) == 1
    assert await _count(QuestionReport) == 1

    response = await client.delete("/api/v1/me", headers=headers)

    assert response.status_code == 204
    assert await _count(User) == 0
    assert await _count(UserSpecialization) == 0
    assert await _count(UserAnswer) == 0
    assert await _count(UserTopicRating) == 0
    assert await _count(ReviewState) == 0
    assert await _count(QuestionReport) == 0


async def test_deletion_keeps_the_question_bank(client: AsyncClient, content: None) -> None:
    """Каскад не должен утащить за собой общий контент."""
    headers = await make_active_user(client, f"del-{uuid.uuid4().hex[:8]}@example.com")
    before = await _count(Question)

    await client.delete("/api/v1/me", headers=headers)

    assert await _count(Question) == before


async def test_deletion_does_not_touch_other_users(client: AsyncClient, content: None) -> None:
    victim = await make_active_user(client, f"del-{uuid.uuid4().hex[:8]}@example.com")
    await make_active_user(client, f"keep-{uuid.uuid4().hex[:8]}@example.com")

    await client.delete("/api/v1/me", headers=victim)

    assert await _count(User) == 1
    assert await _count(UserAnswer) == 1


async def test_token_stops_working_after_deletion(client: AsyncClient, content: None) -> None:
    headers = await make_active_user(client, f"del-{uuid.uuid4().hex[:8]}@example.com")

    await client.delete("/api/v1/me", headers=headers)

    response = await client.get("/api/v1/me", headers=headers)
    assert response.status_code == 401


async def test_same_email_can_register_again(client: AsyncClient, content: None) -> None:
    """Удаление настоящее: почта освобождается, новый аккаунт пустой."""
    email = f"del-{uuid.uuid4().hex[:8]}@example.com"
    headers = await make_active_user(client, email)

    await client.delete("/api/v1/me", headers=headers)
    fresh = await register(client, email)

    body = (await client.get("/api/v1/me", headers=fresh)).json()
    assert body["specializations"] == []


async def test_deletion_requires_authentication(client: AsyncClient, content: None) -> None:
    response = await client.delete("/api/v1/me")

    assert response.status_code == 401
