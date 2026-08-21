import os
import mlflow
import mlflow.sklearn
from sklearn.datasets import fetch_california_housing
from sklearn.model_selection import train_test_split
from sklearn.linear_model import Ridge
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_squared_error, mean_absolute_error, r2_score

EXPERIMENT_NAME = "california-housing-n1"

def run_experiment(name, model, params, X_train, X_test, y_train, y_test):
    with mlflow.start_run(run_name=name) as run:
        model.fit(X_train, y_train)
        pred = model.predict(X_test)
        rmse = mean_squared_error(y_test, pred) ** 0.5
        mae = mean_absolute_error(y_test, pred)
        r2 = r2_score(y_test, pred)
        mlflow.log_params(params)
        mlflow.log_metrics({"rmse": rmse, "mae": mae, "r2": r2})
        mlflow.sklearn.log_model(model, artifact_path="model")
        print(f"  Run '{name}' (id={run.info.run_id[:8]}...) -> RMSE={rmse:.4f}  MAE={mae:.4f}  R2={r2:.4f}")
        return rmse, mae, r2, run.info.run_id

def main():
    tracking_uri = os.environ.get("MLFLOW_TRACKING_URI")
    if not tracking_uri:
        raise RuntimeError("MLFLOW_TRACKING_URI doit être défini")
    mlflow.set_tracking_uri(tracking_uri)
    mlflow.set_experiment(EXPERIMENT_NAME)
    print(f"Tracking URI : {tracking_uri}")
    print(f"Expérience   : {EXPERIMENT_NAME}
")
    data = fetch_california_housing(as_frame=True)
    X, y = data.data, data.target
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    print(f"Dataset chargé : {len(X_train)} train / {len(X_test)} test
")
    runs = []
    p1 = {"alpha": 1.0}
    runs.append(("ridge_baseline", *run_experiment("ridge_baseline", Ridge(**p1), p1, X_train, X_test, y_train, y_test)))
    p2 = {"n_estimators": 100, "max_depth": 12, "random_state": 42, "n_jobs": -1}
    runs.append(("random_forest_light", *run_experiment("random_forest_light", RandomForestRegressor(**p2), p2, X_train, X_test, y_train, y_test)))
    p3 = {"n_estimators": 300, "max_depth": None, "random_state": 42, "n_jobs": -1}
    runs.append(("random_forest_deep", *run_experiment("random_forest_deep", RandomForestRegressor(**p3), p3, X_train, X_test, y_train, y_test)))
    best = min(runs, key=lambda x: x[1])
    print("
" + "="*60 + "
RÉSUMÉ DES 3 RUNS
" + "="*60)
    for name, rmse, mae, r2, run_id in runs:
        mark = "  <-- MEILLEUR" if run_id == best[4] else ""
        print(f"{name:24} RMSE={rmse:.4f}  MAE={mae:.4f}  R2={r2:.4f}{mark}")
    print(f"
Run ID à promouvoir : {best[4]}")

if __name__ == "__main__":
    main()
