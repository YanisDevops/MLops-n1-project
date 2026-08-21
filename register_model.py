import os, sys
import mlflow
from mlflow.tracking import MlflowClient

MODEL_NAME = "california-housing-model"
MODEL_STAGE = "Production"

if len(sys.argv) != 2:
    raise SystemExit("Usage: python register_model.py <RUN_ID>")
run_id = sys.argv[1]
uri = os.environ.get("MLFLOW_TRACKING_URI")
if not uri:
    raise RuntimeError("MLFLOW_TRACKING_URI doit être défini")
mlflow.set_tracking_uri(uri)
result = mlflow.register_model(f"runs:/{run_id}/model", MODEL_NAME)
client = MlflowClient()
client.transition_model_version_stage(name=MODEL_NAME, version=result.version, stage=MODEL_STAGE, archive_existing_versions=True)
print(f"Modèle enregistré : {MODEL_NAME} version {result.version} (run={run_id[:8]}...)")
print(f"Version {result.version} promue en '{MODEL_STAGE}'.")
