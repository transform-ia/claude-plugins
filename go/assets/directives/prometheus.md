# OTel Metrics Directive

**MANDATORY for every long-running application.** Any process that runs
continuously (HTTP servers, gRPC servers, workers, consumers, schedulers,
daemons) MUST expose OTel metrics via a Prometheus-compatible `/metrics`
endpoint. There are NO exceptions.

## Rule: Every Long-Running App Gets Metrics

A "long-running application" is any process that does not exit after completing a
single task. This includes but is not limited to:

- HTTP/gRPC servers
- Queue consumers and background workers
- Cron/scheduler processes
- File watchers or event-driven daemons

If the application already has an HTTP server, add `/metrics` and `/health` to
the existing `http.ServeMux` — do NOT open a second port. See
`assets/directives/http-server.md`.

If the application does NOT have an HTTP server (e.g. a worker), you MUST create
one solely for `/metrics` and `/health` exposition on the same configured HTTP
port.

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

## Worker Pattern (No Existing HTTP Server)

Workers MUST start an HTTP server for observability. Run it in a goroutine
alongside the worker loop:

```go
func runWorker(ctx context.Context) error {
    cfg, err := LoadConfig()
    if err != nil {
        return fmt.Errorf("failed to load config: %w", err)
    }

    metricsHandler, shutdownMetrics, err := InitMetrics("myworker")
    if err != nil {
        return fmt.Errorf("failed to init metrics: %w", err)
    }
    defer shutdownMetrics()

    mux := http.NewServeMux()
    mux.Handle("/health", HealthHandler())
    mux.Handle("/metrics", metricsHandler)

    server := &http.Server{
        Addr:    fmt.Sprintf(":%d", cfg.HTTPPort),
        Handler: mux,
    }

    go func() {
        if err := server.ListenAndServe(); err != http.ErrServerClosed {
            // log error
        }
    }()

    // ... worker loop using ctx ...

    shutdownCtx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
    defer cancel()
    return server.Shutdown(shutdownCtx)
}
```

## Metric Naming

- Prefix: `<service>_`
- Suffixes: `_total` (counter), `_seconds` (histogram), `_bytes` (gauge)
- Example: `myapp_requests_total{endpoint="/api",status="200"}`
