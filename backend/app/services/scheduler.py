"""Планировщик интервальных повторений (CLAUDE.md §3.6).

Алгоритм спрятан за протоколом `ReviewScheduler`: заменить SM-2 на FSRS можно
подменой реализации, вызывающий код не меняется.
"""

from __future__ import annotations

from dataclasses import dataclass, replace
from datetime import datetime, timedelta
from typing import Final, Protocol

MIN_EASINESS_FACTOR: Final = 1.3
DEFAULT_EASINESS_FACTOR: Final = 2.5

# Порог качества: ниже — повторение сбрасывается.
FAILURE_THRESHOLD: Final = 3

FIRST_INTERVAL_DAYS: Final = 1
SECOND_INTERVAL_DAYS: Final = 6

MIN_QUALITY: Final = 0
MAX_QUALITY: Final = 5


@dataclass(frozen=True, slots=True)
class ReviewSnapshot:
    """Снимок состояния повторения. Неизменяемый: планировщик возвращает новый."""

    easiness_factor: float = DEFAULT_EASINESS_FACTOR
    repetitions: int = 0
    interval_days: int = 0
    due_at: datetime | None = None

    @property
    def is_new(self) -> bool:
        return self.repetitions == 0


class ReviewScheduler(Protocol):
    """Контракт планировщика: из состояния и оценки получить новое состояние."""

    def review(self, state: ReviewSnapshot, quality: int, now: datetime) -> ReviewSnapshot: ...


class SM2Scheduler:
    """Классический SM-2."""

    def review(self, state: ReviewSnapshot, quality: int, now: datetime) -> ReviewSnapshot:
        if not MIN_QUALITY <= quality <= MAX_QUALITY:
            raise ValueError(f"качество ответа {quality} вне диапазона {MIN_QUALITY}–{MAX_QUALITY}")

        easiness_factor = self._next_easiness_factor(state.easiness_factor, quality)

        if quality < FAILURE_THRESHOLD:
            # Провал сбрасывает цепочку: вопрос вернётся завтра.
            repetitions = 0
            interval_days = FIRST_INTERVAL_DAYS
        else:
            repetitions = state.repetitions + 1
            interval_days = self._next_interval(repetitions, state.interval_days, easiness_factor)

        return replace(
            state,
            easiness_factor=easiness_factor,
            repetitions=repetitions,
            interval_days=interval_days,
            due_at=now + timedelta(days=interval_days),
        )

    @staticmethod
    def _next_easiness_factor(easiness_factor: float, quality: int) -> float:
        delta = 0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02)
        return max(MIN_EASINESS_FACTOR, easiness_factor + delta)

    @staticmethod
    def _next_interval(repetitions: int, interval_days: int, easiness_factor: float) -> int:
        if repetitions == 1:
            return FIRST_INTERVAL_DAYS
        if repetitions == 2:
            return SECOND_INTERVAL_DAYS
        return max(FIRST_INTERVAL_DAYS, round(interval_days * easiness_factor))


def get_scheduler() -> ReviewScheduler:
    """Точка подмены алгоритма для всего приложения."""
    return SM2Scheduler()
