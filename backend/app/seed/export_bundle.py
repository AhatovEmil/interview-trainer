"""Сборка контента в один файл для приложения.

    python -m app.seed.export_bundle

Приложение работает без сервера, поэтому таксономия и банк вопросов едут
внутри установочного пакета. Файл собирается теми же загрузчиками, что и сид в
базу: битый YAML роняет сборку здесь, а не превращается в пустой экран у
пользователя.

Формат намеренно повторяет ответы API (`schemas/sync.py` и `schemas/taxonomy.py`):
разбор на стороне приложения уже написан под них, и при возврате синхронизации
между устройствами менять его не придётся.
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any

from app.core.config import get_settings
from app.core.grades import ALL_GRADES, GRADE_TITLES, GRADE_VALUES, code_from_grade
from app.db.models.question import difficulty_from_peak_grade
from app.seed.loader import load_questions, load_taxonomy
from app.seed.question_schema import QuestionIn, question_id
from app.seed.schema import TaxonomyFile

# Файл кладётся в ресурсы приложения и коммитится: сборка в CI не должна
# зависеть от установленного Python и содержимого /content.
DEFAULT_OUTPUT = Path(__file__).resolve().parents[3] / "mobile" / "assets" / "content" / "bank.json"


def _grades() -> list[dict[str, Any]]:
    return [
        {"value": grade, "code": code_from_grade(grade), "title": GRADE_TITLES[grade]}
        for grade in ALL_GRADES
    ]


def _topics(taxonomy: TaxonomyFile, specialization_id: str) -> list[dict[str, Any]]:
    return [
        {
            "code": topic.code,
            "title": topic.title,
            # Веса нужны на устройстве: по ним считается общая оценка уровня и
            # приоритет тем в плане подготовки.
            "weights": {str(grade): weight for grade, weight in topic.weights_by_grade().items()},
            "subtopics": [
                {"code": subtopic.code, "title": subtopic.title} for subtopic in topic.subtopics
            ],
        }
        for topic in taxonomy.topics.get(specialization_id, [])
    ]


def _taxonomy_payload(taxonomy: TaxonomyFile) -> dict[str, Any]:
    return {
        "professions": [
            {
                "id": profession.id,
                "title": profession.title,
                "specializations": [
                    {
                        "id": specialization.id,
                        "title": specialization.title,
                        "is_active": specialization.is_active,
                        # У неактивной специализации разделов наружу нет: она
                        # показывается как «скоро».
                        "topics": (
                            _topics(taxonomy, specialization.id) if specialization.is_active else []
                        ),
                    }
                    for specialization in profession.specializations
                ],
            }
            for profession in taxonomy.professions
        ],
        "grades": _grades(),
    }


def _question_payload(
    question: QuestionIn,
    topic_titles: dict[str, str],
    subtopic_titles: dict[str, str],
) -> dict[str, Any]:
    peak_grade = GRADE_VALUES[question.peak_grade]
    return {
        "id": str(question_id(question.slug)),
        "specializations": list(question.specializations),
        "type": question.type.value,
        "title": question.title,
        "topic_code": question.topic,
        "topic_title": topic_titles.get(question.topic, question.topic),
        "subtopic_code": question.subtopic,
        "subtopic_title": (
            subtopic_titles.get(question.subtopic, question.subtopic) if question.subtopic else None
        ),
        "min_grade": GRADE_VALUES[question.min_grade],
        "peak_grade": peak_grade,
        "max_grade": GRADE_VALUES[question.max_grade],
        "frequency": question.frequency,
        # Стартовая сложность выводится из пикового грейда так же, как на
        # сервере: на устройстве накопленной статистики нет.
        "difficulty_rating": question.difficulty_rating or difficulty_from_peak_grade(peak_grade),
        "options": [
            {"code": option.code, "text": option.text, "is_correct": option.is_correct}
            for option in question.options
        ],
        # Проверенным вопрос делает человек, сид этого не решает (CLAUDE.md §8.1).
        "is_verified": False,
        "answer_short": question.answer_short,
        "answer_detailed": question.answer_detailed,
        "common_mistakes": list(question.common_mistakes),
        "follow_ups": list(question.follow_ups),
    }


def build(output: Path | None = None) -> Path:
    settings = get_settings()
    taxonomy = load_taxonomy(settings.taxonomy_file)

    titles: dict[str, dict[str, str]] = {"topics": {}, "subtopics": {}}
    for topics in taxonomy.topics.values():
        for topic in topics:
            titles["topics"][topic.code] = topic.title
            for subtopic in topic.subtopics:
                titles["subtopics"][subtopic.code] = subtopic.title

    questions: list[dict[str, Any]] = []
    for path in sorted(settings.questions_dir.glob("*.yaml")):
        for question in load_questions(path, taxonomy).questions:
            questions.append(_question_payload(question, titles["topics"], titles["subtopics"]))

    payload = {
        "version": 1,
        "taxonomy": _taxonomy_payload(taxonomy),
        "questions": questions,
    }

    target = output or DEFAULT_OUTPUT
    target.parent.mkdir(parents=True, exist_ok=True)
    # Отступы и сортировка ключей — чтобы diff в git был читаемым, а проверка
    # свежести в CI сравнивала содержимое, а не порядок полей.
    #
    # Перевод строки задан явно: на Windows запись в текстовом режиме подставила
    # бы CRLF, и файл, собранный там и в CI, отличался бы каждым байтом перевода
    # строки. Проверка свежести на этом бы и падала.
    with target.open("w", encoding="utf-8", newline="\n") as handle:
        handle.write(json.dumps(payload, ensure_ascii=False, indent=1, sort_keys=True) + "\n")
    return target


def main() -> None:
    target = build()
    size_mb = target.stat().st_size / 1024 / 1024
    payload = json.loads(target.read_text(encoding="utf-8"))
    active = [
        specialization["id"]
        for profession in payload["taxonomy"]["professions"]
        for specialization in profession["specializations"]
        if specialization["is_active"]
    ]
    print(f"Контент собран: {target}")
    print(f"  вопросов:       {len(payload['questions'])}")
    print(f"  специализаций:  {len(active)} активных")
    print(f"  размер:         {size_mb:.1f} МБ")


if __name__ == "__main__":
    main()
