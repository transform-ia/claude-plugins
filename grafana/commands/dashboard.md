---
description: "Manage Grafana dashboards: /grafana:dashboard [uid|name|create]"
allowed-tools: [mcp__grafana__*]
---

# Grafana Dashboard Command

Use the grafana MCP tools to handle the dashboard request from $ARGUMENTS.

- Empty / no args: list all dashboards with UIDs, titles, and folder names
- UID or name: retrieve and summarize that dashboard's panels and queries
- "create" or a description: guide the user through creating a new dashboard
  following RED/USE method patterns from `skills/dashboards/instructions.md`

Always show the direct URL: `https://graph.robotinfra.com/d/<uid>`
