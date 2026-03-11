---
description: "Run a PromQL or LogQL query: /grafana:query <query>"
allowed-tools: [mcp__grafana__*]
---

# Grafana Query Command

Run the query in $ARGUMENTS against the appropriate datasource via `query_datasource`.

- PromQL (uses metric names, `rate()`, `sum()`, labels): use VictoriaMetrics datasource
- LogQL (uses `{container=...}`, `|=`, `| json`): use VictoriaLogs datasource

Default time range: last 1 hour. If results are empty, suggest checking metric/container
names using `label_values()` or adjusting the time range.

Reference patterns in `skills/grafana/instructions.md`.
