"""Реестр ORM-моделей.

Все модели импортируются здесь, чтобы Alembic видел полную metadata.
"""

from __future__ import annotations

from app.db.base import Base
from app.db.models.question import (
    Question,
    QuestionOption,
    question_specializations,
)
from app.db.models.taxonomy import (
    Profession,
    Specialization,
    Subtopic,
    Topic,
    TopicWeight,
)

__all__ = [
    "Base",
    "Profession",
    "Question",
    "QuestionOption",
    "Specialization",
    "Subtopic",
    "Topic",
    "TopicWeight",
    "question_specializations",
]
