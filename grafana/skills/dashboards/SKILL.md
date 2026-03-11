---
name: dashboards
description: |
  Grafana dashboard design: creating panels, layouts, variables, and dashboard JSON.
  Includes RED/USE method patterns for the Victoria stack.

  ONLY activate when:
  - User wants to create or edit a Grafana dashboard
  - User asks about panel types, layout, dashboard variables, or templating
  - User wants to improve dashboard organization or design

  DO NOT activate when:
  - User only wants to query data (use grafana skill)
  - User is working on alert rules only (use alerting skill)

allowed-tools:
  Read, Write(*.json, *.yaml), Edit(*.json, *.yaml), Glob, Grep,
  SlashCommand(/grafana:*), mcp__grafana__*
---
