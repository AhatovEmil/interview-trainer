"""Чтение YAML-файлов контента с понятными сообщениями об ошибках."""

from __future__ import annotations

from pathlib import Path
from typing import Any

import yaml
from pydantic import ValidationError

from app.seed.schema import TaxonomyFile


class ContentError(RuntimeError):
    """Контент не удалось прочитать или он не прошёл валидацию."""


def load_taxonomy(path: Path) -> TaxonomyFile:
    """Прочитать и провалидировать taxonomy.yaml.

    Кидает ContentError с указанием файла и места ошибки — загрузка должна падать
    громко, а не молча пропускать половину дерева.
    """
    raw = _read_yaml(path)
    try:
        return TaxonomyFile.model_validate(raw)
    except ValidationError as exc:
        raise ContentError(f"{path}: файл не прошёл валидацию\n{_format(exc)}") from exc


def _read_yaml(path: Path) -> dict[str, Any]:
    if not path.is_file():
        raise ContentError(f"{path}: файл не найден")

    try:
        with path.open(encoding="utf-8") as stream:
            data = yaml.safe_load(stream)
    except yaml.YAMLError as exc:
        raise ContentError(f"{path}: некорректный YAML\n{exc}") from exc

    if data is None:
        raise ContentError(f"{path}: файл пуст")
    if not isinstance(data, dict):
        raise ContentError(
            f"{path}: ожидался объект на верхнем уровне, получен {type(data).__name__}"
        )
    return data


def _format(exc: ValidationError) -> str:
    lines: list[str] = []
    for error in exc.errors():
        location = " → ".join(str(part) for part in error["loc"]) or "<корень>"
        lines.append(f"  {location}: {error['msg']}")
    return "\n".join(lines)
