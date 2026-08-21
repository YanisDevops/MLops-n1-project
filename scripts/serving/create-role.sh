#!/usr/bin/env bash
set -euo pipefail

PROFILE="${AWS_PROFILE:-mlops-n1}"
ROLE_NAME="mlops-n1-serving-role"
INSTANCE_PROFILE_NAME="mlops-n1-serving-profile"
POLICY_NAME="MLOpsN1ServingPolicy"

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text --profile "$PROFILE")
POLICY_ARN="arn:aws:iam::${ACCOUNT_ID}:policy/${POLICY_NAME}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

TRUST_POLICY="$PROJECT_ROOT/iam/ec2-trust-policy.json"
ROLE_POLICY="$PROJECT_ROOT/iam/serving-role-policy.json"

if ! aws iam get-role --role-name "$ROLE_NAME" --profile "$PROFILE" >/dev/null 2>&1; then
  aws iam create-role     --role-name "$ROLE_NAME"     --assume-role-policy-document "file://${TRUST_POLICY}"     --profile "$PROFILE"
fi

if ! aws iam get-policy --policy-arn "$POLICY_ARN" --profile "$PROFILE" >/dev/null 2>&1; then
  aws iam create-policy     --policy-name "$POLICY_NAME"     --policy-document "file://${ROLE_POLICY}"     --profile "$PROFILE"
fi

aws iam attach-role-policy   --role-name "$ROLE_NAME"   --policy-arn "$POLICY_ARN"   --profile "$PROFILE"

if ! aws iam get-instance-profile   --instance-profile-name "$INSTANCE_PROFILE_NAME"   --profile "$PROFILE" >/dev/null 2>&1; then
  aws iam create-instance-profile     --instance-profile-name "$INSTANCE_PROFILE_NAME"     --profile "$PROFILE"
fi

CURRENT_ROLE=$(aws iam get-instance-profile   --instance-profile-name "$INSTANCE_PROFILE_NAME"   --query 'InstanceProfile.Roles[0].RoleName'   --output text   --profile "$PROFILE")

if [[ "$CURRENT_ROLE" == "None" || -z "$CURRENT_ROLE" ]]; then
  aws iam add-role-to-instance-profile     --instance-profile-name "$INSTANCE_PROFILE_NAME"     --role-name "$ROLE_NAME"     --profile "$PROFILE"
elif [[ "$CURRENT_ROLE" != "$ROLE_NAME" ]]; then
  echo "ERREUR: profile déjà lié à $CURRENT_ROLE"
  exit 1
fi

echo "IAM prêt: $ROLE_NAME / $INSTANCE_PROFILE_NAME"
