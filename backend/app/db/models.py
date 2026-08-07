"""Реестр ORM-моделей.

Все модели импортируются здесь, чтобы Alembic видел полную metadata.
На этапе 0 моделей ещё нет — они появятся на этапе 1 (таксономия).
"""

from __future__ import annotations

from app.db.base import Base

__all__ = ["Base"]
