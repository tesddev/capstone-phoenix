#!/usr/bin/env bash
set -euo pipefail

: "${DATABASE_PASSWORD:?Set DATABASE_PASSWORD first}"
: "${SECRET_KEY:?Set SECRET_KEY first}"

kubectl create namespace taskapp --dry-run=client -o yaml | kubectl apply -f -
kubectl -n taskapp create secret generic taskapp-secret \
  --from-literal=DATABASE_PASSWORD="$DATABASE_PASSWORD" \
  --from-literal=SECRET_KEY="$SECRET_KEY" \
  --dry-run=client -o yaml | kubectl apply -f -
