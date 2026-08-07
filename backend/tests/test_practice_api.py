"""Полный путь пользователя: регистрация → профиль → выдача → ответ → статистика."""

import os
import uuid
from datetime import timedelta

import pytest
from httpx import AsyncClient
from sqlalchemy import select, update

from app.core.config import get_settings
from app.core.grades import GRADE_INTERN, GRADE_LEAD, GRADE_MIDDLE
from app.db.models.question import Question
from app.db.models.user import ReviewState, User, UserAnswer, UserTopicRating
from app.db.session import get_session_factory
from app.seed.questions import seed_questions
from app.seed.taxonomy import seed_taxonomy
from app.services.rating import MIN_ANSWERS_FOR_ESTIMATE, START_RATING

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
    email = f"user-{uuid.uuid4().hex[:8]}@example.com"
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


# --- Регистрация и вход ------------------------------------------------------------


async def test_register_returns_token_pair(content: None, client: AsyncClient) -> None:
    response = await client.post(
        "/api/v1/auth/register", json={"email": "new@example.com", "password": "very-secret-1"}
    )

    assert response.status_code == 201
    body = response.json()
    assert body["access_token"] and body["refresh_token"]
    assert body["token_type"] == "bearer"


async def test_duplicate_email_rejected(content: None, client: AsyncClient) -> None:
    payload = {"email": "dup@example.com", "password": "very-secret-1"}
    await client.post("/api/v1/auth/register", json=payload)

    response = await client.post("/api/v1/auth/register", json=payload)

    assert response.status_code == 409
    assert "почтой уже зарегистрирован" in response.json()["detail"]


async def test_login_with_wrong_password_is_401(content: None, client: AsyncClient) -> None:
    await client.post(
        "/api/v1/auth/register", json={"email": "who@example.com", "password": "very-secret-1"}
    )

    response = await client.post(
        "/api/v1/auth/login", json={"email": "who@example.com", "password": "wrong-password"}
    )

    assert response.status_code == 401


async def test_refresh_returns_new_pair(content: None, client: AsyncClient) -> None:
    registered = await client.post(
        "/api/v1/auth/register", json={"email": "ref@example.com", "password": "very-secret-1"}
    )

    response = await client.post(
        "/api/v1/auth/refresh", json={"refresh_token": registered.json()["refresh_token"]}
    )

    assert response.status_code == 200
    assert response.json()["access_token"]


async def test_access_token_not_accepted_as_refresh(content: None, client: AsyncClient) -> None:
    registered = await client.post(
        "/api/v1/auth/register", json={"email": "mix@example.com", "password": "very-secret-1"}
    )

    response = await client.post(
        "/api/v1/auth/refresh", json={"refresh_token": registered.json()["access_token"]}
    )

    assert response.status_code == 401


async def test_protected_endpoint_requires_token(content: None, client: AsyncClient) -> None:
    response = await client.get("/api/v1/me")

    assert response.status_code == 401


# --- Профиль -----------------------------------------------------------------------


async def test_profile_update_sets_specialization(
    client: AsyncClient, auth_headers: dict[str, str]
) -> None:
    await set_profile(client, auth_headers, GRADE_MIDDLE)

    response = await client.get("/api/v1/me", headers=auth_headers)

    body = response.json()
    assert body["specializations"] == [
        {
            "specialization_id": SPECIALIZATION,
            "self_assessed_grade": GRADE_MIDDLE,
            "grade_code": "middle",
            "is_primary": True,
            "answers_count": 0,
        }
    ]


async def test_inactive_specialization_rejected(
    client: AsyncClient, auth_headers: dict[str, str]
) -> None:
    response = await client.patch(
        "/api/v1/me",
        headers=auth_headers,
        json={
            "specialization_id": "backend_go",
            "self_assessed_grade": GRADE_MIDDLE,
            "is_primary": True,
        },
    )

    assert response.status_code == 422
    assert "скоро" in response.json()["detail"]


# --- Выдача вопроса ----------------------------------------------------------------


async def test_next_question_requires_profile(
    client: AsyncClient, auth_headers: dict[str, str]
) -> None:
    response = await client.get(
        f"/api/v1/practice/next?specialization={SPECIALIZATION}", headers=auth_headers
    )

    assert response.status_code == 404


async def test_next_question_hides_answers(
    client: AsyncClient, auth_headers: dict[str, str]
) -> None:
    await set_profile(client, auth_headers, GRADE_MIDDLE)

    response = await client.get(
        f"/api/v1/practice/next?specialization={SPECIALIZATION}", headers=auth_headers
    )

    assert response.status_code == 200
    question = response.json()["question"]
    assert "answer_short" not in question
    assert "answer_detailed" not in question
    for option in question["options"]:
        assert "is_correct" not in option


async def test_question_outside_grade_range_is_not_served(
    client: AsyncClient, auth_headers: dict[str, str]
) -> None:
    """Приёмка этапа 3: вопрос вне [min_grade, max_grade] не выдаётся."""
    await set_profile(client, auth_headers, GRADE_INTERN)

    seen: set[str] = set()
    for _ in range(40):
        response = await client.get(
            f"/api/v1/practice/next?specialization={SPECIALIZATION}", headers=auth_headers
        )
        if response.status_code == 404:
            break
        question = response.json()["question"]
        assert question["min_grade"] <= GRADE_INTERN <= question["max_grade"], question["title"]
        seen.add(question["id"])
        await _answer(client, auth_headers, question, self_assessment=5)

    assert seen, "для стажёра должен найтись хотя бы один вопрос"

    async with get_session_factory()() as session:
        out_of_range = list(
            await session.scalars(
                select(Question.slug).where(
                    (Question.min_grade > GRADE_INTERN) | (Question.max_grade < GRADE_INTERN)
                )
            )
        )
        served = list(
            await session.scalars(select(Question.slug).where(Question.id.in_(list(seen))))
        )

    assert out_of_range, "в банке должны быть вопросы вне грейда стажёра"
    assert not set(served) & set(out_of_range)


async def test_lead_gets_only_questions_within_range(
    client: AsyncClient, auth_headers: dict[str, str]
) -> None:
    await set_profile(client, auth_headers, GRADE_LEAD)

    response = await client.get(
        f"/api/v1/practice/next?specialization={SPECIALIZATION}", headers=auth_headers
    )

    question = response.json()["question"]
    assert question["min_grade"] <= GRADE_LEAD <= question["max_grade"]


# --- Ответ -------------------------------------------------------------------------


async def _answer(
    client: AsyncClient,
    headers: dict[str, str],
    question: dict,
    *,
    self_assessment: int | None = None,
    selected_options: list[str] | None = None,
    submission_id: str | None = None,
) -> dict:
    payload: dict[str, object] = {
        "submission_id": submission_id or str(uuid.uuid4()),
        "question_id": question["id"],
        "specialization_id": SPECIALIZATION,
    }
    if question["options"]:
        payload["selected_options"] = selected_options or [question["options"][0]["code"]]
    else:
        payload["self_assessment"] = self_assessment if self_assessment is not None else 4

    response = await client.post("/api/v1/practice/answer", headers=headers, json=payload)
    assert response.status_code == 200, response.text
    return response.json()


async def test_answer_returns_explanation_and_rating(
    client: AsyncClient, auth_headers: dict[str, str]
) -> None:
    await set_profile(client, auth_headers, GRADE_MIDDLE)
    question = (
        await client.get(
            f"/api/v1/practice/next?specialization={SPECIALIZATION}", headers=auth_headers
        )
    ).json()["question"]

    body = await _answer(client, auth_headers, question, self_assessment=5)

    assert body["explanation"]["answer_short"]
    assert body["rating_before"] == pytest.approx(START_RATING)
    assert body["rating_after"] != body["rating_before"]
    assert body["rating_delta"] == pytest.approx(
        body["rating_after"] - body["rating_before"], abs=0.2
    )
    assert body["next_review_at"]
    assert body["is_duplicate"] is False


async def test_repeated_submission_is_idempotent(
    client: AsyncClient, auth_headers: dict[str, str]
) -> None:
    """Приёмка этапа 3: повторная отправка того же ответа не двигает рейтинг."""
    await set_profile(client, auth_headers, GRADE_MIDDLE)
    question = (
        await client.get(
            f"/api/v1/practice/next?specialization={SPECIALIZATION}", headers=auth_headers
        )
    ).json()["question"]
    submission_id = str(uuid.uuid4())

    first = await _answer(
        client, auth_headers, question, self_assessment=5, submission_id=submission_id
    )
    second = await _answer(
        client, auth_headers, question, self_assessment=5, submission_id=submission_id
    )

    assert second["is_duplicate"] is True
    assert second["rating_after"] == first["rating_after"]
    assert second["rating_before"] == first["rating_before"]

    async with get_session_factory()() as session:
        answers = list(await session.scalars(select(UserAnswer)))
        ratings = list(await session.scalars(select(UserTopicRating)))

    assert len(answers) == 1, "второй ответ не должен создавать новую запись"
    assert ratings[0].answers_count == 1


async def test_wrong_choice_lowers_rating(
    client: AsyncClient, auth_headers: dict[str, str]
) -> None:
    await set_profile(client, auth_headers, GRADE_MIDDLE)

    async with get_session_factory()() as session:
        question_row = (
            await session.scalars(
                select(Question).where(Question.slug == "mutable_default_argument")
            )
        ).one()
        wrong = next(option.code for option in question_row.options if not option.is_correct)
        question = {"id": str(question_row.id), "options": [{"code": wrong}]}

    body = await _answer(client, auth_headers, question, selected_options=[wrong])

    assert body["score"] == 0.0
    assert body["rating_delta"] < 0


async def test_correct_choice_raises_rating(
    client: AsyncClient, auth_headers: dict[str, str]
) -> None:
    await set_profile(client, auth_headers, GRADE_MIDDLE)

    async with get_session_factory()() as session:
        question_row = (
            await session.scalars(
                select(Question).where(Question.slug == "mutable_default_argument")
            )
        ).one()
        correct = [option.code for option in question_row.options if option.is_correct]
        question = {"id": str(question_row.id), "options": [{"code": code} for code in correct]}

    body = await _answer(client, auth_headers, question, selected_options=correct)

    assert body["score"] == 1.0
    assert body["rating_delta"] > 0


async def test_answer_creates_review_state(
    client: AsyncClient, auth_headers: dict[str, str]
) -> None:
    await set_profile(client, auth_headers, GRADE_MIDDLE)
    question = (
        await client.get(
            f"/api/v1/practice/next?specialization={SPECIALIZATION}", headers=auth_headers
        )
    ).json()["question"]

    await _answer(client, auth_headers, question, self_assessment=5)

    async with get_session_factory()() as session:
        state = (await session.scalars(select(ReviewState))).one()

    assert state.repetitions == 1
    assert state.interval_days == 1


async def test_answered_question_is_not_served_again(
    client: AsyncClient, auth_headers: dict[str, str]
) -> None:
    await set_profile(client, auth_headers, GRADE_MIDDLE)
    first = (
        await client.get(
            f"/api/v1/practice/next?specialization={SPECIALIZATION}", headers=auth_headers
        )
    ).json()["question"]

    await _answer(client, auth_headers, first, self_assessment=5)
    second = (
        await client.get(
            f"/api/v1/practice/next?specialization={SPECIALIZATION}", headers=auth_headers
        )
    ).json()["question"]

    assert second["id"] != first["id"]


async def test_due_review_takes_priority_over_new_question(
    client: AsyncClient, auth_headers: dict[str, str]
) -> None:
    await set_profile(client, auth_headers, GRADE_MIDDLE)
    answered = (
        await client.get(
            f"/api/v1/practice/next?specialization={SPECIALIZATION}", headers=auth_headers
        )
    ).json()["question"]
    await _answer(client, auth_headers, answered, self_assessment=5)

    # Двигаем срок повторения в прошлое: вопрос обязан вернуться раньше новых.
    async with get_session_factory()() as session:
        await session.execute(
            update(ReviewState).values(due_at=ReviewState.due_at - timedelta(days=10))
        )
        await session.commit()

    response = await client.get(
        f"/api/v1/practice/next?specialization={SPECIALIZATION}", headers=auth_headers
    )

    body = response.json()
    assert body["is_review"] is True
    assert body["question"]["id"] == answered["id"]


# --- Статистика --------------------------------------------------------------------


async def test_stats_locked_until_enough_answers(
    client: AsyncClient, auth_headers: dict[str, str]
) -> None:
    await set_profile(client, auth_headers, GRADE_MIDDLE)

    response = await client.get(
        f"/api/v1/practice/stats?specialization={SPECIALIZATION}", headers=auth_headers
    )

    body = response.json()
    assert body["locked_reason"] == "not_enough_data"
    assert body["overall_grade"] is None


async def test_stats_requires_premium_after_enough_answers(
    client: AsyncClient, auth_headers: dict[str, str]
) -> None:
    """Оценка уровня — платная фича, флаг проверяется в сервисном слое."""
    await set_profile(client, auth_headers, GRADE_MIDDLE)
    await _answer_many(client, auth_headers, MIN_ANSWERS_FOR_ESTIMATE)

    response = await client.get(
        f"/api/v1/practice/stats?specialization={SPECIALIZATION}", headers=auth_headers
    )

    body = response.json()
    assert body["answers_count"] >= MIN_ANSWERS_FOR_ESTIMATE
    assert body["locked_reason"] == "premium_required"
    assert body["overall_grade"] is None
    assert body["topics"], "рейтинги по темам доступны и без подписки"


async def test_premium_user_sees_grade_estimate(
    client: AsyncClient, auth_headers: dict[str, str]
) -> None:
    await set_profile(client, auth_headers, GRADE_MIDDLE)
    await _answer_many(client, auth_headers, MIN_ANSWERS_FOR_ESTIMATE)

    async with get_session_factory()() as session:
        await session.execute(update(User).values(is_premium=True))
        await session.commit()

    response = await client.get(
        f"/api/v1/practice/stats?specialization={SPECIALIZATION}", headers=auth_headers
    )

    body = response.json()
    assert body["locked_reason"] is None
    assert body["overall_grade"] is not None
    assert body["overall_grade_code"]
    assert body["overall_rating"] > START_RATING, "после верных ответов оценка выше стартовой"


async def _answer_many(client: AsyncClient, headers: dict[str, str], count: int) -> None:
    for _ in range(count):
        response = await client.get(
            f"/api/v1/practice/next?specialization={SPECIALIZATION}", headers=headers
        )
        if response.status_code == 404:
            return
        question = response.json()["question"]
        selected = (
            [option["code"] for option in question["options"]] if question["options"] else None
        )
        await _answer(client, headers, question, self_assessment=5, selected_options=selected)
