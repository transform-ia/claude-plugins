---
description: "Create Grafana service account and token: /grafana:setup <admin-password>"
allowed-tools: [Bash(${CLAUDE_PLUGIN_ROOT}/scripts/setup.sh *)]
---

# Grafana Setup

Run the setup script to create a Grafana service account and API token.
This only needs to be done once per user.

The admin password is in the infra repo at:
`inventory/host_vars/robotinfra-tnvt.yaml` → `docker.secrets.grafana.admin_password`

After the script runs, add the printed export to your shell profile and restart Claude Code.
The plugin will then automatically start the MCP server when needed.

Bash("${CLAUDE_PLUGIN_ROOT}/scripts/setup.sh $ARGUMENTS")
