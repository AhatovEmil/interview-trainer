"""Построение плана подготовки к собеседованию (CLAUDE.md §3.7).

Чистая логика без БД: на вход — темы с весами и рейтингами, на выход — расписание.
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import date, timedelta
from typing import Final

from app.services.rating import normalized_rating

# Сколько тем даём в один день: больше — распыление внимания.
TOPICS_PER_DAY: Final = 3
DEFAULT_DAILY_CAPACITY: Final = 10
MAX_PLAN_DAYS: Final = 30


@dataclass(frozen=True, slots=True)
class TopicPriority:
    topic_code: str
    weight: float
    rating: float

    @property
    def priority(self) -> float:
        """Вес темы для целевого грейда × пробел пользователя по ней."""
        return self.weight * (1.0 - normalized_rating(self.rating))


@dataclass(frozen=True, slots=True)
class DayPlan:
    day_index: int
    day: date
    topics: tuple[str, ...]
    new_questions: int
    review_only: bool


class PlanError(ValueError):
    """План построить нельзя: некорректные даты или пустая таксономия."""


def plan_days(today: date, interview_date: date) -> list[date]:
    """Дни подготовки: с сегодня по день перед собеседованием включительно."""
    if interview_date <= today:
        raise PlanError("дата собеседования должна быть в будущем")

    total = (interview_date - today).days
    if total > MAX_PLAN_DAYS:
        raise PlanError(f"план строится максимум на {MAX_PLAN_DAYS} дней")

    return [today + timedelta(days=offset) for offset in range(total)]


def build_plan(
    topics: list[TopicPriority],
    days: list[date],
    daily_capacity: int = DEFAULT_DAILY_CAPACITY,
) -> list[DayPlan]:
    """Разложить темы по дням.

    Нагрузка распределяется равномерно, приоритетные темы встречаются чаще,
    последний день перед собеседованием — только повторение пройденного.
    """
    if not days:
        raise PlanError("нет ни одного дня для подготовки")
    if daily_capacity < 1:
        raise PlanError("дневная нагрузка должна быть положительной")

    ranked = sorted(
        (topic for topic in topics if topic.weight > 0.0),
        key=lambda topic: (-topic.priority, topic.topic_code),
    )
    if not ranked:
        raise PlanError("для этой специализации нет тем с весами")

    # Последний день всегда закрепление: новых тем в него не кладём.
    study_days = days[:-1]

    if not study_days:
        return [
            DayPlan(
                day_index=0,
                day=days[0],
                topics=(),
                new_questions=0,
                review_only=True,
            )
        ]

    schedule = _distribute(ranked, len(study_days))

    plan = [
        DayPlan(
            day_index=index,
            day=day,
            topics=tuple(schedule[index]),
            new_questions=daily_capacity,
            review_only=False,
        )
        for index, day in enumerate(study_days)
    ]
    plan.append(
        DayPlan(
            day_index=len(study_days),
            day=days[-1],
            topics=(),
            new_questions=0,
            review_only=True,
        )
    )
    return plan


def _distribute(ranked: list[TopicPriority], day_count: int) -> list[list[str]]:
    """Разложить темы по дням так, чтобы ни одна не осталась без слота.

    Сначала каждая тема получает по слоту в порядке приоритета — это гарантирует
    покрытие всех слабых мест. Оставшиеся слоты добираются по кругу с начала
    списка, то есть достаются самым приоритетным.
    """
    per_day = min(TOPICS_PER_DAY, len(ranked))
    total_slots = day_count * per_day

    codes = [topic.topic_code for topic in ranked]
    sequence: list[str] = []
    while len(sequence) < total_slots:
        remaining = total_slots - len(sequence)
        sequence.extend(codes[:remaining])

    schedule: list[list[str]] = [[] for _ in range(day_count)]
    # Раскладываем по кругу: тема с высоким приоритетом попадает в разные дни,
    # а не забивает один.
    for position, code in enumerate(sequence):
        index = position % day_count
        if code not in schedule[index]:
            schedule[index].append(code)

    # Дни, где из-за дедупликации осталось меньше тем, добираем по приоритету.
    for day_topics in schedule:
        for code in codes:
            if len(day_topics) >= per_day:
                break
            if code not in day_topics:
                day_topics.append(code)

    return schedule


def covered_topics(plan: list[DayPlan]) -> set[str]:
    return {topic for day in plan for topic in day.topics}
