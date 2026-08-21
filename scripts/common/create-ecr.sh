#!/usr/bin/env bash
set -euo pipefail

PROFILE="${AWS_PROFILE:-mlops-n1}"
REGION="${AWS_REGION:-us-east-1}"
REPOSITORY="${ECR_REPOSITORY:-california-housing-api}"

if aws ecr describe-repositories \
  --repository-names "$REPOSITORY" \
  --region "$REGION" \
  --profile "$PROFILE" >/dev/null 2>&1; then
  echo "ECR déjà existant : $REPOSITORY"
else
  aws ecr create-repository \
    --repository-name "$REPOSITORY" \
    --region "$REGION" \
    --image-scanning-configuration scanOnPush=true \
    --image-tag-mutability MUTABLE \
    --profile "$PROFILE"
fi
