# OTEL Operations — Instructions

## Stack Overview

All observability data lives on `robotinfra-tnvt`. Three backends:

| Signal | Backend | Query Language | MCP Tools |
|--------|---------|----------------|-----------|
| Logs | VictoriaLogs | LogsQL | `mcp__victorialogs__*` |
| Metrics | VictoriaMetrics | PromQL | `mcp__victoriametrics__*` |
| Traces | VictoriaTraces | — | `mcp__victoriatraces__*` |

## Ingestion Endpoints

### From WireGuard network (10.255.255.0/26) — no auth
- Metrics: `http://10.255.255.13/opentelemetry/v1/metrics`
- Logs: `http://10.255.255.13/insert/loki/api/v1/push` (Loki JSON format)
- Logs (OTLP protobuf only): `http://10.255.255.13/insert/opentelemetry/v1/logs`
- Traces: `http://10.255.255.13/insert/opentelemetry/v1/traces`
- Prometheus: `http://10.255.255.13/api/v1/import/prometheus`

### From internet — Bearer token required
- Logs: `https://otel.robotinfra.com/insert/loki/api/v1/push`
- Metrics: `https://otel.robotinfra.com/opentelemetry/v1/metrics`
- Traces: `https://otel.robotinfra.com/insert/opentelemetry/v1/traces`

## Log Sources

| Host | Hostname in VL | Sends |
|------|---------------|-------|
| robotinfra-tnvt | `robotinfra-tnvt` | docker container logs (telegraf) |
| lac-des-coudes-router | `lac-des-coudes-router` | docker container logs (telegraf) |
| command-center | `command-center` | docker logs + system syslog |
| lac-pelletier-router | `rock64` | system syslog |
| ldc-menu-display | `club` | system syslog |
| camera-ldc-01 | `camera-ldc-01` | system syslog |

## Workflows

### Query logs
Use `mcp__victorialogs__query` with LogsQL. Always scope by time with `start`.

Examples:
- All logs from a host: `{host="command-center"}`
- Errors only: `{host="robotinfra-tnvt"} error`
- Container logs: `{container_name="oauth2-server"}`
- By program: `{program="sshd"}`

Aggregate with stats:
- `* | stats by (host) count() as count` — log volume per host
- `{host="robotinfra-tnvt"} | stats by (container_name) count() as count`

### Query metrics
Use `mcp__victoriametrics__query` with PromQL.

- List all metric names: `mcp__victoriametrics__metrics`
- Query a metric: `up{job="telegraf"}`

### Explore traces
Use `mcp__victoriatraces__services` to list services, then `mcp__victoriatraces__traces` to find traces.

### Delete a metric series
SSH into robotinfra-tnvt and use the VictoriaMetrics delete API:

```bash
ssh robotinfra-tnvt "docker exec victoriametrics wget -qO- --post-data='' \
  'http://victoriametrics:8428/api/v1/admin/tsdb/delete_series?match[]=<metric_name>'"
```

### Wipe all logs
Use the `/infrastructure:otel-wipe-logs` command. This is destructive and irreversible.

The script stops victorialogs, wipes the Docker volume, and restarts the container:
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/wipe-logs.sh
```

**Always confirm with the user before running.**

## Common Pitfalls

- **OTLP endpoint rejects JSON**: `/insert/opentelemetry/v1/logs` requires protobuf encoding. Use the Loki endpoint (`/insert/loki/api/v1/push`) for JSON.
- **nginx buffers large Prometheus payloads to disk**: Normal for big telegraf metric batches — not an error.
- **VictoriaLogs has no HTTP delete API** (v1.47.0): Wipe requires stopping the container and clearing the volume.
