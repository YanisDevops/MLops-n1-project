#!/bin/bash
set -e

apt-get update -y
apt-get install -y python3-pip

if ! swapon --show | grep -q /swapfile; then
  fallocate -l 2G /swapfile
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  echo '/swapfile swap swap defaults 0 0' >> /etc/fstab
fi

pip3 install mlflow==3.15.1 boto3

cat > /etc/systemd/system/mlflow.service <<'SERVICE'
[Unit]
Description=MLflow Tracking Server
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/home/ubuntu
ExecStart=/usr/local/bin/mlflow server \
  --host 0.0.0.0 \
  --port 5000 \
  --backend-store-uri sqlite:////home/ubuntu/mlflow.db \
  --default-artifact-root s3://mlops-n1-artifacts/ \
  --allowed-hosts "*" \
  --cors-allowed-origins "*"
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
SERVICE

systemctl daemon-reload
systemctl enable mlflow
systemctl start mlflow
