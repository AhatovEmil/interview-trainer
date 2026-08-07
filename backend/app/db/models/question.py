"""Вопрос банка: формулировка, эталонный ответ, градация по грейдам."""

from __future__ import annotations

import uuid
from typing import TYPE_CHECKING

from sqlalchemy import (
    Boolean,
    CheckConstraint,
    Column,
    Enum,
    ForeignKey,
    Index,
    SmallInteger,
    String,
    Table,
    Text,
    UniqueConstraint,
)
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.enums import QuestionSource, QuestionType
from app.core.grades import MAX_GRADE, MIN_GRADE
from app.db.base import Base, TimestampMixin

if TYPE_CHECKING:
    from app.db.models.taxonomy import Specialization

# Вопрос может относиться к нескольким стекам: «что такое индекс» одинаково спрашивают
# и питониста, и джависта.
question_specializations = Table(
    "question_specializations",
    Base.metadata,
    Column(
        "question_id",
        ForeignKey("questions.id", ondelete="CASCADE"),
        primary_key=True,
    ),
    Column(
        "specialization_id",
        ForeignKey("specializations.id", ondelete="CASCADE"),
        primary_key=True,
    ),
)

# Стартовый рейтинг сложности выводится из peak_grade (CLAUDE.md §3.5).
DIFFICULTY_BASE = 1000
DIFFICULTY_PER_GRADE = 130


def difficulty_from_peak_grade(peak_grade: int) -> int:
    return DIFFICULTY_BASE + peak_grade * DIFFICULTY_PER_GRADE


def _enum_column(enum: type[QuestionType] | type[QuestionSource], name: str) -> Enum:
    """VARCHAR + CHECK вместо нативного enum Postgres.

    Нативный тип пришлось бы менять отдельной миграцией на каждое новое значение,
    а конвертацию в Python-enum при чтении SQLAlchemy делает в обоих случаях.
    """
    return Enum(
        enum,
        name=name,
        native_enum=False,
        length=32,
        values_callable=lambda members: [member.value for member in members],
    )


class Question(Base, TimestampMixin):
    __tablename__ = "questions"
    __table_args__ = (
        CheckConstraint(
            f"min_grade BETWEEN {MIN_GRADE} AND {MAX_GRADE} "
            f"AND peak_grade BETWEEN {MIN_GRADE} AND {MAX_GRADE} "
            f"AND max_grade BETWEEN {MIN_GRADE} AND {MAX_GRADE}",
            name="grade_range",
        ),
        CheckConstraint(
            "min_grade <= peak_grade AND peak_grade <= max_grade",
            name="grade_order",
        ),
        CheckConstraint("frequency BETWEEN 1 AND 5", name="frequency_range"),
        Index("ix_questions_topic_code", "topic_code"),
        Index("ix_questions_grades", "min_grade", "max_grade"),
    )

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True)
    # Человекочитаемый ключ из YAML: по нему сид находит вопрос и не плодит дубли.
    slug: Mapped[str] = mapped_column(String(96), nullable=False, unique=True)

    topic_code: Mapped[str] = mapped_column(String(64), nullable=False)
    subtopic_code: Mapped[str | None] = mapped_column(String(64), nullable=True)

    # Градация по грейдам: три поля, а не одно (CLAUDE.md §3.4).
    min_grade: Mapped[int] = mapped_column(SmallInteger, nullable=False)
    peak_grade: Mapped[int] = mapped_column(SmallInteger, nullable=False)
    max_grade: Mapped[int] = mapped_column(SmallInteger, nullable=False)

    difficulty_rating: Mapped[int] = mapped_column(SmallInteger, nullable=False)
    frequency: Mapped[int] = mapped_column(SmallInteger, nullable=False)

    type: Mapped[QuestionType] = mapped_column(
        _enum_column(QuestionType, "question_type"), nullable=False
    )
    title: Mapped[str] = mapped_column(Text, nullable=False)
    answer_short: Mapped[str] = mapped_column(Text, nullable=False)
    answer_detailed: Mapped[str] = mapped_column(Text, nullable=False)

    common_mistakes: Mapped[list[str]] = mapped_column(JSONB, nullable=False, default=list)
    follow_ups: Mapped[list[str]] = mapped_column(JSONB, nullable=False, default=list)
    company_tags: Mapped[list[str]] = mapped_column(JSONB, nullable=False, default=list)

    # Всё, что не просмотрено человеком, остаётся непроверенным (CLAUDE.md §8.1).
    is_verified: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    source: Mapped[QuestionSource] = mapped_column(
        _enum_column(QuestionSource, "question_source"), nullable=False
    )

    specializations: Mapped[list[Specialization]] = relationship(
        secondary=question_specializations,
        lazy="selectin",
        order_by="Specialization.sort_order",
    )
    options: Mapped[list[QuestionOption]] = relationship(
        back_populates="question",
        cascade="all, delete-orphan",
        order_by="QuestionOption.sort_order",
        lazy="selectin",
    )


class QuestionOption(Base):
    """Вариант ответа для single_choice и multi_choice."""

    __tablename__ = "question_options"
    __table_args__ = (UniqueConstraint("question_id", "code", name="question_id_code"),)

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    question_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("questions.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    code: Mapped[str] = mapped_column(String(16), nullable=False)
    text: Mapped[str] = mapped_column(Text, nullable=False)
    is_correct: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    sort_order: Mapped[int] = mapped_column(SmallInteger, nullable=False, default=0)

    question: Mapped[Question] = relationship(back_populates="options")
