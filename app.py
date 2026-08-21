import os, logging
import mlflow
import mlflow.sklearn
import pandas as pd
from fastapi import FastAPI, HTTPException
from mlflow.tracking import MlflowClient
from pydantic import BaseModel, ConfigDict

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("california-housing-api")
MODEL_NAME = os.getenv("MODEL_NAME", "california-housing-model")
MODEL_STAGE = os.getenv("MODEL_STAGE", "Production")

class HousingInput(BaseModel):
    MedInc: float
    HouseAge: float
    AveRooms: float
    AveBedrms: float
    Population: float
    AveOccup: float
    Latitude: float
    Longitude: float

class HealthResponse(BaseModel):
    model_config = ConfigDict(protected_namespaces=())
    status: str
    model_name: str
    model_version: str | None

class PredictionResponse(BaseModel):
    model_config = ConfigDict(protected_namespaces=())
    prediction: float
    model_name: str
    model_version: str | None

app = FastAPI(title="California Housing API", version="1.0.0")
model = None
model_version = None

@app.on_event("startup")
def startup():
    global model, model_version
    uri = os.environ.get("MLFLOW_TRACKING_URI")
    if not uri:
        raise RuntimeError("MLFLOW_TRACKING_URI doit être défini")
    mlflow.set_tracking_uri(uri)
    model_uri = f"models:/{MODEL_NAME}/{MODEL_STAGE}"
    logger.info("Chargement du modèle depuis %s ...", model_uri)
    model = mlflow.sklearn.load_model(model_uri)
    versions = MlflowClient().get_latest_versions(MODEL_NAME, stages=[MODEL_STAGE])
    if versions:
        model_version = versions[0].version
    logger.info("Modèle chargé : %s v%s", MODEL_NAME, model_version)

@app.get("/health", response_model=HealthResponse)
def health():
    return {"status": "ok", "model_name": MODEL_NAME, "model_version": str(model_version) if model_version else None}

@app.post("/predict", response_model=PredictionResponse)
def predict(payload: HousingInput):
    if model is None:
        raise HTTPException(status_code=503, detail="Model not loaded")
    df = pd.DataFrame([payload.model_dump()])
    pred = float(model.predict(df)[0])
    return {"prediction": pred, "model_name": MODEL_NAME, "model_version": str(model_version) if model_version else None}
