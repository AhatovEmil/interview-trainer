"""Грейды: числовая шкала 0–6 с человекочитаемыми кодами.

В БД грейд хранится как SmallInteger, строковый enum намеренно не используется —
по числовой шкале считается адаптивная выдача и веса тем.
"""

from __future__ import annotations

from types import MappingProxyType
from typing import Final

GRADE_INTERN: Final = 0
GRADE_JUNIOR: Final = 1
GRADE_JUNIOR_PLUS: Final = 2
GRADE_MIDDLE: Final = 3
GRADE_MIDDLE_PLUS: Final = 4
GRADE_SENIOR: Final = 5
GRADE_LEAD: Final = 6

MIN_GRADE: Final = GRADE_INTERN
MAX_GRADE: Final = GRADE_LEAD

GRADE_CODES: Final[MappingProxyType[int, str]] = MappingProxyType(
    {
        GRADE_INTERN: "intern",
        GRADE_JUNIOR: "junior",
        GRADE_JUNIOR_PLUS: "junior_plus",
        GRADE_MIDDLE: "middle",
        GRADE_MIDDLE_PLUS: "middle_plus",
        GRADE_SENIOR: "senior",
        GRADE_LEAD: "lead",
    }
)

GRADE_TITLES: Final[MappingProxyType[int, str]] = MappingProxyType(
    {
        GRADE_INTERN: "Стажёр",
        GRADE_JUNIOR: "Junior",
        GRADE_JUNIOR_PLUS: "Junior+",
        GRADE_MIDDLE: "Middle",
        GRADE_MIDDLE_PLUS: "Middle+",
        GRADE_SENIOR: "Senior",
        GRADE_LEAD: "Lead / Staff",
    }
)

GRADE_VALUES: Final[MappingProxyType[str, int]] = MappingProxyType(
    {code: grade for grade, code in GRADE_CODES.items()}
)

ALL_GRADES: Final[tuple[int, ...]] = tuple(GRADE_CODES)


def grade_from_code(code: str) -> int:
    """Код грейда в число. Кидает ValueError на неизвестном коде."""
    try:
        return GRADE_VALUES[code]
    except KeyError:
        known = ", ".join(GRADE_VALUES)
        raise ValueError(f"неизвестный грейд {code!r}, допустимые: {known}") from None


def code_from_grade(grade: int) -> str:
    """Число в код грейда. Кидает ValueError вне диапазона 0–6."""
    try:
        return GRADE_CODES[grade]
    except KeyError:
        raise ValueError(f"грейд {grade} вне диапазона {MIN_GRADE}–{MAX_GRADE}") from None


def is_valid_grade(grade: int) -> bool:
    return MIN_GRADE <= grade <= MAX_GRADE
