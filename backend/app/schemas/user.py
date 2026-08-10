"""Схемы профиля пользователя."""

from __future__ import annotations

import uuid

from pydantic import BaseModel, EmailStr, Field

from app.core.grades import MAX_GRADE, MIN_GRADE

Grade = Field(ge=MIN_GRADE, le=MAX_GRADE, description="числовая шкала грейдов 0–6")


class UserSpecializationOut(BaseModel):
    specialization_id: str = Field(examples=["backend_python"])
    self_assessed_grade: int = Grade
    grade_code: str = Field(examples=["middle"])
    target_grade: int = Grade
    target_grade_code: str = Field(examples=["senior"])
    is_primary: bool
    answers_count: int


class UserResponse(BaseModel):
    id: uuid.UUID
    email: EmailStr
    is_premium: bool
    specializations: list[UserSpecializationOut]

    @property
    def primary_specialization(self) -> str | None:
        for item in self.specializations:
            if item.is_primary:
                return item.specialization_id
        return None


class UpdateProfileRequest(BaseModel):
    """Специализация, текущий уровень и уровень, к которому человек готовится."""

    specialization_id: str = Field(min_length=1, examples=["backend_python"])
    self_assessed_grade: int = Grade
    target_grade: int | None = Field(
        default=None,
        ge=MIN_GRADE,
        le=MAX_GRADE,
        description="уровень подготовки; не задан — готовимся на свой же",
        examples=[5],
    )
    is_primary: bool = True
