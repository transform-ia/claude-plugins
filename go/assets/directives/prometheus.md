# Prometheus Metrics Directive

**Triggers when:** Application needs observability or runs as daemon

## Libraries

- `github.com/prometheus/client_golang/prometheus/promhttp`
- `go.opentelemetry.io/otel/exporters/prometheus`
- `go.opentelemetry.io/otel/sdk/metric`

## Setup Pattern

```go
func InitMetrics(serviceName string) (http.Handler, func(), error) {
    exporter, err := prometheus.New()
    if err != nil {
        return nil, nil, fmt.Errorf("failed to create prometheus exporter: %w", err)
    }

    provider := sdkmetric.NewMeterProvider(sdkmetric.WithReader(exporter))
    otel.SetMeterProvider(provider)

    return promhttp.Handler(), func() { provider.Shutdown(context.Background()) }, nil
}
```

## Health Check Handler

```go
func HealthHandler() http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        w.Header().Set("Content-Type", "application/json")
        w.WriteHeader(http.StatusOK)
        json.NewEncoder(w).Encode(map[string]string{"status": "ok"})
    })
}
```

## Metric Naming

- Prefix: `<service>_`
- Suffixes: `_total` (counter), `_seconds` (histogram), `_bytes` (gauge)
- Example: `myapp_requests_total{endpoint="/api",status="200"}`
