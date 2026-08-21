#!/usr/bin/env bash
set -euo pipefail
aws sts get-caller-identity
aws s3 ls s3://mlops-n1-artifacts
python3 --version
docker --version
