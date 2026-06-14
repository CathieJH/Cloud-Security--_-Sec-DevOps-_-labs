#!/usr/bin/env bash
# Destroys all resources in the dev environment to stop billing.
# The VPN gateway is the main cost - always tear down when finished.
set -euo pipefail

cd "$(dirname "$0")/../environments/dev"

echo "==> terraform destroy"
terraform destroy -auto-approve

echo "==> All resources destroyed."
