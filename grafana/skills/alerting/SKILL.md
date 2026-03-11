---
name: alerting
description: |
  Grafana unified alerting: creating alert rules, notification policies,
  contact points, and silence management. Grafana 12.x alerting model.

  ONLY activate when:
  - User wants to create or edit Grafana alert rules
  - User asks about notification policies, contact points, or silences
  - User wants to investigate firing or pending alerts

  DO NOT activate when:
  - User only wants to view dashboards (use dashboards skill)
  - User only wants to query without alert context (use grafana skill)

allowed-tools:
  Read, Glob, Grep, SlashCommand(/grafana:*), mcp__grafana__*
---
