#!/usr/bin/env bash
set -euo pipefail
PROFILE="${AWS_PROFILE:-mlops-n1}"
REGION="${AWS_REGION:-us-east-1}"
SG_NAME="mlops-n1-serving-sg"
MY_IP=$(curl -s https://checkip.amazonaws.com)

VPC_ID=$(aws ec2 describe-vpcs \
  --filters "Name=isDefault,Values=true" \
  --query 'Vpcs[0].VpcId' --output text \
  --region "$REGION" --profile "$PROFILE")

SG_ID=$(aws ec2 describe-security-groups \
  --filters "Name=group-name,Values=$SG_NAME" "Name=vpc-id,Values=$VPC_ID" \
  --query 'SecurityGroups[0].GroupId' --output text \
  --region "$REGION" --profile "$PROFILE")

if [[ "$SG_ID" == "None" || -z "$SG_ID" ]]; then
  SG_ID=$(aws ec2 create-security-group \
    --group-name "$SG_NAME" \
    --description "Serving EC2 SG" \
    --vpc-id "$VPC_ID" \
    --query 'GroupId' --output text \
    --region "$REGION" --profile "$PROFILE")
fi

aws ec2 authorize-security-group-ingress \
  --group-id "$SG_ID" --protocol tcp --port 22 \
  --cidr "${MY_IP}/32" --region "$REGION" --profile "$PROFILE" 2>/dev/null || true

aws ec2 authorize-security-group-ingress \
  --group-id "$SG_ID" --protocol tcp --port 8000 \
  --cidr 0.0.0.0/0 --region "$REGION" --profile "$PROFILE" 2>/dev/null || true

echo "$SG_ID"
