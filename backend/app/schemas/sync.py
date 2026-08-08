"""Схемы офлайн-синхронизации.

Отличие от `practice`: пакет вопросов уходит на устройство целиком, вместе с
разборами и признаком правильности вариантов. Иначе в самолёте нечем показать
результат ответа. Плата за это — банк вопросов лежит на устройстве в открытом
виде; для бесплатного контента это приемлемо, платные разборы сюда попадать
не должны.
"""

from __future__ import annotations

import uuid
from datetime import datetime

from pydantic import BaseModel, Field

from app.core.enums import QuestionType
from app.core.grades import MAX_GRADE, MIN_GRADE


class SyncOptionOut(BaseModel):
    code: str
    text: str
    # В отличие от выдачи по одному вопросу — правильность едет на устройство:
    # без неё офлайн не проверить ответ.
    is_correct: bool


class SyncQuestionOut(BaseModel):
    id: uuid.UUID
    type: QuestionType
    title: str
    topic_code: str
    topic_title: str
    subtopic_code: str | None
    subtopic_title: str | None
    min_grade: int = Field(ge=MIN_GRADE, le=MAX_GRADE)
    peak_grade: int = Field(ge=MIN_GRADE, le=MAX_GRADE)
    max_grade: int = Field(ge=MIN_GRADE, le=MAX_GRADE)
    frequency: int = Field(ge=1, le=5)
    options: list[SyncOptionOut]
    is_verified: bool

    answer_short: str
    answer_detailed: str
    common_mistakes: list[str]
    follow_ups: list[str]

    updated_at: datetime


class QuestionPackageResponse(BaseModel):
    specialization_id: str
    # Метка сервера: клиент присылает её в следующий раз как `since`.
    synced_at: datetime
    questions: list[SyncQuestionOut]


class SyncAnswerIn(BaseModel):
    submission_id: uuid.UUID
    question_id: uuid.UUID
    specialization_id: str = Field(min_length=1)
    selected_options: list[str] = Field(default_factory=list)
    free_text: str | None = None
    self_assessment: int | None = Field(default=None, ge=0, le=5)
    # Время по часам устройства. Сервер обрежет будущее и слишком старое.
    answered_at: datetime


class SyncAnswersRequest(BaseModel):
    answers: list[SyncAnswerIn] = Field(min_length=1, max_length=500)


class SyncAnswerResultOut(BaseModel):
    submission_id: uuid.UUID
    accepted: bool
    is_duplicate: bool = False
    rating_after: float | None = None
    next_review_at: datetime | None = None
    error: str | None = None


class SyncAnswersResponse(BaseModel):
    accepted: int
    duplicates: int
    rejected: int
    results: list[SyncAnswerResultOut]
