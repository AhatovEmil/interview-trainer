"""Пользователь, его специализации, рейтинги по темам, ответы и состояние повторений."""

from __future__ import annotations

import uuid
from datetime import datetime

from sqlalchemy import (
    Boolean,
    CheckConstraint,
    DateTime,
    Float,
    ForeignKey,
    Index,
    Integer,
    SmallInteger,
    String,
    Text,
    UniqueConstraint,
    func,
)
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.grades import MAX_GRADE, MIN_GRADE
from app.db.base import Base, TimestampMixin

# Стартовый рейтинг пользователя по теме (CLAUDE.md §3.5).
START_RATING = 1200


class User(Base, TimestampMixin):
    __tablename__ = "users"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    email: Mapped[str] = mapped_column(String(320), nullable=False, unique=True)
    password_hash: Mapped[str] = mapped_column(String(255), nullable=False)
    is_active: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)
    # Платные фичи отделены флагом на уровне сервисного слоя (CLAUDE.md §1).
    is_premium: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)

    specializations: Mapped[list[UserSpecialization]] = relationship(
        back_populates="user",
        cascade="all, delete-orphan",
        lazy="selectin",
    )


class UserSpecialization(Base, TimestampMixin):
    """Прогресс хранится по каждой специализации отдельно, основная — одна."""

    __tablename__ = "user_specializations"
    __table_args__ = (
        CheckConstraint(
            f"self_assessed_grade BETWEEN {MIN_GRADE} AND {MAX_GRADE}",
            name="grade_range",
        ),
        Index("ix_user_specializations_primary", "user_id", "is_primary"),
    )

    user_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"),
        primary_key=True,
    )
    specialization_id: Mapped[str] = mapped_column(
        ForeignKey("specializations.id", ondelete="CASCADE"),
        primary_key=True,
    )
    self_assessed_grade: Mapped[int] = mapped_column(SmallInteger, nullable=False)
    is_primary: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    answers_count: Mapped[int] = mapped_column(Integer, nullable=False, default=0)

    user: Mapped[User] = relationship(back_populates="specializations")


class UserTopicRating(Base, TimestampMixin):
    """Elo-рейтинг пользователя по паре (специализация, раздел)."""

    __tablename__ = "user_topic_ratings"

    user_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"),
        primary_key=True,
    )
    specialization_id: Mapped[str] = mapped_column(
        ForeignKey("specializations.id", ondelete="CASCADE"),
        primary_key=True,
    )
    topic_code: Mapped[str] = mapped_column(String(64), primary_key=True)

    rating: Mapped[float] = mapped_column(Float, nullable=False, default=float(START_RATING))
    answers_count: Mapped[int] = mapped_column(Integer, nullable=False, default=0)


class UserAnswer(Base):
    """Факт ответа. submission_id приходит от клиента и защищает от дублей."""

    __tablename__ = "user_answers"
    __table_args__ = (
        UniqueConstraint("user_id", "submission_id", name="user_id_submission_id"),
        Index("ix_user_answers_user_question", "user_id", "question_id"),
        CheckConstraint("score >= 0 AND score <= 1", name="score_range"),
        CheckConstraint("quality BETWEEN 0 AND 5", name="quality_range"),
    )

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
    )
    question_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("questions.id", ondelete="CASCADE"),
        nullable=False,
    )
    specialization_id: Mapped[str] = mapped_column(
        ForeignKey("specializations.id", ondelete="CASCADE"),
        nullable=False,
    )
    topic_code: Mapped[str] = mapped_column(String(64), nullable=False)

    # Идентификатор попытки, сгенерированный клиентом: повторная отправка того же
    # ответа (ретрай, офлайн-синхронизация) не должна двигать рейтинг дважды.
    submission_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False)

    selected_options: Mapped[list[str]] = mapped_column(JSONB, nullable=False, default=list)
    free_text: Mapped[str | None] = mapped_column(Text, nullable=True)

    score: Mapped[float] = mapped_column(Float, nullable=False)
    quality: Mapped[int] = mapped_column(SmallInteger, nullable=False)

    rating_before: Mapped[float] = mapped_column(Float, nullable=False)
    rating_after: Mapped[float] = mapped_column(Float, nullable=False)
    difficulty_before: Mapped[int] = mapped_column(SmallInteger, nullable=False)
    difficulty_after: Mapped[int] = mapped_column(SmallInteger, nullable=False)

    answered_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),
    )


class ReviewState(Base, TimestampMixin):
    """Состояние интервального повторения по паре (пользователь, вопрос)."""

    __tablename__ = "review_states"
    __table_args__ = (Index("ix_review_states_due", "user_id", "due_at"),)

    user_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"),
        primary_key=True,
    )
    question_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("questions.id", ondelete="CASCADE"),
        primary_key=True,
    )

    easiness_factor: Mapped[float] = mapped_column(Float, nullable=False, default=2.5)
    repetitions: Mapped[int] = mapped_column(SmallInteger, nullable=False, default=0)
    interval_days: Mapped[int] = mapped_column(SmallInteger, nullable=False, default=0)
    due_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    last_reviewed_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
