#!/usr/bin/env bash
set -euo pipefail
ROLE_NAME="mlops-n1-serving-role"
PROFILE_NAME="mlops-n1-serving-profile"
POLICY_NAME="MLOpsN1ServingPolicy"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
POLICY_ARN="arn:aws:iam::$ACCOUNT_ID:policy/$POLICY_NAME"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
aws iam get-role --role-name "$ROLE_NAME" >/dev/null 2>&1 || aws iam create-role --role-name "$ROLE_NAME" --assume-role-policy-document "file://$ROOT/iam/ec2-trust-policy.json"
aws iam get-policy --policy-arn "$POLICY_ARN" >/dev/null 2>&1 || aws iam create-policy --policy-name "$POLICY_NAME" --policy-document "file://$ROOT/iam/serving-role-policy.json"
aws iam attach-role-policy --role-name "$ROLE_NAME" --policy-arn "$POLICY_ARN"
aws iam get-instance-profile --instance-profile-name "$PROFILE_NAME" >/dev/null 2>&1 || aws iam create-instance-profile --instance-profile-name "$PROFILE_NAME"
CURRENT=$(aws iam get-instance-profile --instance-profile-name "$PROFILE_NAME" --query 'InstanceProfile.Roles[0].RoleName' --output text)
if [[ "$CURRENT" == "None" || -z "$CURRENT" ]]; then aws iam add-role-to-instance-profile --instance-profile-name "$PROFILE_NAME" --role-name "$ROLE_NAME"; fi
echo "Serving IAM prêt"
