# MLOps N1 — California Housing
# 

Projet MLOps complet avec trois machines dédiées :

- **EC2 MLflow** : tracking, registry, SQLite, artifacts S3
- **EC2 Training** : entraînement sklearn, comparaison des runs, build/push Docker
- **EC2 Serving** : pull ECR, FastAPI Docker, inference

## Architecture

```text
EC2 Training
   |
   | metrics / params / runs
   v
EC2 MLflow :5000
   |             \
   |              \ model registry
   v               \
S3 artifacts        \
                     v
                Model Production
                     |
                     v
                 FastAPI
                     |
                     v
                    ECR
                     |
                     v
                EC2 Serving
                   :8000
```

## Ressources utilisées

```text
S3                mlops-n1-artifacts
ECR               california-housing-api

IAM MLflow        mlflow-ec2-role
IAM Training      mlops-n1-training-role
IAM Serving       mlops-n1-serving-role

EC2 MLflow        t3.medium
EC2 Training      t3.medium
EC2 Serving       t3.small
```

## Ordre d'exécution

### 1. Ressources communes

```bash
./scripts/common/create-s3.sh
./scripts/common/create-ecr.sh
```

### 2. Machine MLflow

```bash
./scripts/mlflow/create-role.sh
./scripts/mlflow/create-sg.sh
./scripts/mlflow/create-ec2.sh
```

### 3. Machine Training

```bash
./scripts/training/create-role.sh
./scripts/training/create-sg.sh
./scripts/training/create-ec2.sh
```

### 4. Machine Serving

```bash
./scripts/serving/create-role.sh
./scripts/serving/create-sg.sh
./scripts/serving/create-ec2.sh
```

### 5. Restreindre MLflow aux SG Training/Serving

```bash
export MLFLOW_SG=sg-...
export TRAINING_SG=sg-...
export SERVING_SG=sg-...

./scripts/common/restrict-mlflow-to-sgs.sh
```

### 6. Entraînement

Sur Training :

```bash
cd ~/mlops-n1
source venv/bin/activate

export MLFLOW_TRACKING_URI=http://<MLFLOW_IP>:5000

python train.py
```

### 7. Registry

```bash
python register_model.py <RUN_ID>
```

### 8. Docker + ECR

```bash
docker build -t california-housing-api:local .
./scripts/common/ecr-push.sh
```

### 9. Déploiement Serving

Sur Serving :

```bash
export MLFLOW_TRACKING_URI=http://<MLFLOW_IP>:5000
./scripts/serving/deploy-manual.sh
```

Puis :

```bash
curl http://localhost:8000/health
```

## CI/CD

Workflow :

```text
.github/workflows/mlops.yml
```

Pipeline :

```text
push main
  -> pytest
  -> docker build
  -> push ECR
  -> SSH Serving EC2
  -> docker pull/run
  -> /health
```

## Sécurité

- `.pem` exclus de Git
- pas d'Access Key dans les EC2
- EC2 utilisent des IAM Roles
- SSH limité à l'IP de l'administrateur
- MLflow 5000 à limiter aux SG Training/Serving
- Serving 8000 ouvert publiquement uniquement pour le lab
