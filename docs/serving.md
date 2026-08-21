# Machine Serving

Création :

```bash
./scripts/serving/create-role.sh
./scripts/serving/create-sg.sh
./scripts/serving/create-ec2.sh
```

Déploiement manuel :

```bash
export MLFLOW_TRACKING_URI=http://<MLFLOW_IP>:5000
./scripts/serving/deploy-manual.sh
```

Tests :

```bash
curl http://localhost:8000/health
curl http://<SERVING_PUBLIC_IP>:8000/docs
```
