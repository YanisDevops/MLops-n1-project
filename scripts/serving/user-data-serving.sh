#!/bin/bash
set -e
apt-get update -y
apt-get install -y docker.io unzip curl
systemctl enable --now docker
usermod -aG docker ubuntu
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
unzip -q /tmp/awscliv2.zip -d /tmp
/tmp/aws/install
rm -rf /tmp/aws /tmp/awscliv2.zip
touch /home/ubuntu/.serving-ready
chown ubuntu:ubuntu /home/ubuntu/.serving-ready
