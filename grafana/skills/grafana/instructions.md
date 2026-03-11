# Grafana Stack — Usage Guide

## Our Stack

| Component | URL | Purpose |
|-----------|-----|---------|
| Grafana | https://graph.robotinfra.com | Visualization (v12.4.1) |
| VictoriaMetrics | datasource in Grafana | Prometheus-compatible metrics store |
| VictoriaLogs | datasource in Grafana | Log storage |
| VictoriaTraces | datasource in Grafana | Jaeger-compatible traces |

**Grafana datasources (provisioned, names to use in queries):**
- `VictoriaMetrics` — default, Prometheus-compatible, use PromQL
- `VictoriaLogs` — use LogQL (similar to Loki)
- `VictoriaTraces` — Jaeger-compatible, use trace IDs

## Setup

The MCP server runs locally via Docker. First-time setup:
```bash
/grafana:setup <admin-password>
# Then add the printed GRAFANA_SERVICE_ACCOUNT_TOKEN export to ~/.bashrc
```

Admin password is at `docker.secrets.grafana.admin_password` in the infra repo's
`inventory/host_vars/robotinfra-tnvt.yaml`.

## MCP Tools Available

**Dashboards:**
- `list_dashboards` / `search_dashboards` — find by name/tag
- `get_dashboard` — full dashboard JSON by UID
- `create_dashboard` / `update_dashboard` — save changes

**Querying:**
- `query_datasource` — PromQL against VictoriaMetrics or LogQL against VictoriaLogs
- `list_datasources` — all configured datasources and their UIDs

**Alerting:**
- `list_alert_rules` — all alert rules
- `list_alert_instances` — currently firing alerts

**Annotations:**
- `create_annotation` / `list_annotations`

## PromQL Patterns for VictoriaMetrics

```promql
# Container CPU usage
rate(container_cpu_usage_seconds_total{name="grafana"}[5m])

# Memory usage
container_memory_usage_bytes{name="grafana"}

# HTTP request rate (Go services)
rate(http_requests_total{service="afk"}[5m])

# Error rate
rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m])

# 95th percentile latency
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))

# Go runtime memory
go_memstats_alloc_bytes{job="afk"}
```

## LogQL Patterns for VictoriaLogs

```logql
# Logs from a specific container
{container="grafana"}

# Filter by content
{container="afk"} |= "ERROR"

# Parse JSON logs
{container="afk"} | json | level="error"

# Count errors over time
count_over_time({container="afk"} |= "ERROR" [5m])
```

## Services on This Stack

Containers being monitored: `afk`, `ramezay`, `gitea`, `grafana`, `mattermost`,
`minio`, `openclaw`, `quickbooks-bridge`, `victoriametrics`, `victorialogs`,
`victoriatraces`, `database`, `nginx`

## Best Practices

- Always query with a time range (last 1h, 6h, 24h)
- Use `rate()` for counters, never raw values
- When investigating: check metrics → logs → traces in order
- Use `sum by (label)` to break down aggregates
