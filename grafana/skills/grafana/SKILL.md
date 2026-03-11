---
name: grafana
description: |
  Grafana stack operations: querying VictoriaMetrics/Logs/Traces, exploring
  dashboards, understanding datasources, and using the Grafana MCP tools.

  ONLY activate when:
  - User asks about metrics, logs, traces, or Grafana dashboards
  - User wants to query VictoriaMetrics (PromQL) or VictoriaLogs (LogQL)
  - User asks to investigate infrastructure health, performance, or errors
  - User asks about the grafana plugin setup or GRAFANA_SERVICE_ACCOUNT_TOKEN

  DO NOT activate when:
  - Working purely on infra/Ansible files (use infrastructure:ansible skill)
  - Writing Go/TypeScript code unrelated to observability

allowed-tools:
  Read, Glob, Grep, mcp__grafana__*
---
