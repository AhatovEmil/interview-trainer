"""Сид таксономии: python -m app.seed.taxonomy [путь/к/taxonomy.yaml]

Идемпотентен: повторный запуск не создаёт дублей и не меняет данные.
"""

from __future__ import annotations

import argparse
import asyncio
import logging
import sys
from pathlib import Path

from app.core.config import get_settings
from app.db.session import dispose_engine, get_session_factory
from app.seed.loader import ContentError, load_taxonomy
from app.services.taxonomy import SyncReport, TaxonomyService

logger = logging.getLogger("seed.taxonomy")


async def seed_taxonomy(path: Path) -> SyncReport:
    payload = load_taxonomy(path)

    async with get_session_factory()() as session:
        report = await TaxonomyService(session).sync(payload)
        await session.commit()
    return report


def _parse_args(argv: list[str] | None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Загрузка таксономии из YAML в базу")
    parser.add_argument(
        "path",
        nargs="?",
        type=Path,
        default=None,
        help="путь к taxonomy.yaml (по умолчанию — из настроек CONTENT_DIR)",
    )
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    logging.basicConfig(level=logging.INFO, format="%(message)s")
    args = _parse_args(argv)
    path = args.path or get_settings().taxonomy_file

    try:
        report = asyncio.run(_run(path))
    except ContentError as exc:
        print(f"Ошибка контента: {exc}", file=sys.stderr)
        return 1

    logger.info("Таксономия загружена из %s", path)
    for line in report.as_lines():
        logger.info("  %s", line)
    if not report.has_changes:
        logger.info("  изменений нет — база уже соответствует файлу")
    return 0


async def _run(path: Path) -> SyncReport:
    try:
        return await seed_taxonomy(path)
    finally:
        await dispose_engine()


if __name__ == "__main__":
    raise SystemExit(main())
