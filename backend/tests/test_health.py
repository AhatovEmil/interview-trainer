from fastapi import FastAPI
from httpx import AsyncClient

from app import __version__
from app.services.health import ComponentStatus, HealthService, get_health_service


async def test_health_returns_200(client: AsyncClient) -> None:
    response = await client.get("/health")

    assert response.status_code == 200
    body = response.json()
    assert body["status"] == "ok"
    assert body["version"] == __version__


async def test_health_does_not_touch_dependencies(client: AsyncClient) -> None:
    """Liveness обязан отвечать 200 даже при лежащих Postgres и Redis."""
    response = await client.get("/health")

    assert response.status_code == 200
    assert "components" not in response.json()


class _StubHealthService(HealthService):
    def __init__(self, *statuses: ComponentStatus) -> None:
        super().__init__()
        self._statuses = list(statuses)

    async def check_all(self) -> list[ComponentStatus]:
        return self._statuses


async def test_readiness_ok(app: FastAPI, client: AsyncClient) -> None:
    app.dependency_overrides[get_health_service] = lambda: _StubHealthService(
        ComponentStatus("postgres", ok=True),
        ComponentStatus("redis", ok=True),
    )

    response = await client.get("/health/ready")

    assert response.status_code == 200
    assert response.json()["status"] == "ready"


async def test_readiness_degraded_when_component_down(app: FastAPI, client: AsyncClient) -> None:
    app.dependency_overrides[get_health_service] = lambda: _StubHealthService(
        ComponentStatus("postgres", ok=False, detail="connection refused"),
        ComponentStatus("redis", ok=True),
    )

    response = await client.get("/health/ready")

    assert response.status_code == 503
    body = response.json()
    assert body["status"] == "degraded"
    assert body["components"][0] == {
        "name": "postgres",
        "ok": False,
        "detail": "connection refused",
    }
