#!/usr/bin/env bash
set -euo pipefail

# Manage the lifecycle of the mun-app ArgoCD Application.
#
# Usage:
#   setup.sh --create    Apply the ArgoCD Application manifest.
#   setup.sh --delete    Remove the app and all related cluster resources.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_MANIFEST="$REPO_ROOT/application.yaml"
APP_NAME="${APP_NAME:-mun-app}"
NAMESPACE="${NAMESPACE:-mun-app}"

usage() {
  sed -n 's/^# \{0,1\}//p' "${BASH_SOURCE[0]}" | sed -n '3,8p'
}

create() {
  kubectl apply -f "$APP_MANIFEST"
  echo "ArgoCD Application '$APP_NAME' applied."
  echo "Reminder: create the Docker Hub pull secret with create-dockerhub-secret.sh"
}

delete() {
  if argocd app get "$APP_NAME" >/dev/null 2>&1; then
    argocd app delete "$APP_NAME" --cascade -y
  else
    echo "ArgoCD app '$APP_NAME' not found, skipping app delete."
  fi

  if kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
    kubectl delete namespace "$NAMESPACE"
  else
    echo "Namespace '$NAMESPACE' not found, skipping namespace delete."
  fi

  verify_clean
}

verify_clean() {
  local leftover=0

  if argocd app get "$APP_NAME" >/dev/null 2>&1; then
    echo "FAIL: ArgoCD app '$APP_NAME' still exists." >&2
    leftover=1
  fi

  if kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
    echo "FAIL: namespace '$NAMESPACE' still exists." >&2
    leftover=1
  fi

  if [ "$leftover" -ne 0 ]; then
    echo "Cleanup verification failed." >&2
    exit 1
  fi

  echo "Verified: no leftover resources for '$APP_NAME'."
}

case "${1:-}" in
  --create) create ;;
  --delete) delete ;;
  "") usage; exit 1 ;;
  *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
esac