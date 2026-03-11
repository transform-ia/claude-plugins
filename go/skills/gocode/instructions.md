# Go Development

## Standards

### NEVER

- Use `os.Getenv()` — use envconfig struct tags
- Use `internal/` packages — all packages must be importable
- Put `main.go` in `cmd/` — keep at repository root
- Write `main()` with manual cobra setup — use `gokit.Run()` or `gokit.RunSingle()`
- Write manual signal handling, config loading, or logger creation — gokit owns all of it
- Set up OTel providers manually — gokit owns telemetry initialization
- Create `http.Server` manually — use `gokit.ServeCommand()`
- Register `/health` or `/metrics` handlers — gokit registers them automatically
- Depend on concrete implementations for external resources — always depend on interfaces
- Leave any function that does real work without a span
- Leave any error path without `span.RecordError()` and a structured log entry

### ALWAYS

- Wrap ALL errors: `fmt.Errorf("context: %w", err)`
- Use MCP tools for semantic navigation (not grep)
- Use `gokit.Run()` for multi-command apps, `gokit.RunSingle()` for single-command apps
- Use `gokit.ServeCommand()` for HTTP server commands, `gokit.NewCommand()` for workers/CLI
- Define per-command config structs with envconfig + validator tags
- Access logger via `ctx.Logger.Ctx(ctx)` — never create loggers
- **Instrument everything** — every function that does real work needs spans, logs, and metrics
- **Ship tests with every change** — no PR is complete without tests

## Required Libraries

| Purpose   | Library                       |
| --------- | ----------------------------- |
| Framework | github.com/transform-ia/gokit |
| Testing   | github.com/stretchr/testify   |
| MCP       | github.com/mark3labs/mcp-go   |

All other libraries (cobra, envconfig, validator, otelzap, OTel, prometheus) are provided
by gokit. Do NOT import them directly.

## MCP Tools (gopls)

Prefer MCP tools over grep — they understand Go semantics:

    mcp__golang-*__definition   - Go to definition
    mcp__golang-*__references   - Find all references
    mcp__golang-*__callers      - Who calls this function
    mcp__golang-*__callees      - What does this function call
    mcp__golang-*__hover        - Type information
    mcp__golang-*__diagnostics  - Compiler errors

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

## Telemetry

gokit initializes all OTel providers. Your job is to instrument business code
**densely**. Sparse telemetry is incomplete code — treat it the same as missing tests.

### Required Imports

    import (
        "go.opentelemetry.io/otel"
        "go.opentelemetry.io/otel/attribute"
        "go.opentelemetry.io/otel/codes"
        "go.opentelemetry.io/otel/metric"
        "go.uber.org/zap"
    )

### Traces — every function that does real work

    ctx, span := otel.Tracer("myapp").Start(ctx, "Service.Method")
    defer span.End()

    span.SetAttributes(
        attribute.String("entity.id", id),
        attribute.Int("batch.size", n),
    )

On error — always both RecordError AND SetStatus:

    span.RecordError(err)
    span.SetStatus(codes.Error, err.Error())

Nest spans for sub-operations (DB call, external API, validation step). A service
method calling a repository should produce a parent span with a child span for the
query. Never flatten work into a single span.

### Metrics — define at package level, instrument key operations

Six instrument types, all available via `otel.Meter("myapp")`:

    // Monotonically increasing counts
    requestsTotal, _ := meter.Int64Counter("myapp.requests.total",
        metric.WithDescription("Total requests processed"),
        metric.WithUnit("{request}"),
    )

    // Current value (async, read at collection time)
    _, _ = meter.Int64ObservableGauge("myapp.queue.depth",
        metric.WithInt64Callback(func(_ context.Context, o metric.Int64Observer) error {
            o.Observe(currentDepth)
            return nil
        }),
    )

    // Distribution of durations or sizes
    duration, _ := meter.Int64Histogram("myapp.operation.duration_ms",
        metric.WithUnit("ms"),
    )
    duration.Record(ctx, elapsed.Milliseconds())

**Metric naming:** `<service>.<noun>.<unit_or_type>` — e.g. `worker.jobs.total`,
`api.request.duration_ms`, `queue.messages.depth`.

**Cardinality rule:** Never use high-cardinality values (IDs, user emails, request
bodies) as metric attributes. Low-cardinality only: status, method, error_type,
environment.

What to measure — at minimum:
- Request/job/event counters (total processed, total failed)
- Queue or backlog depth (observable gauge)
- Processing duration (histogram)
- Payload or data sizes (histogram)
- Resource utilization (CPU, connection pool — observable gauge)

### Logs — structured, at every meaningful event

    logger := ctx.Logger.Ctx(ctx) // propagates trace/span IDs automatically

    logger.Info("job started", zap.String("job_id", id), zap.Int("payload_bytes", n))
    logger.Warn("slow operation", zap.Duration("duration", d), zap.String("op", name))
    logger.Error("job failed", zap.Error(err), zap.String("job_id", id))

Log at every: function entry (debug), success (info), warning condition (warn),
and error (error). Always include the relevant entity IDs and key measurements as
structured fields — never embed them in the message string.

### Telemetry Density Checklist

Before marking any feature complete, verify:

- [ ] Every service method has a span with relevant attributes
- [ ] Every error path calls `span.RecordError()` + logs at Error level
- [ ] Every loop or batch operation has a counter for items processed
- [ ] Every timed operation records to a histogram
- [ ] Every "depth" or "size" state has a gauge
- [ ] Every function entry/exit has debug/info logs with structured fields
- [ ] No metric attribute has unbounded cardinality

## Linting

golangci-lint runs automatically as a Stop hook after every `/go:*` command —
it formats and fixes your code, then blocks completion if errors remain. You do
not need to invoke it manually during normal development.

To run explicitly: `/go:golint <directory>`

**Never skip or suppress lint errors.** If golangci-lint blocks, fix the
reported issues. Do not add `//nolint` directives without a documented reason.

`.golangci.yaml` is owned by the project — do not modify it without explicit
user approval.

## Testing

Every package MUST have `_test.go` files. Code without tests is incomplete.

- Table-driven tests with `testify/assert` and `testify/require`
- Test success and error paths
- Use hand-written fakes for external dependencies (prefer simple structs over
  mock frameworks)
- All external dependencies (DB, API, queue) accessed through interfaces so they
  can be faked in tests

### OTel Testing with testkit

gokit apps emit spans, metrics, and logs. Use `github.com/transform-ia/gokit/testkit`
to capture and assert on all three signals in-process — no real OTel collector needed.

```go
import (
    "context"
    "testing"
    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/require"
    "go.opentelemetry.io/otel/sdk/metric/metricdata"
    sdktrace "go.opentelemetry.io/otel/sdk/trace"
    "github.com/transform-ia/gokit/testkit"
)

func TestMyHandler(t *testing.T) {
    tk := testkit.Setup(t)  // installs in-memory OTel providers; cleaned up via t.Cleanup
    ctx := testkit.NewContext[Config](t, tk, &Config{Port: 8080})

    // call your code that uses ctx.Logger, otel.Tracer(), otel.Meter()
    err := myFunc(ctx)
    require.NoError(t, err)

    // Assert spans
    ended := tk.Spans.Ended()
    names := make([]string, len(ended))
    for i, s := range ended { names[i] = s.Name() }
    assert.Contains(t, names, "MyService.DoWork")

    // Assert span status / events
    for _, s := range ended {
        if s.Name() == "MyService.DoWork" {
            assert.Equal(t, codes.Ok, s.Status().Code)
        }
    }

    // Assert metrics
    var rm metricdata.ResourceMetrics
    require.NoError(t, tk.Metrics.Collect(context.Background(), &rm))
    // find counter by name and attribute value

    // Assert logs
    assert.NotEmpty(t, tk.Logs.Records())
}
```

**`testkit.Setup(t)`** wires `tracetest.SpanRecorder`, `sdkmetric.ManualReader`,
and `InMemoryLogExporter` as the global OTel providers. Call it once per test;
providers are replaced for each test (no cross-test leakage).

**`testkit.NewContext[T]`** creates a `*gokit.Context[T]` with a silent (discarding)
zap core and `otelzap.WithMinLevel(DebugLevel)` so every log level flows through
to the OTel bridge and appears in `tk.Logs.Records()`.

### Testing HTTP Handlers

Call `buildRoutes(ctx)` directly — no need to start an HTTP server:

```go
func TestGetWork_HappyPath(t *testing.T) {
    tk := testkit.Setup(t)
    ctx := testkit.NewContext[Config](t, tk, &Config{Port: 8080})
    rts := buildRoutes(ctx)  // returns []gokit.Route

    req := httptest.NewRequest(http.MethodGet, "/work", nil)
    rec := httptest.NewRecorder()
    // find the handler for the route pattern and invoke it
    for _, r := range rts {
        if r.Pattern == "GET /work" {
            r.Handler.ServeHTTP(rec, req)
        }
    }

    assert.Equal(t, http.StatusOK, rec.Code)
    assert.Contains(t, spanNames(tk.Spans.Ended()), "work")
}
```

### Testing Workers (infinite loops)

Workers use `ctx.Done()` to exit. Use `context.WithTimeout` to run one iteration:

```go
func TestRun_ProcessesOneBatch(t *testing.T) {
    tk := testkit.Setup(t)
    ctx := testkit.NewContext[Config](t, tk, &Config{})

    // give enough time for at least one batch (job sleep ≤ 30ms, batch ≤ 5 jobs)
    cancelCtx, cancel := context.WithTimeout(ctx.Context, 400*time.Millisecond)
    defer cancel()
    ctx.Context = cancelCtx

    require.NoError(t, run(ctx))

    assert.Contains(t, spanNames(tk.Spans.Ended()), "batch.process")
    assert.NotEmpty(t, tk.Logs.Records())
}
```

### Asserting Metrics

`tk.Metrics` is an `sdkmetric.ManualReader` — call `Collect` to pull the
current state:

```go
var rm metricdata.ResourceMetrics
require.NoError(t, tk.Metrics.Collect(context.Background(), &rm))

// find a counter with a specific attribute value
for _, sm := range rm.ScopeMetrics {
    for _, m := range sm.Metrics {
        if m.Name == "myapp.requests.total" {
            sum := m.Data.(metricdata.Sum[int64])
            for _, dp := range sum.DataPoints {
                v, ok := dp.Attributes.Value(attribute.Key("endpoint"))
                if ok && v.AsString() == "/work" {
                    assert.Equal(t, int64(1), dp.Value)
                }
            }
        }
    }
}
```

Note: attribute lookup uses `attribute.Key("keyname")`, not a plain string.

## OTLP Environment Variables

Configured at infra level, NOT in application code:

| Variable                               | Example value |
| -------------------------------------- | ------------- |
| `OTEL_EXPORTER_OTLP_TRACES_ENDPOINT`  | `http://victoriatraces:9428/insert/opentelemetry/v1/traces` |
| `OTEL_EXPORTER_OTLP_METRICS_ENDPOINT` | `http://victoriametrics:8428/opentelemetry/v1/metrics` |
| `OTEL_EXPORTER_OTLP_LOGS_ENDPOINT`    | `http://victorialogs:9428/insert/opentelemetry/v1/logs` |
| `OTEL_EXPORTER_OTLP_HEADERS`          | `authorization=Bearer <token>` |
| `OTEL_METRIC_EXPORT_INTERVAL`         | `10000` (ms, default 60000) |

Transport is **HTTP** (not gRPC). URL scheme controls TLS: `http://` inside Docker,
`https://` externally. External endpoint: `https://otel.robotinfra.com` (bearer token
required). When no endpoint is set, traces fall back to stdout.
