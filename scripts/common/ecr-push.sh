#!/usr/bin/env bash
set -euo pipefail

REGION="${AWS_REGION:-us-east-1}"
REPOSITORY="${ECR_REPOSITORY:-california-housing-api}"
IMAGE_TAG="${IMAGE_TAG:-v1}"

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGISTRY="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"
IMAGE_URI="${REGISTRY}/${REPOSITORY}:${IMAGE_TAG}"

aws ecr get-login-password --region "$REGION" | \
docker login --username AWS --password-stdin "$REGISTRY"

docker tag california-housing-api:local "$IMAGE_URI"
docker push "$IMAGE_URI"

echo "Pushed: $IMAGE_URI"
