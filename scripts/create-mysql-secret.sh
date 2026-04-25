#!/usr/bin/env bash
set -euo pipefail

# Creates the `mysql-secret` Secret in the `mun-app` namespace.
#
# Usage:
#   MYSQL_HOST=<host> \
#   MYSQL_USER=<user> \
#   MYSQL_PASSWORD=<password> \
#   MYSQL_DATABASE=<database> \
#   ./scripts/create-mysql-secret.sh

: "${MYSQL_HOST:?Set MYSQL_HOST}"
: "${MYSQL_USER:?Set MYSQL_USER}"
: "${MYSQL_PASSWORD:?Set MYSQL_PASSWORD}"
: "${MYSQL_DATABASE:?Set MYSQL_DATABASE}"

NAMESPACE="${NAMESPACE:-mun-app}"
SECRET_NAME="${SECRET_NAME:-mysql-secret}"

kubectl get namespace "$NAMESPACE" >/dev/null 2>&1 || \
  kubectl create namespace "$NAMESPACE"

kubectl create secret generic "$SECRET_NAME" \
  --from-literal=MYSQL_HOST="$MYSQL_HOST" \
  --from-literal=MYSQL_USER="$MYSQL_USER" \
  --from-literal=MYSQL_PASSWORD="$MYSQL_PASSWORD" \
  --from-literal=MYSQL_DATABASE="$MYSQL_DATABASE" \
  --namespace="$NAMESPACE" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Secret '$SECRET_NAME' applied in namespace '$NAMESPACE'."