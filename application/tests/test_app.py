import os
import sys

sys.path.insert(
    0,
    os.path.abspath(os.path.join(os.path.dirname(__file__), "../src")),
)

from app import app


def test_index_endpoint():
    client = app.test_client()

    response = client.get("/")
    data = response.get_json()

    assert response.status_code == 200
    assert data["application"] == "TFM DevOps Platform"
    assert data["status"] == "running"


def test_health_endpoint():
    client = app.test_client()

    response = client.get("/health")
    data = response.get_json()

    assert response.status_code == 200
    assert data["status"] == "healthy"


def test_ready_endpoint():
    client = app.test_client()

    response = client.get("/ready")
    data = response.get_json()

    assert response.status_code == 200
    assert data["status"] == "ready"


def test_metrics_endpoint():
    client = app.test_client()

    response = client.get("/metrics")

    assert response.status_code == 200
    assert "tfm_app_http_requests_total" in response.get_data(as_text=True)
