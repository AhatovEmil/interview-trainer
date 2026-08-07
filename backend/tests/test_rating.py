"""Юнит-тесты Elo. Без БД: проверяется математика из CLAUDE.md §3.5."""

import pytest

from app.core.grades import (
    GRADE_INTERN,
    GRADE_JUNIOR,
    GRADE_JUNIOR_PLUS,
    GRADE_LEAD,
    GRADE_MIDDLE,
    GRADE_MIDDLE_PLUS,
    GRADE_SENIOR,
)
from app.services.rating import (
    EXPERIENCE_THRESHOLD,
    K_EXPERIENCED,
    K_INITIAL,
    K_QUESTION,
    SCORE_CORRECT,
    SCORE_PARTIAL,
    SCORE_WRONG,
    START_RATING,
    apply_elo,
    expected_score,
    grade_from_rating,
    normalized_rating,
    overall_rating,
    quality_from_score,
    score_from_quality,
    user_k_factor,
)


def test_expected_score_is_half_for_equal_ratings() -> None:
    assert expected_score(1200, 1200) == pytest.approx(0.5)


def test_expected_score_grows_when_question_is_easier() -> None:
    assert expected_score(1600, 1200) > 0.9
    assert expected_score(1200, 1600) < 0.1


def test_expected_score_matches_formula_for_400_points() -> None:
    """Разница в 400 очков — классическое соотношение 10 к 1."""
    assert expected_score(1600, 1200) == pytest.approx(10 / 11, abs=1e-6)


def test_k_factor_drops_after_threshold() -> None:
    assert user_k_factor(0) == K_INITIAL
    assert user_k_factor(EXPERIENCE_THRESHOLD - 1) == K_INITIAL
    assert user_k_factor(EXPERIENCE_THRESHOLD) == K_EXPERIENCED


# --- Приёмка этапа 3 --------------------------------------------------------------


def test_rating_grows_a_lot_on_hard_question_answered_right() -> None:
    """Верный ответ на сложный вопрос заметно поднимает рейтинг."""
    update = apply_elo(
        user_rating=START_RATING,
        question_rating=1700,
        score=SCORE_CORRECT,
        answers_on_topic=0,
    )

    assert update.user_delta > 0
    assert update.user_delta > 25, "за сложный вопрос ожидается почти полный K"
    assert update.question_delta < 0, "вопрос, который взяли, становится легче"


def test_rating_drops_a_lot_on_easy_question_answered_wrong() -> None:
    """Провал на лёгком вопросе заметно роняет рейтинг."""
    update = apply_elo(
        user_rating=START_RATING,
        question_rating=900,
        score=SCORE_WRONG,
        answers_on_topic=0,
    )

    assert update.user_delta < 0
    assert update.user_delta < -25
    assert update.question_delta > 0, "вопрос, на котором завалились, становится сложнее"


def test_easy_question_answered_right_moves_rating_barely() -> None:
    update = apply_elo(START_RATING, 900, SCORE_CORRECT, 0)

    assert 0 < update.user_delta < 6


def test_hard_question_answered_wrong_moves_rating_barely() -> None:
    update = apply_elo(START_RATING, 1700, SCORE_WRONG, 0)

    assert -6 < update.user_delta < 0


def test_partial_answer_on_equal_question_keeps_rating() -> None:
    update = apply_elo(START_RATING, int(START_RATING), SCORE_PARTIAL, 0)

    assert update.user_delta == pytest.approx(0.0)


def test_experienced_user_moves_slower() -> None:
    novice = apply_elo(START_RATING, 1700, SCORE_CORRECT, answers_on_topic=0)
    veteran = apply_elo(START_RATING, 1700, SCORE_CORRECT, answers_on_topic=EXPERIENCE_THRESHOLD)

    assert abs(veteran.user_delta) < abs(novice.user_delta)
    assert veteran.user_delta == pytest.approx(novice.user_delta * K_EXPERIENCED / K_INITIAL)


def test_question_rating_moves_slower_than_user_rating() -> None:
    update = apply_elo(START_RATING, 1700, SCORE_CORRECT, 0)

    assert abs(update.question_delta) <= K_QUESTION


def test_repeated_wins_push_rating_up_monotonically() -> None:
    rating = START_RATING
    for _ in range(10):
        rating = apply_elo(rating, 1500, SCORE_CORRECT, 0).user_rating_after

    assert rating > START_RATING + 100


# --- Маппинг рейтинга в грейд -----------------------------------------------------


@pytest.mark.parametrize(
    ("rating", "expected"),
    [
        (800, GRADE_INTERN),
        (999.9, GRADE_INTERN),
        (1000, GRADE_JUNIOR),
        (1149, GRADE_JUNIOR),
        (1150, GRADE_JUNIOR_PLUS),
        (1299, GRADE_JUNIOR_PLUS),
        (1300, GRADE_MIDDLE),
        (1449, GRADE_MIDDLE),
        (1450, GRADE_MIDDLE_PLUS),
        (1599, GRADE_MIDDLE_PLUS),
        (1600, GRADE_SENIOR),
        (1799, GRADE_SENIOR),
        (1800, GRADE_LEAD),
        (2400, GRADE_LEAD),
    ],
)
def test_grade_from_rating(rating: float, expected: int) -> None:
    assert grade_from_rating(rating) == expected


def test_start_rating_maps_to_junior_plus() -> None:
    assert grade_from_rating(START_RATING) == GRADE_JUNIOR_PLUS


# --- Взвешенная оценка по специализации -------------------------------------------


def test_overall_rating_respects_weights() -> None:
    ratings = {"language": 1000.0, "system_design": 1800.0}

    language_heavy = overall_rating(ratings, {"language": 1.0, "system_design": 0.0})
    design_heavy = overall_rating(ratings, {"language": 0.0, "system_design": 1.0})

    assert language_heavy == pytest.approx(1000.0)
    assert design_heavy == pytest.approx(1800.0)


def test_overall_rating_is_weighted_average() -> None:
    ratings = {"language": 1200.0, "db": 1600.0}
    weights = {"language": 1.0, "db": 3.0}

    assert overall_rating(ratings, weights) == pytest.approx((1200 + 1600 * 3) / 4)


def test_overall_rating_without_weighted_topics_is_none() -> None:
    assert overall_rating({"language": 1400.0}, {"language": 0.0}) is None
    assert overall_rating({}, {"language": 1.0}) is None


def test_normalized_rating_is_clamped() -> None:
    assert normalized_rating(500) == 0.0
    assert normalized_rating(2500) == 1.0
    assert normalized_rating(1400) == pytest.approx(0.5)


# --- Оценка ответа ----------------------------------------------------------------


@pytest.mark.parametrize(
    ("quality", "score"),
    [
        (0, SCORE_WRONG),
        (2, SCORE_WRONG),
        (3, SCORE_PARTIAL),
        (4, SCORE_CORRECT),
        (5, SCORE_CORRECT),
    ],
)
def test_score_from_quality(quality: int, score: float) -> None:
    assert score_from_quality(quality) == score


def test_quality_from_score_round_trips_to_same_score() -> None:
    for score in (SCORE_WRONG, SCORE_PARTIAL, SCORE_CORRECT):
        assert score_from_quality(quality_from_score(score)) == score
