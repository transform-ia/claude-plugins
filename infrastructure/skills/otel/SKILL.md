---
name: otel
description: |
  OpenTelemetry operations for the Victoria stack (VictoriaLogs, VictoriaMetrics, VictoriaTraces).
  Query logs with LogsQL, query metrics with PromQL, explore traces, manage data retention,
  and perform maintenance operations like wiping logs or deleting metric series.

  ONLY activate when:
  - User invokes /infrastructure:otel
  - User asks about logs, metrics, or traces in the Victoria stack
  - User wants to query, explore, or debug observability data
  - User asks to wipe, delete, or manage OTEL data

  DO NOT activate when:
  - User is deploying infrastructure (use deploy skill)
  - User is asking about Ansible or host configuration

allowed-tools:
  mcp__victorialogs__query,
  mcp__victorialogs__streams,
  mcp__victorialogs__stream_field_names,
  mcp__victorialogs__stream_field_values,
  mcp__victorialogs__stats_query,
  mcp__victorialogs__stats_query_range,
  mcp__victoriametrics__query,
  mcp__victoriametrics__query_range,
  mcp__victoriametrics__labels,
  mcp__victoriametrics__label_values,
  mcp__victoriametrics__metrics,
  mcp__victoriametrics__series,
  mcp__victoriatraces__services,
  mcp__victoriatraces__traces,
  mcp__victoriatraces__trace,
  Bash(${CLAUDE_PLUGIN_ROOT}/scripts/wipe-logs.sh *),
  Bash(ssh robotinfra-tnvt *)
---

# OTEL Operations Skill

Query and manage observability data across the Victoria stack.

See `instructions.md` for detailed workflows.
