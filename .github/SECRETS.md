# GitHub Secrets

Configurer dans **Settings → Secrets and variables → Actions** :

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `SERVING_EC2_HOST`
- `SERVING_EC2_SSH_KEY`
- `MLFLOW_TRACKING_URI`

À terme, remplacer les Access Keys statiques par GitHub OIDC + IAM Role.
