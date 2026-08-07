"""План перед собеседованием на живой базе."""

import os
import uuid
from datetime import UTC, datetime, timedelta

import pytest
from httpx import AsyncClient
from sqlalchemy import select, update

from app.core.config import get_settings
from app.core.grades import GRADE_MIDDLE
from app.db.models.user import ReviewState, User
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
async def premium_headers(content: None, client: AsyncClient) -> dict[str, str]:
    email = f"plan-{uuid.uuid4().hex[:8]}@example.com"
    registered = await client.post(
        "/api/v1/auth/register", json={"email": email, "password": "very-secret-1"}
    )
    headers = {"Authorization": f"Bearer {registered.json()['access_token']}"}
    await client.patch(
        "/api/v1/me",
        headers=headers,
        json={
            "specialization_id": SPECIALIZATION,
            "self_assessed_grade": GRADE_MIDDLE,
            "is_primary": True,
        },
    )
    async with get_session_factory()() as session:
        await session.execute(update(User).where(User.email == email).values(is_premium=True))
        await session.commit()
    return headers


def in_days(days: int) -> str:
    return (datetime.now(UTC).date() + timedelta(days=days)).isoformat()


async def create_plan(
    client: AsyncClient, headers: dict[str, str], days: int = 7, capacity: int = 10
):
    return await client.post(
        "/api/v1/plan",
        headers=headers,
        json={
            "specialization_id": SPECIALIZATION,
            "interview_date": in_days(days),
            "daily_capacity": capacity,
        },
    )


# --- Платность ---------------------------------------------------------------------


async def test_plan_requires_premium(content: None, client: AsyncClient) -> None:
    registered = await client.post(
        "/api/v1/auth/register", json={"email": "free@example.com", "password": "very-secret-1"}
    )
    headers = {"Authorization": f"Bearer {registered.json()['access_token']}"}
    await client.patch(
        "/api/v1/me",
        headers=headers,
        json={
            "specialization_id": SPECIALIZATION,
            "self_assessed_grade": GRADE_MIDDLE,
            "is_primary": True,
        },
    )

    response = await create_plan(client, headers)

    assert response.status_code == 402
    assert "платном тарифе" in response.json()["detail"]


# --- Создание плана ----------------------------------------------------------------


async def test_create_plan_returns_schedule(
    client: AsyncClient, premium_headers: dict[str, str]
) -> None:
    response = await create_plan(client, premium_headers, days=7)

    assert response.status_code == 201, response.text
    body = response.json()
    assert body["specialization_id"] == SPECIALIZATION
    assert body["target_grade_code"] == "middle"
    assert len(body["days"]) == 7
    assert [day["day_index"] for day in body["days"]] == list(range(7))


async def test_last_day_is_review_only(
    client: AsyncClient, premium_headers: dict[str, str]
) -> None:
    """Приёмка этапа 6: последний день содержит только повторения."""
    body = (await create_plan(client, premium_headers, days=7)).json()

    last = body["days"][-1]
    assert last["review_only"] is True
    assert last["topic_codes"] == []
    assert last["new_questions"] == 0
    assert all(not day["review_only"] for day in body["days"][:-1])


async def test_week_plan_covers_all_weak_topics(
    client: AsyncClient, premium_headers: dict[str, str]
) -> None:
    """Приёмка этапа 6: план на 7 дней покрывает все темы с низким рейтингом."""
    body = (await create_plan(client, premium_headers, days=7)).json()

    covered = {topic for day in body["days"] for topic in day["topic_codes"]}
    taxonomy = (await client.get("/api/v1/taxonomy")).json()
    python = next(
        specialization
        for profession in taxonomy["professions"]
        for specialization in profession["specializations"]
        if specialization["id"] == SPECIALIZATION
    )
    # У новичка рейтинг стартовый по всем темам, значит слабые — все с ненулевым весом.
    all_topics = {topic["code"] for topic in python["topics"]}

    assert covered == all_topics, f"не покрыты: {all_topics - covered}"


async def test_daily_capacity_is_respected(
    client: AsyncClient, premium_headers: dict[str, str]
) -> None:
    body = (await create_plan(client, premium_headers, days=5, capacity=15)).json()

    study_days = [day for day in body["days"] if not day["review_only"]]
    assert {day["new_questions"] for day in study_days} == {15}


async def test_interview_in_the_past_is_rejected(
    client: AsyncClient, premium_headers: dict[str, str]
) -> None:
    response = await client.post(
        "/api/v1/plan",
        headers=premium_headers,
        json={"specialization_id": SPECIALIZATION, "interview_date": in_days(-1)},
    )

    assert response.status_code == 422
    assert "будущем" in response.json()["detail"]


async def test_interview_tomorrow_gives_single_review_day(
    client: AsyncClient, premium_headers: dict[str, str]
) -> None:
    body = (await create_plan(client, premium_headers, days=1)).json()

    assert len(body["days"]) == 1
    assert body["days"][0]["review_only"] is True


async def test_new_plan_replaces_previous(
    client: AsyncClient, premium_headers: dict[str, str]
) -> None:
    first = (await create_plan(client, premium_headers, days=7)).json()

    second = (await create_plan(client, premium_headers, days=5)).json()
    today = (
        await client.get(
            f"/api/v1/plan/today?specialization={SPECIALIZATION}", headers=premium_headers
        )
    ).json()

    assert first["id"] != second["id"]
    assert today["plan_id"] == second["id"]


# --- Сегодняшний день --------------------------------------------------------------


async def test_today_without_plan_is_404(
    client: AsyncClient, premium_headers: dict[str, str]
) -> None:
    response = await client.get(
        f"/api/v1/plan/today?specialization={SPECIALIZATION}", headers=premium_headers
    )

    assert response.status_code == 404
    assert "активного плана нет" in response.json()["detail"]


async def test_today_returns_first_day_with_questions(
    client: AsyncClient, premium_headers: dict[str, str]
) -> None:
    await create_plan(client, premium_headers, days=7)

    response = await client.get(
        f"/api/v1/plan/today?specialization={SPECIALIZATION}", headers=premium_headers
    )

    assert response.status_code == 200
    body = response.json()
    assert body["day_index"] == 0
    assert body["days_left"] == 7
    assert body["review_only"] is False
    assert body["topic_codes"]
    assert body["new_questions"], "на первый день должны подобраться вопросы"
    for question in body["new_questions"]:
        assert question["topic_code"] in body["topic_codes"]
        assert question["min_grade"] <= GRADE_MIDDLE <= question["max_grade"]
        assert "answer_short" not in question


async def test_today_counts_due_reviews_first(
    client: AsyncClient, premium_headers: dict[str, str]
) -> None:
    """Повторения из SRS имеют приоритет над новыми вопросами."""
    await create_plan(client, premium_headers, days=7, capacity=3)

    # Отвечаем на вопрос и двигаем его повторение в прошлое.
    question = (
        await client.get(
            f"/api/v1/practice/next?specialization={SPECIALIZATION}", headers=premium_headers
        )
    ).json()["question"]
    await client.post(
        "/api/v1/practice/answer",
        headers=premium_headers,
        json={
            "submission_id": str(uuid.uuid4()),
            "question_id": question["id"],
            "specialization_id": SPECIALIZATION,
            "self_assessment": 5,
        },
    )
    async with get_session_factory()() as session:
        await session.execute(
            update(ReviewState).values(due_at=datetime.now(UTC) - timedelta(days=1))
        )
        await session.commit()

    body = (
        await client.get(
            f"/api/v1/plan/today?specialization={SPECIALIZATION}", headers=premium_headers
        )
    ).json()

    assert body["due_reviews"] == 1
    assert len(body["new_questions"]) == 2, "норма дня уменьшилась на счёт повторения"
    assert body["total_target"] == 3


async def test_today_tracks_completed_answers(
    client: AsyncClient, premium_headers: dict[str, str]
) -> None:
    await create_plan(client, premium_headers, days=7)
    question = (
        await client.get(
            f"/api/v1/practice/next?specialization={SPECIALIZATION}", headers=premium_headers
        )
    ).json()["question"]
    await client.post(
        "/api/v1/practice/answer",
        headers=premium_headers,
        json={
            "submission_id": str(uuid.uuid4()),
            "question_id": question["id"],
            "specialization_id": SPECIALIZATION,
            "self_assessment": 4,
        },
    )

    body = (
        await client.get(
            f"/api/v1/plan/today?specialization={SPECIALIZATION}", headers=premium_headers
        )
    ).json()

    assert body["completed_today"] == 1


async def test_last_day_offers_no_new_questions(
    client: AsyncClient, premium_headers: dict[str, str]
) -> None:
    """За день до собеседования — только повторение, никаких новых тем."""
    await create_plan(client, premium_headers, days=2)

    async with get_session_factory()() as session:
        # Сдвигаем план на день назад, чтобы «сегодня» стало последним днём.
        from app.db.models.plan import StudyPlan, StudyPlanDay

        plan_id = (await session.scalars(select(StudyPlan.id))).one()
        days = list(await session.scalars(select(StudyPlanDay).order_by(StudyPlanDay.day_index)))
        for day in days:
            day.day = day.day - timedelta(days=1)
        await session.execute(
            update(StudyPlan)
            .where(StudyPlan.id == plan_id)
            .values(interview_date=datetime.now(UTC).date() + timedelta(days=1))
        )
        await session.commit()

    body = (
        await client.get(
            f"/api/v1/plan/today?specialization={SPECIALIZATION}", headers=premium_headers
        )
    ).json()

    assert body["review_only"] is True
    assert body["new_questions"] == []
    assert body["topic_codes"] == []
