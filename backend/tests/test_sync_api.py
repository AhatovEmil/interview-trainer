"""Офлайн-синхронизация: пакет вопросов и загрузка накопленных ответов."""

import itertools
import os
import uuid
from datetime import UTC, datetime, timedelta

import pytest
from httpx import AsyncClient
from sqlalchemy import func, select

from app.core.config import get_settings
from app.core.grades import GRADE_MIDDLE
from app.db.models.user import ReviewState, UserAnswer
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


@pytest.fixture
async def content(clean_db: None) -> None:
    await seed_taxonomy(get_settings().taxonomy_file)
    await seed_questions()


@pytest.fixture
async def auth_headers(content: None, client: AsyncClient) -> dict[str, str]:
    email = f"sync-{uuid.uuid4().hex[:8]}@example.com"
    response = await client.post(
        "/api/v1/auth/register", json={"email": email, "password": "very-secret-1"}
    )
    assert response.status_code == 201, response.text
    headers = {"Authorization": f"Bearer {response.json()['access_token']}"}

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
    return headers


async def fetch_package(client: AsyncClient, headers: dict[str, str]) -> dict:
    response = await client.get(
        f"/api/v1/sync/questions?specialization={SPECIALIZATION}", headers=headers
    )
    assert response.status_code == 200, response.text
    return response.json()


def answer_payload(question: dict, *, answered_at: datetime, correct: bool = True) -> dict:
    """Собирает ответ так, как это сделало бы устройство в офлайне."""
    payload: dict = {
        "submission_id": str(uuid.uuid4()),
        "question_id": question["id"],
        "specialization_id": SPECIALIZATION,
        "answered_at": answered_at.isoformat(),
    }
    if question["options"]:
        codes = [
            option["code"] for option in question["options"] if option["is_correct"] == correct
        ]
        payload["selected_options"] = codes or [question["options"][0]["code"]]
    else:
        payload["self_assessment"] = 5 if correct else 0
    return payload


# --- Пакет вопросов ----------------------------------------------------------------


async def test_package_carries_everything_needed_offline(
    client: AsyncClient, auth_headers: dict[str, str]
) -> None:
    package = await fetch_package(client, auth_headers)

    assert package["specialization_id"] == SPECIALIZATION
    assert len(package["questions"]) == 30

    question = package["questions"][0]
    # Без разбора и правильности вариантов офлайн нечего показать после ответа.
    assert question["answer_short"]
    assert question["answer_detailed"]
    assert question["topic_title"]
    for option in question["options"]:
        assert "is_correct" in option


async def test_package_since_returns_only_changed(
    client: AsyncClient, auth_headers: dict[str, str]
) -> None:
    first = await fetch_package(client, auth_headers)

    response = await client.get(
        f"/api/v1/sync/questions?specialization={SPECIALIZATION}&since={first['synced_at']}",
        headers=auth_headers,
    )

    assert response.status_code == 200
    # Ничего не менялось — устройству нечего докачивать.
    assert response.json()["questions"] == []


async def test_package_rejects_unknown_specialization(
    client: AsyncClient, auth_headers: dict[str, str]
) -> None:
    response = await client.get(
        "/api/v1/sync/questions?specialization=backend_cobol", headers=auth_headers
    )

    assert response.status_code == 404


# --- Загрузка ответов --------------------------------------------------------------


async def test_batch_upload_accepts_offline_answers(
    client: AsyncClient, auth_headers: dict[str, str]
) -> None:
    package = await fetch_package(client, auth_headers)
    now = datetime.now(UTC)
    answers = [
        answer_payload(question, answered_at=now - timedelta(minutes=30 - index))
        for index, question in enumerate(package["questions"][:5])
    ]

    response = await client.post(
        "/api/v1/sync/answers", headers=auth_headers, json={"answers": answers}
    )

    assert response.status_code == 200, response.text
    body = response.json()
    assert body["accepted"] == 5
    assert body["duplicates"] == 0
    assert body["rejected"] == 0
    assert all(item["accepted"] for item in body["results"])


async def test_repeated_upload_creates_no_duplicates(
    client: AsyncClient, auth_headers: dict[str, str]
) -> None:
    """Приёмка этапа 5: после включения сети дублей нет.

    Сценарий обрыва: устройство отправило пачку, ответ сервера не дошёл,
    клиент повторяет отправку той же пачки.
    """
    package = await fetch_package(client, auth_headers)
    now = datetime.now(UTC)
    answers = [
        answer_payload(question, answered_at=now - timedelta(minutes=10 - index))
        for index, question in enumerate(package["questions"][:3])
    ]

    first = await client.post(
        "/api/v1/sync/answers", headers=auth_headers, json={"answers": answers}
    )
    second = await client.post(
        "/api/v1/sync/answers", headers=auth_headers, json={"answers": answers}
    )

    assert first.json()["accepted"] == 3
    assert second.json()["duplicates"] == 3
    assert second.json()["accepted"] == 0

    async with get_session_factory()() as session:
        stored = await session.scalar(select(func.count()).select_from(UserAnswer))
        assert stored == 3

    # Рейтинг тоже не должен сдвинуться второй раз.
    first_ratings = [item["rating_after"] for item in first.json()["results"]]
    second_ratings = [item["rating_after"] for item in second.json()["results"]]
    assert first_ratings == second_ratings


async def test_answers_applied_in_time_order(
    client: AsyncClient, auth_headers: dict[str, str]
) -> None:
    """Elo зависит от порядка, поэтому пачка сортируется по времени ответа."""
    package = await fetch_package(client, auth_headers)
    now = datetime.now(UTC)

    # Одна и та же тема, ответы перемешаны во времени относительно порядка в списке.
    same_topic = [
        question
        for question in package["questions"]
        if question["topic_code"] == package["questions"][0]["topic_code"]
    ][:3]
    assert len(same_topic) == 3

    shuffled = [
        answer_payload(same_topic[0], answered_at=now - timedelta(minutes=5)),
        answer_payload(same_topic[1], answered_at=now - timedelta(minutes=30)),
        answer_payload(same_topic[2], answered_at=now - timedelta(minutes=15)),
    ]

    response = await client.post(
        "/api/v1/sync/answers", headers=auth_headers, json={"answers": shuffled}
    )
    assert response.status_code == 200

    async with get_session_factory()() as session:
        rows = list(await session.scalars(select(UserAnswer).order_by(UserAnswer.answered_at)))

    # Рейтинг каждого следующего ответа стартует с того, чем закончился предыдущий.
    for previous, current in itertools.pairwise(rows):
        assert current.rating_before == pytest.approx(previous.rating_after)


async def test_answer_time_drives_review_schedule(
    client: AsyncClient, auth_headers: dict[str, str]
) -> None:
    """Срок повторения считается от ответа, а не от момента синхронизации."""
    package = await fetch_package(client, auth_headers)
    answered_at = datetime.now(UTC) - timedelta(days=3)

    response = await client.post(
        "/api/v1/sync/answers",
        headers=auth_headers,
        json={"answers": [answer_payload(package["questions"][0], answered_at=answered_at)]},
    )
    assert response.status_code == 200

    async with get_session_factory()() as session:
        state = await session.scalar(select(ReviewState))
        assert state is not None
        # Первое повторение через сутки после ответа — то есть уже просрочено.
        assert state.due_at < datetime.now(UTC)


async def test_future_answer_time_is_clamped(
    client: AsyncClient, auth_headers: dict[str, str]
) -> None:
    """Часы устройства могут врать вперёд — в будущее ответ не записываем."""
    package = await fetch_package(client, auth_headers)
    sent_at = datetime.now(UTC)

    response = await client.post(
        "/api/v1/sync/answers",
        headers=auth_headers,
        json={
            "answers": [
                answer_payload(package["questions"][0], answered_at=sent_at + timedelta(days=365))
            ]
        },
    )
    assert response.status_code == 200

    async with get_session_factory()() as session:
        answer = await session.scalar(select(UserAnswer))
        assert answer is not None
        assert answer.answered_at <= datetime.now(UTC) + timedelta(seconds=1)


async def test_bad_item_does_not_sink_the_batch(
    client: AsyncClient, auth_headers: dict[str, str]
) -> None:
    """Один битый ответ не должен блокировать очередь целиком."""
    package = await fetch_package(client, auth_headers)
    now = datetime.now(UTC)

    good = answer_payload(package["questions"][0], answered_at=now - timedelta(minutes=5))
    broken = answer_payload(package["questions"][1], answered_at=now - timedelta(minutes=4))
    broken["question_id"] = str(uuid.uuid4())  # вопроса с таким id нет

    response = await client.post(
        "/api/v1/sync/answers", headers=auth_headers, json={"answers": [good, broken]}
    )

    assert response.status_code == 200
    body = response.json()
    assert body["accepted"] == 1
    assert body["rejected"] == 1
    rejected = next(item for item in body["results"] if not item["accepted"])
    assert rejected["error"]


async def test_upload_requires_auth(client: AsyncClient) -> None:
    response = await client.post("/api/v1/sync/answers", json={"answers": []})

    assert response.status_code in (401, 403, 422)


async def test_offline_answers_land_in_stats(
    client: AsyncClient, auth_headers: dict[str, str]
) -> None:
    """Ответы из офлайна должны учитываться наравне с онлайновыми."""
    package = await fetch_package(client, auth_headers)
    now = datetime.now(UTC)
    answers = [
        answer_payload(question, answered_at=now - timedelta(minutes=20 - index))
        for index, question in enumerate(package["questions"][:4])
    ]

    await client.post("/api/v1/sync/answers", headers=auth_headers, json={"answers": answers})

    stats = await client.get(
        f"/api/v1/practice/stats?specialization={SPECIALIZATION}", headers=auth_headers
    )
    assert stats.status_code == 200
    assert stats.json()["answers_count"] == 4


async def test_user_is_isolated_from_other_users_answers(
    client: AsyncClient, auth_headers: dict[str, str], content: None
) -> None:
    """Один и тот же submission_id у разных людей — это разные ответы."""
    package = await fetch_package(client, auth_headers)
    payload = answer_payload(package["questions"][0], answered_at=datetime.now(UTC))

    other = await client.post(
        "/api/v1/auth/register",
        json={"email": f"other-{uuid.uuid4().hex[:8]}@example.com", "password": "very-secret-1"},
    )
    other_headers = {"Authorization": f"Bearer {other.json()['access_token']}"}
    await client.patch(
        "/api/v1/me",
        headers=other_headers,
        json={
            "specialization_id": SPECIALIZATION,
            "self_assessed_grade": GRADE_MIDDLE,
            "is_primary": True,
        },
    )

    first = await client.post(
        "/api/v1/sync/answers", headers=auth_headers, json={"answers": [payload]}
    )
    second = await client.post(
        "/api/v1/sync/answers", headers=other_headers, json={"answers": [payload]}
    )

    assert first.json()["accepted"] == 1
    assert second.json()["accepted"] == 1
    assert second.json()["duplicates"] == 0

    # Один submission_id, но два разных владельца: уникальность в БД составная.
    async with get_session_factory()() as session:
        stored = await session.scalars(
            select(UserAnswer).where(
                UserAnswer.submission_id == uuid.UUID(payload["submission_id"])
            )
        )
        owners = {answer.user_id for answer in stored}
        assert len(owners) == 2
