"""Вопрос, присланный пользователем с реального собеседования (CLAUDE.md §7).

Присланное не попадает в банк напрямую: банк — это выверенный контент, а поток
из приложения содержит опечатки, дубли и обрывки формулировок. Отчёт живёт в
отдельной таблице со статусом модерации, и только принятый превращается в
вопрос с `source=crowdsourced`.
"""

from __future__ import annotations

import uuid

from sqlalchemy import (
    CheckConstraint,
    Enum,
    ForeignKey,
    Index,
    SmallInteger,
    String,
    Text,
    UniqueConstraint,
)
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.core.enums import ReportStatus
from app.core.grades import MAX_GRADE, MIN_GRADE
from app.db.base import Base, TimestampMixin


class QuestionReport(Base, TimestampMixin):
    __tablename__ = "question_reports"
    __table_args__ = (
        CheckConstraint(
            f"asked_grade IS NULL OR asked_grade BETWEEN {MIN_GRADE} AND {MAX_GRADE}",
            name="asked_grade_range",
        ),
        # Один и тот же вопрос от одного пользователя учитывается один раз:
        # повторная отправка (ретрай, две вкладки) возвращает прежний отчёт.
        UniqueConstraint("user_id", "title_fingerprint", name="user_id_title_fingerprint"),
        Index("ix_question_reports_status", "status", "created_at"),
    )

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    specialization_id: Mapped[str] = mapped_column(
        ForeignKey("specializations.id", ondelete="CASCADE"),
        nullable=False,
    )
    # Раздел указывает пользователь, и он может ошибиться: проверяем по таксономии,
    # но не требуем — вопрос без раздела полезнее, чем неотправленный.
    topic_code: Mapped[str | None] = mapped_column(String(64), nullable=True)

    title: Mapped[str] = mapped_column(Text, nullable=False)
    # Нормализованная формулировка: по ней ищутся дубли, наружу не отдаётся.
    title_fingerprint: Mapped[str] = mapped_column(String(128), nullable=False)
    details: Mapped[str | None] = mapped_column(Text, nullable=True)
    company: Mapped[str | None] = mapped_column(String(128), nullable=True)
    asked_grade: Mapped[int | None] = mapped_column(SmallInteger, nullable=True)

    status: Mapped[ReportStatus] = mapped_column(
        Enum(
            ReportStatus,
            name="report_status",
            native_enum=False,
            length=32,
            values_callable=lambda members: [member.value for member in members],
        ),
        nullable=False,
        default=ReportStatus.NEW,
    )
    # Заполняется модератором при отклонении — пользователю показывать необязательно,
    # но без причины разбор накопившегося потока превращается в гадание.
    moderation_note: Mapped[str | None] = mapped_column(Text, nullable=True)
