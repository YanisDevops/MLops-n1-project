#!/usr/bin/env bash
set -euo pipefail
sudo systemctl status mlflow --no-pager
curl -f http://localhost:5000
aws sts get-caller-identity
aws s3 ls s3://mlops-n1-artifacts
