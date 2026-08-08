"""Офлайн-синхронизация: скачать пакет вопросов, отправить накопленные ответы."""

from __future__ import annotations

from datetime import datetime
from typing import Annotated

from fastapi import APIRouter, Query

from app.core.deps import CurrentUser, SessionDep
from app.db.models.question import Question
from app.schemas.sync import (
    QuestionPackageResponse,
    SyncAnswerResultOut,
    SyncAnswersRequest,
    SyncAnswersResponse,
    SyncOptionOut,
    SyncQuestionOut,
)
from app.services.practice import (
    AnswerSubmission,
    BatchItemResult,
    PracticeService,
    QuestionPackage,
)

router = APIRouter(prefix="/sync", tags=["sync"])


@router.get(
    "/questions",
    response_model=QuestionPackageResponse,
    summary="Пакет вопросов для офлайна",
)
async def question_package(
    user: CurrentUser,
    session: SessionDep,
    specialization: Annotated[str, Query(min_length=1, examples=["backend_python"])],
    since: Annotated[
        datetime | None,
        Query(description="метка прошлой синхронизации: отдаём только изменившееся с тех пор"),
    ] = None,
) -> QuestionPackageResponse:
    package = await PracticeService(session).question_package(specialization, since)
    return _to_package(package)


@router.post(
    "/answers",
    response_model=SyncAnswersResponse,
    summary="Отправка накопленных офлайн-ответов",
)
async def upload_answers(
    payload: SyncAnswersRequest,
    user: CurrentUser,
    session: SessionDep,
) -> SyncAnswersResponse:
    results = await PracticeService(session).submit_batch(
        user,
        [
            AnswerSubmission(
                submission_id=item.submission_id,
                question_id=item.question_id,
                specialization_id=item.specialization_id,
                selected_options=item.selected_options,
                free_text=item.free_text,
                self_assessment=item.self_assessment,
                answered_at=item.answered_at,
            )
            for item in payload.answers
        ],
    )
    await session.commit()
    return _to_response(results)


def _to_package(package: QuestionPackage) -> QuestionPackageResponse:
    return QuestionPackageResponse(
        specialization_id=package.specialization_id,
        synced_at=package.synced_at,
        questions=[
            _to_sync_question(question, package.topic_titles, package.subtopic_titles)
            for question in package.questions
        ],
    )


def _to_sync_question(
    question: Question,
    topic_titles: dict[str, str],
    subtopic_titles: dict[str, str],
) -> SyncQuestionOut:
    return SyncQuestionOut(
        id=question.id,
        type=question.type,
        title=question.title,
        topic_code=question.topic_code,
        topic_title=topic_titles.get(question.topic_code, question.topic_code),
        subtopic_code=question.subtopic_code,
        subtopic_title=(
            subtopic_titles.get(question.subtopic_code, question.subtopic_code)
            if question.subtopic_code
            else None
        ),
        min_grade=question.min_grade,
        peak_grade=question.peak_grade,
        max_grade=question.max_grade,
        frequency=question.frequency,
        options=[
            SyncOptionOut(code=option.code, text=option.text, is_correct=option.is_correct)
            for option in question.options
        ],
        is_verified=question.is_verified,
        answer_short=question.answer_short,
        answer_detailed=question.answer_detailed,
        common_mistakes=question.common_mistakes,
        follow_ups=question.follow_ups,
        updated_at=question.updated_at,
    )


def _to_response(results: list[BatchItemResult]) -> SyncAnswersResponse:
    items = [
        SyncAnswerResultOut(
            submission_id=item.submission_id,
            accepted=item.accepted,
            is_duplicate=item.result.is_duplicate if item.result else False,
            rating_after=round(item.result.rating_after, 1) if item.result else None,
            next_review_at=item.result.next_review_at if item.result else None,
            error=item.error,
        )
        for item in results
    ]
    return SyncAnswersResponse(
        # Дубли считаем отдельно: клиенту важно понять, что ответ уже был учтён,
        # а не потерян, и очередь можно чистить.
        accepted=sum(1 for item in items if item.accepted and not item.is_duplicate),
        duplicates=sum(1 for item in items if item.is_duplicate),
        rejected=sum(1 for item in items if not item.accepted),
        results=items,
    )
