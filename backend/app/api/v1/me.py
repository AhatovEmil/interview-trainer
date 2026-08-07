"""Профиль текущего пользователя."""

from __future__ import annotations

from fastapi import APIRouter

from app.core.deps import CurrentUser, SessionDep
from app.core.grades import code_from_grade
from app.db.models.user import User, UserSpecialization
from app.schemas.user import UpdateProfileRequest, UserResponse, UserSpecializationOut
from app.services.user import UserService

router = APIRouter(prefix="/me", tags=["me"])


@router.get("", response_model=UserResponse, summary="Текущий профиль")
async def get_me(user: CurrentUser, session: SessionDep) -> UserResponse:
    specializations = await UserService(session).list_specializations(user)
    return _to_response(user, specializations)


@router.patch("", response_model=UserResponse, summary="Специализация и самооценка грейда")
async def update_me(
    payload: UpdateProfileRequest,
    user: CurrentUser,
    session: SessionDep,
) -> UserResponse:
    service = UserService(session)
    await service.set_specialization(
        user,
        specialization_id=payload.specialization_id,
        self_assessed_grade=payload.self_assessed_grade,
        is_primary=payload.is_primary,
    )
    specializations = await service.list_specializations(user)
    await session.commit()
    return _to_response(user, specializations)


def _to_response(user: User, specializations: list[UserSpecialization]) -> UserResponse:
    return UserResponse(
        id=user.id,
        email=user.email,
        is_premium=user.is_premium,
        specializations=[
            UserSpecializationOut(
                specialization_id=row.specialization_id,
                self_assessed_grade=row.self_assessed_grade,
                grade_code=code_from_grade(row.self_assessed_grade),
                is_primary=row.is_primary,
                answers_count=row.answers_count,
            )
            for row in specializations
        ],
    )
