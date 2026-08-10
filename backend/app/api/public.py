"""Публичные страницы вне API.

Магазины требуют, чтобы удалить аккаунт можно было и без установленного
приложения, по обычной ссылке. Поэтому страница живёт на том же домене, что и
API, и не требует ни отдельного хостинга, ни сборки фронтенда.

Здесь же политика конфиденциальности: её адрес указывается в карточке
приложения, и он должен открываться у любого, без входа.
"""

from __future__ import annotations

from pathlib import Path

from fastapi import APIRouter, HTTPException, status
from fastapi.responses import HTMLResponse

router = APIRouter(tags=["public"])

_PAGES = Path(__file__).resolve().parent / "pages"


def _page(name: str) -> HTMLResponse:
    path = _PAGES / f"{name}.html"
    if not path.is_file():
        raise HTTPException(status.HTTP_404_NOT_FOUND, "страница не найдена")
    return HTMLResponse(path.read_text(encoding="utf-8"))


@router.get("/account/delete", response_class=HTMLResponse, summary="Удаление аккаунта")
async def account_deletion_page() -> HTMLResponse:
    return _page("account_delete")


@router.get("/privacy", response_class=HTMLResponse, summary="Политика конфиденциальности")
async def privacy_page() -> HTMLResponse:
    return _page("privacy")
