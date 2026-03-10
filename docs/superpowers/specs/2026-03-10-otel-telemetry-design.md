# OpenTelemetry Telemetry Library & Go Plugin Update

## Summary

Create a shared Go library (`github.com/transform-ia/telemetry`) that
initializes all three OTel pillars (traces, metrics, logs) with a single
`Init()` call. Update the `go:gocode` plugin to use this library instead of
manual Prometheus setup.

## Problem

The current gocode skill focuses on Prometheus metrics scraping and barely
mentions traces or logs. Generated Go code lacks observability. Each service
re-implements OTel setup differently or not at all.

## Solution

### Part 1: `github.com/transform-ia/telemetry` Library

Monolith package with flat structure:

```text
telemetry/
  telemetry.go    Config, Init(), resource setup, shutdown orchestration
  traces.go       TracerProvider: stdouttrace + OTLP gRPC
  metrics.go      MeterProvider: OTLP push + optional Prometheus scrape
  logs.go         otelzap: console + OTLP log bridge
  go.mod
```

#### Public API

```go
type Config struct {
    ServiceName string         // required - otel resource service.name
    Mux         *http.ServeMux // optional - if non-nil, registers /metrics
}

func Init(ctx context.Context, cfg Config) (shutdown func(context.Context) error, err error)
```

#### Environment Variables (standard OTel SDK)

| Variable                              | Purpose                       | Fallback                      |
| ------------------------------------- | ----------------------------- | ----------------------------- |
| `OTEL_EXPORTER_OTLP_ENDPOINT`        | Default endpoint, all signals | Console output                |
| `OTEL_EXPORTER_OTLP_TRACES_ENDPOINT` | VictoriaTraces                | `OTEL_EXPORTER_OTLP_ENDPOINT` |
| `OTEL_EXPORTER_OTLP_METRICS_ENDPOINT`| VictoriaMetrics               | `OTEL_EXPORTER_OTLP_ENDPOINT` |
| `OTEL_EXPORTER_OTLP_LOGS_ENDPOINT`   | VictoriaLogs                  | `OTEL_EXPORTER_OTLP_ENDPOINT` |
| `OTEL_SERVICE_NAME`                   | Override Config.ServiceName   | Config.ServiceName            |

#### Behavior Matrix

| Signal      | Endpoint set                                  | Endpoint not set                                |
| ----------- | --------------------------------------------- | ----------------------------------------------- |
| **Traces**  | OTLP gRPC to VictoriaTraces + stdouttrace     | stdouttrace only                                |
| **Metrics** | OTLP gRPC push to VictoriaMetrics             | No push (Prometheus scrape only if Mux provided)|
| **Logs**    | otelzap console + OTLP log bridge to VictoriaLogs | otelzap console only                       |

#### Dependencies

| Purpose    | Library                                                                |
| ---------- | ---------------------------------------------------------------------- |
| Traces     | `go.opentelemetry.io/otel/sdk/trace`                                  |
| Traces     | `go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracegrpc`    |
| Traces     | `go.opentelemetry.io/otel/exporters/stdout/stdouttrace`               |
| Metrics    | `go.opentelemetry.io/otel/sdk/metric`                                 |
| Metrics    | `go.opentelemetry.io/otel/exporters/otlp/otlpmetric/otlpmetricgrpc`  |
| Metrics    | `go.opentelemetry.io/otel/exporters/prometheus`                       |
| Logs       | `github.com/uptrace/opentelemetry-go-extra/otelzap`                   |
| Logs       | `go.opentelemetry.io/otel/sdk/log`                                    |
| Logs       | `go.opentelemetry.io/otel/exporters/otlp/otlplog/otlploggrpc`        |
| Prometheus | `github.com/prometheus/client_golang/prometheus/promhttp`              |

#### Short-lived vs Long-running

- Long-running daemon: pass `Mux` to get Prometheus `/metrics` scrape endpoint
- Short-lived command: pass `nil` for Mux, metrics only pushed via OTLP if
  configured

### Part 2: Go Plugin Update

#### Files Changed

| File                                 | Change                                              |
| ------------------------------------ | --------------------------------------------------- |
| `skills/gocode/instructions.md`     | Replace Prometheus with full OTel via telemetry lib  |
| `assets/directives/prometheus.md`   | Delete (replaced by telemetry.md)                    |
| `assets/directives/telemetry.md`    | New: all three pillars, env vars, Victoria* backends |
| `assets/examples/cmd-serve.go`      | Add telemetry.Init() with Mux, spans, logging       |
| `assets/examples/cmd-worker.go`     | Replace InitMetrics() with telemetry.Init()          |
| `assets/examples/service.go`        | Add spans, error recording, metrics, otelzap         |

#### Updated Required Libraries Table

| Purpose     | Library                                           |
| ----------- | ------------------------------------------------- |
| CLI         | `github.com/spf13/cobra`                          |
| Config      | `github.com/kelseyhightower/envconfig`            |
| Validation  | `github.com/go-playground/validator/v10`          |
| Testing     | `github.com/stretchr/testify`                     |
| Telemetry   | `github.com/transform-ia/telemetry`               |
| MCP Server  | `github.com/mark3labs/mcp-go`                     |

#### Usage Patterns in Skill

**Long-running daemon:**

```go
mux := http.NewServeMux()
shutdown, err := telemetry.Init(ctx, telemetry.Config{
    ServiceName: "myapp",
    Mux:         mux,
})
if err != nil {
    return fmt.Errorf("failed to init telemetry: %w", err)
}
defer shutdown(ctx)
```

**Short-lived command:**

```go
shutdown, err := telemetry.Init(ctx, telemetry.Config{
    ServiceName: "myapp-migrate",
    Mux:         nil,
})
if err != nil {
    return fmt.Errorf("failed to init telemetry: %w", err)
}
defer shutdown(ctx)
```

**Traces in business code:**

```go
ctx, span := otel.Tracer("myapp").Start(ctx, "UserService.GetUser")
defer span.End()
span.SetAttributes(attribute.String("user.id", id))
// on error:
span.RecordError(err)
span.SetStatus(codes.Error, err.Error())
```

**Metrics in business code:**

```go
var requestCounter, _ = otel.Meter("myapp").Int64Counter("myapp_requests_total")
requestCounter.Add(ctx, 1, metric.WithAttributes(
    attribute.String("method", "GetUser"),
))
```

**Logs in business code:**

```go
logger.Ctx(ctx).Info("user fetched", zap.String("user_id", id))
```

#### What Gets Dropped

- `github.com/prometheus/client_golang/prometheus` from required libraries
- `github.com/uptrace/opentelemetry-go-extra/otelzap` from required libraries
  (still used, but pulled in transitively via telemetry lib)
- `go.opentelemetry.io/otel` from required libraries (same reason)
- `InitMetrics()` and `HealthHandler()` patterns
- `assets/directives/prometheus.md`

## Not Changed

- `SKILL.md` frontmatter
- Templates (`main.go.tmpl`, `cmd.go.tmpl`)
- Other directives (`http-server.md`, `testing.md`, etc.)
- `assets/examples/main.go` (stays thin cobra setup)
- `assets/examples/config.go` (envconfig pattern unchanged)
