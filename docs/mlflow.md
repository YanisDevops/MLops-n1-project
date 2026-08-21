# Machine MLflow

Création :

```bash
./scripts/mlflow/create-role.sh
./scripts/mlflow/create-sg.sh
./scripts/mlflow/create-ec2.sh
```

Diagnostic :

```bash
sudo systemctl status mlflow
sudo journalctl -u mlflow --no-pager -n 100
curl http://localhost:5000
free -h
```

SQLite :

```bash
sqlite3 /home/ubuntu/mlflow.db
```

Quitter :

```text
.quit
```
