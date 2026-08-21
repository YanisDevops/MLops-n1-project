#!/usr/bin/env bash
set -euo pipefail
REGION="${AWS_REGION:-us-east-1}"
INSTANCE_TYPE="${INSTANCE_TYPE:-t3.small}"
KEY_NAME="${KEY_NAME:-mlops-n1-key}"
SG_NAME="mlops-n1-serving-sg"
PROFILE_NAME="mlops-n1-serving-profile"
INSTANCE_NAME="mlops-n1-serving"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" --query 'Vpcs[0].VpcId' --output text --region "$REGION")
SG_ID=$(aws ec2 describe-security-groups --filters "Name=group-name,Values=$SG_NAME" "Name=vpc-id,Values=$VPC_ID" --query 'SecurityGroups[0].GroupId' --output text --region "$REGION")
[[ -n "$SG_ID" && "$SG_ID" != "None" ]] || { echo "Lance d'abord create-serving-sg.sh"; exit 1; }
AMI_ID=$(aws ec2 describe-images --owners 099720109477 --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*" "Name=state,Values=available" "Name=architecture,Values=x86_64" "Name=root-device-type,Values=ebs" --query 'sort_by(Images,&CreationDate)[-1].ImageId' --output text --region "$REGION")
EXISTING=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$INSTANCE_NAME" "Name=instance-state-name,Values=pending,running,stopping,stopped" --query 'Reservations[0].Instances[0].InstanceId' --output text --region "$REGION")
if [[ "$EXISTING" != "None" && -n "$EXISTING" ]]; then echo "Instance déjà existante: $EXISTING"; exit 0; fi
INSTANCE_ID=$(aws ec2 run-instances --image-id "$AMI_ID" --instance-type "$INSTANCE_TYPE" --key-name "$KEY_NAME" --security-group-ids "$SG_ID" --iam-instance-profile Name="$PROFILE_NAME" --user-data "file://$DIR/user-data-serving.sh" --block-device-mappings 'DeviceName=/dev/sda1,Ebs={VolumeSize=20,VolumeType=gp3,DeleteOnTermination=true}' --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE_NAME}]" --query 'Instances[0].InstanceId' --output text --region "$REGION")
aws ec2 wait instance-running --instance-ids "$INSTANCE_ID" --region "$REGION"
IP=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --query 'Reservations[0].Instances[0].PublicIpAddress' --output text --region "$REGION")
echo "Instance: $INSTANCE_ID"
echo "IP: $IP"
