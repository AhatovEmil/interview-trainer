"""Публичные страницы: удаление аккаунта и политика конфиденциальности.

Их адреса указываются в карточке приложения в магазине, поэтому важны две
вещи: они открываются без входа и не зависят от версии API. Если страница
отвалится, приложение снимут с публикации, а узнаем мы об этом от Google.
"""

import pytest
from httpx import AsyncClient

PAGES = ("/account/delete", "/privacy")


@pytest.mark.parametrize("path", PAGES)
async def test_page_opens_without_authentication(client: AsyncClient, path: str) -> None:
    response = await client.get(path)

    assert response.status_code == 200
    assert response.headers["content-type"].startswith("text/html")
    assert len(response.text) > 500, "страница подозрительно пустая"


@pytest.mark.parametrize("path", PAGES)
async def test_page_is_outside_api_version(client: AsyncClient, path: str) -> None:
    """Адрес не должен уехать при выходе v2 — он опубликован в магазине."""
    response = await client.get(f"/api/v1{path}")

    assert response.status_code == 404


async def test_deletion_page_explains_both_paths(client: AsyncClient) -> None:
    body = (await client.get("/account/delete")).text

    # Требование магазина: удаление доступно и тем, кто снёс приложение.
    assert "Если приложение установлено" in body
    assert "Если приложение уже удалено" in body


async def test_pages_link_to_each_other(client: AsyncClient) -> None:
    assert "/privacy" in (await client.get("/account/delete")).text
    assert "/account/delete" in (await client.get("/privacy")).text
