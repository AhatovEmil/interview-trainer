"""Схемы тренировки: выдача вопроса, приём ответа, статистика."""

from __future__ import annotations

import uuid
from datetime import datetime
from typing import Self

from pydantic import BaseModel, Field, model_validator

from app.core.enums import QuestionType
from app.core.grades import MAX_GRADE, MIN_GRADE
from app.services.scheduler import MAX_QUALITY, MIN_QUALITY


class QuestionOptionOut(BaseModel):
    code: str = Field(examples=["a"])
    text: str


class QuestionOut(BaseModel):
    """Вопрос без ответа: разбор приходит только после отправки ответа."""

    id: uuid.UUID
    type: QuestionType
    title: str
    topic_code: str
    # Человекочитаемое название темы: интерфейсу незачем знать про коды.
    topic_title: str
    subtopic_code: str | None
    subtopic_title: str | None
    min_grade: int = Field(ge=MIN_GRADE, le=MAX_GRADE)
    peak_grade: int = Field(ge=MIN_GRADE, le=MAX_GRADE)
    max_grade: int = Field(ge=MIN_GRADE, le=MAX_GRADE)
    frequency: int = Field(ge=1, le=5)
    options: list[QuestionOptionOut]
    is_verified: bool


class NextQuestionResponse(BaseModel):
    question: QuestionOut
    is_review: bool = Field(description="вопрос пришёл из очереди повторений, а не как новый")
    due_at: datetime | None = None


class QuestionExplanation(BaseModel):
    answer_short: str
    answer_detailed: str
    common_mistakes: list[str]
    follow_ups: list[str]


class AnswerRequest(BaseModel):
    # Идентификатор попытки генерирует клиент: повтор при ретрае или офлайн-синхронизации
    # не должен двигать рейтинг второй раз.
    submission_id: uuid.UUID
    question_id: uuid.UUID
    specialization_id: str = Field(min_length=1)
    selected_options: list[str] = Field(default_factory=list)
    free_text: str | None = None
    self_assessment: int | None = Field(default=None, ge=MIN_QUALITY, le=MAX_QUALITY)

    @model_validator(mode="after")
    def check_answer_present(self) -> Self:
        if not self.selected_options and self.self_assessment is None:
            raise ValueError(
                "нужен либо selected_options для выборочного вопроса, "
                "либо self_assessment 0–5 для развёрнутого"
            )
        return self


class AnswerResponse(BaseModel):
    score: float = Field(description="1.0 верно, 0.5 частично, 0.0 неверно")
    quality: int = Field(ge=MIN_QUALITY, le=MAX_QUALITY)
    rating_before: float
    rating_after: float
    rating_delta: float
    grade: int = Field(ge=MIN_GRADE, le=MAX_GRADE)
    grade_code: str
    difficulty_before: int
    difficulty_after: int
    next_review_at: datetime
    is_duplicate: bool = Field(description="ответ уже был принят ранее, рейтинг не менялся")
    explanation: QuestionExplanation


class TopicStatsOut(BaseModel):
    topic_code: str
    title: str
    rating: float
    grade: int = Field(ge=MIN_GRADE, le=MAX_GRADE)
    grade_code: str
    answers_count: int
    weight: float


class StatsResponse(BaseModel):
    specialization_id: str
    answers_count: int
    topics: list[TopicStatsOut]
    overall_rating: float | None = None
    overall_grade: int | None = None
    overall_grade_code: str | None = None
    locked_reason: str | None = Field(
        default=None,
        description="not_enough_data — мало ответов, premium_required — нужен платный тариф",
    )
