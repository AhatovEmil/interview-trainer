"""Тренировка: следующий вопрос, приём ответа, статистика по темам."""

from __future__ import annotations

from fastapi import APIRouter, Query

from app.core.deps import CurrentUser, SessionDep
from app.core.grades import code_from_grade
from app.db.models.question import Question
from app.schemas.practice import (
    AnswerRequest,
    AnswerResponse,
    NextQuestionResponse,
    QuestionExplanation,
    QuestionOptionOut,
    QuestionOut,
    StatsResponse,
    TopicStatsOut,
)
from app.services.practice import AnswerResult, AnswerSubmission, PracticeService

router = APIRouter(prefix="/practice", tags=["practice"])


@router.get("/next", response_model=NextQuestionResponse, summary="Следующий вопрос")
async def next_question(
    user: CurrentUser,
    session: SessionDep,
    specialization: str = Query(min_length=1, examples=["backend_python"]),
) -> NextQuestionResponse:
    result = await PracticeService(session).next_question(user, specialization)
    return NextQuestionResponse(
        question=to_question(
            result.question,
            topic_title=result.topic_title,
            subtopic_title=result.subtopic_title,
        ),
        is_review=result.is_review,
        due_at=result.due_at,
    )


@router.post("/answer", response_model=AnswerResponse, summary="Ответ и разбор")
async def submit_answer(
    payload: AnswerRequest,
    user: CurrentUser,
    session: SessionDep,
) -> AnswerResponse:
    result = await PracticeService(session).submit_answer(
        user,
        AnswerSubmission(
            submission_id=payload.submission_id,
            question_id=payload.question_id,
            specialization_id=payload.specialization_id,
            selected_options=payload.selected_options,
            free_text=payload.free_text,
            self_assessment=payload.self_assessment,
        ),
    )
    await session.commit()
    return _to_answer(result)


@router.get("/stats", response_model=StatsResponse, summary="Рейтинги по темам и оценка грейда")
async def stats(
    user: CurrentUser,
    session: SessionDep,
    specialization: str = Query(min_length=1, examples=["backend_python"]),
) -> StatsResponse:
    result = await PracticeService(session).stats(user, specialization)
    return StatsResponse(
        specialization_id=result.specialization_id,
        answers_count=result.answers_count,
        topics=[
            TopicStatsOut(
                topic_code=topic.topic_code,
                title=topic.title,
                rating=round(topic.rating, 1),
                grade=topic.grade,
                grade_code=code_from_grade(topic.grade),
                answers_count=topic.answers_count,
                weight=topic.weight,
            )
            for topic in result.topics
        ],
        overall_rating=round(result.overall_rating, 1) if result.overall_rating else None,
        overall_grade=result.overall_grade,
        overall_grade_code=(
            code_from_grade(result.overall_grade) if result.overall_grade is not None else None
        ),
        locked_reason=result.locked_reason,
    )


def to_question(
    question: Question,
    *,
    topic_title: str | None = None,
    subtopic_title: str | None = None,
) -> QuestionOut:
    return QuestionOut(
        id=question.id,
        type=question.type,
        title=question.title,
        topic_code=question.topic_code,
        # Без таксономии под рукой откатываемся на код — лучше, чем пустая строка.
        topic_title=topic_title or question.topic_code,
        subtopic_code=question.subtopic_code,
        subtopic_title=subtopic_title,
        min_grade=question.min_grade,
        peak_grade=question.peak_grade,
        max_grade=question.max_grade,
        frequency=question.frequency,
        # Правильность вариантов наружу до ответа не уходит.
        options=[
            QuestionOptionOut(code=option.code, text=option.text) for option in question.options
        ],
        is_verified=question.is_verified,
    )


def _to_answer(result: AnswerResult) -> AnswerResponse:
    question = result.question
    return AnswerResponse(
        score=result.score,
        quality=result.quality,
        rating_before=round(result.rating_before, 1),
        rating_after=round(result.rating_after, 1),
        rating_delta=round(result.rating_delta, 1),
        grade=result.grade,
        grade_code=code_from_grade(result.grade),
        difficulty_before=result.difficulty_before,
        difficulty_after=result.difficulty_after,
        next_review_at=result.next_review_at,
        is_duplicate=result.is_duplicate,
        explanation=QuestionExplanation(
            answer_short=question.answer_short,
            answer_detailed=question.answer_detailed,
            common_mistakes=question.common_mistakes,
            follow_ups=question.follow_ups,
        ),
    )
