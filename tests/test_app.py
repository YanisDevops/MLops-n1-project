"""
Tests de l'API -- MLflow est mocké pour ne pas dépendre d'un serveur réel en CI.
"""
from unittest.mock import MagicMock, patch

import pytest
from fastapi.testclient import TestClient


@pytest.fixture
def client():
    """Patch le chargement du modèle avant que le lifespan de l'app ne s'exécute."""
    fake_model = MagicMock()
    fake_model.predict.return_value = [4.526]  # valeur factice, unité du dataset

    with patch("mlflow.set_tracking_uri"), \
         patch("mlflow.sklearn.load_model", return_value=fake_model), \
         patch("mlflow.tracking.MlflowClient") as mock_client_cls:

        mock_client = MagicMock()
        mock_version = MagicMock()
        mock_version.version = "1"
        mock_client.get_latest_versions.return_value = [mock_version]
        mock_client_cls.return_value = mock_client

        import os
        os.environ["MLFLOW_TRACKING_URI"] = "http://fake-mlflow:5000"

        from app import app
        with TestClient(app) as c:
            yield c


def test_health(client):
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"


def test_predict(client):
    payload = {
        "MedInc": 8.3, "HouseAge": 41.0, "AveRooms": 6.98,
        "AveBedrms": 1.02, "Population": 322.0, "AveOccup": 2.55,
        "Latitude": 37.88, "Longitude": -122.23,
    }
    response = client.post("/predict", json=payload)
    assert response.status_code == 200
    body = response.json()
    assert body["prediction"] == pytest.approx(4.526)
    assert body["model_version"] == "1"


def test_predict_missing_field(client):
    """Un champ manquant doit être rejeté par la validation Pydantic (422)."""
    payload = {"MedInc": 8.3}
    response = client.post("/predict", json=payload)
    assert response.status_code == 422