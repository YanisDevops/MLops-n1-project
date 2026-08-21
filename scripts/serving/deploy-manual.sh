#!/usr/bin/env bash
set -euo pipefail

REGION="${AWS_REGION:-us-east-1}"
REPOSITORY="${ECR_REPOSITORY:-california-housing-api}"
IMAGE_TAG="${IMAGE_TAG:-v1}"
MLFLOW_TRACKING_URI="${MLFLOW_TRACKING_URI:?MLFLOW_TRACKING_URI doit être défini}"

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGISTRY="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"
IMAGE_URI="${REGISTRY}/${REPOSITORY}:${IMAGE_TAG}"

aws ecr get-login-password --region "$REGION" | \
docker login --username AWS --password-stdin "$REGISTRY"

docker pull "$IMAGE_URI"

docker stop california-housing-api 2>/dev/null || true
docker rm california-housing-api 2>/dev/null || true

docker run -d \
  --name california-housing-api \
  --restart unless-stopped \
  -p 8000:8000 \
  -e MLFLOW_TRACKING_URI="$MLFLOW_TRACKING_URI" \
  -e AWS_DEFAULT_REGION="$REGION" \
  "$IMAGE_URI"

sleep 10
curl -f http://localhost:8000/health
