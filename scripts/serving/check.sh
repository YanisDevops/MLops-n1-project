#!/usr/bin/env bash
set -euo pipefail
aws sts get-caller-identity
docker --version
curl -f http://localhost:8000/health
