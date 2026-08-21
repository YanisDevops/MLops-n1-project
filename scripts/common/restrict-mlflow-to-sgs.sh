#!/usr/bin/env bash
set -euo pipefail

PROFILE="${AWS_PROFILE:-mlops-n1}"
REGION="${AWS_REGION:-us-east-1}"

MLFLOW_SG="${MLFLOW_SG:?Définir MLFLOW_SG}"
TRAINING_SG="${TRAINING_SG:?Définir TRAINING_SG}"
SERVING_SG="${SERVING_SG:?Définir SERVING_SG}"

for SOURCE_SG in "$TRAINING_SG" "$SERVING_SG"; do
  aws ec2 authorize-security-group-ingress \
    --group-id "$MLFLOW_SG" \
    --protocol tcp \
    --port 5000 \
    --source-group "$SOURCE_SG" \
    --region "$REGION" \
    --profile "$PROFILE" 2>/dev/null || true
done

echo "Training + Serving autorisés vers MLflow:5000."
echo "Retirer manuellement la règle 0.0.0.0/0:5000 si elle existe encore."
