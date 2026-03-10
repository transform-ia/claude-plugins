# OTel Telemetry Library & Go Plugin Update — Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development
> (if subagents available) or superpowers:executing-plans to implement this plan.
> Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create `github.com/transform-ia/telemetry` Go library that
initializes all three OTel pillars with one call, then update the gocode plugin
to use it.

**Architecture:** Single-package Go library with flat file structure. One
`Init()` entry point configures traces (stdouttrace + OTLP), metrics (OTLP push
+ optional Prometheus scrape), and logs (otelzap console + OTLP bridge).
Standard `OTEL_EXPORTER_OTLP_*` env vars control Victoria* backend
connectivity. The gocode plugin replaces its Prometheus-only directive and
examples with the new library.

**Tech Stack:** Go, OpenTelemetry SDK, otelzap, Prometheus client, gRPC OTLP
exporters.

**Spec:** `docs/superpowers/specs/2026-03-10-otel-telemetry-design.md`

---

## Chunk 1: `github.com/transform-ia/telemetry` Library

### File Structure

| File           | Responsibility                                           |
| -------------- | -------------------------------------------------------- |
| `go.mod`       | Module definition and dependencies                       |
| `telemetry.go` | `Config` struct, `Init()` orchestrator, resource builder |
| `traces.go`    | `initTraces()` — stdouttrace + optional OTLP gRPC       |
| `metrics.go`   | `initMetrics()` — OTLP push + optional Prometheus reader |
| `logs.go`      | `initLogs()` — otelzap console + optional OTLP bridge   |

All work in this chunk happens in a **new repository**:
`/home/patate/sandbox/transformia/telemetry/`

---

### Task 1: Initialize the Go module

**Files:**

- Create: `go.mod`
- Create: `telemetry.go` (minimal, compiles)

- [ ] **Step 1: Create repo directory**

```bash
mkdir -p /home/patate/sandbox/transformia/telemetry
cd /home/patate/sandbox/transformia/telemetry
git init
```

- [ ] **Step 2: Initialize go.mod**

```bash
go mod init github.com/transform-ia/telemetry
```

- [ ] **Step 3: Write minimal telemetry.go with Config and Init stub**

```go
package telemetry

import (
	"context"
	"fmt"
	"net/http"
	"os"

	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/sdk/resource"
	semconv "go.opentelemetry.io/otel/semconv/v1.26.0"
)

// Config holds telemetry initialization options.
type Config struct {
	// ServiceName is the OTel resource service.name attribute.
	// Can be overridden by OTEL_SERVICE_NAME env var.
	ServiceName string

	// Mux is an optional HTTP mux. If non-nil, a /metrics endpoint is
	// registered for Prometheus scraping. Pass nil for short-lived commands.
	Mux *http.ServeMux
}

// Init sets up all three OTel pillars (traces, metrics, logs).
// It reads OTEL_EXPORTER_OTLP_* env vars for backend connectivity.
// When endpoints are not configured, output falls back to console.
// Returns a shutdown function that must be called on exit.
func Init(ctx context.Context, cfg Config) (func(context.Context) error, error) {
	serviceName := cfg.ServiceName
	if env := os.Getenv("OTEL_SERVICE_NAME"); env != "" {
		serviceName = env
	}
	if serviceName == "" {
		return nil, fmt.Errorf("telemetry: ServiceName is required")
	}

	res, err := resource.New(ctx,
		resource.WithAttributes(semconv.ServiceName(serviceName)),
		resource.WithTelemetrySDK(),
		resource.WithHost(),
	)
	if err != nil {
		return nil, fmt.Errorf("telemetry: failed to create resource: %w", err)
	}

	_ = res // will be used by sub-initializers
	shutdown := func(ctx context.Context) error { return nil }
	return shutdown, nil
}
```

- [ ] **Step 4: Run go mod tidy and verify it compiles**

```bash
go mod tidy
go build ./...
```

Expected: compiles with no errors.

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "init: go module with Config and Init stub"
```

---

### Task 2: Implement traces.go

**Files:**

- Create: `traces.go`
- Modify: `telemetry.go` (wire initTraces into Init)

- [ ] **Step 1: Write traces.go**

```go
package telemetry

import (
	"context"
	"fmt"
	"os"

	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracegrpc"
	"go.opentelemetry.io/otel/exporters/stdout/stdouttrace"
	"go.opentelemetry.io/otel/sdk/resource"
	sdktrace "go.opentelemetry.io/otel/sdk/trace"
)

// initTraces sets up the TracerProvider with:
// - stdouttrace exporter (always)
// - OTLP gRPC exporter to VictoriaTraces (when endpoint configured)
//
// Endpoint resolution:
//  1. OTEL_EXPORTER_OTLP_TRACES_ENDPOINT (per-signal override)
//  2. OTEL_EXPORTER_OTLP_ENDPOINT (global fallback)
//  3. No OTLP export (console only)
func initTraces(ctx context.Context, res *resource.Resource) (shutdown func(context.Context) error, err error) {
	var exporters []sdktrace.SpanExporter

	// Console exporter (always active).
	consoleExporter, err := stdouttrace.New(stdouttrace.WithPrettyPrint())
	if err != nil {
		return nil, fmt.Errorf("telemetry: failed to create stdout trace exporter: %w", err)
	}
	exporters = append(exporters, consoleExporter)

	// OTLP exporter (when endpoint is configured).
	endpoint := otlpTracesEndpoint()
	if endpoint != "" {
		otlpExporter, err := otlptracegrpc.New(ctx,
			otlptracegrpc.WithEndpoint(endpoint),
			otlptracegrpc.WithInsecure(),
		)
		if err != nil {
			return nil, fmt.Errorf("telemetry: failed to create OTLP trace exporter: %w", err)
		}
		exporters = append(exporters, otlpExporter)
	}

	opts := []sdktrace.TracerProviderOption{sdktrace.WithResource(res)}
	for _, exp := range exporters {
		opts = append(opts, sdktrace.WithBatchSpanProcessor(
			sdktrace.NewBatchSpanProcessor(exp),
		))
	}

	tp := sdktrace.NewTracerProvider(opts...)
	otel.SetTracerProvider(tp)

	return func(ctx context.Context) error {
		return tp.Shutdown(ctx)
	}, nil
}

// otlpTracesEndpoint returns the OTLP endpoint for traces, or empty string.
func otlpTracesEndpoint() string {
	if v := os.Getenv("OTEL_EXPORTER_OTLP_TRACES_ENDPOINT"); v != "" {
		return v
	}
	return os.Getenv("OTEL_EXPORTER_OTLP_ENDPOINT")
}
```

- [ ] **Step 2: Wire initTraces into Init in telemetry.go**

Replace the stub shutdown in `telemetry.go` `Init()` with:

```go
	var shutdowns []func(context.Context) error

	tracesShutdown, err := initTraces(ctx, res)
	if err != nil {
		return nil, fmt.Errorf("telemetry: traces init failed: %w", err)
	}
	shutdowns = append(shutdowns, tracesShutdown)

	shutdown := func(ctx context.Context) error {
		var errs []error
		for _, fn := range shutdowns {
			if err := fn(ctx); err != nil {
				errs = append(errs, err)
			}
		}
		if len(errs) > 0 {
			return fmt.Errorf("telemetry shutdown errors: %v", errs)
		}
		return nil
	}
	return shutdown, nil
```

- [ ] **Step 3: Run go mod tidy and verify it compiles**

```bash
go mod tidy
go build ./...
```

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "feat: add trace provider with stdouttrace and OTLP gRPC"
```

---

### Task 3: Implement metrics.go

**Files:**

- Create: `metrics.go`
- Modify: `telemetry.go` (wire initMetrics into Init)

- [ ] **Step 1: Write metrics.go**

```go
package telemetry

import (
	"context"
	"fmt"
	"net/http"
	"os"

	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/exporters/otlp/otlpmetric/otlpmetricgrpc"
	promexporter "go.opentelemetry.io/otel/exporters/prometheus"
	sdkmetric "go.opentelemetry.io/otel/sdk/metric"
	"go.opentelemetry.io/otel/sdk/resource"

	"github.com/prometheus/client_golang/prometheus/promhttp"
)

// initMetrics sets up the MeterProvider with:
// - OTLP gRPC periodic reader (when endpoint configured)
// - Prometheus scrape reader + /metrics handler (when mux provided)
//
// Endpoint resolution:
//  1. OTEL_EXPORTER_OTLP_METRICS_ENDPOINT (per-signal override)
//  2. OTEL_EXPORTER_OTLP_ENDPOINT (global fallback)
//  3. No OTLP push
func initMetrics(ctx context.Context, res *resource.Resource, mux *http.ServeMux) (shutdown func(context.Context) error, err error) {
	var opts []sdkmetric.Option
	opts = append(opts, sdkmetric.WithResource(res))

	// OTLP push exporter (when endpoint is configured).
	endpoint := otlpMetricsEndpoint()
	if endpoint != "" {
		otlpExporter, err := otlpmetricgrpc.New(ctx,
			otlpmetricgrpc.WithEndpoint(endpoint),
			otlpmetricgrpc.WithInsecure(),
		)
		if err != nil {
			return nil, fmt.Errorf("telemetry: failed to create OTLP metric exporter: %w", err)
		}
		opts = append(opts, sdkmetric.WithReader(
			sdkmetric.NewPeriodicReader(otlpExporter),
		))
	}

	// Prometheus scrape exporter (when mux is provided).
	if mux != nil {
		promExp, err := promexporter.New()
		if err != nil {
			return nil, fmt.Errorf("telemetry: failed to create prometheus exporter: %w", err)
		}
		opts = append(opts, sdkmetric.WithReader(promExp))
		mux.Handle("/metrics", promhttp.Handler())
	}

	mp := sdkmetric.NewMeterProvider(opts...)
	otel.SetMeterProvider(mp)

	return func(ctx context.Context) error {
		return mp.Shutdown(ctx)
	}, nil
}

// otlpMetricsEndpoint returns the OTLP endpoint for metrics, or empty string.
func otlpMetricsEndpoint() string {
	if v := os.Getenv("OTEL_EXPORTER_OTLP_METRICS_ENDPOINT"); v != "" {
		return v
	}
	return os.Getenv("OTEL_EXPORTER_OTLP_ENDPOINT")
}
```

- [ ] **Step 2: Wire initMetrics into Init in telemetry.go**

Add after the traces init block:

```go
	metricsShutdown, err := initMetrics(ctx, res, cfg.Mux)
	if err != nil {
		return nil, fmt.Errorf("telemetry: metrics init failed: %w", err)
	}
	shutdowns = append(shutdowns, metricsShutdown)
```

- [ ] **Step 3: Run go mod tidy and verify it compiles**

```bash
go mod tidy
go build ./...
```

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "feat: add meter provider with OTLP push and Prometheus scrape"
```

---

### Task 4: Implement logs.go

**Files:**

- Create: `logs.go`
- Modify: `telemetry.go` (wire initLogs into Init, return logger)

- [ ] **Step 1: Write logs.go**

```go
package telemetry

import (
	"context"
	"fmt"
	"os"

	"github.com/uptrace/opentelemetry-go-extra/otelzap"
	"go.opentelemetry.io/otel/exporters/otlp/otlplog/otlploggrpc"
	"go.opentelemetry.io/otel/log/global"
	sdklog "go.opentelemetry.io/otel/sdk/log"
	"go.opentelemetry.io/otel/sdk/resource"
	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"
)

// initLogs sets up the otelzap logger with:
// - Console output (always, via zap)
// - OTLP log bridge to VictoriaLogs (when endpoint configured)
//
// Endpoint resolution:
//  1. OTEL_EXPORTER_OTLP_LOGS_ENDPOINT (per-signal override)
//  2. OTEL_EXPORTER_OTLP_ENDPOINT (global fallback)
//  3. No OTLP export (console only)
func initLogs(ctx context.Context, res *resource.Resource) (*otelzap.Logger, func(context.Context) error, error) {
	// Base zap logger (console output).
	zapCfg := zap.NewProductionConfig()
	zapCfg.EncoderConfig.TimeKey = "timestamp"
	zapCfg.EncoderConfig.EncodeTime = zapcore.ISO8601TimeEncoder
	baseLogger, err := zapCfg.Build()
	if err != nil {
		return nil, nil, fmt.Errorf("telemetry: failed to create zap logger: %w", err)
	}

	var logShutdown func(context.Context) error

	// OTLP log bridge (when endpoint is configured).
	endpoint := otlpLogsEndpoint()
	if endpoint != "" {
		otlpExporter, err := otlploggrpc.New(ctx,
			otlploggrpc.WithEndpoint(endpoint),
			otlploggrpc.WithInsecure(),
		)
		if err != nil {
			return nil, nil, fmt.Errorf("telemetry: failed to create OTLP log exporter: %w", err)
		}

		lp := sdklog.NewLoggerProvider(
			sdklog.WithResource(res),
			sdklog.WithProcessor(sdklog.NewBatchProcessor(otlpExporter)),
		)
		global.SetLoggerProvider(lp)
		logShutdown = lp.Shutdown
	} else {
		logShutdown = func(ctx context.Context) error { return nil }
	}

	// Wrap with otelzap to inject trace/span IDs into log entries.
	logger := otelzap.New(baseLogger)

	shutdown := func(ctx context.Context) error {
		_ = baseLogger.Sync()
		return logShutdown(ctx)
	}

	return logger, shutdown, nil
}

// otlpLogsEndpoint returns the OTLP endpoint for logs, or empty string.
func otlpLogsEndpoint() string {
	if v := os.Getenv("OTEL_EXPORTER_OTLP_LOGS_ENDPOINT"); v != "" {
		return v
	}
	return os.Getenv("OTEL_EXPORTER_OTLP_ENDPOINT")
}
```

- [ ] **Step 2: Update Config and Init in telemetry.go**

Add `Logger` to the return value of `Init()` so callers get a ready-to-use
otelzap logger:

```go
// Init sets up all three OTel pillars (traces, metrics, logs).
// Returns an otelzap logger and a shutdown function.
func Init(ctx context.Context, cfg Config) (*otelzap.Logger, func(context.Context) error, error) {
```

Add after the metrics init block:

```go
	logger, logsShutdown, err := initLogs(ctx, res)
	if err != nil {
		return nil, nil, fmt.Errorf("telemetry: logs init failed: %w", err)
	}
	shutdowns = append(shutdowns, logsShutdown)

	return logger, shutdown, nil
```

- [ ] **Step 3: Run go mod tidy and verify it compiles**

```bash
go mod tidy
go build ./...
```

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "feat: add otelzap logger with console and OTLP log bridge"
```

---

### Task 5: Write tests

**Files:**

- Create: `telemetry_test.go`

- [ ] **Step 1: Write telemetry_test.go**

```go
package telemetry_test

import (
	"context"
	"net/http"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"github.com/transform-ia/telemetry"
)

func TestInit_RequiresServiceName(t *testing.T) {
	_, _, err := telemetry.Init(context.Background(), telemetry.Config{})
	require.Error(t, err)
	assert.Contains(t, err.Error(), "ServiceName is required")
}

func TestInit_ConsoleOnly(t *testing.T) {
	// No OTEL_EXPORTER_OTLP_* env vars set — pure console fallback.
	t.Setenv("OTEL_EXPORTER_OTLP_ENDPOINT", "")
	t.Setenv("OTEL_EXPORTER_OTLP_TRACES_ENDPOINT", "")
	t.Setenv("OTEL_EXPORTER_OTLP_METRICS_ENDPOINT", "")
	t.Setenv("OTEL_EXPORTER_OTLP_LOGS_ENDPOINT", "")

	logger, shutdown, err := telemetry.Init(context.Background(), telemetry.Config{
		ServiceName: "test-service",
	})
	require.NoError(t, err)
	require.NotNil(t, logger)
	require.NotNil(t, shutdown)

	err = shutdown(context.Background())
	require.NoError(t, err)
}

func TestInit_WithMux(t *testing.T) {
	// Mux provided — /metrics should be registered.
	t.Setenv("OTEL_EXPORTER_OTLP_ENDPOINT", "")

	mux := http.NewServeMux()
	logger, shutdown, err := telemetry.Init(context.Background(), telemetry.Config{
		ServiceName: "test-service",
		Mux:         mux,
	})
	require.NoError(t, err)
	require.NotNil(t, logger)
	defer shutdown(context.Background())

	// Verify /metrics is registered by making a request.
	rec := httptest.NewRecorder()
	mux.ServeHTTP(rec, httptest.NewRequest("GET", "/metrics", nil))
	assert.Equal(t, http.StatusOK, rec.Code)
}

func TestInit_ServiceNameFromEnv(t *testing.T) {
	t.Setenv("OTEL_SERVICE_NAME", "env-service")
	t.Setenv("OTEL_EXPORTER_OTLP_ENDPOINT", "")

	logger, shutdown, err := telemetry.Init(context.Background(), telemetry.Config{
		ServiceName: "config-service", // overridden by env
	})
	require.NoError(t, err)
	require.NotNil(t, logger)
	defer shutdown(context.Background())
}
```

Note: add `"net/http/httptest"` to imports.

- [ ] **Step 2: Run tests**

```bash
go test ./... -v
```

Expected: all tests PASS.

- [ ] **Step 3: Commit**

```bash
git add -A
git commit -m "test: add telemetry init tests"
```

---

### Task 6: Add README.md

**Files:**

- Create: `README.md`

- [ ] **Step 1: Write README.md**

```markdown
# telemetry

Go library for initializing OpenTelemetry traces, metrics, and logs with a
single call. Designed for the transform-ia ecosystem with Victoria* backends.

## Install

    go get github.com/transform-ia/telemetry

## Usage

### Long-running daemon

    mux := http.NewServeMux()
    logger, shutdown, err := telemetry.Init(ctx, telemetry.Config{
        ServiceName: "myapp",
        Mux:         mux, // registers /metrics for Prometheus scrape
    })
    if err != nil {
        return fmt.Errorf("failed to init telemetry: %w", err)
    }
    defer shutdown(ctx)

### Short-lived command

    logger, shutdown, err := telemetry.Init(ctx, telemetry.Config{
        ServiceName: "myapp-migrate",
        Mux:         nil, // no Prometheus scrape
    })
    if err != nil {
        return fmt.Errorf("failed to init telemetry: %w", err)
    }
    defer shutdown(ctx)

## Environment Variables

| Variable                               | Purpose            | Fallback                       |
| -------------------------------------- | ------------------ | ------------------------------ |
| `OTEL_EXPORTER_OTLP_ENDPOINT`         | All signals        | Console output                 |
| `OTEL_EXPORTER_OTLP_TRACES_ENDPOINT`  | VictoriaTraces     | `OTEL_EXPORTER_OTLP_ENDPOINT` |
| `OTEL_EXPORTER_OTLP_METRICS_ENDPOINT` | VictoriaMetrics    | `OTEL_EXPORTER_OTLP_ENDPOINT` |
| `OTEL_EXPORTER_OTLP_LOGS_ENDPOINT`    | VictoriaLogs       | `OTEL_EXPORTER_OTLP_ENDPOINT` |
| `OTEL_SERVICE_NAME`                    | Override cfg name  | `Config.ServiceName`           |

## Behavior

| Signal      | Endpoint set            | Endpoint not set                   |
| ----------- | ----------------------- | ---------------------------------- |
| **Traces**  | OTLP + stdouttrace      | stdouttrace only                   |
| **Metrics** | OTLP push               | Prometheus scrape only (if Mux)    |
| **Logs**    | Console + OTLP bridge   | Console only                       |
```

- [ ] **Step 2: Commit**

```bash
git add README.md
git commit -m "docs: add README"
```

---

## Chunk 2: Go Plugin Update in claude-plugins

All work in this chunk happens in:
`/home/patate/sandbox/transformia/claude-plugins/`

---

### Task 7: Create telemetry.md directive (replaces prometheus.md)

**Files:**

- Create: `go/assets/directives/telemetry.md`
- Delete: `go/assets/directives/prometheus.md`

- [ ] **Step 1: Write telemetry.md**

Create `go/assets/directives/telemetry.md`:

```markdown
# Telemetry Directive

**MANDATORY for every application.** All Go applications MUST initialize
telemetry using `github.com/transform-ia/telemetry`. This covers traces,
metrics, and logs in a single call.

## Rule: Every App Gets Telemetry

- Long-running daemons: pass `Mux` to `telemetry.Init()` for Prometheus scrape
- Short-lived commands: pass `nil` for Mux (OTLP push still works if configured)

## Setup

    logger, shutdown, err := telemetry.Init(ctx, telemetry.Config{
        ServiceName: "myapp",
        Mux:         mux, // nil for short-lived commands
    })
    if err != nil {
        return fmt.Errorf("failed to init telemetry: %w", err)
    }
    defer shutdown(ctx)

## Environment Variables

Standard OTel env vars control backend connectivity:

| Variable                               | Backend         |
| -------------------------------------- | --------------- |
| `OTEL_EXPORTER_OTLP_ENDPOINT`         | All signals     |
| `OTEL_EXPORTER_OTLP_TRACES_ENDPOINT`  | VictoriaTraces  |
| `OTEL_EXPORTER_OTLP_METRICS_ENDPOINT` | VictoriaMetrics |
| `OTEL_EXPORTER_OTLP_LOGS_ENDPOINT`    | VictoriaLogs    |

When no endpoint is configured, traces go to stdout and logs go to console.

## Traces in Business Code

Every public method on a service SHOULD create a span:

    ctx, span := otel.Tracer("myapp").Start(ctx, "ServiceName.MethodName")
    defer span.End()

    span.SetAttributes(attribute.String("key", "value"))

On error, record it on the span:

    span.RecordError(err)
    span.SetStatus(codes.Error, err.Error())

## Metrics in Business Code

Define meters at package level, use in functions:

    var requestCounter, _ = otel.Meter("myapp").Int64Counter(
        "myapp_requests_total",
        metric.WithDescription("Total requests processed"),
    )

    requestCounter.Add(ctx, 1, metric.WithAttributes(
        attribute.String("method", "GetUser"),
    ))

### Metric Naming

- Prefix: `<service>_`
- Suffixes: `_total` (counter), `_seconds` (histogram), `_bytes` (gauge)

## Logs in Business Code

Use the otelzap logger returned by `Init()`. It automatically injects
trace/span IDs into log entries:

    logger.Ctx(ctx).Info("user fetched", zap.String("user_id", id))
    logger.Ctx(ctx).Error("failed to fetch user", zap.Error(err))

## Required Imports

    import (
        "go.opentelemetry.io/otel"
        "go.opentelemetry.io/otel/attribute"
        "go.opentelemetry.io/otel/codes"
        "go.opentelemetry.io/otel/metric"
        "go.uber.org/zap"
    )
```

- [ ] **Step 2: Delete prometheus.md**

```bash
rm go/assets/directives/prometheus.md
```

- [ ] **Step 3: Commit**

```bash
git add go/assets/directives/telemetry.md
git rm go/assets/directives/prometheus.md
git commit -m "feat: replace prometheus directive with comprehensive telemetry directive"
```

---

### Task 8: Update instructions.md

**Files:**

- Modify: `go/skills/gocode/instructions.md`

- [ ] **Step 1: Update NEVER section**

Replace:

```markdown
- Ship a long-running application without OTel metrics - see
  `assets/directives/prometheus.md`
```

With:

```markdown
- Ship any application without telemetry - see `assets/directives/telemetry.md`
```

- [ ] **Step 2: Update ALWAYS section**

Replace:

```markdown
- **Expose OTel metrics** for every long-running application (servers, workers,
  consumers, daemons) via `/metrics` on the shared HTTP port - if the app has no
  HTTP server, create one for `/health` and `/metrics`. See
  `assets/directives/prometheus.md`
```

With:

```markdown
- **Initialize telemetry** in every application using
  `github.com/transform-ia/telemetry`. Long-running daemons pass `Mux` for
  Prometheus scrape; short-lived commands pass `nil`. See
  `assets/directives/telemetry.md`
- **Create spans** in every public service method using
  `otel.Tracer().Start()` and record errors with `span.RecordError()`
- **Use otelzap** for all logging via `logger.Ctx(ctx)` to inject trace context
```

- [ ] **Step 3: Update Required Libraries table**

Replace the entire table with:

```markdown
| Purpose    | Library                                |
| ---------- | -------------------------------------- |
| CLI        | github.com/spf13/cobra                 |
| Config     | github.com/kelseyhightower/envconfig   |
| Validation | github.com/go-playground/validator/v10 |
| Testing    | github.com/stretchr/testify            |
| Telemetry  | github.com/transform-ia/telemetry      |
| MCP Server | github.com/mark3labs/mcp-go            |
```

- [ ] **Step 4: Update Code Patterns table**

Add telemetry directive to the directives list. Replace:

```markdown
- `prometheus.md` - Prometheus metrics
```

With:

```markdown
- `telemetry.md` - Traces, metrics, and logs (OTel + Victoria*)
```

- [ ] **Step 5: Update logging quick reference**

Replace:

```markdown
**Logging (otelzap):** `logger.Ctx(ctx).Info("msg", zap.String("key", "val"))`
```

With:

```markdown
**Telemetry:** Initialize with `telemetry.Init(ctx, cfg)`. Use
`otel.Tracer().Start()` for spans, `otel.Meter()` for metrics,
`logger.Ctx(ctx)` for logs. See `assets/directives/telemetry.md`.
```

- [ ] **Step 6: Verify file is well-formed**

Read the full file and confirm all changes are consistent.

- [ ] **Step 7: Commit**

```bash
git add go/skills/gocode/instructions.md
git commit -m "feat: update gocode skill for full OTel telemetry"
```

---

### Task 9: Update example files

**Files:**

- Modify: `go/assets/examples/cmd-serve.go`
- Modify: `go/assets/examples/cmd-worker.go`
- Modify: `go/assets/examples/service.go`

- [ ] **Step 1: Update cmd-serve.go**

```go
package main

import (
	"context"
	"fmt"
	"net/http"
	"os/signal"
	"syscall"
	"time"

	"github.com/spf13/cobra"
	"github.com/transform-ia/telemetry"
)

func serveCmd() *cobra.Command {
	return &cobra.Command{
		Use:   "serve",
		Short: "Start HTTP server",
		RunE: func(cmd *cobra.Command, args []string) error {
			return runServe(cmd.Context())
		},
	}
}

func runServe(ctx context.Context) error {
	cfg, err := LoadConfig()
	if err != nil {
		return fmt.Errorf("failed to load config: %w", err)
	}

	mux := http.NewServeMux()

	logger, shutdown, err := telemetry.Init(ctx, telemetry.Config{
		ServiceName: "myapp",
		Mux:         mux,
	})
	if err != nil {
		return fmt.Errorf("failed to init telemetry: %w", err)
	}
	defer shutdown(ctx)

	// Health check
	mux.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
	})

	// Business handlers go here
	// mux.Handle("/api/users", usersHandler(logger))

	server := &http.Server{
		Addr:    fmt.Sprintf(":%d", cfg.Port),
		Handler: mux,
	}

	ctx, stop := signal.NotifyContext(ctx, syscall.SIGINT, syscall.SIGTERM)
	defer stop()

	go func() {
		logger.Ctx(ctx).Info("server starting")
		if err := server.ListenAndServe(); err != http.ErrServerClosed {
			logger.Ctx(ctx).Error("server error", zap.Error(err))
		}
	}()

	<-ctx.Done()

	shutdownCtx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()
	return server.Shutdown(shutdownCtx)
}
```

- [ ] **Step 2: Update cmd-worker.go**

```go
package main

import (
	"context"
	"fmt"
	"net/http"
	"os/signal"
	"syscall"
	"time"

	"github.com/spf13/cobra"
	"github.com/transform-ia/telemetry"
	"go.uber.org/zap"
)

func workerCmd() *cobra.Command {
	return &cobra.Command{
		Use:   "worker",
		Short: "Start background worker",
		RunE: func(cmd *cobra.Command, args []string) error {
			return runWorker(cmd.Context())
		},
	}
}

func runWorker(ctx context.Context) error {
	cfg, err := LoadConfig()
	if err != nil {
		return fmt.Errorf("failed to load config: %w", err)
	}

	mux := http.NewServeMux()

	logger, shutdown, err := telemetry.Init(ctx, telemetry.Config{
		ServiceName: "myworker",
		Mux:         mux,
	})
	if err != nil {
		return fmt.Errorf("failed to init telemetry: %w", err)
	}
	defer shutdown(ctx)

	mux.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
	})

	server := &http.Server{
		Addr:    fmt.Sprintf(":%d", cfg.Port),
		Handler: mux,
	}

	go func() {
		if err := server.ListenAndServe(); err != http.ErrServerClosed {
			logger.Ctx(ctx).Error("http server error", zap.Error(err))
		}
	}()

	ctx, stop := signal.NotifyContext(ctx, syscall.SIGINT, syscall.SIGTERM)
	defer stop()

	logger.Ctx(ctx).Info("worker starting")
	// ... worker loop using ctx ...
	<-ctx.Done()

	shutdownCtx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()
	return server.Shutdown(shutdownCtx)
}
```

- [ ] **Step 3: Update service.go**

```go
package main

import (
	"context"
	"fmt"

	"github.com/uptrace/opentelemetry-go-extra/otelzap"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/codes"
	"go.opentelemetry.io/otel/metric"
	"go.uber.org/zap"
)

var (
	userFetchCounter, _ = otel.Meter("myapp").Int64Counter(
		"myapp_user_fetch_total",
		metric.WithDescription("Total user fetch operations"),
	)
)

// UserService handles user business logic.
type UserService struct {
	repo   UserRepository
	logger *otelzap.Logger
}

func NewUserService(repo UserRepository, logger *otelzap.Logger) *UserService {
	return &UserService{repo: repo, logger: logger}
}

func (s *UserService) GetUser(ctx context.Context, id string) (*User, error) {
	ctx, span := otel.Tracer("myapp").Start(ctx, "UserService.GetUser")
	defer span.End()

	span.SetAttributes(attribute.String("user.id", id))
	userFetchCounter.Add(ctx, 1, metric.WithAttributes(
		attribute.String("method", "GetUser"),
	))

	s.logger.Ctx(ctx).Info("fetching user", zap.String("user_id", id))

	user, err := s.repo.FindByID(ctx, id)
	if err != nil {
		span.RecordError(err)
		span.SetStatus(codes.Error, err.Error())
		return nil, fmt.Errorf("failed to find user %s: %w", id, err)
	}
	return user, nil
}
```

- [ ] **Step 4: Commit**

```bash
git add go/assets/examples/cmd-serve.go go/assets/examples/cmd-worker.go go/assets/examples/service.go
git commit -m "feat: update example files with full OTel telemetry patterns"
```

---

### Task 10: Update http-server.md directive

**Files:**

- Modify: `go/assets/directives/http-server.md`

- [ ] **Step 1: Update metrics reference**

Replace the `mux.Handle("/metrics", metricsHandler)` line in the example with a
comment indicating telemetry.Init handles this:

```go
// /metrics is registered automatically by telemetry.Init() when Mux is provided
```

- [ ] **Step 2: Commit**

```bash
git add go/assets/directives/http-server.md
git commit -m "fix: update http-server directive to reference telemetry.Init"
```
