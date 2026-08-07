"""Сид банка вопросов на живой базе: полнота, идемпотентность, связи и флаги."""

import os
import uuid

import pytest
from sqlalchemy import func, select

from app.core.config import get_settings
from app.core.enums import QuestionSource, QuestionType
from app.db.models.question import Question, QuestionOption, difficulty_from_peak_grade
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


@pytest.fixture
async def seeded_taxonomy(clean_db: None) -> None:
    await seed_taxonomy(get_settings().taxonomy_file)


async def _count(model: type) -> int:
    async with get_session_factory()() as session:
        return int((await session.execute(select(func.count()).select_from(model))).scalar_one())


async def test_seed_loads_thirty_questions(seeded_taxonomy: None) -> None:
    report = await seed_questions()

    assert report.questions.created == 30
    assert await _count(Question) == 30


async def test_all_questions_are_unverified(seeded_taxonomy: None) -> None:
    """Приёмка этапа 2: всё, что пришло из сида, не проверено человеком."""
    await seed_questions()

    async with get_session_factory()() as session:
        verified = (
            await session.execute(
                select(func.count()).select_from(Question).where(Question.is_verified.is_(True))
            )
        ).scalar_one()
        sources = set(await session.scalars(select(Question.source).distinct()))

    assert verified == 0
    assert sources == {QuestionSource.SEED}


async def test_seed_is_idempotent(seeded_taxonomy: None) -> None:
    await seed_questions()

    second = await seed_questions()

    assert not second.has_changes, second.as_lines()
    assert await _count(Question) == 30
    assert await _count(QuestionOption) == 28


async def test_difficulty_derived_from_peak_grade(seeded_taxonomy: None) -> None:
    await seed_questions()

    async with get_session_factory()() as session:
        rows = (
            await session.execute(select(Question.peak_grade, Question.difficulty_rating))
        ).all()

    assert rows
    for peak_grade, difficulty in rows:
        assert difficulty == difficulty_from_peak_grade(peak_grade)


async def test_questions_linked_to_specialization(seeded_taxonomy: None) -> None:
    await seed_questions()

    async with get_session_factory()() as session:
        question = (
            await session.scalars(select(Question).where(Question.slug == "gil_what_is_and_impact"))
        ).one()
        specializations = [row.id for row in question.specializations]

    assert specializations == ["backend_python"]
    assert question.topic_code == "language"
    assert question.subtopic_code == "gil"


async def test_choice_questions_have_options(seeded_taxonomy: None) -> None:
    await seed_questions()

    async with get_session_factory()() as session:
        questions = list(
            await session.scalars(
                select(Question).where(
                    Question.type.in_([QuestionType.SINGLE_CHOICE, QuestionType.MULTI_CHOICE])
                )
            )
        )

    assert questions
    for question in questions:
        assert len(question.options) >= 2, question.slug
        correct = [option for option in question.options if option.is_correct]
        if question.type is QuestionType.SINGLE_CHOICE:
            assert len(correct) == 1, question.slug
        else:
            assert len(correct) >= 2, question.slug


async def test_seed_updates_changed_question(seeded_taxonomy: None) -> None:
    await seed_questions()

    async with get_session_factory()() as session:
        question = (
            await session.scalars(select(Question).where(Question.slug == "gil_what_is_and_impact"))
        ).one()
        question.title = "Устаревшая формулировка"
        await session.commit()

    report = await seed_questions()

    assert report.questions.updated == 1
    async with get_session_factory()() as session:
        question = (
            await session.scalars(select(Question).where(Question.slug == "gil_what_is_and_impact"))
        ).one()
    assert question.title.startswith("Что такое GIL")


async def test_seed_keeps_crowdsourced_questions(seeded_taxonomy: None) -> None:
    """Присланное пользователями не управляется файлами и не должно удаляться сидом."""
    await seed_questions()

    async with get_session_factory()() as session:
        session.add(
            Question(
                id=uuid.uuid4(),
                slug="from_user_report",
                topic_code="language",
                subtopic_code=None,
                min_grade=1,
                peak_grade=3,
                max_grade=5,
                difficulty_rating=1390,
                frequency=1,
                type=QuestionType.SHORT_ANSWER,
                title="Вопрос с собеседования, присланный пользователем",
                answer_short="Ответ",
                answer_detailed="Разбор",
                common_mistakes=[],
                follow_ups=[],
                company_tags=[],
                is_verified=False,
                source=QuestionSource.CROWDSOURCED,
                specializations=[],
                options=[],
            )
        )
        await session.commit()

    report = await seed_questions()

    assert report.questions.deleted == 0
    assert await _count(Question) == 31
