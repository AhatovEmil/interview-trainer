"""Валидация content/taxonomy.yaml. Без БД: проверяется только разбор и правила."""

import textwrap
from pathlib import Path

import pytest

from app.core.config import get_settings
from app.core.grades import ALL_GRADES, GRADE_VALUES
from app.seed.loader import ContentError, load_taxonomy

MINIMAL = """
version: 1
professions:
  - id: backend
    title: Backend-разработчик
    specializations:
      - id: backend_python
        title: Python
        is_active: true
      - id: backend_go
        title: Go
topics:
  backend_python:
    - code: language
      title: Язык
      weights: {intern: 1.0, junior: 1.0, junior_plus: 0.9, middle: 0.8,
                middle_plus: 0.7, senior: 0.6, lead: 0.5}
      subtopics:
        - code: gil
          title: GIL
"""


def write(tmp_path: Path, body: str) -> Path:
    path = tmp_path / "taxonomy.yaml"
    path.write_text(textwrap.dedent(body), encoding="utf-8")
    return path


def test_minimal_file_parses(tmp_path: Path) -> None:
    payload = load_taxonomy(write(tmp_path, MINIMAL))

    assert payload.version == 1
    assert [p.id for p in payload.professions] == ["backend"]
    assert payload.topics["backend_python"][0].weights_by_grade() == {
        GRADE_VALUES["intern"]: 1.0,
        GRADE_VALUES["junior"]: 1.0,
        GRADE_VALUES["junior_plus"]: 0.9,
        GRADE_VALUES["middle"]: 0.8,
        GRADE_VALUES["middle_plus"]: 0.7,
        GRADE_VALUES["senior"]: 0.6,
        GRADE_VALUES["lead"]: 0.5,
    }


def test_inactive_by_default(tmp_path: Path) -> None:
    payload = load_taxonomy(write(tmp_path, MINIMAL))
    specializations = {s.id: s for s in payload.professions[0].specializations}

    assert specializations["backend_python"].is_active is True
    assert specializations["backend_go"].is_active is False


def test_missing_file(tmp_path: Path) -> None:
    with pytest.raises(ContentError, match="файл не найден"):
        load_taxonomy(tmp_path / "нет-такого.yaml")


def test_broken_yaml(tmp_path: Path) -> None:
    with pytest.raises(ContentError, match="некорректный YAML"):
        load_taxonomy(write(tmp_path, "version: 1\n  professions: [\n"))


def test_empty_file(tmp_path: Path) -> None:
    with pytest.raises(ContentError, match="файл пуст"):
        load_taxonomy(write(tmp_path, "\n"))


def test_missing_weight_for_grade(tmp_path: Path) -> None:
    body = MINIMAL.replace("middle_plus: 0.7,", "")

    with pytest.raises(ContentError, match="нет весов для грейдов middle_plus"):
        load_taxonomy(write(tmp_path, body))


def test_unknown_grade_in_weights(tmp_path: Path) -> None:
    body = MINIMAL.replace("lead: 0.5}", "lead: 0.5, principal: 0.4}")

    with pytest.raises(ContentError, match="неизвестные грейды principal"):
        load_taxonomy(write(tmp_path, body))


def test_weight_out_of_range(tmp_path: Path) -> None:
    body = MINIMAL.replace("senior: 0.6", "senior: 1.4")

    with pytest.raises(ContentError, match="допустимый диапазон"):
        load_taxonomy(write(tmp_path, body))


def test_topics_for_unknown_specialization(tmp_path: Path) -> None:
    body = MINIMAL.replace("  backend_python:\n", "  backend_rust:\n")

    with pytest.raises(ContentError, match="неизвестной специализации 'backend_rust'"):
        load_taxonomy(write(tmp_path, body))


def test_active_specialization_without_topics(tmp_path: Path) -> None:
    # Темы объявлены для неактивной backend_go, активная backend_python осталась пустой.
    body = MINIMAL.replace("  backend_python:\n", "  backend_go:\n")

    with pytest.raises(ContentError, match="активная специализация 'backend_python'"):
        load_taxonomy(write(tmp_path, body))


def test_duplicate_subtopic_codes(tmp_path: Path) -> None:
    body = MINIMAL + "        - code: gil\n          title: GIL ещё раз\n"

    with pytest.raises(ContentError, match="повторяющиеся коды тем: gil"):
        load_taxonomy(write(tmp_path, body))


def test_code_format_is_enforced(tmp_path: Path) -> None:
    body = MINIMAL.replace("code: language", "code: Язык-Раздел")

    with pytest.raises(ContentError, match="String should match pattern"):
        load_taxonomy(write(tmp_path, body))


def test_unknown_field_rejected(tmp_path: Path) -> None:
    body = MINIMAL.replace("version: 1", "version: 1\nunexpected: true")

    with pytest.raises(ContentError, match="Extra inputs are not permitted"):
        load_taxonomy(write(tmp_path, body))


# --- Реальный файл проекта -------------------------------------------------------


def test_project_taxonomy_is_valid() -> None:
    """content/taxonomy.yaml должен грузиться всегда: на нём стоит сид."""
    payload = load_taxonomy(get_settings().taxonomy_file)

    professions = {p.id: p for p in payload.professions}
    assert set(professions) == {
        "backend",
        "frontend",
        "mobile",
        "qa",
        "data",
        "infra",
        "enterprise",
        "analysis",
    }

    specializations = {
        spec.id: spec for profession in payload.professions for spec in profession.specializations
    }
    assert len(specializations) == 22
    active = [spec_id for spec_id, spec in specializations.items() if spec.is_active]
    assert active == ["backend_python"], "в MVP активна только backend_python"

    topics = payload.topics["backend_python"]
    assert [topic.code for topic in topics] == [
        "language",
        "async",
        "db",
        "web",
        "architecture",
        "system_design",
        "infra",
        "algorithms",
        "soft",
    ]
    assert sum(len(topic.subtopics) for topic in topics) == 44

    for topic in topics:
        assert set(topic.weights_by_grade()) == set(ALL_GRADES)


def test_system_design_outweighs_language_for_senior() -> None:
    """Проверка смысла весов, а не только формата (пример прямо из CLAUDE.md §3.5)."""
    payload = load_taxonomy(get_settings().taxonomy_file)
    by_code = {topic.code: topic.weights_by_grade() for topic in payload.topics["backend_python"]}

    senior, junior = GRADE_VALUES["senior"], GRADE_VALUES["junior"]
    assert by_code["system_design"][senior] > by_code["language"][senior]
    assert by_code["language"][junior] > by_code["system_design"][junior]
