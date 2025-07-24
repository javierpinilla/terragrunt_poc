#!/bin/bash

apt update
apt upgrade -y
apt install -y unzip zip wget curl


curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

rm -rf ~/awscliv2.zip ~/aws

# Leer secreto desde AWS Secrets Manager
GITHUB_SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id ${secret_name} \
  --region us-east-1 \
  --query SecretString --output text)

GITHUB_PAT=$(echo "$GITHUB_SECRET_JSON" | jq -r .GITHUB_PAT)
if [[ "$GITHUB_PAT" == "null" ]]; then
  GITHUB_PAT=$(echo "$GITHUB_SECRET_JSON" | jq -r .github_pat)
fi

REPO_URL=$(echo "$GITHUB_SECRET_JSON" | jq -r .REPO_URL)
if [[ "$REPO_URL" == "null" ]]; then
  REPO_URL=$(echo "$GITHUB_SECRET_JSON" | jq -r .repo_url)
fi

REPO_NAME=$(echo "$GITHUB_SECRET_JSON" | jq -r .REPO_NAME)
if [[ "$REPO_NAME" == "null" ]]; then
  REPO_NAME=$(echo "$GITHUB_SECRET_JSON" | jq -r .repo_name)
fi

OWNER=$(echo "$GITHUB_SECRET_JSON" | jq -r .OWNER)
if [[ "$OWNER" == "null" ]]; then
  OWNER=$(echo "$GITHUB_SECRET_JSON" | jq -r .owner)
fi

if [[ -z "$GITHUB_PAT" || "$GITHUB_PAT" == "null" || \
      -z "$REPO_URL"   || "$REPO_URL"   == "null" || \
      -z "$REPO_NAME"  || "$REPO_NAME"  == "null" || \
      -z "$OWNER"      || "$OWNER"      == "null" ]]; then
  echo "❌ ERROR: Uno o más campos del secreto de GitHub están vacíos o no definidos."
  exit 1
fi

# Crear usuario
useradd -m githubrunner
cd /home/githubrunner


# Descargar runner
RUNNER_VERSION="2.325.0"
curl -LO https://github.com/actions/runner/releases/download/v$${RUNNER_VERSION}/actions-runner-linux-x64-$${RUNNER_VERSION}.tar.gz
tar xzf actions-runner-linux-x64-$${RUNNER_VERSION}.tar.gz
chown -R githubrunner:githubrunner .

# Obtener token de registro desde GitHub
REGISTRATION_TOKEN=$(curl -s -X POST \
  -H "Authorization: token $${GITHUB_PAT}" \
  -H "Accept: application/vnd.github+json" \
  https://api.github.com/repos/$${OWNER}/$${REPO_NAME}/actions/runners/registration-token \
  | jq -r .token)

# Configurar y ejecutar el runner
sudo -u githubrunner ./config.sh \
  --url "$${REPO_URL}" \
  --token "$${REGISTRATION_TOKEN}" \
  --unattended \
  --name "ec2-spot-$(hostname)" \
  --labels "ec2,spot"

sudo -u githubrunner ./run.sh
#./svc.sh install
#./svc.sh start