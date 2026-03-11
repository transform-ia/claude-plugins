#!/bin/bash
# Creates a Grafana service account and API token for mcp-grafana.
# Usage: ./setup.sh <grafana-admin-password>
# The admin password is in inventory/host_vars/robotinfra-tnvt.yaml (infra repo).

set -euo pipefail

GRAFANA_URL="https://graph.robotinfra.com"
ADMIN_PASSWORD="${1:-}"
SA_NAME="mcp-grafana"
TOKEN_NAME="claude-mcp"

if [ -z "$ADMIN_PASSWORD" ]; then
  echo "Usage: $0 <grafana-admin-password>"
  echo ""
  echo "Find the password in the infra repo:"
  echo "  inventory/host_vars/robotinfra-tnvt.yaml → docker.secrets.grafana.admin_password"
  exit 1
fi

echo "Creating Grafana service account '${SA_NAME}'..."
SA=$(curl -s -f -X POST "${GRAFANA_URL}/api/serviceaccounts" \
  -H "Content-Type: application/json" \
  -u "admin:${ADMIN_PASSWORD}" \
  -d "{\"name\":\"${SA_NAME}\",\"role\":\"Viewer\"}")

SA_ID=$(echo "$SA" | jq -r '.id')
if [ -z "$SA_ID" ] || [ "$SA_ID" = "null" ]; then
  echo "Error creating service account: $SA"
  exit 1
fi

echo "Creating token '${TOKEN_NAME}' for service account ID ${SA_ID}..."
TOKEN_RESP=$(curl -s -f -X POST "${GRAFANA_URL}/api/serviceaccounts/${SA_ID}/tokens" \
  -H "Content-Type: application/json" \
  -u "admin:${ADMIN_PASSWORD}" \
  -d "{\"name\":\"${TOKEN_NAME}\"}")

TOKEN_VALUE=$(echo "$TOKEN_RESP" | jq -r '.key')
if [ -z "$TOKEN_VALUE" ] || [ "$TOKEN_VALUE" = "null" ]; then
  echo "Error creating token: $TOKEN_RESP"
  exit 1
fi

echo ""
echo "Service account created (ID: ${SA_ID})"
echo "Token created (save this — it cannot be retrieved again)"
echo ""
echo "Add this to your shell profile (~/.bashrc or ~/.zshrc):"
echo ""
echo "  export GRAFANA_SERVICE_ACCOUNT_TOKEN='${TOKEN_VALUE}'"
echo ""
echo "Then: source ~/.bashrc && restart Claude Code"
