#!/usr/bin/env bash
set -euo pipefail

PROFILE="${AWS_PROFILE:-mlops-n1}"
REGION="${AWS_REGION:-us-east-1}"
BUCKET="${S3_BUCKET:-mlops-n1-artifacts}"

if aws s3api head-bucket --bucket "$BUCKET" --profile "$PROFILE" >/dev/null 2>&1; then
  echo "Bucket déjà existant : $BUCKET"
else
  aws s3api create-bucket \
    --bucket "$BUCKET" \
    --region "$REGION" \
    --profile "$PROFILE"
fi

aws s3api put-public-access-block \
  --bucket "$BUCKET" \
  --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true \
  --profile "$PROFILE"

aws s3api put-bucket-versioning \
  --bucket "$BUCKET" \
  --versioning-configuration Status=Enabled \
  --profile "$PROFILE"

echo "S3 prêt : s3://$BUCKET"
