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
