#!/usr/bin/env bash
set -euo pipefail
REGION="${AWS_REGION:-us-east-1}"
aws ecr create-repository --repository-name california-housing-api --region "$REGION" --image-scanning-configuration scanOnPush=true --image-tag-mutability MUTABLE
