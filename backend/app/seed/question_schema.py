"""Схема файлов content/questions/*.yaml.

Здесь же живут проверки из приёмки этапа 2: порядок грейдов, непустой короткий ответ,
три уровневых блока в разборе open_answer и согласованность вариантов ответа.
"""

from __future__ import annotations

import re
import uuid
from typing import Annotated, Self

from pydantic import BaseModel, ConfigDict, Field, StringConstraints, model_validator

from app.core.enums import QuestionSource, QuestionType
from app.core.grades import GRADE_VALUES
from app.seed.schema import Code, StrictModel, TaxonomyFile, reject_duplicates

Slug = Annotated[str, StringConstraints(pattern=r"^[a-z][a-z0-9_]{2,95}$")]
NonEmpty = Annotated[str, StringConstraints(min_length=1, strip_whitespace=True)]

# Пространство имён для uuid5: slug → стабильный id, одинаковый в любой базе.
QUESTION_NAMESPACE = uuid.UUID("6f1c9d3a-5f2e-4a63-9a2b-2f1f0d7c8e10")

# Разбор open_answer обязан отвечать на вопрос «что достаточно сказать на каждом уровне».
LEVEL_HEADINGS = ("Junior", "Middle", "Senior")


def question_id(slug: str) -> uuid.UUID:
    return uuid.uuid5(QUESTION_NAMESPACE, slug)


class OptionIn(StrictModel):
    code: Annotated[str, StringConstraints(pattern=r"^[a-z]$")]
    text: NonEmpty
    is_correct: bool = False


class QuestionIn(StrictModel):
    slug: Slug
    specializations: list[Code] = Field(min_length=1)
    topic: Code
    subtopic: Code | None = None

    min_grade: str
    peak_grade: str
    max_grade: str

    frequency: int = Field(ge=1, le=5)
    type: QuestionType
    title: NonEmpty
    options: list[OptionIn] = Field(default_factory=list)

    answer_short: Annotated[str, StringConstraints(min_length=1, max_length=600)]
    answer_detailed: NonEmpty
    common_mistakes: list[NonEmpty] = Field(default_factory=list)
    follow_ups: list[NonEmpty] = Field(default_factory=list)
    company_tags: list[NonEmpty] = Field(default_factory=list)

    source: QuestionSource = QuestionSource.SEED
    difficulty_rating: int | None = None

    model_config = ConfigDict(extra="forbid", use_enum_values=False)

    @model_validator(mode="after")
    def check_everything(self) -> Self:
        self._check_grades()
        self._check_options()
        self._check_answer()
        reject_duplicates(
            self.specializations, f"вопрос {self.slug!r}: повторяющиеся специализации"
        )
        return self

    def _check_grades(self) -> None:
        for field in ("min_grade", "peak_grade", "max_grade"):
            code = getattr(self, field)
            if code not in GRADE_VALUES:
                known = ", ".join(GRADE_VALUES)
                raise ValueError(f"вопрос {self.slug!r}: {field}={code!r}, допустимые: {known}")

        low, peak, high = self.grades()
        if not low <= peak <= high:
            raise ValueError(
                f"вопрос {self.slug!r}: нарушен порядок грейдов "
                f"{self.min_grade} ≤ {self.peak_grade} ≤ {self.max_grade}"
            )

    def _check_options(self) -> None:
        if not self.type.has_options:
            if self.options:
                raise ValueError(
                    f"вопрос {self.slug!r}: у типа {self.type} не может быть вариантов"
                )
            return

        if len(self.options) < 2:
            raise ValueError(f"вопрос {self.slug!r}: нужно минимум два варианта ответа")

        reject_duplicates(
            [option.code for option in self.options],
            f"вопрос {self.slug!r}: повторяющиеся коды вариантов",
        )

        correct = sum(option.is_correct for option in self.options)
        if self.type is QuestionType.SINGLE_CHOICE and correct != 1:
            raise ValueError(
                f"вопрос {self.slug!r}: у single_choice должен быть ровно один верный "
                f"вариант, найдено {correct}"
            )
        if self.type is QuestionType.MULTI_CHOICE and correct < 2:
            raise ValueError(
                f"вопрос {self.slug!r}: у multi_choice должно быть минимум два верных "
                f"варианта, найдено {correct}"
            )

    def _check_answer(self) -> None:
        if self.type is not QuestionType.OPEN_ANSWER:
            return

        missing = [
            level
            for level in LEVEL_HEADINGS
            if not re.search(rf"^#{{2,4}}\s*{level}\b", self.answer_detailed, re.MULTILINE)
        ]
        if missing:
            raise ValueError(
                f"вопрос {self.slug!r}: в answer_detailed нет уровневых блоков "
                f"{', '.join(missing)} — для open_answer нужны все три "
                f"({', '.join(LEVEL_HEADINGS)})"
            )

    def grades(self) -> tuple[int, int, int]:
        return (
            GRADE_VALUES[self.min_grade],
            GRADE_VALUES[self.peak_grade],
            GRADE_VALUES[self.max_grade],
        )

    @property
    def uuid(self) -> uuid.UUID:
        return question_id(self.slug)


class QuestionFile(StrictModel):
    """Корень content/questions/<специализация>.yaml."""

    version: int = Field(ge=1)
    questions: list[QuestionIn] = Field(min_length=1)

    @model_validator(mode="after")
    def check_unique_slugs(self) -> Self:
        reject_duplicates([question.slug for question in self.questions], "повторяющиеся slug")
        return self


class TaxonomyIndex(BaseModel):
    """Плоский указатель «специализация → разделы → темы» для проверки ссылок."""

    topics: dict[str, dict[str, set[str]]]

    @classmethod
    def from_taxonomy(cls, taxonomy: TaxonomyFile) -> TaxonomyIndex:
        return cls(
            topics={
                specialization_id: {
                    topic.code: {subtopic.code for subtopic in topic.subtopics} for topic in topics
                }
                for specialization_id, topics in taxonomy.topics.items()
            }
        )

    def check(self, questions: list[QuestionIn]) -> None:
        """Проверить, что каждый вопрос ссылается на существующие специализацию и тему."""
        for question in questions:
            for specialization in question.specializations:
                if specialization not in self.topics:
                    known = ", ".join(sorted(self.topics))
                    raise ValueError(
                        f"вопрос {question.slug!r}: неизвестная специализация "
                        f"{specialization!r}; известные: {known}"
                    )

                subtopics = self.topics[specialization].get(question.topic)
                if subtopics is None:
                    known = ", ".join(sorted(self.topics[specialization]))
                    raise ValueError(
                        f"вопрос {question.slug!r}: раздел {question.topic!r} не найден "
                        f"в специализации {specialization!r}; известные: {known}"
                    )

                if question.subtopic is not None and question.subtopic not in subtopics:
                    known = ", ".join(sorted(subtopics))
                    raise ValueError(
                        f"вопрос {question.slug!r}: тема {question.subtopic!r} не найдена "
                        f"в разделе {question.topic!r}; известные: {known}"
                    )
