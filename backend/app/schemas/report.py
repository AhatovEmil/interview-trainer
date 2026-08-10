"""Схемы краудсорсинга: пользователь присылает вопрос с собеседования."""

from __future__ import annotations

import uuid
from datetime import datetime

from pydantic import BaseModel, Field

from app.core.enums import ReportStatus
from app.core.grades import MAX_GRADE, MIN_GRADE
from app.services.reports import MIN_TITLE_LENGTH


class QuestionReportRequest(BaseModel):
    specialization_id: str = Field(min_length=1, examples=["backend_python"])
    title: str = Field(
        min_length=MIN_TITLE_LENGTH,
        max_length=2000,
        description="формулировка вопроса так, как её задали",
        examples=["Чем отличается процесс от потока и когда что выбирать?"],
    )
    topic_code: str | None = Field(
        default=None,
        max_length=64,
        description="раздел, если пользователь его выбрал; неизвестный код отбрасывается",
    )
    details: str | None = Field(
        default=None,
        max_length=4000,
        description="контекст: что уточняли дальше, чего ждали в ответе",
    )
    company: str | None = Field(default=None, max_length=128)
    asked_grade: int | None = Field(
        default=None,
        ge=MIN_GRADE,
        le=MAX_GRADE,
        description="грейд позиции, на которую собеседовали",
    )


class QuestionReportResponse(BaseModel):
    id: uuid.UUID
    status: ReportStatus
    specialization_id: str
    topic_code: str | None
    title: str
    created_at: datetime
    is_duplicate: bool = Field(
        description="такой вопрос от этого пользователя уже был — новая запись не создана"
    )
