"""План подготовки к собеседованию."""

from __future__ import annotations

import uuid
from datetime import date

from sqlalchemy import (
    Boolean,
    CheckConstraint,
    Date,
    ForeignKey,
    Index,
    SmallInteger,
    UniqueConstraint,
)
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.grades import MAX_GRADE, MIN_GRADE
from app.db.base import Base, TimestampMixin


class StudyPlan(Base, TimestampMixin):
    __tablename__ = "study_plans"
    __table_args__ = (
        CheckConstraint(
            f"target_grade BETWEEN {MIN_GRADE} AND {MAX_GRADE}",
            name="grade_range",
        ),
        CheckConstraint("daily_capacity > 0", name="capacity_positive"),
        Index("ix_study_plans_active", "user_id", "specialization_id", "is_active"),
    )

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
    )
    specialization_id: Mapped[str] = mapped_column(
        ForeignKey("specializations.id", ondelete="CASCADE"),
        nullable=False,
    )
    interview_date: Mapped[date] = mapped_column(Date, nullable=False)
    target_grade: Mapped[int] = mapped_column(SmallInteger, nullable=False)
    daily_capacity: Mapped[int] = mapped_column(SmallInteger, nullable=False)
    # Активный план один: создание нового гасит предыдущий.
    is_active: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)

    days: Mapped[list[StudyPlanDay]] = relationship(
        back_populates="plan",
        cascade="all, delete-orphan",
        order_by="StudyPlanDay.day_index",
        lazy="selectin",
    )


class StudyPlanDay(Base):
    """День плана.

    Хранится не список вопросов, а темы и объём: конкретные вопросы подбираются
    в момент запроса, иначе повторения из SRS не попадут в план дня.
    """

    __tablename__ = "study_plan_days"
    __table_args__ = (
        UniqueConstraint("plan_id", "day_index", name="plan_id_day_index"),
        Index("ix_study_plan_days_date", "plan_id", "day"),
    )

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    plan_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("study_plans.id", ondelete="CASCADE"),
        nullable=False,
    )
    day_index: Mapped[int] = mapped_column(SmallInteger, nullable=False)
    day: Mapped[date] = mapped_column(Date, nullable=False)
    topic_codes: Mapped[list[str]] = mapped_column(JSONB, nullable=False, default=list)
    new_questions: Mapped[int] = mapped_column(SmallInteger, nullable=False, default=0)
    review_only: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)

    plan: Mapped[StudyPlan] = relationship(back_populates="days")
