#!/usr/bin/env bash
# Deploys the dev environment. Run from the repo root.
set -euo pipefail

cd "$(dirname "$0")/../environments/dev"

echo "==> terraform init"
terraform init

echo "==> terraform validate"
terraform validate

echo "==> terraform plan"
terraform plan -out=tfplan

echo "==> terraform apply"
terraform apply tfplan

echo "==> Done. Remember to run scripts/teardown.sh to avoid VPN gateway charges."
