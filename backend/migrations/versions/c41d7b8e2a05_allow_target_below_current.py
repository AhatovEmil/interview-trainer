"""allow target grade below current

Revision ID: c41d7b8e2a05
Revises: e0bdc0ed4b5d
Create Date: 2026-08-10 16:40:00.000000

Ограничение «цель не ниже текущего уровня» оказалось неверным. Повторить основы
перед собеседованием — обычное дело, и запрет мешал вместо того, чтобы помогать.
"""

from __future__ import annotations

from collections.abc import Sequence

from alembic import op

revision: str = "c41d7b8e2a05"
down_revision: str | None = "e0bdc0ed4b5d"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None

_NAME = op.f("ck_user_specializations_target_not_below_current")


def upgrade() -> None:
    op.drop_constraint(_NAME, "user_specializations", type_="check")


def downgrade() -> None:
    op.create_check_constraint(
        "target_not_below_current",
        "user_specializations",
        "target_grade >= self_assessed_grade",
    )
