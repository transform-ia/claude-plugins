# Grafana Dashboard Design

## Dashboard JSON Structure

Key top-level fields:
- `title` — Dashboard name
- `uid` — Short unique ID used in URLs (e.g., `afk-overview`)
- `tags` — Array of strings for organization
- `panels` — Array of panel objects
- `templating.list` — Variables for filtering
- `time` — Default range: `{"from": "now-1h", "to": "now"}`
- `refresh` — Auto-refresh: `"30s"`, `"1m"`, `"5m"`
- `schemaVersion` — Use `39` for Grafana 12.x

## Panel Types

| Type | `type` value | Use for |
|------|-------------|---------|
| Time series | `timeseries` | Metrics over time (default choice) |
| Stat | `stat` | Single current value |
| Gauge | `gauge` | Value with min/max context |
| Bar gauge | `bargauge` | Comparing multiple values |
| Table | `table` | Tabular/multi-column data |
| Logs | `logs` | Log streams from VictoriaLogs |
| Heatmap | `heatmap` | Value distribution over time |
| Text | `text` | Markdown notes, links |

## Layout (24-Column Grid)

Each panel has `gridPos`:
```json
"gridPos": {"x": 0, "y": 0, "w": 12, "h": 8}
```
- `w`: 24 = full width, 12 = half, 8 = third
- `h`: 4 = small stat, 8 = standard, 16 = large
- Increment `y` to stack rows

## Variables

Add a container selector:
```json
{
  "name": "container",
  "type": "query",
  "datasource": {"type": "prometheus", "uid": "VictoriaMetrics"},
  "definition": "label_values(container_cpu_usage_seconds_total, name)",
  "label": "Container",
  "multi": true,
  "includeAll": true
}
```
Use in queries: `{name=~"$container"}`

## Organization

- **Folders**: Group by domain — `Infrastructure`, `Applications`, `Databases`
- **Tags**: `infra`, `app`, `slo`, `oncall`
- **Naming**: `[Domain] Service — Type` (e.g., `[App] afk — Performance`)
- **Rows**: Group related panels under collapsible row panels

## Dashboard Patterns

**RED Method** (per service):
- Rate: `rate(http_requests_total[5m])`
- Errors: `rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m])`
- Duration: `histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))`

**USE Method** (infrastructure):
- Utilization: CPU %, Memory %
- Saturation: queue depth, wait times
- Errors: error counts, OOM events

## Best Practices

- **One dashboard per service** — avoid mega-dashboards
- **Stats at top** — current health at a glance, then details below
- **Consistent colors** — green = healthy, yellow = warning, red = error
- **Always `rate()`** — never plot raw counters in timeseries
- **Set `min: 0`** — on axes unless negative values are meaningful
- **Panel descriptions** — use the info icon to explain what each panel shows
- **Data links** — link panels to drill-down dashboards
- **`create_dashboard` MCP tool** — send the JSON directly; verify at https://graph.robotinfra.com
