"""Приём вопросов, присланных пользователями с реальных собеседований.

Сервис намеренно ничего не добавляет в банк вопросов: он только фиксирует
присланное со статусом `new`. Публикация — отдельное решение человека
(CLAUDE.md §8.1), и автоматизировать её здесь было бы прямым нарушением.
"""

from __future__ import annotations

import hashlib
import re
import unicodedata
from dataclasses import dataclass
from datetime import UTC, datetime, timedelta

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.enums import ReportStatus
from app.core.exceptions import InvalidInputError, NotFoundError
from app.db.models.report import QuestionReport
from app.db.models.taxonomy import Specialization, Topic
from app.db.models.user import User

# Ограничение потока от одного пользователя. Не защита от злоумышленника —
# от случайного цикла в клиенте и от увлечённого пользователя, который за вечер
# вывалит сотню обрывков и утопит очередь модерации.
DAILY_LIMIT = 20
RATE_WINDOW = timedelta(days=1)

# Слишком короткая формулировка — это не вопрос, а обрывок: «про GIL спросили».
MIN_TITLE_LENGTH = 15

_PUNCTUATION = re.compile(r"[^\w\s]", flags=re.UNICODE)
_SPACES = re.compile(r"\s+")


def fingerprint(title: str) -> str:
    """Отпечаток формулировки для поиска дублей.

    Регистр, пунктуация и лишние пробелы отбрасываются: «Что такое GIL?» и
    «что такое gil» — один и тот же вопрос. Отпечаток хешируется, чтобы длина
    не зависела от формулировки и влезала в индекс.
    """
    folded = unicodedata.normalize("NFKC", title).casefold()
    folded = _PUNCTUATION.sub(" ", folded)
    folded = _SPACES.sub(" ", folded).strip()
    return hashlib.sha256(folded.encode()).hexdigest()


@dataclass(frozen=True, slots=True)
class ReportSubmission:
    specialization_id: str
    title: str
    topic_code: str | None = None
    details: str | None = None
    company: str | None = None
    asked_grade: int | None = None


@dataclass(frozen=True, slots=True)
class ReportResult:
    report: QuestionReport
    # Тот же вопрос уже присылали — повторная отправка не создала новую запись.
    is_duplicate: bool


class ReportService:
    def __init__(self, session: AsyncSession) -> None:
        self._session = session

    async def submit(self, user: User, submission: ReportSubmission) -> ReportResult:
        title = submission.title.strip()
        if len(title) < MIN_TITLE_LENGTH:
            raise InvalidInputError(
                f"формулировка короче {MIN_TITLE_LENGTH} символов — "
                "по такому обрывку вопрос не восстановить"
            )

        await self._ensure_specialization(submission.specialization_id)
        topic_code = await self._resolve_topic(submission.specialization_id, submission.topic_code)

        digest = fingerprint(title)
        existing = await self._session.scalar(
            select(QuestionReport).where(
                QuestionReport.user_id == user.id,
                QuestionReport.title_fingerprint == digest,
            )
        )
        if existing is not None:
            return ReportResult(report=existing, is_duplicate=True)

        await self._check_rate_limit(user)

        report = QuestionReport(
            user_id=user.id,
            specialization_id=submission.specialization_id,
            topic_code=topic_code,
            title=title,
            title_fingerprint=digest,
            details=_clean(submission.details),
            company=_clean(submission.company),
            asked_grade=submission.asked_grade,
            status=ReportStatus.NEW,
        )
        self._session.add(report)
        await self._session.flush()
        return ReportResult(report=report, is_duplicate=False)

    async def _ensure_specialization(self, specialization_id: str) -> None:
        specialization = await self._session.get(Specialization, specialization_id)
        if specialization is None:
            raise NotFoundError(f"специализация {specialization_id!r} не найдена")

    async def _resolve_topic(self, specialization_id: str, topic_code: str | None) -> str | None:
        """Неизвестный раздел не роняет отправку, а просто отбрасывается.

        Пользователь на собеседовании не обязан правильно раскладывать вопрос по
        нашей таксономии; потерять формулировку из-за неверного кода — хуже, чем
        оставить раздел пустым и разложить при модерации.
        """
        if topic_code is None:
            return None
        exists = await self._session.scalar(
            select(Topic.code).where(
                Topic.specialization_id == specialization_id,
                Topic.code == topic_code,
            )
        )
        return exists

    async def _check_rate_limit(self, user: User) -> None:
        since = datetime.now(UTC) - RATE_WINDOW
        recent = await self._session.scalar(
            select(func.count())
            .select_from(QuestionReport)
            .where(
                QuestionReport.user_id == user.id,
                QuestionReport.created_at >= since,
            )
        )
        if (recent or 0) >= DAILY_LIMIT:
            raise InvalidInputError(
                f"за сутки можно прислать не больше {DAILY_LIMIT} вопросов — "
                "остальные подождут до завтра"
            )


def _clean(value: str | None) -> str | None:
    if value is None:
        return None
    stripped = value.strip()
    return stripped or None
