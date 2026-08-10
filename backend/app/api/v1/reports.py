"""Краудсорсинг: пользователь присылает вопрос с собеседования (CLAUDE.md §7)."""

from __future__ import annotations

from fastapi import APIRouter, status

from app.core.deps import CurrentUser, SessionDep
from app.schemas.report import QuestionReportRequest, QuestionReportResponse
from app.services.reports import ReportService, ReportSubmission

router = APIRouter(prefix="/questions", tags=["questions"])


@router.post(
    "/report",
    response_model=QuestionReportResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Прислать вопрос с собеседования",
    description=(
        "Вопрос попадает в очередь модерации со статусом new и в банк сам по себе "
        "не добавляется: публикует его человек."
    ),
)
async def report_question(
    payload: QuestionReportRequest,
    user: CurrentUser,
    session: SessionDep,
) -> QuestionReportResponse:
    result = await ReportService(session).submit(
        user,
        ReportSubmission(
            specialization_id=payload.specialization_id,
            title=payload.title,
            topic_code=payload.topic_code,
            details=payload.details,
            company=payload.company,
            asked_grade=payload.asked_grade,
        ),
    )
    await session.commit()

    report = result.report
    return QuestionReportResponse(
        id=report.id,
        status=report.status,
        specialization_id=report.specialization_id,
        topic_code=report.topic_code,
        title=report.title,
        created_at=report.created_at,
        is_duplicate=result.is_duplicate,
    )
