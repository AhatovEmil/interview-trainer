"""Elo-оценка уровня пользователя (CLAUDE.md §3.5).

Математика вынесена в чистые функции: их можно проверить юнит-тестами без БД.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Final

from app.core.grades import (
    GRADE_INTERN,
    GRADE_JUNIOR,
    GRADE_JUNIOR_PLUS,
    GRADE_LEAD,
    GRADE_MIDDLE,
    GRADE_MIDDLE_PLUS,
    GRADE_SENIOR,
)

START_RATING: Final = 1200.0

K_INITIAL: Final = 32
K_EXPERIENCED: Final = 16
K_QUESTION: Final = 4
EXPERIENCE_THRESHOLD: Final = 30

# Пока ответов меньше, оценку уровня не показываем — «собираем данные».
MIN_ANSWERS_FOR_ESTIMATE: Final = 20

SCORE_CORRECT: Final = 1.0
SCORE_PARTIAL: Final = 0.5
SCORE_WRONG: Final = 0.0

# Нижние границы рейтинга для каждого грейда, по убыванию.
_GRADE_THRESHOLDS: Final[tuple[tuple[float, int], ...]] = (
    (1800.0, GRADE_LEAD),
    (1600.0, GRADE_SENIOR),
    (1450.0, GRADE_MIDDLE_PLUS),
    (1300.0, GRADE_MIDDLE),
    (1150.0, GRADE_JUNIOR_PLUS),
    (1000.0, GRADE_JUNIOR),
)

# Диапазон, в котором рейтинг нормализуется в 0..1 для приоритета тем в плане.
NORMALIZE_MIN: Final = 1000.0
NORMALIZE_MAX: Final = 1800.0


@dataclass(frozen=True, slots=True)
class EloUpdate:
    user_rating_before: float
    user_rating_after: float
    question_rating_before: int
    question_rating_after: int

    @property
    def user_delta(self) -> float:
        return self.user_rating_after - self.user_rating_before

    @property
    def question_delta(self) -> int:
        return self.question_rating_after - self.question_rating_before


def expected_score(user_rating: float, question_rating: float) -> float:
    """Вероятность верного ответа по формуле Elo."""
    return float(1.0 / (1.0 + 10.0 ** ((question_rating - user_rating) / 400.0)))


def user_k_factor(answers_on_topic: int) -> int:
    """Новичок по теме двигается быстрее: рейтинг должен быстро найти уровень."""
    return K_INITIAL if answers_on_topic < EXPERIENCE_THRESHOLD else K_EXPERIENCED


def apply_elo(
    user_rating: float,
    question_rating: int,
    score: float,
    answers_on_topic: int,
) -> EloUpdate:
    """Пересчитать рейтинги пользователя и вопроса после одного ответа."""
    expected = expected_score(user_rating, question_rating)
    k_user = user_k_factor(answers_on_topic)

    new_user_rating = user_rating + k_user * (score - expected)
    new_question_rating = round(question_rating - K_QUESTION * (score - expected))

    return EloUpdate(
        user_rating_before=user_rating,
        user_rating_after=new_user_rating,
        question_rating_before=question_rating,
        question_rating_after=new_question_rating,
    )


def grade_from_rating(rating: float) -> int:
    for threshold, grade in _GRADE_THRESHOLDS:
        if rating >= threshold:
            return grade
    return GRADE_INTERN


def normalized_rating(rating: float) -> float:
    """Рейтинг в шкале 0..1 — множитель приоритета темы в плане подготовки."""
    span = NORMALIZE_MAX - NORMALIZE_MIN
    return min(1.0, max(0.0, (rating - NORMALIZE_MIN) / span))


def overall_rating(ratings: dict[str, float], weights: dict[str, float]) -> float | None:
    """Взвешенное среднее по темам; вес темы берётся для целевого грейда.

    Темы без веса игнорируются, темы без рейтинга не учитываются вовсе:
    иначе нетронутый раздел тянул бы оценку к стартовым 1200.
    """
    numerator = 0.0
    denominator = 0.0
    for topic_code, rating in ratings.items():
        weight = weights.get(topic_code, 0.0)
        if weight <= 0.0:
            continue
        numerator += rating * weight
        denominator += weight

    if denominator == 0.0:
        return None
    return numerator / denominator


def score_from_quality(quality: int) -> float:
    """Самооценка 0–5 в Elo-очки: 4–5 верно, 3 частично, ниже — неверно."""
    if quality >= 4:
        return SCORE_CORRECT
    if quality == 3:
        return SCORE_PARTIAL
    return SCORE_WRONG


def quality_from_score(score: float) -> int:
    """Обратное преобразование для выборочных вопросов, где нет самооценки."""
    if score >= SCORE_CORRECT:
        return 5
    if score >= SCORE_PARTIAL:
        return 3
    return 1
