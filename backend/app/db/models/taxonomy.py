"""Таксономия: профессия → специализация → раздел → тема, плюс веса разделов по грейдам."""

from __future__ import annotations

from sqlalchemy import (
    Boolean,
    CheckConstraint,
    Float,
    ForeignKey,
    Index,
    SmallInteger,
    String,
    UniqueConstraint,
)
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.grades import MAX_GRADE, MIN_GRADE
from app.db.base import Base, TimestampMixin


class Profession(Base, TimestampMixin):
    """Верхний уровень: backend, frontend, qa..."""

    __tablename__ = "professions"

    id: Mapped[str] = mapped_column(String(64), primary_key=True)
    title: Mapped[str] = mapped_column(String(128), nullable=False)
    sort_order: Mapped[int] = mapped_column(SmallInteger, nullable=False, default=0)

    specializations: Mapped[list[Specialization]] = relationship(
        back_populates="profession",
        cascade="all, delete-orphan",
        order_by="Specialization.sort_order",
        lazy="selectin",
    )


class Specialization(Base, TimestampMixin):
    """Стек внутри профессии: backend_python, frontend_react...

    Вопросы и темы привязаны именно сюда, а не к профессии.
    """

    __tablename__ = "specializations"

    id: Mapped[str] = mapped_column(String(64), primary_key=True)
    profession_id: Mapped[str] = mapped_column(
        ForeignKey("professions.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    title: Mapped[str] = mapped_column(String(128), nullable=False)
    # В MVP активна только backend_python, остальные показываются как «скоро».
    is_active: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    sort_order: Mapped[int] = mapped_column(SmallInteger, nullable=False, default=0)

    profession: Mapped[Profession] = relationship(back_populates="specializations")
    topics: Mapped[list[Topic]] = relationship(
        back_populates="specialization",
        cascade="all, delete-orphan",
        order_by="Topic.sort_order",
        lazy="selectin",
    )


class Topic(Base, TimestampMixin):
    """Раздел — первый уровень дерева тем внутри специализации."""

    __tablename__ = "topics"
    __table_args__ = (UniqueConstraint("specialization_id", "code", name="specialization_id_code"),)

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    specialization_id: Mapped[str] = mapped_column(
        ForeignKey("specializations.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    code: Mapped[str] = mapped_column(String(64), nullable=False)
    title: Mapped[str] = mapped_column(String(128), nullable=False)
    sort_order: Mapped[int] = mapped_column(SmallInteger, nullable=False, default=0)

    specialization: Mapped[Specialization] = relationship(back_populates="topics")
    subtopics: Mapped[list[Subtopic]] = relationship(
        back_populates="topic",
        cascade="all, delete-orphan",
        order_by="Subtopic.sort_order",
        lazy="selectin",
    )
    weights: Mapped[list[TopicWeight]] = relationship(
        back_populates="topic",
        cascade="all, delete-orphan",
        order_by="TopicWeight.grade",
        lazy="selectin",
    )


class Subtopic(Base, TimestampMixin):
    """Тема — второй и последний уровень. Глубже дерево не растёт."""

    __tablename__ = "subtopics"
    __table_args__ = (UniqueConstraint("topic_id", "code", name="topic_id_code"),)

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    topic_id: Mapped[int] = mapped_column(
        ForeignKey("topics.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    code: Mapped[str] = mapped_column(String(64), nullable=False)
    title: Mapped[str] = mapped_column(String(128), nullable=False)
    sort_order: Mapped[int] = mapped_column(SmallInteger, nullable=False, default=0)

    topic: Mapped[Topic] = relationship(back_populates="subtopics")


class TopicWeight(Base):
    """Вес раздела для конкретного грейда.

    По этим весам считается общий грейд по специализации (взвешенное среднее по темам)
    и приоритет тем в плане подготовки.
    """

    __tablename__ = "topic_weights"
    __table_args__ = (
        CheckConstraint(f"grade BETWEEN {MIN_GRADE} AND {MAX_GRADE}", name="grade_range"),
        CheckConstraint("weight >= 0 AND weight <= 1", name="weight_range"),
        Index("ix_topic_weights_grade", "grade"),
    )

    topic_id: Mapped[int] = mapped_column(
        ForeignKey("topics.id", ondelete="CASCADE"),
        primary_key=True,
    )
    grade: Mapped[int] = mapped_column(SmallInteger, primary_key=True)
    weight: Mapped[float] = mapped_column(Float, nullable=False)

    topic: Mapped[Topic] = relationship(back_populates="weights")
