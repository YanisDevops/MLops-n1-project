#!/bin/bash
set -e

apt-get update -y
apt-get install -y \
  python3 python3-pip python3-venv \
  git docker.io curl unzip

systemctl enable docker
systemctl start docker
usermod -aG docker ubuntu

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
  -o /tmp/awscliv2.zip
unzip -q /tmp/awscliv2.zip -d /tmp
/tmp/aws/install
rm -rf /tmp/aws /tmp/awscliv2.zip

mkdir -p /home/ubuntu/mlops-n1
chown -R ubuntu:ubuntu /home/ubuntu/mlops-n1

sudo -u ubuntu python3 -m venv /home/ubuntu/mlops-n1/venv
sudo -u ubuntu /home/ubuntu/mlops-n1/venv/bin/pip install --upgrade pip
sudo -u ubuntu /home/ubuntu/mlops-n1/venv/bin/pip install \
  mlflow==2.13.0 scikit-learn==1.5.0 pandas==2.2.2 \
  numpy==1.26.4 boto3==1.34.100 fastapi==0.111.0 \
  "uvicorn[standard]==0.30.1" pydantic==2.7.1
