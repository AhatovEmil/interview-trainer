"""Схемы плана подготовки."""

from __future__ import annotations

import uuid
from datetime import date

from pydantic import BaseModel, Field

from app.core.grades import MAX_GRADE, MIN_GRADE
from app.schemas.practice import QuestionOut
from app.services.planner import DEFAULT_DAILY_CAPACITY, MAX_PLAN_DAYS


class CreatePlanRequest(BaseModel):
    specialization_id: str = Field(min_length=1, examples=["backend_python"])
    interview_date: date = Field(description="дата собеседования, строго в будущем")
    daily_capacity: int = Field(
        default=DEFAULT_DAILY_CAPACITY,
        ge=1,
        le=100,
        description="сколько вопросов в день готов проходить пользователь",
    )


class PlanDayOut(BaseModel):
    day_index: int
    day: date
    topic_codes: list[str]
    new_questions: int
    review_only: bool = Field(description="день закрепления: только повторение пройденного")


class PlanResponse(BaseModel):
    id: uuid.UUID
    specialization_id: str
    interview_date: date
    target_grade: int = Field(ge=MIN_GRADE, le=MAX_GRADE)
    target_grade_code: str
    daily_capacity: int = Field(le=100)
    days: list[PlanDayOut] = Field(max_length=MAX_PLAN_DAYS)


class TodayResponse(BaseModel):
    plan_id: uuid.UUID
    specialization_id: str
    day: date
    day_index: int
    days_left: int = Field(description="сколько дней осталось до собеседования")
    review_only: bool
    topic_codes: list[str]
    due_reviews: int = Field(description="вопросов из очереди повторений на сегодня")
    completed_today: int
    total_target: int
    new_questions: list[QuestionOut]
