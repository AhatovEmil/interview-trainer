"""Сид таксономии на живой базе: полнота дерева, идемпотентность, синхронизация.

Ожидания считаются из самого YAML, а не зашиты числами: иначе каждая новая
специализация ломала бы тесты, ничего при этом не проверяя по существу.
Смысл проверок — «база соответствует файлу», а не «в файле ровно девять разделов».
"""

import os

import pytest
from httpx import AsyncClient
from sqlalchemy import func, select

from app.core.config import get_settings
from app.core.grades import ALL_GRADES, GRADE_VALUES
from app.db.models.taxonomy import Profession, Specialization, Subtopic, Topic, TopicWeight
from app.db.session import get_session_factory
from app.seed.loader import load_taxonomy
from app.seed.schema import TaxonomyFile
from app.seed.taxonomy import seed_taxonomy
from app.services.taxonomy import TaxonomyService

pytestmark = [
    pytest.mark.integration,
    pytest.mark.skipif(
        os.getenv("RUN_INTEGRATION_TESTS") != "1",
        reason="нужны поднятые Postgres и Redis",
    ),
]


@pytest.fixture
def payload() -> TaxonomyFile:
    return load_taxonomy(get_settings().taxonomy_file)


def expected_counts(payload: TaxonomyFile) -> dict[str, int]:
    topics = [topic for topics in payload.topics.values() for topic in topics]
    return {
        "professions": len(payload.professions),
        "specializations": sum(
            len(profession.specializations) for profession in payload.professions
        ),
        "topics": len(topics),
        "subtopics": sum(len(topic.subtopics) for topic in topics),
        "weights": len(topics) * len(ALL_GRADES),
    }


async def _count(model: type) -> int:
    async with get_session_factory()() as session:
        return int((await session.execute(select(func.count()).select_from(model))).scalar_one())


async def test_seed_loads_full_tree(clean_db: None, payload: TaxonomyFile) -> None:
    expected = expected_counts(payload)

    report = await seed_taxonomy(get_settings().taxonomy_file)

    assert report.professions.created == expected["professions"]
    assert report.specializations.created == expected["specializations"]
    assert report.topics.created == expected["topics"]
    assert report.subtopics.created == expected["subtopics"]
    assert report.weights.created == expected["weights"]

    assert await _count(Profession) == expected["professions"]
    assert await _count(Specialization) == expected["specializations"]
    assert await _count(Topic) == expected["topics"]
    assert await _count(Subtopic) == expected["subtopics"]
    assert await _count(TopicWeight) == expected["weights"]


async def test_active_specializations_match_yaml(clean_db: None, payload: TaxonomyFile) -> None:
    expected = sorted(
        spec.id
        for profession in payload.professions
        for spec in profession.specializations
        if spec.is_active
    )
    await seed_taxonomy(get_settings().taxonomy_file)

    async with get_session_factory()() as session:
        active = sorted(
            await session.scalars(select(Specialization.id).where(Specialization.is_active))
        )

    assert active == expected
    # backend_python активна всегда: на ней держится приёмка остальных этапов.
    assert "backend_python" in active


async def test_active_specialization_always_has_topics(
    clean_db: None, payload: TaxonomyFile
) -> None:
    """Активная специализация без тем — пустой экран у пользователя."""
    await seed_taxonomy(get_settings().taxonomy_file)

    async with get_session_factory()() as session:
        rows = (
            await session.execute(
                select(Specialization.id, func.count(Topic.id))
                .outerjoin(Topic, Topic.specialization_id == Specialization.id)
                .where(Specialization.is_active)
                .group_by(Specialization.id)
            )
        ).all()

    assert rows, "не найдено ни одной активной специализации"
    for specialization_id, topic_count in rows:
        assert topic_count > 0, f"{specialization_id}: активна, но разделов нет"


async def test_seed_is_idempotent(clean_db: None, payload: TaxonomyFile) -> None:
    """Приёмка этапа 1: повторный запуск не создаёт дублей и ничего не меняет."""
    path = get_settings().taxonomy_file
    expected = expected_counts(payload)
    await seed_taxonomy(path)

    second = await seed_taxonomy(path)

    assert not second.has_changes, second.as_lines()
    assert await _count(Profession) == expected["professions"]
    assert await _count(Specialization) == expected["specializations"]
    assert await _count(Topic) == expected["topics"]
    assert await _count(Subtopic) == expected["subtopics"]
    assert await _count(TopicWeight) == expected["weights"]


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


async def test_seed_removes_entries_absent_in_yaml(clean_db: None, payload: TaxonomyFile) -> None:
    """YAML — источник истины: лишнее из базы уезжает."""
    path = get_settings().taxonomy_file
    await seed_taxonomy(path)

    async with get_session_factory()() as session:
        session.add(Profession(id="astrology", title="Астролог", sort_order=99))
        await session.commit()

    report = await seed_taxonomy(path)

    assert report.professions.deleted == 1
    assert await _count(Profession) == len(payload.professions)


async def test_weights_match_yaml(clean_db: None, payload: TaxonomyFile) -> None:
    await seed_taxonomy(get_settings().taxonomy_file)

    # Ключ обязан включать специализацию: код раздела вроде db повторяется
    # в разных стеках, и без этого веса схлопнулись бы друг на друга.
    expected = {
        (specialization_id, topic.code): topic.weights_by_grade()
        for specialization_id, topics in payload.topics.items()
        for topic in topics
    }

    async with get_session_factory()() as session:
        rows = (
            await session.execute(
                select(
                    Topic.specialization_id, Topic.code, TopicWeight.grade, TopicWeight.weight
                ).join(TopicWeight, TopicWeight.topic_id == Topic.id)
            )
        ).all()

    stored: dict[tuple[str, str], dict[int, float]] = {}
    for specialization_id, code, grade, weight in rows:
        stored.setdefault((specialization_id, code), {})[grade] = weight

    assert stored == expected


async def test_system_design_outweighs_language_for_senior(
    clean_db: None, payload: TaxonomyFile
) -> None:
    """Инвариант из CLAUDE.md §3.5, а не деталь одной специализации."""
    await seed_taxonomy(get_settings().taxonomy_file)
    senior = GRADE_VALUES["senior"]

    async with get_session_factory()() as session:
        rows = (
            await session.execute(
                select(Topic.specialization_id, Topic.code, TopicWeight.weight)
                .join(TopicWeight, TopicWeight.topic_id == Topic.id)
                .where(TopicWeight.grade == senior)
            )
        ).all()

    weights = {(spec, code): weight for spec, code, weight in rows}
    specializations = {spec for spec, _ in weights}

    for specialization in specializations:
        design = weights.get((specialization, "system_design"))
        language = weights.get((specialization, "language"))
        if design is None or language is None:
            continue
        assert design > language, f"{specialization}: для senior системный дизайн весит не больше"


async def test_tree_is_ordered_and_nested(clean_db: None, payload: TaxonomyFile) -> None:
    await seed_taxonomy(get_settings().taxonomy_file)

    async with get_session_factory()() as session:
        tree = await TaxonomyService(session).get_tree()

    # Порядок в дереве повторяет порядок в файле — он осмысленный, а не случайный.
    assert [profession.id for profession in tree] == [
        profession.id for profession in payload.professions
    ]
    python = next(spec for spec in tree[0].specializations if spec.id == "backend_python")
    expected_topics = [topic.code for topic in payload.topics["backend_python"]]
    assert [topic.code for topic in python.topics] == expected_topics
    assert next(subtopic.code for subtopic in python.topics[0].subtopics) == "gil"


async def test_taxonomy_endpoint_returns_tree(
    clean_db: None, client: AsyncClient, payload: TaxonomyFile
) -> None:
    await seed_taxonomy(get_settings().taxonomy_file)

    response = await client.get("/api/v1/taxonomy")

    assert response.status_code == 200
    body = response.json()
    assert len(body["professions"]) == len(payload.professions)
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
    python = next(spec for spec in backend["specializations"] if spec["id"] == "backend_python")
    assert python["is_active"] is True
    assert len(python["topics"]) == len(payload.topics["backend_python"])

    # У неактивной специализации тем нет — она показывается как «скоро».
    # Ищем по всему дереву: банк вопросов растёт, и внутри одной профессии
    # неактивных специализаций может не остаться вовсе.
    inactive = [
        spec
        for profession in body["professions"]
        for spec in profession["specializations"]
        if not spec["is_active"]
    ]
    for spec in inactive:
        assert spec["topics"] == [], f"{spec['id']}: неактивна, но разделы отдаются наружу"
