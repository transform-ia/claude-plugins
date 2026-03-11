# Grafana Alerting

## Components

- **Alert rule**: Query + condition + evaluation schedule
- **Notification policy**: Routes alerts to contact points by label matchers
- **Contact point**: Delivery target (email, Slack/Mattermost webhook, etc.)
- **Silence**: Temporarily mute alerts matching label matchers

## Alert Rule JSON

```json
{
  "title": "High Error Rate — afk",
  "condition": "C",
  "data": [
    {
      "refId": "A",
      "relativeTimeRange": {"from": 300, "to": 0},
      "datasourceUid": "VictoriaMetrics",
      "model": {
        "expr": "rate(http_requests_total{service=\"afk\",status=~\"5..\"}[5m]) / rate(http_requests_total{service=\"afk\"}[5m])",
        "refId": "A"
      }
    },
    {
      "refId": "C",
      "datasourceUid": "-100",
      "model": {
        "type": "threshold",
        "refId": "C",
        "conditions": [{"evaluator": {"params": [0.05], "type": "gt"}}]
      }
    }
  ],
  "intervalSeconds": 60,
  "for": "5m",
  "labels": {"severity": "warning", "team": "infra"},
  "annotations": {
    "summary": "Error rate above 5% for afk",
    "description": "Current rate: {{ $values.A }}"
  }
}
```

## Alert State Machine

```
Normal → Pending (condition true, within "for" window)
       → Firing  (condition true for full "for" duration)
       → Normal  (condition no longer true)
```

Use `for: 5m` minimum to avoid flapping.

## Common Alert Patterns

```promql
# Service producing no metrics (down)
absent(up{job="afk"})

# HTTP error rate > 5%
rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m]) > 0.05

# p95 latency > 1s
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 1

# Container memory > 85% of limit
container_memory_usage_bytes / container_spec_memory_limit_bytes > 0.85

# Disk > 85% full
(node_filesystem_size_bytes - node_filesystem_free_bytes) / node_filesystem_size_bytes > 0.85
```

## Notification Routing

Route by `severity` label:
- `critical` → immediate (PagerDuty, phone)
- `warning` → Mattermost (`chat.robotinfra.com`), business hours
- `info` → email digest

Defaults: `group_wait: 30s`, `group_interval: 5m`, `repeat_interval: 4h`

## Best Practices

- **Alert on symptoms** — high error rate, not "CPU is high"
- **Use `for`** — minimum 2-5 min to avoid flapping
- **Label consistently** — always `severity` + `team`
- **Add runbook links** — `runbook_url` annotation
- **Test first** — use Grafana's "Test" button before enabling
- **Silence with reason** — always include a comment
