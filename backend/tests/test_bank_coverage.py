"""Покрытие банка вопросов по уровням.

Человек выбирает уровень, к которому готовится, и выдача считается от него.
Если в разделе на этот уровень нечего показать, продукт не работает — вместо
подготовки получается три вопроса и пустой экран.

Тест читает YAML напрямую, без базы: это проверка контента, а не загрузчика,
и она должна падать до того, как сид что-то запишет.
"""

from __future__ import annotations

from collections import defaultdict

import pytest

from app.core.config import get_settings
from app.core.grades import (
    GRADE_JUNIOR,
    GRADE_MIDDLE,
    GRADE_SENIOR,
    GRADE_VALUES,
)
from app.seed.loader import load_questions, load_taxonomy
from app.seed.question_schema import QuestionIn
from app.seed.schema import TaxonomyFile

# Уровни, по которым меряем покрытие. Промежуточные (junior+, middle+) отдельно
# не проверяются: вопрос, покрывающий junior и middle, почти всегда покрывает и
# junior+ между ними.
CHECKED_GRADES = (GRADE_JUNIOR, GRADE_MIDDLE, GRADE_SENIOR)

# Сколько вопросов должно найтись в разделе на каждый проверяемый уровень.
# Три — это минимум, при котором тренировка по теме не вырождается в один и тот
# же вопрос через день.
MIN_PER_TOPIC_GRADE = 3

# Специализации, к которым планка применяется. Список растёт по мере наполнения
# банков; специализация попадает сюда, когда её банк доведён до планки, и с
# этого момента просесть обратно уже не может.
COVERED = frozenset(
    {
        "backend_python",
        "backend_go",
    }
)

# Разделы, для которых требование ослаблено. Поведенческую секцию не делят по
# грейдам так же жёстко: «расскажите про конфликт» спрашивают всех, а глубина
# ожидаемого ответа живёт в разборе, а не в отдельных вопросах.
RELAXED_TOPICS = frozenset({"soft"})
MIN_RELAXED = 2


@pytest.fixture(scope="module")
def taxonomy() -> TaxonomyFile:
    return load_taxonomy(get_settings().taxonomy_file)


def _questions(specialization_id: str, taxonomy: TaxonomyFile) -> list[QuestionIn]:
    path = get_settings().questions_dir / f"{specialization_id}.yaml"
    if not path.exists():
        return []
    return [
        question
        for question in load_questions(path, taxonomy).questions
        if specialization_id in question.specializations
    ]


def _grade(code: str) -> int:
    return GRADE_VALUES[code]


def _coverage(questions: list[QuestionIn]) -> dict[tuple[str, int], int]:
    """Сколько вопросов в разделе попадает в выдачу на каждом уровне."""
    counts: dict[tuple[str, int], int] = defaultdict(int)
    for question in questions:
        low = _grade(question.min_grade)
        high = _grade(question.max_grade)
        for grade in CHECKED_GRADES:
            if low <= grade <= high:
                counts[(question.topic, grade)] += 1
    return counts


@pytest.mark.parametrize("specialization_id", sorted(COVERED))
def test_every_topic_is_covered_on_every_grade(
    specialization_id: str, taxonomy: TaxonomyFile
) -> None:
    questions = _questions(specialization_id, taxonomy)
    assert questions, f"{specialization_id}: файла с вопросами нет"

    topics = [topic.code for topic in taxonomy.topics[specialization_id]]
    counts = _coverage(questions)

    gaps: list[str] = []
    for topic in topics:
        required = MIN_RELAXED if topic in RELAXED_TOPICS else MIN_PER_TOPIC_GRADE
        for grade in CHECKED_GRADES:
            found = counts.get((topic, grade), 0)
            if found < required:
                gaps.append(f"{topic} на грейде {grade}: {found} из {required}")

    assert not gaps, "не хватает вопросов:\n  " + "\n  ".join(gaps)


@pytest.mark.parametrize("specialization_id", sorted(COVERED))
def test_grade_bands_are_not_all_the_same(specialization_id: str, taxonomy: TaxonomyFile) -> None:
    """Диапазоны не должны быть выставлены «на всякий случай» от 0 до 6.

    Вопрос, доступный всем грейдам сразу, — признак того, что автор не думал
    про уровень, а покрытие получается формальным.
    """
    questions = _questions(specialization_id, taxonomy)

    everywhere = [
        question.slug
        for question in questions
        if _grade(question.min_grade) == 0 and _grade(question.max_grade) == 6
    ]

    assert not everywhere, "диапазон 0–6 обесценивает градацию: " + ", ".join(everywhere)


def test_covered_list_matches_reality(taxonomy: TaxonomyFile) -> None:
    """Список COVERED не должен ссылаться на несуществующие специализации."""
    known = {spec.id for profession in taxonomy.professions for spec in profession.specializations}

    assert COVERED <= known, f"неизвестные специализации: {sorted(COVERED - known)}"
