"""План подготовки к собеседованию."""

from __future__ import annotations

from fastapi import APIRouter, Query, status

from app.api.v1.practice import to_question
from app.core.deps import CurrentUser, SessionDep
from app.core.grades import code_from_grade
from app.db.models.plan import StudyPlan
from app.schemas.plan import CreatePlanRequest, PlanDayOut, PlanResponse, TodayResponse
from app.services.plan import PlanService, TodayPlan

router = APIRouter(prefix="/plan", tags=["plan"])


@router.post("", response_model=PlanResponse, status_code=status.HTTP_201_CREATED)
async def create_plan(
    payload: CreatePlanRequest,
    user: CurrentUser,
    session: SessionDep,
) -> PlanResponse:
    plan = await PlanService(session).create(
        user,
        specialization_id=payload.specialization_id,
        interview_date=payload.interview_date,
        daily_capacity=payload.daily_capacity,
    )
    await session.commit()
    return _to_plan(plan)


@router.get("/today", response_model=TodayResponse, summary="Что делать сегодня")
async def today(
    user: CurrentUser,
    session: SessionDep,
    specialization: str = Query(min_length=1, examples=["backend_python"]),
) -> TodayResponse:
    result = await PlanService(session).today(user, specialization)
    return _to_today(result)


def _to_plan(plan: StudyPlan) -> PlanResponse:
    return PlanResponse(
        id=plan.id,
        specialization_id=plan.specialization_id,
        interview_date=plan.interview_date,
        target_grade=plan.target_grade,
        target_grade_code=code_from_grade(plan.target_grade),
        daily_capacity=plan.daily_capacity,
        days=[
            PlanDayOut(
                day_index=day.day_index,
                day=day.day,
                topic_codes=day.topic_codes,
                new_questions=day.new_questions,
                review_only=day.review_only,
            )
            for day in plan.days
        ],
    )


def _to_today(result: TodayPlan) -> TodayResponse:
    return TodayResponse(
        plan_id=result.plan.id,
        specialization_id=result.plan.specialization_id,
        day=result.day.day,
        day_index=result.day.day_index,
        days_left=result.days_left,
        review_only=result.day.review_only,
        topic_codes=result.day.topic_codes,
        due_reviews=result.due_reviews,
        completed_today=result.completed_today,
        total_target=result.total_target,
        new_questions=[to_question(question) for question in result.new_questions],
    )
