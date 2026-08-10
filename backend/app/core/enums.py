"""Доменные перечисления, общие для моделей, схем и загрузчиков контента."""

from __future__ import annotations

from enum import StrEnum


class QuestionType(StrEnum):
    SINGLE_CHOICE = "single_choice"
    MULTI_CHOICE = "multi_choice"
    SHORT_ANSWER = "short_answer"
    OPEN_ANSWER = "open_answer"

    @property
    def has_options(self) -> bool:
        """Варианты ответа есть только у выборочных типов."""
        return self in {QuestionType.SINGLE_CHOICE, QuestionType.MULTI_CHOICE}


class QuestionSource(StrEnum):
    SEED = "seed"
    CROWDSOURCED = "crowdsourced"
    IMPORTED = "imported"


class ReportStatus(StrEnum):
    """Статус присланного пользователем вопроса.

    DUPLICATE отделён от REJECTED намеренно: дубль — признак того, что вопрос
    реально встречается, и это повод поднять ему частоту, а не просто отказ.
    """

    NEW = "new"
    ACCEPTED = "accepted"
    REJECTED = "rejected"
    DUPLICATE = "duplicate"


class QuestionStatus(StrEnum):
    """Как пользователь закрыл вопрос в последний раз.

    Берётся именно последняя попытка, а не лучшая: список должен показывать
    текущее положение дел, иначе забытый вопрос выглядел бы освоенным.
    """

    UNANSWERED = "unanswered"
    CORRECT = "correct"
    PARTIAL = "partial"
    WRONG = "wrong"

    @classmethod
    def from_score(cls, score: float) -> QuestionStatus:
        if score >= 1.0:
            return cls.CORRECT
        if score > 0.0:
            return cls.PARTIAL
        return cls.WRONG
