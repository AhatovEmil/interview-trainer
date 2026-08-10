"""Повторный сид не должен стирать накопленную сложность вопросов."""

import os

import pytest
from sqlalchemy import select

from app.core.config import get_settings
from app.db.models.question import Question
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
async def seeded(clean_db: None) -> None:
    await seed_taxonomy(get_settings().taxonomy_file)
    await seed_questions()


async def _any_question() -> Question:
    async with get_session_factory()() as session:
        question = (await session.scalars(select(Question).limit(1))).one()
        return question


async def test_second_seed_keeps_drifted_difficulty(seeded: None) -> None:
    """Сид запускается на старте контейнера — он не вправе сбрасывать Elo."""
    async with get_session_factory()() as session:
        question = (await session.scalars(select(Question).limit(1))).one()
        question_id = question.id
        original = question.difficulty_rating
        # Имитируем дрейф от ответов пользователей.
        question.difficulty_rating = original + 57
        await session.commit()

    report = await seed_questions()

    async with get_session_factory()() as session:
        again = await session.get(Question, question_id)
        assert again is not None
        assert again.difficulty_rating == original + 57, (
            "повторный сид вернул стартовое значение и стёр накопленную сложность"
        )
    # Прочие поля при этом не разъезжаются: изменений быть не должно.
    assert report.questions.deleted == 0


async def test_first_seed_sets_difficulty_from_peak_grade(seeded: None) -> None:
    async with get_session_factory()() as session:
        rows = list(await session.scalars(select(Question)))

    assert rows, "банк вопросов пуст"
    for question in rows:
        # 1000 + peak_grade * 130 по CLAUDE.md §3.5.
        assert question.difficulty_rating == 1000 + question.peak_grade * 130
