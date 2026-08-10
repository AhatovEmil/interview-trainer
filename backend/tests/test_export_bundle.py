"""Сборка контента для приложения.

Приложение работает без сервера, и этот файл — единственный источник вопросов
на устройстве. Если он разъедется с /content, пользователь увидит устаревший
банк, и заметить это будет нечем.
"""

from __future__ import annotations

import json
from pathlib import Path

import pytest

from app.core.grades import ALL_GRADES
from app.seed.export_bundle import DEFAULT_OUTPUT, build


@pytest.fixture(scope="module")
def bundle(tmp_path_factory: pytest.TempPathFactory) -> dict:
    target = tmp_path_factory.mktemp("bundle") / "bank.json"
    build(target)
    return json.loads(target.read_text(encoding="utf-8"))


def test_bundle_carries_questions_and_taxonomy(bundle: dict) -> None:
    assert bundle["questions"], "банк пуст"
    assert bundle["taxonomy"]["professions"], "таксономия пуста"
    assert len(bundle["taxonomy"]["grades"]) == len(ALL_GRADES)


def test_questions_carry_everything_needed_offline(bundle: dict) -> None:
    """Без разбора и правильности вариантов офлайн нечего показать после ответа."""
    question = bundle["questions"][0]

    assert question["answer_short"]
    assert question["answer_detailed"]
    assert question["topic_title"]
    assert question["difficulty_rating"] > 0
    for option in question["options"]:
        assert "is_correct" in option


def test_active_specializations_carry_topics_with_weights(bundle: dict) -> None:
    """Веса нужны на устройстве: по ним считается оценка уровня и план."""
    active = [
        specialization
        for profession in bundle["taxonomy"]["professions"]
        for specialization in profession["specializations"]
        if specialization["is_active"]
    ]
    assert active

    for specialization in active:
        assert specialization["topics"], f"{specialization['id']}: активна, но разделов нет"
        for topic in specialization["topics"]:
            assert len(topic["weights"]) == len(ALL_GRADES)
            assert topic["subtopics"]


def test_inactive_specializations_carry_no_topics(bundle: dict) -> None:
    inactive = [
        specialization
        for profession in bundle["taxonomy"]["professions"]
        for specialization in profession["specializations"]
        if not specialization["is_active"]
    ]

    for specialization in inactive:
        assert specialization["topics"] == []


def test_every_question_belongs_to_a_known_specialization(bundle: dict) -> None:
    known = {
        specialization["id"]
        for profession in bundle["taxonomy"]["professions"]
        for specialization in profession["specializations"]
    }

    for question in bundle["questions"]:
        assert set(question["specializations"]) <= known, question["id"]


def test_nothing_is_marked_verified(bundle: dict) -> None:
    """Проверенным вопрос делает человек, а не сборка (CLAUDE.md §8.1)."""
    assert not any(question["is_verified"] for question in bundle["questions"])


def test_committed_bundle_is_up_to_date(tmp_path: Path) -> None:
    """Файл в репозитории должен совпадать с тем, что собирается из /content.

    Иначе правка в YAML не доедет до приложения: сборка берёт коммит, а не
    исходники, и расхождение обнаружится только по жалобам пользователей.
    """
    assert DEFAULT_OUTPUT.is_file(), (
        "нет собранного контента; выполните: python -m app.seed.export_bundle"
    )

    fresh = tmp_path / "bank.json"
    build(fresh)

    assert fresh.read_text(encoding="utf-8") == DEFAULT_OUTPUT.read_text(encoding="utf-8"), (
        "контент в mobile/assets устарел; пересоберите: python -m app.seed.export_bundle"
    )
