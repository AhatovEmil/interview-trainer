"""Дерево профессий, специализаций и тем."""

from __future__ import annotations

from typing import Annotated

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.grades import ALL_GRADES, GRADE_CODES, GRADE_TITLES
from app.db.session import get_session
from app.schemas.taxonomy import (
    GradeOut,
    ProfessionOut,
    SpecializationOut,
    SubtopicOut,
    TaxonomyResponse,
    TopicOut,
)
from app.services.taxonomy import TaxonomyService

router = APIRouter(tags=["taxonomy"])


@router.get("/taxonomy", response_model=TaxonomyResponse, summary="Дерево профессий и тем")
async def get_taxonomy(session: Annotated[AsyncSession, Depends(get_session)]) -> TaxonomyResponse:
    professions = await TaxonomyService(session).get_tree()

    return TaxonomyResponse(
        professions=[
            ProfessionOut(
                id=profession.id,
                title=profession.title,
                specializations=[
                    SpecializationOut(
                        id=specialization.id,
                        title=specialization.title,
                        is_active=specialization.is_active,
                        topics=[
                            TopicOut(
                                code=topic.code,
                                title=topic.title,
                                subtopics=[
                                    SubtopicOut(code=subtopic.code, title=subtopic.title)
                                    for subtopic in topic.subtopics
                                ],
                            )
                            for topic in specialization.topics
                        ],
                    )
                    for specialization in profession.specializations
                ],
            )
            for profession in professions
        ],
        grades=[
            GradeOut(value=grade, code=GRADE_CODES[grade], title=GRADE_TITLES[grade])
            for grade in ALL_GRADES
        ],
    )
