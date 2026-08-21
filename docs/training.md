# Machine Training

Création :

```bash
./scripts/training/create-role.sh
./scripts/training/create-sg.sh
./scripts/training/create-ec2.sh
```

Sur la machine :

```bash
cd ~/mlops-n1
source venv/bin/activate

export MLFLOW_TRACKING_URI=http://<MLFLOW_IP>:5000
unset AWS_PROFILE

python train.py
```

Push Docker :

```bash
docker build -t california-housing-api:local .
./scripts/common/ecr-push.sh
```
