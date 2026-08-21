from fastapi.testclient import TestClient
import app as api

class DummyModel:
    def predict(self, df):
        return [2.5]

def test_health(monkeypatch):
    monkeypatch.setattr(api, "model", DummyModel())
    monkeypatch.setattr(api, "model_version", "3")
    with TestClient(api.app) as client:
        r = client.get("/health")
    assert r.status_code == 200
    assert r.json()["status"] == "ok"

def test_predict(monkeypatch):
    monkeypatch.setattr(api, "model", DummyModel())
    monkeypatch.setattr(api, "model_version", "3")
    payload = {"MedInc":5.0,"HouseAge":20,"AveRooms":5.0,"AveBedrms":1.0,"Population":1000,"AveOccup":3.0,"Latitude":34.0,"Longitude":-118.0}
    with TestClient(api.app) as client:
        r = client.post("/predict", json=payload)
    assert r.status_code == 200
    assert r.json()["prediction"] == 2.5
