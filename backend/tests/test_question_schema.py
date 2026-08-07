"""Валидация банка вопросов. Без БД: разбор YAML и правила из приёмки этапа 2."""

import textwrap
from collections import Counter
from pathlib import Path

import pytest

from app.core.config import get_settings
from app.core.enums import QuestionSource, QuestionType
from app.seed.loader import ContentError, load_questions, load_taxonomy

MINIMAL = """
version: 1
questions:
  - slug: gil_basics
    specializations: [backend_python]
    topic: language
    subtopic: gil
    min_grade: junior
    peak_grade: middle
    max_grade: senior
    frequency: 5
    type: open_answer
    title: Что такое GIL?
    answer_short: Мьютекс интерпретатора, из-за которого байткод исполняет один поток.
    answer_detailed: |
      ### Junior
      Одна блокировка на интерпретатор.

      ### Middle
      Освобождается на время I/O.

      ### Senior
      Переключение по интервалу.
"""


def write(tmp_path: Path, body: str) -> Path:
    path = tmp_path / "questions.yaml"
    path.write_text(textwrap.dedent(body), encoding="utf-8")
    return path


def test_minimal_file_parses(tmp_path: Path) -> None:
    payload = load_questions(write(tmp_path, MINIMAL))

    question = payload.questions[0]
    assert question.slug == "gil_basics"
    assert question.type is QuestionType.OPEN_ANSWER
    assert question.source is QuestionSource.SEED
    assert question.grades() == (1, 3, 5)


def test_uuid_is_stable_for_slug(tmp_path: Path) -> None:
    """id вопроса выводится из slug, поэтому одинаков в любой базе."""
    first = load_questions(write(tmp_path, MINIMAL)).questions[0]
    second = load_questions(write(tmp_path, MINIMAL)).questions[0]

    assert first.uuid == second.uuid


def test_grade_order_is_enforced(tmp_path: Path) -> None:
    body = MINIMAL.replace("peak_grade: middle", "peak_grade: lead")

    with pytest.raises(ContentError, match="нарушен порядок грейдов"):
        load_questions(write(tmp_path, body))


def test_unknown_grade_code(tmp_path: Path) -> None:
    body = MINIMAL.replace("min_grade: junior", "min_grade: novice")

    with pytest.raises(ContentError, match="min_grade='novice'"):
        load_questions(write(tmp_path, body))


def test_empty_answer_short(tmp_path: Path) -> None:
    body = MINIMAL.replace(
        "answer_short: Мьютекс интерпретатора, из-за которого байткод исполняет один поток.",
        'answer_short: ""',
    )

    with pytest.raises(ContentError, match="answer_short"):
        load_questions(write(tmp_path, body))


def test_open_answer_requires_three_level_blocks(tmp_path: Path) -> None:
    body = MINIMAL.replace("      ### Senior\n      Переключение по интервалу.\n", "")

    with pytest.raises(ContentError, match="нет уровневых блоков Senior"):
        load_questions(write(tmp_path, body))


def test_short_answer_does_not_need_level_blocks(tmp_path: Path) -> None:
    body = MINIMAL.replace("type: open_answer", "type: short_answer")
    body = body.replace("      ### Senior\n      Переключение по интервалу.\n", "")

    payload = load_questions(write(tmp_path, body))

    assert payload.questions[0].type is QuestionType.SHORT_ANSWER


def test_single_choice_requires_exactly_one_correct(tmp_path: Path) -> None:
    body = (
        MINIMAL.replace("type: open_answer", "type: single_choice")
        + """
    options:
      - code: a
        text: Первый
        is_correct: true
      - code: b
        text: Второй
        is_correct: true
"""
    )

    with pytest.raises(ContentError, match="ровно один верный вариант, найдено 2"):
        load_questions(write(tmp_path, body))


def test_open_answer_cannot_have_options(tmp_path: Path) -> None:
    body = (
        MINIMAL
        + """
    options:
      - code: a
        text: Первый
      - code: b
        text: Второй
"""
    )

    with pytest.raises(ContentError, match="не может быть вариантов"):
        load_questions(write(tmp_path, body))


def test_duplicate_slugs_rejected(tmp_path: Path) -> None:
    body = MINIMAL + MINIMAL.split("questions:")[1]

    with pytest.raises(ContentError, match="повторяющиеся slug: gil_basics"):
        load_questions(write(tmp_path, body))


def test_frequency_out_of_range(tmp_path: Path) -> None:
    body = MINIMAL.replace("frequency: 5", "frequency: 9")

    with pytest.raises(ContentError, match="frequency"):
        load_questions(write(tmp_path, body))


# --- Кросс-проверка со ссылками на таксономию ------------------------------------


def taxonomy():
    return load_taxonomy(get_settings().taxonomy_file)


def test_unknown_topic_rejected(tmp_path: Path) -> None:
    body = MINIMAL.replace("topic: language", "topic: quantum")

    with pytest.raises(ContentError, match="раздел 'quantum' не найден"):
        load_questions(write(tmp_path, body), taxonomy())


def test_unknown_subtopic_rejected(tmp_path: Path) -> None:
    body = MINIMAL.replace("subtopic: gil", "subtopic: monads")

    with pytest.raises(ContentError, match="тема 'monads' не найдена"):
        load_questions(write(tmp_path, body), taxonomy())


def test_unknown_specialization_rejected(tmp_path: Path) -> None:
    body = MINIMAL.replace("specializations: [backend_python]", "specializations: [backend_rust]")

    with pytest.raises(ContentError, match="неизвестная специализация 'backend_rust'"):
        load_questions(write(tmp_path, body), taxonomy())


# --- Реальный банк проекта -------------------------------------------------------


def project_questions():
    return load_questions(get_settings().questions_dir / "backend_python.yaml", taxonomy())


def test_project_bank_has_thirty_questions() -> None:
    payload = project_questions()

    assert len(payload.questions) == 30


def test_project_bank_covers_all_topics() -> None:
    """Приёмка этапа 2: вопросы распределены по темам, а не свалены в одну."""
    by_topic = Counter(question.topic for question in project_questions().questions)

    assert set(by_topic) == {
        "language",
        "async",
        "db",
        "web",
        "architecture",
        "system_design",
        "infra",
        "algorithms",
        "soft",
    }
    assert min(by_topic.values()) >= 2


def test_project_bank_spreads_across_grades() -> None:
    peaks = {question.grades()[1] for question in project_questions().questions}

    assert len(peaks) >= 4, "пиковые грейды должны покрывать диапазон, а не один уровень"


def test_project_bank_uses_all_question_types() -> None:
    types = {question.type for question in project_questions().questions}

    assert types == set(QuestionType)


def test_project_bank_is_seed_sourced() -> None:
    assert all(question.source is QuestionSource.SEED for question in project_questions().questions)
