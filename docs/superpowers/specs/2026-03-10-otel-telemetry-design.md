# gokit — Go Application Framework & Go Plugin Update

## Summary

Create a shared Go application framework (`github.com/transform-ia/gokit`)
that owns the full application lifecycle: cobra CLI, config loading with
generics, validation, telemetry (traces/metrics/logs), and optional HTTP server
bootstrap. Update the `go:gocode` plugin to use this framework.

## Problem

Every Go application in the transform-ia ecosystem re-implements the same
boilerplate: cobra setup, signal handling, envconfig loading, validator/v10
validation, zap/otelzap logging, OTel setup, HTTP server with graceful
shutdown. The gocode skill describes these patterns as instructions that Claude
reproduces each time, leading to inconsistency and missing observability.

## Solution

### Part 1: `github.com/transform-ia/gokit` Library

#### File Structure

```text
gokit/
  gokit.go          App, Command, Context[T], Run(), RunSingle()
  config.go         Generic config loading (envconfig + validator)
  telemetry.go      OTel orchestrator: Init(), shutdown
  traces.go         TracerProvider: stdouttrace + OTLP gRPC
  metrics.go        MeterProvider: OTLP push + optional Prometheus scrape
  logs.go           otelzap: console + OTLP log bridge
  serve.go          ServeCommand(), Route, /health, /metrics, graceful shutdown
  go.mod
```

#### Public API

##### App Entry Points

```go
// App defines a multi-command CLI application.
type App struct {
    Name     string
    Short    string
    Commands []Command
}

// Command is an interface satisfied by both NewCommand and ServeCommand.
type Command interface {
    cobra() *cobra.Command
}

// Run starts a multi-command app. Sets up signal handling (SIGINT/SIGTERM)
// and executes cobra.
func Run(app App)

// RunSingle starts a single-command app (no subcommands).
// The root command itself runs the function.
func RunSingle[T any](name, short string, fn func(ctx *Context[T]) error)
```

##### Context

```go
// Context is passed to every command handler. T is the command's config type.
type Context[T any] struct {
    context.Context
    Config *T
    Logger *otelzap.Logger
}
```

gokit builds `Context[T]` before calling the handler:
1. Creates signal-aware context (SIGINT/SIGTERM)
2. Calls `envconfig.Process("", &cfg)` on `T`
3. Calls `validator.New().Struct(&cfg)` on `T`
4. Initializes telemetry (reads `OTEL_EXPORTER_OTLP_*` env vars)
5. Creates otelzap logger
6. Defers telemetry shutdown

##### Commands

```go
// NewCommand creates a generic command with typed config.
func NewCommand[T any](use, short string, fn func(ctx *Context[T]) error) Command

// ServeCommand creates an HTTP server command with typed config.
// It creates an http.ServeMux, registers /health and /metrics automatically,
// mounts consumer routes, starts the server, and handles graceful shutdown.
// The config struct MUST have a Port field (envconfig:"PORT").
func ServeCommand[T any](use, short string, fn func(ctx *Context[T]) []Route) Command

// Route defines an HTTP route for ServeCommand.
type Route struct {
    Pattern string
    Handler http.Handler
}
```

##### Health Check

gokit provides a built-in health check at `/health` that returns 200 OK with
`{"status": "ok"}`. This is registered automatically by `ServeCommand` and
cannot be overridden by consumer routes (reserved path).

For non-HTTP commands (`NewCommand`/`RunSingle`), no health endpoint exists —
these are short-lived processes that don't need one.

##### Usage Examples

**Multi-command app with HTTP server:**

```go
package main

import "github.com/transform-ia/gokit"

type ServeConfig struct {
    Port         int    `envconfig:"PORT" default:"8080" validate:"required"`
    DatabaseURL  string `envconfig:"DATABASE_URL" required:"true" validate:"required"`
}

type MigrateConfig struct {
    DatabaseURL string `envconfig:"DATABASE_URL" required:"true" validate:"required"`
}

func main() {
    gokit.Run(gokit.App{
        Name:  "myapp",
        Short: "My application",
        Commands: []gokit.Command{
            gokit.ServeCommand[ServeConfig]("serve", "Start HTTP server", routes),
            gokit.NewCommand[MigrateConfig]("migrate", "Run migrations", runMigrate),
        },
    })
}

func routes(ctx *gokit.Context[ServeConfig]) []gokit.Route {
    return []gokit.Route{
        {Pattern: "/api/users", Handler: usersHandler(ctx)},
        {Pattern: "/graphql", Handler: graphqlHandler(ctx)},
    }
}

func runMigrate(ctx *gokit.Context[MigrateConfig]) error {
    ctx.Logger.Ctx(ctx).Info("running migrations")
    // telemetry active, no HTTP server
    return nil
}
```

**Single-command app (no subcommands):**

```go
package main

import "github.com/transform-ia/gokit"

type Config struct {
    CloverToken  string `envconfig:"CLOVER_TOKEN" required:"true" validate:"required"`
    VMURL        string `envconfig:"VM_URL" required:"true" validate:"required,url"`
    VMMetricName string `envconfig:"VM_METRIC_NAME" default:"clover_order_net_amount"`
}

func main() {
    gokit.RunSingle[Config]("clover-metrics", "Export metrics", runExport)
}

func runExport(ctx *gokit.Context[Config]) error {
    ctx.Logger.Ctx(ctx).Info("starting export")
    ctx.Config.CloverToken // typed access
    return nil
}
```

#### ServeCommand Internals

When `ServeCommand` runs:
1. Builds `Context[T]` (config, telemetry, logger — same as `NewCommand`)
2. Creates `http.ServeMux`
3. Registers `/health` with `HealthHandler()`
4. Registers `/metrics` with Prometheus handler (from telemetry init)
5. Calls consumer's route function
6. **Validates routes**: if any route uses a reserved path (`/health`,
   `/metrics`), `ServeCommand` returns an error and refuses to start
7. Mounts validated consumer routes
8. Starts `http.Server` on `Config.Port`
9. Waits for context cancellation (SIGINT/SIGTERM)
10. Graceful shutdown with 30s timeout

##### Reserved Paths

`/health` and `/metrics` are reserved by gokit. Consumer routes that conflict
with these paths cause a startup error:

```text
gokit: route "/metrics" conflicts with reserved path
```

This is intentional — these endpoints must behave consistently across all
services for infrastructure tooling (Prometheus scraping, load balancer health
checks).

#### Telemetry

##### Environment Variables (standard OTel SDK)

| Variable                               | Purpose                       | Fallback                       |
| -------------------------------------- | ----------------------------- | ------------------------------ |
| `OTEL_EXPORTER_OTLP_ENDPOINT`         | Default endpoint, all signals | Console output                 |
| `OTEL_EXPORTER_OTLP_TRACES_ENDPOINT`  | VictoriaTraces                | `OTEL_EXPORTER_OTLP_ENDPOINT` |
| `OTEL_EXPORTER_OTLP_METRICS_ENDPOINT` | VictoriaMetrics               | `OTEL_EXPORTER_OTLP_ENDPOINT` |
| `OTEL_EXPORTER_OTLP_LOGS_ENDPOINT`    | VictoriaLogs                  | `OTEL_EXPORTER_OTLP_ENDPOINT` |
| `OTEL_SERVICE_NAME`                    | Override app name             | `App.Name`                     |

##### Behavior Matrix

| Signal      | Endpoint set                               | Endpoint not set                                 |
| ----------- | ------------------------------------------ | ------------------------------------------------ |
| **Traces**  | OTLP gRPC to VictoriaTraces + stdouttrace  | stdouttrace only                                 |
| **Metrics** | OTLP gRPC push to VictoriaMetrics          | No push (Prometheus scrape only via ServeCommand)|
| **Logs**    | otelzap console + OTLP bridge to VictoriaLogs | otelzap console only                          |

##### Telemetry in Business Code

Traces:

```go
ctx, span := otel.Tracer("myapp").Start(ctx, "UserService.GetUser")
defer span.End()
span.SetAttributes(attribute.String("user.id", id))
// on error:
span.RecordError(err)
span.SetStatus(codes.Error, err.Error())
```

Metrics:

```go
var requestCounter, _ = otel.Meter("myapp").Int64Counter("myapp_requests_total")
requestCounter.Add(ctx, 1, metric.WithAttributes(
    attribute.String("method", "GetUser"),
))
```

Logs:

```go
ctx.Logger.Ctx(ctx).Info("user fetched", zap.String("user_id", id))
```

#### Dependencies

| Purpose    | Library                                                                |
| ---------- | ---------------------------------------------------------------------- |
| CLI        | `github.com/spf13/cobra`                                              |
| Config     | `github.com/kelseyhightower/envconfig`                                |
| Validation | `github.com/go-playground/validator/v10`                              |
| Logging    | `github.com/uptrace/opentelemetry-go-extra/otelzap`                   |
| Logging    | `go.uber.org/zap`                                                     |
| Traces     | `go.opentelemetry.io/otel/sdk/trace`                                  |
| Traces     | `go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracegrpc`    |
| Traces     | `go.opentelemetry.io/otel/exporters/stdout/stdouttrace`               |
| Metrics    | `go.opentelemetry.io/otel/sdk/metric`                                 |
| Metrics    | `go.opentelemetry.io/otel/exporters/otlp/otlpmetric/otlpmetricgrpc`  |
| Metrics    | `go.opentelemetry.io/otel/exporters/prometheus`                       |
| Logs       | `go.opentelemetry.io/otel/sdk/log`                                    |
| Logs       | `go.opentelemetry.io/otel/exporters/otlp/otlplog/otlploggrpc`        |
| Prometheus | `github.com/prometheus/client_golang/prometheus/promhttp`              |

### Part 2: Go Plugin Rewrite

The go:gocode plugin MUST be rewritten to **enforce** gokit usage. The skill
instructions should make it clear that gokit is not optional — it is the
required way to build Go applications in this ecosystem.

#### Enforcement Rules (new NEVER/ALWAYS entries)

**NEVER:**

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

**ALWAYS:**

- Use `gokit.Run()` for multi-command apps, `gokit.RunSingle()` for
  single-command apps
- Define per-command config structs with envconfig + validator tags
- Use `gokit.ServeCommand()` for HTTP server commands
- Use `gokit.NewCommand()` for non-HTTP commands
- Access logger via `ctx.Logger.Ctx(ctx)` — never create loggers
- Use `otel.Tracer()` and `otel.Meter()` for business code telemetry (these
  are standard OTel APIs, not gokit-specific)

#### Files Changed

| File                                | Change                                               |
| ----------------------------------- | ---------------------------------------------------- |
| `skills/gocode/instructions.md`    | Full rewrite: enforce gokit, update NEVER/ALWAYS,     |
|                                     | replace required libs table, update all patterns.     |
|                                     | Telemetry usage (traces, metrics, logs) embedded      |
|                                     | directly — NOT a separate directive.                  |
| `assets/directives/prometheus.md`  | Delete (absorbed by gokit)                            |
| `assets/directives/http-server.md` | Simplify: reference gokit.ServeCommand instead of     |
|                                     | manual mux/server setup.                              |
| `assets/examples/main.go`          | Rewrite: use gokit.Run() with commands                |
| `assets/examples/cmd-serve.go`     | Rewrite: use gokit.ServeCommand, return routes        |
| `assets/examples/cmd-worker.go`    | Rewrite: use gokit.NewCommand                         |
| `assets/examples/service.go`       | Add spans, error recording, metrics, otelzap          |
| `assets/examples/config.go`        | Delete (config structs live in command files now)      |
| `assets/templates/main.go.tmpl`    | Rewrite: gokit.Run template                           |
| `assets/templates/cmd.go.tmpl`     | Rewrite: gokit.NewCommand template                    |

#### Updated Required Libraries Table

| Purpose    | Library                                |
| ---------- | -------------------------------------- |
| Framework  | `github.com/transform-ia/gokit`        |
| Testing    | `github.com/stretchr/testify`          |
| MCP Server | `github.com/mark3labs/mcp-go`          |

All other libraries (cobra, envconfig, validator, otelzap, OTel, prometheus)
are pulled in transitively via gokit. Consumers MUST NOT import them directly
for functionality that gokit provides.

#### What Gets Dropped from Skill

- `github.com/spf13/cobra` — gokit owns it
- `github.com/kelseyhightower/envconfig` — gokit owns it
- `github.com/go-playground/validator/v10` — gokit owns it
- `github.com/uptrace/opentelemetry-go-extra/otelzap` — gokit owns it
- `go.opentelemetry.io/otel` — gokit owns it
- `github.com/prometheus/client_golang/prometheus` — gokit owns it
- Manual `main()` patterns (signal handling, cobra setup)
- Manual config loading patterns
- `InitMetrics()` and `HealthHandler()` patterns
- `assets/directives/prometheus.md`

## Not Changed

- `SKILL.md` frontmatter
- `assets/directives/graphql-server.md` (gqlgen is app-specific)
- `assets/directives/mcp-server.md` (mcp-go is app-specific)
- `assets/directives/testing.md` (patterns, not code)
- `assets/directives/oauth2-server.md` (project-specific)
- `assets/directives/minio-integration.md` (project-specific)
- `assets/directives/gemini-ocr.md` (project-specific)
