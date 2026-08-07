"""Юнит-тесты планировщика подготовки. Без БД: проверяется раскладка из CLAUDE.md §3.7."""

from datetime import date, timedelta

import pytest

from app.services.planner import (
    DEFAULT_DAILY_CAPACITY,
    MAX_PLAN_DAYS,
    TOPICS_PER_DAY,
    DayPlan,
    PlanError,
    TopicPriority,
    build_plan,
    covered_topics,
    plan_days,
)

TODAY = date(2026, 8, 8)

# Девять разделов backend_python с весами для middle и разными рейтингами.
TOPICS = [
    TopicPriority("language", 0.85, 1500.0),
    TopicPriority("async", 0.85, 1200.0),
    TopicPriority("db", 1.0, 1050.0),
    TopicPriority("web", 0.95, 1300.0),
    TopicPriority("architecture", 0.8, 1100.0),
    TopicPriority("system_design", 0.6, 1000.0),
    TopicPriority("infra", 0.6, 1400.0),
    TopicPriority("algorithms", 0.6, 1600.0),
    TopicPriority("soft", 0.7, 1200.0),
]


def week() -> list[date]:
    return plan_days(TODAY, TODAY + timedelta(days=7))


# --- Дни плана ---------------------------------------------------------------------


def test_plan_days_covers_up_to_day_before_interview() -> None:
    days = plan_days(TODAY, TODAY + timedelta(days=7))

    assert len(days) == 7
    assert days[0] == TODAY
    assert days[-1] == TODAY + timedelta(days=6)


def test_interview_in_the_past_is_rejected() -> None:
    with pytest.raises(PlanError, match="в будущем"):
        plan_days(TODAY, TODAY - timedelta(days=1))

    with pytest.raises(PlanError, match="в будущем"):
        plan_days(TODAY, TODAY)


def test_too_long_horizon_is_rejected() -> None:
    with pytest.raises(PlanError, match=str(MAX_PLAN_DAYS)):
        plan_days(TODAY, TODAY + timedelta(days=MAX_PLAN_DAYS + 1))


# --- Приоритет тем -----------------------------------------------------------------


def test_priority_grows_when_rating_is_low() -> None:
    strong = TopicPriority("db", 1.0, 1800.0)
    weak = TopicPriority("db", 1.0, 1000.0)

    assert weak.priority > strong.priority
    assert strong.priority == pytest.approx(0.0)


def test_priority_grows_with_topic_weight() -> None:
    heavy = TopicPriority("system_design", 1.0, 1200.0)
    light = TopicPriority("language", 0.5, 1200.0)

    assert heavy.priority > light.priority


# --- Раскладка по дням -------------------------------------------------------------


def test_plan_has_one_entry_per_day() -> None:
    days = week()

    plan = build_plan(TOPICS, days)

    assert len(plan) == len(days)
    assert [item.day for item in plan] == days
    assert [item.day_index for item in plan] == list(range(len(days)))


def test_last_day_is_review_only() -> None:
    """Приёмка этапа 6: последний день содержит только повторения."""
    plan = build_plan(TOPICS, week())

    last = plan[-1]
    assert last.review_only is True
    assert last.topics == ()
    assert last.new_questions == 0


def test_only_last_day_is_review_only() -> None:
    plan = build_plan(TOPICS, week())

    assert all(not item.review_only for item in plan[:-1])


def test_week_plan_covers_all_weak_topics() -> None:
    """Приёмка этапа 6: план на 7 дней покрывает все темы с низким рейтингом."""
    plan = build_plan(TOPICS, week())

    covered = covered_topics(plan)
    weak = {topic.topic_code for topic in TOPICS if topic.priority > 0}

    assert weak <= covered, f"не покрыты: {weak - covered}"


def test_daily_load_is_even() -> None:
    plan = build_plan(TOPICS, week(), daily_capacity=12)

    study_days = [item for item in plan if not item.review_only]
    assert {item.new_questions for item in study_days} == {12}
    assert {len(item.topics) for item in study_days} == {TOPICS_PER_DAY}


def test_highest_priority_topic_appears_most_often() -> None:
    plan = build_plan(TOPICS, week())
    counts: dict[str, int] = {}
    for day in plan:
        for topic in day.topics:
            counts[topic] = counts.get(topic, 0) + 1

    top = max(TOPICS, key=lambda topic: topic.priority)
    weakest_count = counts[top.topic_code]

    assert weakest_count == max(counts.values())


def test_topics_within_day_are_unique() -> None:
    plan = build_plan(TOPICS, week())

    for day in plan:
        assert len(set(day.topics)) == len(day.topics)


def test_zero_weight_topics_are_skipped() -> None:
    topics = [
        TopicPriority("language", 1.0, 1200.0),
        TopicPriority("system_design", 0.0, 1000.0),
    ]

    plan = build_plan(topics, week())

    assert "system_design" not in covered_topics(plan)


def test_single_day_plan_is_review_only() -> None:
    """Собеседование завтра: учить новое уже поздно."""
    days = plan_days(TODAY, TODAY + timedelta(days=1))

    plan = build_plan(TOPICS, days)

    assert len(plan) == 1
    assert plan[0].review_only is True


def test_two_day_plan_has_one_study_day() -> None:
    days = plan_days(TODAY, TODAY + timedelta(days=2))

    plan = build_plan(TOPICS, days)

    assert [item.review_only for item in plan] == [False, True]
    assert len(plan[0].topics) == TOPICS_PER_DAY


def test_long_plan_still_covers_everything() -> None:
    days = plan_days(TODAY, TODAY + timedelta(days=14))

    plan = build_plan(TOPICS, days)

    assert covered_topics(plan) == {topic.topic_code for topic in TOPICS}


def test_fewer_topics_than_slots_per_day() -> None:
    topics = [TopicPriority("db", 1.0, 1100.0), TopicPriority("web", 0.9, 1200.0)]

    plan = build_plan(topics, week())

    for day in plan[:-1]:
        assert len(day.topics) == 2


def test_empty_topics_is_rejected() -> None:
    with pytest.raises(PlanError, match="нет тем"):
        build_plan([], week())


def test_no_days_is_rejected() -> None:
    with pytest.raises(PlanError, match="ни одного дня"):
        build_plan(TOPICS, [])


def test_non_positive_capacity_is_rejected() -> None:
    with pytest.raises(PlanError, match="положительной"):
        build_plan(TOPICS, week(), daily_capacity=0)


def test_default_capacity_is_used() -> None:
    plan: list[DayPlan] = build_plan(TOPICS, week())

    assert plan[0].new_questions == DEFAULT_DAILY_CAPACITY
