"""Юнит-тесты SM-2. Без БД: проверяется алгоритм из CLAUDE.md §3.6."""

from datetime import UTC, datetime, timedelta

import pytest

from app.services.scheduler import (
    DEFAULT_EASINESS_FACTOR,
    FIRST_INTERVAL_DAYS,
    MIN_EASINESS_FACTOR,
    SECOND_INTERVAL_DAYS,
    ReviewScheduler,
    ReviewSnapshot,
    SM2Scheduler,
    get_scheduler,
)

NOW = datetime(2026, 8, 8, 12, 0, tzinfo=UTC)


@pytest.fixture
def scheduler() -> ReviewScheduler:
    return SM2Scheduler()


def test_default_scheduler_is_sm2() -> None:
    """Алгоритм выбирается в одном месте: замена на FSRS не тронет вызывающий код."""
    default = get_scheduler()

    assert default.review(ReviewSnapshot(), quality=4, now=NOW) == SM2Scheduler().review(
        ReviewSnapshot(), quality=4, now=NOW
    )


def test_first_successful_review_gives_one_day(scheduler: ReviewScheduler) -> None:
    state = scheduler.review(ReviewSnapshot(), quality=4, now=NOW)

    assert state.repetitions == 1
    assert state.interval_days == FIRST_INTERVAL_DAYS
    assert state.due_at == NOW + timedelta(days=1)


def test_second_successful_review_gives_six_days(scheduler: ReviewScheduler) -> None:
    first = scheduler.review(ReviewSnapshot(), quality=4, now=NOW)

    second = scheduler.review(first, quality=4, now=NOW)

    assert second.repetitions == 2
    assert second.interval_days == SECOND_INTERVAL_DAYS
    assert second.due_at == NOW + timedelta(days=6)


def test_third_review_multiplies_interval_by_easiness(scheduler: ReviewScheduler) -> None:
    state = ReviewSnapshot(easiness_factor=2.5, repetitions=2, interval_days=6, due_at=NOW)

    third = scheduler.review(state, quality=5, now=NOW)

    assert third.repetitions == 3
    assert third.interval_days == round(6 * third.easiness_factor)


def test_failure_resets_repetitions_and_interval(scheduler: ReviewScheduler) -> None:
    state = ReviewSnapshot(easiness_factor=2.6, repetitions=5, interval_days=40, due_at=NOW)

    failed = scheduler.review(state, quality=2, now=NOW)

    assert failed.repetitions == 0
    assert failed.interval_days == FIRST_INTERVAL_DAYS
    assert failed.due_at == NOW + timedelta(days=1)


def test_failure_still_lowers_easiness_factor(scheduler: ReviewScheduler) -> None:
    state = ReviewSnapshot(easiness_factor=2.5, repetitions=3, interval_days=15, due_at=NOW)

    failed = scheduler.review(state, quality=0, now=NOW)

    assert failed.easiness_factor < state.easiness_factor


@pytest.mark.parametrize(
    ("quality", "expected"),
    [
        (5, 2.6),
        (4, 2.5),
        (3, 2.36),
        (2, 2.18),
        (1, 1.96),
        (0, 1.7),
    ],
)
def test_easiness_factor_matches_formula(
    scheduler: ReviewScheduler, quality: int, expected: float
) -> None:
    state = scheduler.review(ReviewSnapshot(easiness_factor=2.5), quality=quality, now=NOW)

    assert state.easiness_factor == pytest.approx(expected, abs=1e-9)


def test_easiness_factor_never_drops_below_floor(scheduler: ReviewScheduler) -> None:
    state = ReviewSnapshot(easiness_factor=MIN_EASINESS_FACTOR)

    for _ in range(20):
        state = scheduler.review(state, quality=0, now=NOW)

    assert state.easiness_factor == MIN_EASINESS_FACTOR


def test_perfect_streak_grows_intervals(scheduler: ReviewScheduler) -> None:
    state = ReviewSnapshot()
    intervals = []
    for _ in range(6):
        state = scheduler.review(state, quality=5, now=NOW)
        intervals.append(state.interval_days)

    assert intervals[0] == 1
    assert intervals[1] == 6
    assert intervals == sorted(intervals), "интервалы должны только расти при идеальных ответах"
    assert intervals[-1] > 60


def test_new_state_defaults() -> None:
    state = ReviewSnapshot()

    assert state.is_new
    assert state.easiness_factor == DEFAULT_EASINESS_FACTOR
    assert state.due_at is None


def test_quality_out_of_range_is_rejected(scheduler: ReviewScheduler) -> None:
    with pytest.raises(ValueError, match="вне диапазона"):
        scheduler.review(ReviewSnapshot(), quality=6, now=NOW)

    with pytest.raises(ValueError, match="вне диапазона"):
        scheduler.review(ReviewSnapshot(), quality=-1, now=NOW)


def test_scheduler_does_not_mutate_input(scheduler: ReviewScheduler) -> None:
    state = ReviewSnapshot(easiness_factor=2.5, repetitions=2, interval_days=6, due_at=NOW)

    scheduler.review(state, quality=5, now=NOW)

    assert state.repetitions == 2
    assert state.interval_days == 6
