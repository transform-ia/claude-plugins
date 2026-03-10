# gokit — Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development
> (if subagents available) or superpowers:executing-plans to implement this plan.
> Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create `github.com/transform-ia/gokit`, a Go application framework
that owns cobra CLI, config loading, telemetry, and HTTP server lifecycle.
Then rewrite the go:gocode plugin to enforce gokit usage.

**Architecture:** Single flat Go package using generics for typed per-command
config. `Run()`/`RunSingle()` entry points set up signal handling, config,
telemetry, and logger. `ServeCommand()` adds HTTP server with automatic
`/health` and `/metrics`. OTel exporters configured via standard
`OTEL_EXPORTER_OTLP_*` env vars targeting Victoria* backends.

**Tech Stack:** Go 1.22+, cobra, envconfig, validator/v10, OTel SDK, otelzap,
Prometheus client, gRPC OTLP exporters.

**Spec:** `docs/superpowers/specs/2026-03-10-otel-telemetry-design.md`

---

## Chunk 1: gokit Library — Core

All work in this chunk happens in a **new repository**:
`/home/patate/sandbox/transformia/gokit/`

### File Structure

| File           | Responsibility                                            |
| -------------- | --------------------------------------------------------- |
| `go.mod`       | Module `github.com/transform-ia/gokit`                    |
| `gokit.go`     | App, Command, Context[T], Run(), RunSingle(), NewCommand()|
| `config.go`    | Generic config loading (envconfig + validator)            |
| `telemetry.go` | OTel orchestrator, resource builder, shutdown             |
| `traces.go`    | TracerProvider: stdouttrace + OTLP gRPC                   |
| `metrics.go`   | MeterProvider: OTLP push + Prometheus reader              |
| `logs.go`      | otelzap: console + OTLP log bridge                        |
| `serve.go`     | ServeCommand(), Route, /health, /metrics, graceful shutdown|

---

### Task 1: Initialize Go module and core types

**Files:**

- Create: `go.mod`
- Create: `gokit.go`

- [ ] **Step 1: Create repo and init module**

```bash
mkdir -p /home/patate/sandbox/transformia/gokit
cd /home/patate/sandbox/transformia/gokit
git init
go mod init github.com/transform-ia/gokit
```

- [ ] **Step 2: Write gokit.go with core types and Run/RunSingle stubs**

```go
package gokit

import (
	"context"
	"fmt"
	"os"
	"os/signal"
	"syscall"

	"github.com/spf13/cobra"
	"github.com/uptrace/opentelemetry-go-extra/otelzap"
)

// Context is passed to every command handler. T is the command's config type.
type Context[T any] struct {
	context.Context
	Config *T
	Logger *otelzap.Logger
}

// App defines a multi-command CLI application.
type App struct {
	Name     string
	Short    string
	Commands []Command
}

// Command is an interface satisfied by NewCommand and ServeCommand.
type Command interface {
	cobraCommand() *cobra.Command
}

// Run starts a multi-command app with signal handling.
func Run(app App) {
	ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer stop()

	rootCmd := &cobra.Command{
		Use:   app.Name,
		Short: app.Short,
	}

	for _, cmd := range app.Commands {
		rootCmd.AddCommand(cmd.cobraCommand())
	}

	if err := rootCmd.ExecuteContext(ctx); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

// RunSingle starts a single-command app (no subcommands).
func RunSingle[T any](name, short string, fn func(ctx *Context[T]) error) {
	ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer stop()

	rootCmd := &cobra.Command{
		Use:   name,
		Short: short,
		RunE: func(cmd *cobra.Command, args []string) error {
			appCtx, err := buildContext[T](cmd.Context(), name)
			if err != nil {
				return err
			}
			defer appCtx.shutdown(cmd.Context())
			return fn(appCtx.context)
		},
	}

	if err := rootCmd.ExecuteContext(ctx); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

// appContext holds the built context and shutdown function.
type appContext[T any] struct {
	context  *Context[T]
	shutdown func(context.Context) error
}

// buildContext creates a Context[T] by loading config, initializing
// telemetry, and creating the logger. Placeholder until config/telemetry
// are implemented.
func buildContext[T any](ctx context.Context, serviceName string) (*appContext[T], error) {
	return &appContext[T]{
		context: &Context[T]{
			Context: ctx,
		},
		shutdown: func(ctx context.Context) error { return nil },
	}, nil
}
```

- [ ] **Step 3: Run go mod tidy and verify compilation**

```bash
go mod tidy
go build ./...
```

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "init: go module with core types, Run, RunSingle stubs"
```

---

### Task 2: Implement config loading with generics

**Files:**

- Create: `config.go`
- Create: `config_test.go`
- Modify: `gokit.go` (wire into buildContext)

- [ ] **Step 1: Write config_test.go (failing tests first)**

```go
package gokit

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

type testConfig struct {
	Port int    `envconfig:"PORT" default:"8080" validate:"required"`
	Name string `envconfig:"APP_NAME" default:"test"`
}

type testBadConfig struct {
	Required string `envconfig:"REQUIRED_FIELD" validate:"required"`
}

func TestLoadConfig_Defaults(t *testing.T) {
	cfg, err := loadConfig[testConfig]()
	require.NoError(t, err)
	assert.Equal(t, 8080, cfg.Port)
	assert.Equal(t, "test", cfg.Name)
}

func TestLoadConfig_ValidationFails(t *testing.T) {
	t.Setenv("REQUIRED_FIELD", "")
	_, err := loadConfig[testBadConfig]()
	require.Error(t, err)
	assert.Contains(t, err.Error(), "config validation failed")
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
go mod tidy
go test ./... -v
```

Expected: FAIL — `loadConfig` not defined.

- [ ] **Step 3: Write config.go**

```go
package gokit

import (
	"fmt"

	"github.com/go-playground/validator/v10"
	"github.com/kelseyhightower/envconfig"
)

func loadConfig[T any]() (*T, error) {
	var cfg T
	if err := envconfig.Process("", &cfg); err != nil {
		return nil, fmt.Errorf("gokit: failed to load config: %w", err)
	}

	validate := validator.New()
	if err := validate.Struct(&cfg); err != nil {
		return nil, fmt.Errorf("gokit: config validation failed: %w", err)
	}

	return &cfg, nil
}
```

- [ ] **Step 4: Wire loadConfig into buildContext in gokit.go**

Update `buildContext`:

```go
func buildContext[T any](ctx context.Context, serviceName string) (*appContext[T], error) {
	cfg, err := loadConfig[T]()
	if err != nil {
		return nil, err
	}

	return &appContext[T]{
		context: &Context[T]{
			Context: ctx,
			Config:  cfg,
		},
		shutdown: func(ctx context.Context) error { return nil },
	}, nil
}
```

- [ ] **Step 5: Run tests to verify they pass**

```bash
go mod tidy
go test ./... -v
```

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat: add generic config loading with envconfig and validator"
```

---

### Task 3: Implement traces.go

**Files:**

- Create: `traces.go`

- [ ] **Step 1: Write traces.go**

```go
package gokit

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

func initTraces(ctx context.Context, res *resource.Resource) (func(context.Context) error, error) {
	var exporters []sdktrace.SpanExporter

	consoleExporter, err := stdouttrace.New(stdouttrace.WithPrettyPrint())
	if err != nil {
		return nil, fmt.Errorf("gokit: stdout trace exporter: %w", err)
	}
	exporters = append(exporters, consoleExporter)

	endpoint := otlpTracesEndpoint()
	if endpoint != "" {
		otlpExporter, err := otlptracegrpc.New(ctx,
			otlptracegrpc.WithEndpoint(endpoint),
			otlptracegrpc.WithInsecure(),
		)
		if err != nil {
			return nil, fmt.Errorf("gokit: OTLP trace exporter: %w", err)
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

	return tp.Shutdown, nil
}

func otlpTracesEndpoint() string {
	if v := os.Getenv("OTEL_EXPORTER_OTLP_TRACES_ENDPOINT"); v != "" {
		return v
	}
	return os.Getenv("OTEL_EXPORTER_OTLP_ENDPOINT")
}
```

- [ ] **Step 2: Compile**

```bash
go mod tidy
go build ./...
```

- [ ] **Step 3: Commit**

```bash
git add -A
git commit -m "feat: add trace provider with stdouttrace and OTLP gRPC"
```

---

### Task 4: Implement metrics.go

**Files:**

- Create: `metrics.go`

- [ ] **Step 1: Write metrics.go**

```go
package gokit

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

func initMetrics(ctx context.Context, res *resource.Resource, mux *http.ServeMux) (func(context.Context) error, error) {
	var opts []sdkmetric.Option
	opts = append(opts, sdkmetric.WithResource(res))

	endpoint := otlpMetricsEndpoint()
	if endpoint != "" {
		otlpExporter, err := otlpmetricgrpc.New(ctx,
			otlpmetricgrpc.WithEndpoint(endpoint),
			otlpmetricgrpc.WithInsecure(),
		)
		if err != nil {
			return nil, fmt.Errorf("gokit: OTLP metric exporter: %w", err)
		}
		opts = append(opts, sdkmetric.WithReader(
			sdkmetric.NewPeriodicReader(otlpExporter),
		))
	}

	if mux != nil {
		promExp, err := promexporter.New()
		if err != nil {
			return nil, fmt.Errorf("gokit: prometheus exporter: %w", err)
		}
		opts = append(opts, sdkmetric.WithReader(promExp))
		mux.Handle("/metrics", promhttp.Handler())
	}

	mp := sdkmetric.NewMeterProvider(opts...)
	otel.SetMeterProvider(mp)

	return mp.Shutdown, nil
}

func otlpMetricsEndpoint() string {
	if v := os.Getenv("OTEL_EXPORTER_OTLP_METRICS_ENDPOINT"); v != "" {
		return v
	}
	return os.Getenv("OTEL_EXPORTER_OTLP_ENDPOINT")
}
```

- [ ] **Step 2: Compile**

```bash
go mod tidy
go build ./...
```

- [ ] **Step 3: Commit**

```bash
git add -A
git commit -m "feat: add meter provider with OTLP push and Prometheus scrape"
```

---

### Task 5: Implement logs.go

**Files:**

- Create: `logs.go`

- [ ] **Step 1: Write logs.go**

```go
package gokit

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

func initLogs(ctx context.Context, res *resource.Resource) (*otelzap.Logger, func(context.Context) error, error) {
	zapCfg := zap.NewProductionConfig()
	zapCfg.EncoderConfig.TimeKey = "timestamp"
	zapCfg.EncoderConfig.EncodeTime = zapcore.ISO8601TimeEncoder
	baseLogger, err := zapCfg.Build()
	if err != nil {
		return nil, nil, fmt.Errorf("gokit: zap logger: %w", err)
	}

	var logShutdown func(context.Context) error

	endpoint := otlpLogsEndpoint()
	if endpoint != "" {
		otlpExporter, err := otlploggrpc.New(ctx,
			otlploggrpc.WithEndpoint(endpoint),
			otlploggrpc.WithInsecure(),
		)
		if err != nil {
			return nil, nil, fmt.Errorf("gokit: OTLP log exporter: %w", err)
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

	logger := otelzap.New(baseLogger)

	shutdown := func(ctx context.Context) error {
		_ = baseLogger.Sync()
		return logShutdown(ctx)
	}

	return logger, shutdown, nil
}

func otlpLogsEndpoint() string {
	if v := os.Getenv("OTEL_EXPORTER_OTLP_LOGS_ENDPOINT"); v != "" {
		return v
	}
	return os.Getenv("OTEL_EXPORTER_OTLP_ENDPOINT")
}
```

- [ ] **Step 2: Compile**

```bash
go mod tidy
go build ./...
```

- [ ] **Step 3: Commit**

```bash
git add -A
git commit -m "feat: add otelzap logger with console and OTLP log bridge"
```

---

### Task 6: Implement telemetry.go orchestrator and wire into buildContext

**Files:**

- Create: `telemetry.go`
- Modify: `gokit.go` (update buildContext)

- [ ] **Step 1: Write telemetry.go**

```go
package gokit

import (
	"context"
	"fmt"
	"net/http"
	"os"

	"github.com/uptrace/opentelemetry-go-extra/otelzap"
	"go.opentelemetry.io/otel/sdk/resource"
	semconv "go.opentelemetry.io/otel/semconv/v1.26.0"
)

type telemetryResult struct {
	logger   *otelzap.Logger
	shutdown func(context.Context) error
}

func initTelemetry(ctx context.Context, serviceName string, mux *http.ServeMux) (*telemetryResult, error) {
	if env := os.Getenv("OTEL_SERVICE_NAME"); env != "" {
		serviceName = env
	}

	res, err := resource.New(ctx,
		resource.WithAttributes(semconv.ServiceName(serviceName)),
		resource.WithTelemetrySDK(),
		resource.WithHost(),
	)
	if err != nil {
		return nil, fmt.Errorf("gokit: resource: %w", err)
	}

	var shutdowns []func(context.Context) error

	tracesShutdown, err := initTraces(ctx, res)
	if err != nil {
		return nil, err
	}
	shutdowns = append(shutdowns, tracesShutdown)

	metricsShutdown, err := initMetrics(ctx, res, mux)
	if err != nil {
		return nil, err
	}
	shutdowns = append(shutdowns, metricsShutdown)

	logger, logsShutdown, err := initLogs(ctx, res)
	if err != nil {
		return nil, err
	}
	shutdowns = append(shutdowns, logsShutdown)

	shutdown := func(ctx context.Context) error {
		var errs []error
		for _, fn := range shutdowns {
			if err := fn(ctx); err != nil {
				errs = append(errs, err)
			}
		}
		if len(errs) > 0 {
			return fmt.Errorf("gokit: shutdown errors: %v", errs)
		}
		return nil
	}

	return &telemetryResult{logger: logger, shutdown: shutdown}, nil
}
```

- [ ] **Step 2: Update buildContext in gokit.go**

```go
func buildContext[T any](ctx context.Context, serviceName string) (*appContext[T], error) {
	cfg, err := loadConfig[T]()
	if err != nil {
		return nil, err
	}

	tel, err := initTelemetry(ctx, serviceName, nil)
	if err != nil {
		return nil, err
	}

	return &appContext[T]{
		context: &Context[T]{
			Context: ctx,
			Config:  cfg,
			Logger:  tel.logger,
		},
		shutdown: tel.shutdown,
	}, nil
}
```

- [ ] **Step 3: Write telemetry_test.go**

```go
package gokit

import (
	"context"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestInitTelemetry_ConsoleOnly(t *testing.T) {
	t.Setenv("OTEL_EXPORTER_OTLP_ENDPOINT", "")
	t.Setenv("OTEL_EXPORTER_OTLP_TRACES_ENDPOINT", "")
	t.Setenv("OTEL_EXPORTER_OTLP_METRICS_ENDPOINT", "")
	t.Setenv("OTEL_EXPORTER_OTLP_LOGS_ENDPOINT", "")

	tel, err := initTelemetry(context.Background(), "test-svc", nil)
	require.NoError(t, err)
	require.NotNil(t, tel.logger)
	require.NotNil(t, tel.shutdown)

	err = tel.shutdown(context.Background())
	require.NoError(t, err)
}
```

- [ ] **Step 4: Run tests**

```bash
go mod tidy
go test ./... -v
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "feat: wire telemetry orchestrator into buildContext"
```

---

### Task 7: Implement NewCommand

**Files:**

- Modify: `gokit.go`

- [ ] **Step 1: Add NewCommand and genericCommand to gokit.go**

```go
type genericCommand[T any] struct {
	use   string
	short string
	fn    func(ctx *Context[T]) error
}

func (c *genericCommand[T]) cobraCommand() *cobra.Command {
	return &cobra.Command{
		Use:   c.use,
		Short: c.short,
		RunE: func(cmd *cobra.Command, args []string) error {
			appCtx, err := buildContext[T](cmd.Context(), cmd.Root().Use)
			if err != nil {
				return err
			}
			defer appCtx.shutdown(cmd.Context())
			return c.fn(appCtx.context)
		},
	}
}

func NewCommand[T any](use, short string, fn func(ctx *Context[T]) error) Command {
	return &genericCommand[T]{use: use, short: short, fn: fn}
}
```

- [ ] **Step 2: Compile**

```bash
go build ./...
```

- [ ] **Step 3: Commit**

```bash
git add -A
git commit -m "feat: add NewCommand with generic typed config"
```

---

### Task 8: Implement serve.go (ServeCommand)

**Files:**

- Create: `serve.go`
- Create: `serve_test.go`

- [ ] **Step 1: Write serve_test.go (failing tests first)**

```go
package gokit

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestReservedPathValidation(t *testing.T) {
	tests := []struct {
		name    string
		pattern string
		wantErr bool
	}{
		{"health is reserved", "/health", true},
		{"metrics is reserved", "/metrics", true},
		{"api is allowed", "/api/users", false},
		{"graphql is allowed", "/graphql", false},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if tt.wantErr {
				assert.True(t, reservedPaths[tt.pattern])
			} else {
				assert.False(t, reservedPaths[tt.pattern])
			}
		})
	}
}

func TestHealthEndpoint(t *testing.T) {
	mux := http.NewServeMux()
	registerHealth(mux)

	rec := httptest.NewRecorder()
	mux.ServeHTTP(rec, httptest.NewRequest("GET", "/health", nil))
	assert.Equal(t, http.StatusOK, rec.Code)
	assert.Contains(t, rec.Body.String(), "ok")
}

func TestGetPortFromConfig(t *testing.T) {
	type withPort struct {
		Port int `envconfig:"PORT" default:"9090"`
	}
	type withoutPort struct {
		Name string
	}

	cfg1 := &withPort{Port: 9090}
	port, ok := getPortFromConfig(cfg1)
	require.True(t, ok)
	assert.Equal(t, 9090, port)

	cfg2 := &withoutPort{Name: "test"}
	_, ok = getPortFromConfig(cfg2)
	assert.False(t, ok)
}

func TestValidateRoutes_RejectsReserved(t *testing.T) {
	routes := []Route{
		{Pattern: "/metrics", Handler: http.NotFoundHandler()},
	}
	err := validateRoutes(routes)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "conflicts with reserved path")
}

func TestValidateRoutes_AcceptsNormal(t *testing.T) {
	routes := []Route{
		{Pattern: "/api/users", Handler: http.NotFoundHandler()},
	}
	err := validateRoutes(routes)
	require.NoError(t, err)
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
go mod tidy
go test ./... -v
```

Expected: FAIL — functions not defined.

- [ ] **Step 3: Write serve.go**

```go
package gokit

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"reflect"
	"time"

	"github.com/spf13/cobra"
	"go.uber.org/zap"
)

// Route defines an HTTP route for ServeCommand.
type Route struct {
	Pattern string
	Handler http.Handler
}

var reservedPaths = map[string]bool{
	"/health":  true,
	"/metrics": true,
}

func validateRoutes(routes []Route) error {
	for _, route := range routes {
		if reservedPaths[route.Pattern] {
			return fmt.Errorf("gokit: route %q conflicts with reserved path", route.Pattern)
		}
	}
	return nil
}

func registerHealth(mux *http.ServeMux) {
	mux.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(map[string]string{"status": "ok"})
	})
}

func getPortFromConfig(cfg any) (int, bool) {
	v := reflect.ValueOf(cfg)
	if v.Kind() == reflect.Ptr {
		v = v.Elem()
	}
	if v.Kind() != reflect.Struct {
		return 0, false
	}
	f := v.FieldByName("Port")
	if !f.IsValid() || f.Kind() != reflect.Int {
		return 0, false
	}
	return int(f.Int()), true
}

type serveCommand[T any] struct {
	use   string
	short string
	fn    func(ctx *Context[T]) []Route
}

func (c *serveCommand[T]) cobraCommand() *cobra.Command {
	return &cobra.Command{
		Use:   c.use,
		Short: c.short,
		RunE: func(cmd *cobra.Command, args []string) error {
			return c.run(cmd)
		},
	}
}

func (c *serveCommand[T]) run(cmd *cobra.Command) error {
	ctx := cmd.Context()
	serviceName := cmd.Root().Use

	cfg, err := loadConfig[T]()
	if err != nil {
		return err
	}

	mux := http.NewServeMux()
	registerHealth(mux)

	tel, err := initTelemetry(ctx, serviceName, mux)
	if err != nil {
		return err
	}
	defer tel.shutdown(ctx)

	appCtx := &Context[T]{
		Context: ctx,
		Config:  cfg,
		Logger:  tel.logger,
	}

	routes := c.fn(appCtx)
	if err := validateRoutes(routes); err != nil {
		return err
	}
	for _, route := range routes {
		mux.Handle(route.Pattern, route.Handler)
	}

	port := 8080
	if p, ok := getPortFromConfig(cfg); ok {
		port = p
	}

	server := &http.Server{
		Addr:    fmt.Sprintf(":%d", port),
		Handler: mux,
	}

	go func() {
		tel.logger.Ctx(ctx).Info("server starting", zap.String("addr", server.Addr))
		if err := server.ListenAndServe(); err != http.ErrServerClosed {
			tel.logger.Ctx(ctx).Error("server error", zap.Error(err))
		}
	}()

	<-ctx.Done()

	shutdownCtx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()
	return server.Shutdown(shutdownCtx)
}

func ServeCommand[T any](use, short string, fn func(ctx *Context[T]) []Route) Command {
	return &serveCommand[T]{use: use, short: short, fn: fn}
}
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
go test ./... -v
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "feat: add ServeCommand with /health, /metrics, route validation"
```

---

### Task 9: Integration test and README

**Files:**

- Create: `gokit_integration_test.go`
- Create: `README.md`

- [ ] **Step 1: Write integration test**

```go
package gokit

import (
	"context"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

type integrationConfig struct {
	Name string `envconfig:"APP_NAME" default:"integration-test"`
}

func TestBuildContext_FullStack(t *testing.T) {
	t.Setenv("OTEL_EXPORTER_OTLP_ENDPOINT", "")
	t.Setenv("OTEL_EXPORTER_OTLP_TRACES_ENDPOINT", "")
	t.Setenv("OTEL_EXPORTER_OTLP_METRICS_ENDPOINT", "")
	t.Setenv("OTEL_EXPORTER_OTLP_LOGS_ENDPOINT", "")

	appCtx, err := buildContext[integrationConfig](context.Background(), "test-svc")
	require.NoError(t, err)

	assert.Equal(t, "integration-test", appCtx.context.Config.Name)
	require.NotNil(t, appCtx.context.Logger)

	err = appCtx.shutdown(context.Background())
	require.NoError(t, err)
}
```

- [ ] **Step 2: Run all tests**

```bash
go test ./... -v
```

Expected: all PASS.

- [ ] **Step 3: Write README.md**

```markdown
# gokit

Go application framework for the transform-ia ecosystem. Owns the full
application lifecycle: CLI, config, telemetry, and HTTP server.

## Install

    go get github.com/transform-ia/gokit

## Quick Start

### Single-command app

    package main

    import "github.com/transform-ia/gokit"

    type Config struct {
        Token string `envconfig:"API_TOKEN" required:"true" validate:"required"`
    }

    func main() {
        gokit.RunSingle[Config]("myapp", "Does a thing", run)
    }

    func run(ctx *gokit.Context[Config]) error {
        ctx.Logger.Ctx(ctx).Info("running")
        return nil
    }

### Multi-command app with HTTP server

    package main

    import "github.com/transform-ia/gokit"

    type ServeConfig struct {
        Port int `envconfig:"PORT" default:"8080" validate:"required"`
    }

    type MigrateConfig struct {
        DatabaseURL string `envconfig:"DATABASE_URL" required:"true" validate:"required"`
    }

    func main() {
        gokit.Run(gokit.App{
            Name:  "myapp",
            Short: "My application",
            Commands: []gokit.Command{
                gokit.ServeCommand[ServeConfig]("serve", "Start server", routes),
                gokit.NewCommand[MigrateConfig]("migrate", "Run migrations", migrate),
            },
        })
    }

    func routes(ctx *gokit.Context[ServeConfig]) []gokit.Route {
        return []gokit.Route{
            {Pattern: "/api/users", Handler: usersHandler(ctx)},
        }
    }

    func migrate(ctx *gokit.Context[MigrateConfig]) error {
        ctx.Logger.Ctx(ctx).Info("migrating")
        return nil
    }

## What gokit provides

- **CLI**: cobra root command, signal handling (SIGINT/SIGTERM)
- **Config**: envconfig loading + validator/v10 validation per command
- **Telemetry**: traces (stdouttrace + OTLP), metrics (OTLP + Prometheus),
  logs (otelzap console + OTLP bridge)
- **HTTP**: ServeCommand with automatic /health and /metrics, graceful shutdown

## Environment Variables

| Variable                               | Purpose            |
| -------------------------------------- | ------------------ |
| `OTEL_EXPORTER_OTLP_ENDPOINT`         | All signals        |
| `OTEL_EXPORTER_OTLP_TRACES_ENDPOINT`  | VictoriaTraces     |
| `OTEL_EXPORTER_OTLP_METRICS_ENDPOINT` | VictoriaMetrics    |
| `OTEL_EXPORTER_OTLP_LOGS_ENDPOINT`    | VictoriaLogs       |
| `OTEL_SERVICE_NAME`                    | Override app name  |

When no endpoint is set, traces go to stdout and logs go to console.

## Reserved Paths

`/health` and `/metrics` are reserved by ServeCommand. Consumer routes
that use these paths cause a startup error.
```

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "test: add integration test; docs: add README"
```

---

## Chunk 2: Go Plugin Rewrite

All work in this chunk happens in:
`/home/patate/sandbox/transformia/claude-plugins/`

---

### Task 10: Delete prometheus.md and rewrite instructions.md

**Files:**

- Delete: `go/assets/directives/prometheus.md`
- Modify: `go/skills/gocode/instructions.md`

- [ ] **Step 1: Delete prometheus.md**

```bash
git rm go/assets/directives/prometheus.md
```

- [ ] **Step 2: Rewrite the full instructions file**

Replace entire contents of `go/skills/gocode/instructions.md` with:

```markdown
# Go Development

## Standards

### NEVER

- Use `os.Getenv()` — use envconfig struct tags
- Use manual struct validation — use validator/v10 struct tags
- Use `internal/` packages — all packages must be importable
- Put `main.go` in `cmd/` — keep at repository root
- Ship code without tests — every package MUST have `_test.go` files
- Depend on concrete implementations for external resources (databases, APIs,
  message queues) — always depend on interfaces
- Write `main()` with manual cobra setup — use `gokit.Run()` or
  `gokit.RunSingle()`
- Write manual signal handling (`signal.NotifyContext`) — gokit owns it
- Call `envconfig.Process()` or `validator.Struct()` directly — gokit owns
  config lifecycle
- Create `*zap.Logger` or `*otelzap.Logger` manually — gokit provides it via
  `Context.Logger`
- Set up OTel providers manually — gokit owns telemetry initialization
- Create `http.Server` manually for serving — use `gokit.ServeCommand()`
- Register `/health` or `/metrics` handlers — gokit registers them
  automatically

### ALWAYS

- Wrap ALL errors: `fmt.Errorf("context: %w", err)`
- Use MCP tools for semantic navigation (not grep)
- Put `go.mod` and `main.go` at git root
- Use `gokit.Run()` for multi-command apps, `gokit.RunSingle()` for
  single-command apps
- Use `gokit.ServeCommand()` for HTTP server commands
- Use `gokit.NewCommand()` for non-HTTP commands (workers, migrations, CLI
  tools)
- Define per-command config structs with envconfig + validator tags
- Access logger via `ctx.Logger.Ctx(ctx)` — never create loggers
- Create spans in every public service method using `otel.Tracer().Start()`
  and record errors with `span.RecordError()` — see
  `assets/directives/telemetry.md`
- Define metrics for key operations using `otel.Meter()` — see
  `assets/directives/telemetry.md`
- **Ship tests with every change** — no PR is complete without tests
- Define interfaces for external dependencies and accept them as constructor
  parameters

## Required Libraries

| Purpose    | Library                                |
| ---------- | -------------------------------------- |
| Framework  | github.com/transform-ia/gokit          |
| Testing    | github.com/stretchr/testify            |
| MCP Server | github.com/mark3labs/mcp-go            |

All other libraries (cobra, envconfig, validator, otelzap, OTel, prometheus)
are provided by gokit. Do NOT import them directly for functionality gokit
provides.

## MCP Tools (gopls)

Prefer MCP tools over grep — they understand Go semantics:

    mcp__golang-*__definition   - Go to definition
    mcp__golang-*__references   - Find all references
    mcp__golang-*__callers      - Who calls this function
    mcp__golang-*__callees      - What does this function call
    mcp__golang-*__hover        - Type information
    mcp__golang-*__diagnostics  - Compiler errors

**When to use MCP tools:**

- Renaming symbols across files → `references`
- Understanding code flow → `callers` and `callees`
- Finding implementations → `definition`
- Checking errors before lint → `diagnostics`

**When to use grep/glob:** string literals, comments, file patterns, non-Go
files.

## Code Patterns

Reference files in `assets/` for complete examples:

| Pattern              | Reference File                  |
| -------------------- | ------------------------------- |
| main.go with gokit   | `assets/examples/main.go`       |
| serve command        | `assets/examples/cmd-serve.go`  |
| worker command       | `assets/examples/cmd-worker.go` |
| service with OTel    | `assets/examples/service.go`    |
| repository + testing | `assets/examples/repository.go` |

For domain-specific patterns, see `assets/directives/`:

- `http-server.md` — HTTP routing with gokit.ServeCommand
- `graphql-server.md` — GraphQL with gqlgen
- `mcp-server.md` — MCP server with mcp-go
- `testing.md` — Testing patterns

## Testing Requirements

**Every package MUST have tests.** Code without tests is incomplete code.

- Write table-driven tests using `testify/assert` and `testify/require`
- Test both success and error paths
- Use `testify/mock` or hand-written fakes for external dependencies

### Interface-Driven Design for Testability

All components that connect to external resources MUST be accessed through
interfaces.

    type UserRepository interface {
        GetByID(ctx context.Context, id string) (*User, error)
        Create(ctx context.Context, user *User) error
    }

    type UserService struct {
        repo   UserRepository
        logger *otelzap.Logger
    }

    func NewUserService(repo UserRepository, logger *otelzap.Logger) *UserService {
        return &UserService{repo: repo, logger: logger}
    }

**Rule of thumb:** If `NewXxx()` takes a concrete struct that talks to the
network or disk, refactor it to accept an interface instead.

### Key Patterns (Quick Reference)

**Config (per-command struct):**

    type ServeConfig struct {
        Port     int    `envconfig:"PORT" default:"8080" validate:"required"`
        LogLevel string `envconfig:"LOG_LEVEL" default:"info"`
    }

**Validation (validator/v10):** Common tags: `required`, `email`, `url`,
`min=N,max=N`, `gte=N,lte=N`, `alphanum`, `omitempty`.

**Error wrapping:** Always `fmt.Errorf("context: %w", err)`, never bare
`return err`.

## Telemetry in Business Code

gokit handles all telemetry initialization. The patterns below show how to use
OTel APIs in your business code. This is NOT optional — every service method
MUST have traces, and every key operation MUST have metrics.

### Traces

Every public method on a service MUST create a span:

    ctx, span := otel.Tracer("myapp").Start(ctx, "ServiceName.MethodName")
    defer span.End()

    span.SetAttributes(attribute.String("key", "value"))

On error, record it on the span:

    span.RecordError(err)
    span.SetStatus(codes.Error, err.Error())

### Metrics

Define meters at package level, use in functions:

    var requestCounter, _ = otel.Meter("myapp").Int64Counter(
        "myapp_requests_total",
        metric.WithDescription("Total requests processed"),
    )

    requestCounter.Add(ctx, 1, metric.WithAttributes(
        attribute.String("method", "GetUser"),
    ))

Metric naming: prefix with `<service>_`, suffix with `_total` (counter),
`_seconds` (histogram), `_bytes` (gauge).

### Logs

Use the logger from `ctx.Logger`. It automatically injects trace/span IDs:

    ctx.Logger.Ctx(ctx).Info("user fetched", zap.String("user_id", id))
    ctx.Logger.Ctx(ctx).Error("failed to fetch user", zap.Error(err))

### Required Imports for Business Code

    import (
        "go.opentelemetry.io/otel"
        "go.opentelemetry.io/otel/attribute"
        "go.opentelemetry.io/otel/codes"
        "go.opentelemetry.io/otel/metric"
        "go.uber.org/zap"
    )

### Environment Variables

Configured at the infrastructure level, NOT in application code:

| Variable                               | Backend         |
| -------------------------------------- | --------------- |
| `OTEL_EXPORTER_OTLP_ENDPOINT`         | All signals     |
| `OTEL_EXPORTER_OTLP_TRACES_ENDPOINT`  | VictoriaTraces  |
| `OTEL_EXPORTER_OTLP_METRICS_ENDPOINT` | VictoriaMetrics |
| `OTEL_EXPORTER_OTLP_LOGS_ENDPOINT`    | VictoriaLogs    |

When no endpoint is set, traces go to stdout and logs go to console.

## Troubleshooting

### "Go not found" or "golangci-lint not found"

Go toolchain not installed locally. Install from go.dev and golangci-lint.run.

### "BLOCKED: Bash not allowed in Go plugin context"

Use `/go:*` slash commands instead of direct shell commands.

### "BLOCKED: Go plugin cannot modify linter configuration"

`.golangci.yaml` is read-only. Discuss lint rule changes with the user.

### "LINT ERRORS: Please fix the issues above"

golangci-lint found errors during Stop hook. Review errors, fix code, and the
hook will re-format and re-lint on next completion.

### MCP server not accessible

Verify gopls installed (`gopls version`), check `.mcp.json`, restart MCP
server.
```

- [ ] **Step 2: Commit**

```bash
git add go/skills/gocode/instructions.md
git commit -m "feat: rewrite gocode skill to enforce gokit with embedded telemetry"
```

---

### Task 11: Rewrite example files

**Files:**

- Modify: `go/assets/examples/main.go`
- Modify: `go/assets/examples/cmd-serve.go`
- Modify: `go/assets/examples/cmd-worker.go`
- Modify: `go/assets/examples/service.go`
- Delete: `go/assets/examples/config.go`

- [ ] **Step 1: Rewrite main.go**

```go
package main

import "github.com/transform-ia/gokit"

func main() {
	gokit.Run(gokit.App{
		Name:  "myapp",
		Short: "My application description",
		Commands: []gokit.Command{
			gokit.ServeCommand[ServeConfig]("serve", "Start HTTP server", routes),
			gokit.NewCommand[WorkerConfig]("worker", "Start background worker", runWorker),
		},
	})
}
```

- [ ] **Step 2: Rewrite cmd-serve.go**

```go
package main

import (
	"net/http"

	"github.com/transform-ia/gokit"
)

type ServeConfig struct {
	Port        int    `envconfig:"PORT" default:"8080" validate:"required"`
	DatabaseURL string `envconfig:"DATABASE_URL" required:"true" validate:"required"`
}

func routes(ctx *gokit.Context[ServeConfig]) []gokit.Route {
	// gokit automatically registers /health and /metrics.
	return []gokit.Route{
		{Pattern: "/api/users", Handler: usersHandler(ctx)},
	}
}

func usersHandler(ctx *gokit.Context[ServeConfig]) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		ctx.Logger.Ctx(r.Context()).Info("handling users request")
		w.WriteHeader(http.StatusOK)
	})
}
```

- [ ] **Step 3: Rewrite cmd-worker.go**

```go
package main

import (
	"github.com/transform-ia/gokit"
	"go.uber.org/zap"
)

type WorkerConfig struct {
	Port     int    `envconfig:"PORT" default:"8080" validate:"required"`
	QueueURL string `envconfig:"QUEUE_URL" required:"true" validate:"required"`
}

func runWorker(ctx *gokit.Context[WorkerConfig]) error {
	ctx.Logger.Ctx(ctx).Info("worker starting", zap.String("queue", ctx.Config.QueueURL))

	for {
		select {
		case <-ctx.Done():
			ctx.Logger.Ctx(ctx).Info("worker shutting down")
			return nil
		default:
			// Process work...
		}
	}
}
```

- [ ] **Step 4: Rewrite service.go**

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

- [ ] **Step 5: Delete config.go**

```bash
rm go/assets/examples/config.go
```

- [ ] **Step 6: Commit**

```bash
git add go/assets/examples/main.go go/assets/examples/cmd-serve.go \
    go/assets/examples/cmd-worker.go go/assets/examples/service.go
git rm go/assets/examples/config.go
git commit -m "feat: rewrite example files to use gokit"
```

---

### Task 12: Update http-server.md and templates

**Files:**

- Modify: `go/assets/directives/http-server.md`
- Modify: `go/assets/templates/main.go.tmpl`
- Modify: `go/assets/templates/cmd.go.tmpl`

- [ ] **Step 1: Rewrite http-server.md**

```markdown
# HTTP Server Directive

**Triggers when:** Application needs HTTP endpoints

## Use gokit.ServeCommand

ALL HTTP serving MUST use `gokit.ServeCommand()`. This automatically provides:

- `/health` endpoint (200 OK, JSON)
- `/metrics` endpoint (Prometheus)
- Graceful shutdown (30s timeout)
- Single port, single mux

    gokit.ServeCommand[ServeConfig]("serve", "Start server", func(ctx *gokit.Context[ServeConfig]) []gokit.Route {
        return []gokit.Route{
            {Pattern: "/api", Handler: apiHandler(ctx)},
            {Pattern: "/graphql", Handler: graphqlHandler(ctx)},
        }
    })

## Middleware Composition

    func RequireAuth(next http.Handler) http.Handler {
        return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
            // auth logic...
            next.ServeHTTP(w, r)
        })
    }

    // Usage in routes:
    {Pattern: "/api", Handler: RequireAuth(apiHandler(ctx))}
```

- [ ] **Step 2: Rewrite main.go.tmpl**

```go
package main

import "github.com/transform-ia/gokit"

func main() {
	gokit.Run(gokit.App{
		Name:  "{{.AppName}}",
		Short: "{{.AppDescription}}",
		Commands: []gokit.Command{
			// Add commands here
		},
	})
}
```

- [ ] **Step 3: Rewrite cmd.go.tmpl**

```go
package main

import "github.com/transform-ia/gokit"

type {{.CommandName}}Config struct {
	// Add config fields with envconfig + validator tags
}

func run{{.CommandName}}(ctx *gokit.Context[{{.CommandName}}Config]) error {
	ctx.Logger.Ctx(ctx).Info("{{.CommandName}} starting")
	return nil
}
```

- [ ] **Step 4: Commit**

```bash
git add go/assets/directives/http-server.md \
    go/assets/templates/main.go.tmpl \
    go/assets/templates/cmd.go.tmpl
git commit -m "feat: update http-server directive and templates for gokit"
```
