---
description: "Manage Grafana alerts: /grafana:alert [list|firing|create|silence]"
allowed-tools: [mcp__grafana__*]
---

# Grafana Alert Command

Handle alert requests from $ARGUMENTS using grafana MCP tools.

- Empty / "list": all alert rules with current state (Normal/Pending/Firing)
- "firing": currently firing alert instances only
- "create" or description: help create a new alert rule following patterns
  in `skills/alerting/instructions.md`
- "silence": help create a silence for the specified alert/labels

Always show severity labels and last evaluation time.
