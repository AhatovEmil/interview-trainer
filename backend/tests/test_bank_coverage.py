"""Покрытие банка вопросов по уровням.

Человек выбирает уровень, к которому готовится, и список фильтруется по нему.
Если на выбранном уровне вопросов нет, он упирается в пустой экран — а по
счётчикам в интерфейсе это видно сразу, поэтому дыра не прячется, она
выставлена напоказ.

Отсюда две проверки: сколько вопросов доступно на каждом грейде целиком и
сколько их в каждом разделе. Первая отвечает «есть ли что делать вообще»,
вторая — «не свалено ли всё в одну тему».

Тест читает YAML напрямую, без базы: это проверка контента, а не загрузчика,
и она должна падать до того, как сид что-то запишет.
"""

from __future__ import annotations

from collections import defaultdict

import pytest

from app.core.config import get_settings
from app.core.grades import ALL_GRADES, GRADE_JUNIOR, GRADE_MIDDLE, GRADE_SENIOR, GRADE_VALUES
from app.seed.loader import load_questions, load_taxonomy
from app.seed.question_schema import QuestionIn
from app.seed.schema import TaxonomyFile

# Сколько вопросов должно быть доступно на каждом грейде — от стажёра до лида.
# Двадцать: меньше означает, что за один вечер банк заканчивается, и человек
# видит одни и те же карточки на следующий день.
MIN_PER_GRADE = 20

# Разделы проверяются по трём опорным уровням, а не по всем семи: вопрос,
# покрывающий junior и middle, почти всегда покрывает junior+ между ними.
CHECKED_TOPIC_GRADES = (GRADE_JUNIOR, GRADE_MIDDLE, GRADE_SENIOR)
MIN_PER_TOPIC_GRADE = 3

# Специализации, к которым планка применяется. Список растёт по мере наполнения
# банков; специализация попадает сюда, когда доведена, и с этого момента
# просесть обратно уже не может.
COVERED = frozenset(
    {
        "backend_python",
        "backend_go",
        "backend_java",
    }
)

# Разделы, для которых требование по темам ослаблено. Поведенческую секцию не
# делят по грейдам так же жёстко: «расскажите про конфликт» спрашивают всех, а
# глубина ожидаемого ответа живёт в разборе, а не в отдельных вопросах.
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


def _suits(question: QuestionIn, grade: int) -> bool:
    return _grade(question.min_grade) <= grade <= _grade(question.max_grade)


@pytest.mark.parametrize("specialization_id", sorted(COVERED))
def test_every_grade_has_enough_questions(specialization_id: str, taxonomy: TaxonomyFile) -> None:
    """На любом выбранном уровне есть чем заниматься."""
    questions = _questions(specialization_id, taxonomy)
    assert questions, f"{specialization_id}: файла с вопросами нет"

    gaps: list[str] = []
    for grade in ALL_GRADES:
        found = sum(1 for question in questions if _suits(question, grade))
        if found < MIN_PER_GRADE:
            gaps.append(f"грейд {grade}: {found} из {MIN_PER_GRADE}")

    assert not gaps, "не хватает вопросов:\n  " + "\n  ".join(gaps)


@pytest.mark.parametrize("specialization_id", sorted(COVERED))
def test_every_topic_is_covered_on_every_grade(
    specialization_id: str, taxonomy: TaxonomyFile
) -> None:
    """Вопросы разложены по разделам, а не свалены в один-два.

    Без этой проверки планку по грейду можно закрыть двадцатью вопросами про
    язык, оставив базы данных и архитектуру пустыми.
    """
    questions = _questions(specialization_id, taxonomy)
    topics = [topic.code for topic in taxonomy.topics[specialization_id]]

    counts: dict[tuple[str, int], int] = defaultdict(int)
    for question in questions:
        for grade in CHECKED_TOPIC_GRADES:
            if _suits(question, grade):
                counts[(question.topic, grade)] += 1

    gaps: list[str] = []
    for topic in topics:
        required = MIN_RELAXED if topic in RELAXED_TOPICS else MIN_PER_TOPIC_GRADE
        for grade in CHECKED_TOPIC_GRADES:
            found = counts.get((topic, grade), 0)
            if found < required:
                gaps.append(f"{topic} на грейде {grade}: {found} из {required}")

    assert not gaps, "не хватает вопросов:\n  " + "\n  ".join(gaps)


@pytest.mark.parametrize("specialization_id", sorted(COVERED))
def test_grade_bands_are_not_all_the_same(specialization_id: str, taxonomy: TaxonomyFile) -> None:
    """Диапазоны не должны быть выставлены «на всякий случай» от 0 до 6.

    Планку по грейдам легко закрыть формально: поставить каждому вопросу
    диапазон во всю шкалу, и счётчики сойдутся. Но вопрос, уместный и стажёру,
    и лиду, — редкость, а не правило.
    """
    questions = _questions(specialization_id, taxonomy)

    everywhere = [
        question.slug
        for question in questions
        if _grade(question.min_grade) == 0 and _grade(question.max_grade) == 6
    ]

    assert not everywhere, "диапазон 0–6 обесценивает градацию: " + ", ".join(everywhere)


def test_active_specializations_are_covered_or_hidden(taxonomy: TaxonomyFile) -> None:
    """Активная специализация обязана быть доведена до планки.

    Иначе человек выбирает стек и упирается в пустые уровни. Не доведена —
    значит показывается как «скоро», а не выдаётся за готовую.
    """
    active = {
        specialization.id
        for profession in taxonomy.professions
        for specialization in profession.specializations
        if specialization.is_active
    }

    assert active <= COVERED, "активны, но не доведены до планки: " + ", ".join(
        sorted(active - COVERED)
    )


def test_covered_list_matches_reality(taxonomy: TaxonomyFile) -> None:
    """Список COVERED не должен ссылаться на несуществующие специализации."""
    known = {spec.id for profession in taxonomy.professions for spec in profession.specializations}

    assert COVERED <= known, f"неизвестные специализации: {sorted(COVERED - known)}"
