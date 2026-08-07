"""Сид таксономии на живой базе: полнота дерева, идемпотентность, синхронизация."""

import os

import pytest
from httpx import AsyncClient
from sqlalchemy import func, select

from app.core.config import get_settings
from app.core.grades import ALL_GRADES, GRADE_VALUES
from app.db.models.taxonomy import Profession, Specialization, Subtopic, Topic, TopicWeight
from app.db.session import get_session_factory
from app.seed.loader import load_taxonomy
from app.seed.taxonomy import seed_taxonomy
from app.services.taxonomy import TaxonomyService

pytestmark = [
    pytest.mark.integration,
    pytest.mark.skipif(
        os.getenv("RUN_INTEGRATION_TESTS") != "1",
        reason="нужны поднятые Postgres и Redis",
    ),
]


async def _count(model: type) -> int:
    async with get_session_factory()() as session:
        return int((await session.execute(select(func.count()).select_from(model))).scalar_one())


async def test_seed_loads_full_tree(clean_db: None) -> None:
    path = get_settings().taxonomy_file

    report = await seed_taxonomy(path)

    assert report.professions.created == 8
    assert report.specializations.created == 22
    assert report.topics.created == 9
    assert report.subtopics.created == 44
    assert report.weights.created == 9 * len(ALL_GRADES)

    assert await _count(Profession) == 8
    assert await _count(Specialization) == 22
    assert await _count(Topic) == 9
    assert await _count(Subtopic) == 44
    assert await _count(TopicWeight) == 63


async def test_only_backend_python_is_active(clean_db: None) -> None:
    await seed_taxonomy(get_settings().taxonomy_file)

    async with get_session_factory()() as session:
        active = list(
            await session.scalars(select(Specialization.id).where(Specialization.is_active))
        )

    assert active == ["backend_python"]


async def test_seed_is_idempotent(clean_db: None) -> None:
    """Приёмка этапа 1: повторный запуск не создаёт дублей и ничего не меняет."""
    path = get_settings().taxonomy_file
    await seed_taxonomy(path)

    second = await seed_taxonomy(path)

    assert not second.has_changes, second.as_lines()
    assert await _count(Profession) == 8
    assert await _count(Specialization) == 22
    assert await _count(Topic) == 9
    assert await _count(Subtopic) == 44
    assert await _count(TopicWeight) == 63


async def test_seed_updates_changed_titles(clean_db: None) -> None:
    path = get_settings().taxonomy_file
    await seed_taxonomy(path)

    async with get_session_factory()() as session:
        profession = await session.get(Profession, "backend")
        assert profession is not None
        profession.title = "Устаревшее название"
        await session.commit()

    report = await seed_taxonomy(path)

    assert report.professions.updated == 1
    async with get_session_factory()() as session:
        profession = await session.get(Profession, "backend")
        assert profession is not None
        assert profession.title == "Backend-разработчик"


async def test_seed_removes_entries_absent_in_yaml(clean_db: None) -> None:
    """YAML — источник истины: лишнее из базы уезжает."""
    path = get_settings().taxonomy_file
    await seed_taxonomy(path)

    async with get_session_factory()() as session:
        session.add(Profession(id="astrology", title="Астролог", sort_order=99))
        await session.commit()

    report = await seed_taxonomy(path)

    assert report.professions.deleted == 1
    assert await _count(Profession) == 8


async def test_weights_match_yaml(clean_db: None) -> None:
    path = get_settings().taxonomy_file
    await seed_taxonomy(path)
    payload = load_taxonomy(path)
    expected = {topic.code: topic.weights_by_grade() for topic in payload.topics["backend_python"]}

    async with get_session_factory()() as session:
        rows = (
            await session.execute(
                select(Topic.code, TopicWeight.grade, TopicWeight.weight).join(
                    TopicWeight, TopicWeight.topic_id == Topic.id
                )
            )
        ).all()

    stored: dict[str, dict[int, float]] = {}
    for code, grade, weight in rows:
        stored.setdefault(code, {})[grade] = weight

    assert stored == expected
    senior = GRADE_VALUES["senior"]
    assert stored["system_design"][senior] > stored["language"][senior]


async def test_tree_is_ordered_and_nested(clean_db: None) -> None:
    await seed_taxonomy(get_settings().taxonomy_file)

    async with get_session_factory()() as session:
        tree = await TaxonomyService(session).get_tree()

    assert [profession.id for profession in tree] == [
        "backend",
        "frontend",
        "mobile",
        "qa",
        "data",
        "infra",
        "enterprise",
        "analysis",
    ]
    python = next(spec for spec in tree[0].specializations if spec.id == "backend_python")
    assert [topic.code for topic in python.topics][:3] == ["language", "async", "db"]
    assert next(subtopic.code for subtopic in python.topics[0].subtopics) == "gil"


async def test_taxonomy_endpoint_returns_tree(clean_db: None, client: AsyncClient) -> None:
    await seed_taxonomy(get_settings().taxonomy_file)

    response = await client.get("/api/v1/taxonomy")

    assert response.status_code == 200
    body = response.json()
    assert len(body["professions"]) == 8
    assert [grade["code"] for grade in body["grades"]] == [
        "intern",
        "junior",
        "junior_plus",
        "middle",
        "middle_plus",
        "senior",
        "lead",
    ]

    backend = body["professions"][0]
    python = backend["specializations"][0]
    assert python["id"] == "backend_python"
    assert python["is_active"] is True
    assert len(python["topics"]) == 9
    assert backend["specializations"][1]["topics"] == []
