#!/usr/bin/env bash
set -euo pipefail

# Creates the `dockerhub-creds` imagePullSecret in the `mun-app` namespace.
#
# Usage:
#   DOCKERHUB_USERNAME=<user> \
#   DOCKERHUB_TOKEN=<access-token> \
#   DOCKERHUB_EMAIL=<email> \
#   ./scripts/create-dockerhub-secret.sh
#
# The token must be a Docker Hub Personal Access Token with at least
# Read scope on the target repository (hub.docker.com → Account Settings
# → Security → New Access Token).

: "${DOCKERHUB_USERNAME:?Set DOCKERHUB_USERNAME}"
: "${DOCKERHUB_TOKEN:?Set DOCKERHUB_TOKEN}"
: "${DOCKERHUB_EMAIL:?Set DOCKERHUB_EMAIL}"

NAMESPACE="${NAMESPACE:-mun-app}"
SECRET_NAME="${SECRET_NAME:-dockerhub-creds}"

kubectl get namespace "$NAMESPACE" >/dev/null 2>&1 || \
  kubectl create namespace "$NAMESPACE"

kubectl create secret docker-registry "$SECRET_NAME" \
  --docker-server=https://index.docker.io/v1/ \
  --docker-username="$DOCKERHUB_USERNAME" \
  --docker-password="$DOCKERHUB_TOKEN" \
  --docker-email="$DOCKERHUB_EMAIL" \
  --namespace="$NAMESPACE" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Secret '$SECRET_NAME' applied in namespace '$NAMESPACE'."