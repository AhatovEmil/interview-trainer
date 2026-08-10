"""target grade

Revision ID: e0bdc0ed4b5d
Revises: 5a229104b98f
Create Date: 2026-08-10 10:20:42.495131

Целевой грейд — уровень, к которому человек готовится. Раньше выдача считалась
по самооценке, то есть тренировала текущий уровень, а не тот, на который идут
собеседоваться.

Автогенерация здесь не годилась: она добавляла NOT NULL-колонку без значения
(упало бы на непустой таблице) и не заметила, что диапазонная проверка тоже
изменилась — сравнение check-констрейнтов идёт по имени, а не по телу.
"""

from __future__ import annotations

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "e0bdc0ed4b5d"
down_revision: str | None = "5a229104b98f"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None

# Соглашение об именах достраивает ck_<таблица>_<имя>, поэтому создаём по
# короткому имени, а удаляем по полному через op.f().
_RANGE = "grade_range"
_TARGET_NOT_BELOW = "target_not_below_current"
_RANGE_FULL = op.f("ck_user_specializations_grade_range")
_TARGET_NOT_BELOW_FULL = op.f("ck_user_specializations_target_not_below_current")


def upgrade() -> None:
    # Колонка добавляется допускающей NULL, заполняется самооценкой и только
    # потом становится обязательной: у существующих профилей цель совпадает с
    # текущим уровнем, и это верное значение по умолчанию.
    op.add_column(
        "user_specializations",
        sa.Column("target_grade", sa.SmallInteger(), nullable=True),
    )
    op.execute("UPDATE user_specializations SET target_grade = self_assessed_grade")
    op.alter_column("user_specializations", "target_grade", nullable=False)

    op.drop_constraint(_RANGE_FULL, "user_specializations", type_="check")
    op.create_check_constraint(
        _RANGE,
        "user_specializations",
        "self_assessed_grade BETWEEN 0 AND 6 AND target_grade BETWEEN 0 AND 6",
    )
    op.create_check_constraint(
        _TARGET_NOT_BELOW,
        "user_specializations",
        "target_grade >= self_assessed_grade",
    )


def downgrade() -> None:
    op.drop_constraint(_TARGET_NOT_BELOW_FULL, "user_specializations", type_="check")
    op.drop_constraint(_RANGE_FULL, "user_specializations", type_="check")
    op.create_check_constraint(
        _RANGE,
        "user_specializations",
        "self_assessed_grade BETWEEN 0 AND 6",
    )
    op.drop_column("user_specializations", "target_grade")
