"""Сид банка вопросов: python -m app.seed.questions [файл ...]

Без аргументов грузит все content/questions/*.yaml. Идемпотентен: id вопроса
выводится из slug, повторный запуск не создаёт дублей.
"""

from __future__ import annotations

import argparse
import asyncio
import logging
import sys
from pathlib import Path

from app.core.config import get_settings
from app.db.session import dispose_engine, get_session_factory
from app.seed.loader import ContentError, load_questions, load_taxonomy
from app.seed.question_schema import QuestionIn
from app.services.questions import QuestionService, QuestionSyncReport

logger = logging.getLogger("seed.questions")


def collect_files(paths: list[Path] | None) -> list[Path]:
    if paths:
        return paths

    questions_dir = get_settings().questions_dir
    if not questions_dir.is_dir():
        raise ContentError(f"{questions_dir}: каталог с вопросами не найден")

    files = sorted(questions_dir.glob("*.yaml"))
    if not files:
        raise ContentError(f"{questions_dir}: не найдено ни одного *.yaml")
    return files


async def seed_questions(paths: list[Path] | None = None) -> QuestionSyncReport:
    taxonomy = load_taxonomy(get_settings().taxonomy_file)

    incoming: list[QuestionIn] = []
    for path in collect_files(paths):
        payload = load_questions(path, taxonomy)
        logger.info("  %s: %d вопрос(ов)", path.name, len(payload.questions))
        incoming.extend(payload.questions)

    async with get_session_factory()() as session:
        try:
            report = await QuestionService(session).sync(incoming)
        except ValueError as exc:
            raise ContentError(str(exc)) from exc
        await session.commit()
    return report


def _parse_args(argv: list[str] | None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Загрузка банка вопросов из YAML в базу")
    parser.add_argument(
        "paths",
        nargs="*",
        type=Path,
        help="файлы вопросов (по умолчанию — все из CONTENT_DIR/questions)",
    )
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    logging.basicConfig(level=logging.INFO, format="%(message)s")
    args = _parse_args(argv)

    try:
        report = asyncio.run(_run(args.paths or None))
    except ContentError as exc:
        print(f"Ошибка контента: {exc}", file=sys.stderr)
        return 1

    logger.info("Банк вопросов загружен")
    for line in report.as_lines():
        logger.info("  %s", line)
    if not report.has_changes:
        logger.info("  изменений нет — база уже соответствует файлам")
    return 0


async def _run(paths: list[Path] | None) -> QuestionSyncReport:
    try:
        return await seed_questions(paths)
    finally:
        await dispose_engine()


if __name__ == "__main__":
    raise SystemExit(main())
