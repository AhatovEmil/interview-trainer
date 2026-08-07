"""Схемы ответа для дерева таксономии. ORM-модели наружу не отдаются."""

from __future__ import annotations

from pydantic import BaseModel, Field


class GradeOut(BaseModel):
    value: int = Field(examples=[3], description="числовая шкала 0–6")
    code: str = Field(examples=["middle"])
    title: str = Field(examples=["Middle"])


class SubtopicOut(BaseModel):
    code: str = Field(examples=["gil"])
    title: str = Field(examples=["GIL"])


class TopicOut(BaseModel):
    code: str = Field(examples=["language"])
    title: str = Field(examples=["Язык"])
    subtopics: list[SubtopicOut]


class SpecializationOut(BaseModel):
    id: str = Field(examples=["backend_python"])
    title: str = Field(examples=["Python"])
    is_active: bool = Field(description="неактивные показываются в интерфейсе как «скоро»")
    topics: list[TopicOut]


class ProfessionOut(BaseModel):
    id: str = Field(examples=["backend"])
    title: str = Field(examples=["Backend-разработчик"])
    specializations: list[SpecializationOut]


class TaxonomyResponse(BaseModel):
    professions: list[ProfessionOut]
    grades: list[GradeOut]
