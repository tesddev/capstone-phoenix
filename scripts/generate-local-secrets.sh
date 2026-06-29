#!/usr/bin/env bash
set -euo pipefail

echo "DATABASE_PASSWORD=$(openssl rand -base64 24 | tr -d '\n')"
echo "SECRET_KEY=$(openssl rand -hex 32)"
