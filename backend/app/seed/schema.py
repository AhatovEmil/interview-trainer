"""Схема файла content/taxonomy.yaml.

Валидация живёт здесь: битый YAML должен падать с внятной ошибкой до похода в БД.
"""

from __future__ import annotations

from typing import Annotated, Self

from pydantic import BaseModel, ConfigDict, Field, StringConstraints, model_validator

from app.core.grades import ALL_GRADES, GRADE_VALUES

# Коды используются в URL, YAML вопросов и ключах кеша — только snake_case.
Code = Annotated[str, StringConstraints(pattern=r"^[a-z][a-z0-9_]{1,63}$")]
Title = Annotated[str, StringConstraints(min_length=1, max_length=128, strip_whitespace=True)]


class StrictModel(BaseModel):
    model_config = ConfigDict(extra="forbid")


class SubtopicIn(StrictModel):
    code: Code
    title: Title


class TopicIn(StrictModel):
    code: Code
    title: Title
    weights: dict[str, float]
    subtopics: list[SubtopicIn] = Field(min_length=1)

    @model_validator(mode="after")
    def check_weights_and_subtopics(self) -> Self:
        missing = sorted(set(GRADE_VALUES) - set(self.weights))
        if missing:
            raise ValueError(f"раздел {self.code!r}: нет весов для грейдов {', '.join(missing)}")

        unknown = sorted(set(self.weights) - set(GRADE_VALUES))
        if unknown:
            raise ValueError(f"раздел {self.code!r}: неизвестные грейды {', '.join(unknown)}")

        for grade_code, weight in self.weights.items():
            if not 0.0 <= weight <= 1.0:
                raise ValueError(
                    f"раздел {self.code!r}: вес для {grade_code} = {weight}, "
                    "допустимый диапазон 0.0–1.0"
                )

        reject_duplicates(
            [subtopic.code for subtopic in self.subtopics],
            f"раздел {self.code!r}: повторяющиеся коды тем",
        )
        return self

    def weights_by_grade(self) -> dict[int, float]:
        """Веса, переведённые из кодов грейдов в числовую шкалу."""
        return {GRADE_VALUES[code]: weight for code, weight in self.weights.items()}


class SpecializationIn(StrictModel):
    id: Code
    title: Title
    is_active: bool = False


class ProfessionIn(StrictModel):
    id: Code
    title: Title
    specializations: list[SpecializationIn] = Field(min_length=1)

    @model_validator(mode="after")
    def check_specializations(self) -> Self:
        reject_duplicates(
            [spec.id for spec in self.specializations],
            f"профессия {self.id!r}: повторяющиеся id специализаций",
        )
        return self


class TaxonomyFile(StrictModel):
    """Корень taxonomy.yaml."""

    version: int = Field(ge=1)
    professions: list[ProfessionIn] = Field(min_length=1)
    # specialization_id -> список разделов. Специализации без тем допустимы: они «скоро».
    topics: dict[Code, list[TopicIn]] = Field(default_factory=dict)

    @model_validator(mode="after")
    def check_cross_references(self) -> Self:
        reject_duplicates(
            [profession.id for profession in self.professions],
            "повторяющиеся id профессий",
        )

        known_specializations = {
            spec.id for profession in self.professions for spec in profession.specializations
        }
        reject_duplicates(sorted(known_specializations), "повторяющиеся id специализаций")

        for spec_id in self.topics:
            if spec_id not in known_specializations:
                raise ValueError(
                    f"темы объявлены для неизвестной специализации {spec_id!r}; "
                    f"известные: {', '.join(sorted(known_specializations))}"
                )

        for spec_id, topics in self.topics.items():
            if not topics:
                raise ValueError(f"специализация {spec_id!r}: пустой список разделов")
            reject_duplicates(
                [topic.code for topic in topics],
                f"специализация {spec_id!r}: повторяющиеся коды разделов",
            )

        active = [
            spec.id
            for profession in self.professions
            for spec in profession.specializations
            if spec.is_active
        ]
        for spec_id in active:
            if spec_id not in self.topics:
                raise ValueError(f"активная специализация {spec_id!r} осталась без разделов")
        return self

    @property
    def all_grades(self) -> tuple[int, ...]:
        return ALL_GRADES


def reject_duplicates(values: list[str], message: str) -> None:
    seen: set[str] = set()
    duplicates: list[str] = []
    for value in values:
        if value in seen and value not in duplicates:
            duplicates.append(value)
        seen.add(value)
    if duplicates:
        raise ValueError(f"{message}: {', '.join(duplicates)}")
