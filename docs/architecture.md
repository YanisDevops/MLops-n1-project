# Architecture détaillée

## 1. EC2 MLflow

Contient :

```text
Ubuntu
Python
MLflow 3.x
systemd: mlflow.service
SQLite: /home/ubuntu/mlflow.db
```

Le service :

```text
0.0.0.0:5000
backend: SQLite
artifacts: s3://mlops-n1-artifacts
```

Son IAM Role autorise uniquement les accès nécessaires au bucket d'artifacts.

## 2. EC2 Training

Contient :

```text
Python / venv
scikit-learn
MLflow client
Docker
AWS CLI
train.py
register_model.py
```

Fonctions :

- entraînement Ridge / RF
- logging MLflow
- Model Registry
- build image Docker
- push ECR

## 3. EC2 Serving

Contient :

```text
Docker
AWS CLI
```

Fonctions :

- login ECR via IAM Role
- pull image
- lancement FastAPI
- récupération du modèle MLflow
- accès S3 en lecture

## 4. IAM

```text
MLflow role
  -> S3 read/write artifacts

Training role
  -> S3 read/write artifacts
  -> ECR push

Serving role
  -> ECR pull
  -> S3 read artifacts
```

## 5. Network

```text
Admin IP
  -> SSH 22 vers les trois EC2

Training SG
  -> MLflow SG TCP/5000

Serving SG
  -> MLflow SG TCP/5000

Internet
  -> Serving SG TCP/8000
```
