# Go Development

## Permissions

Unless specified, everything else is BLOCKED by hooks, in which cases:

- This is EXPECTED behavior
- DO NOT suggest workarounds
- Report: "This operation is outside the go plugin scope." Unless you think this
  is an implementation issue, in which case start a conversation with the human
  on how to fix the issue.

### Tools Available

- **Read** - Read any file
- **Glob** - Find files by pattern
- **Grep** - Search file contents
- **Search** - Search file by name
- **Write/Edit** - to restricted files (see below)
- **Bash** - Restricted to:
  - `rm` to restricted files (see below)
- **SlashCommand**: | Command | Purpose | |---------|---------| |
  `/go:init <pkg>` | Initialize go.mod | | `/go:tidy` | Clean dependencies | |
  `/go:build` | Build binary | | `/go:test [args]` | Run tests | | `/go:lint` |
  Run linter | | `/go:run [args]` | Run binary | | `/go:mcp-sync` | Sync MCP
  servers |
- **MCP Tools**:
  - `mcp__context7__*` - Library documentation
  - `mcp__golang-*__*` - gopls language server

### File Restrictions

Only the following file(s) can be written, edited or deleted:

- `*.go`
- `go.mod`
- `go.sum`

**Blocked:** `.golangci.yaml` (linter config cannot be modified)

## Out of Scope - Bail Out Immediately

**If the request does NOT involve allowed tools and/or files, STOP and report:**

`Go plugin can't handle request outside its scope.`

## Post processing

When you finish (Post), hooks will automatically:

- Run golangci-lint validation

Fix all issues before completing the task.

## Standards

### NEVER

- Use `os.Getenv()` - use envconfig
- Use manual struct validation - use validator/v10 struct tags
- Use `internal/` packages - all packages must be importable
- Put `main.go` in `cmd/` - keep at repository root

### ALWAYS

- Wrap ALL errors: `fmt.Errorf("context: %w", err)`
- Use MCP tools for semantic navigation (not grep)
- Put `go.mod` and `main.go` at git root
- Single HTTP port with all handlers on one `http.ServeMux`

## Required Libraries

| Purpose    | Library                                           |
| ---------- | ------------------------------------------------- |
| CLI        | github.com/spf13/cobra                            |
| Config     | github.com/kelseyhightower/envconfig              |
| Validation | github.com/go-playground/validator/v10            |
| Testing    | github.com/stretchr/testify                       |
| Logging    | github.com/uptrace/opentelemetry-go-extra/otelzap |
| Tracing    | go.opentelemetry.io/otel                          |
| Metrics    | github.com/prometheus/client_golang/prometheus    |
| MCP Server | github.com/mark3labs/mcp-go                       |

## MCP Tools (gopls)

Prefer MCP tools over grep - they understand Go semantics:

```text
mcp__golang-*__definition   - Go to definition
mcp__golang-*__references   - Find all references
mcp__golang-*__callers      - Who calls this function
mcp__golang-*__callees      - What does this function call
mcp__golang-*__hover        - Type information
mcp__golang-*__diagnostics  - Compiler errors
```

## Patterns

### main.go Structure

```go
package main

import (
 "context"
 "os"
 "os/signal"
 "syscall"

 "github.com/spf13/cobra"
)

func main() {
 ctx, cancel := signal.NotifyContext(context.Background(),
  syscall.SIGINT, syscall.SIGTERM)
 defer cancel()

 if err := rootCmd.ExecuteContext(ctx); err != nil {
  os.Exit(1)
 }
}

var rootCmd = &cobra.Command{
 Use:   "myapp",
 Short: "Application description",
}
```

### Configuration (envconfig)

```go
type Config struct {
 Port        int    `envconfig:"PORT" default:"80"`
 LogLevel    string `envconfig:"LOG_LEVEL" default:"info"`
 OTLPEndpoint string `envconfig:"OTEL_EXPORTER_OTLP_ENDPOINT"`
}

func loadConfig() (*Config, error) {
 var cfg Config
 if err := envconfig.Process("", &cfg); err != nil {
  return nil, fmt.Errorf("loading config: %w", err)
 }
 return &cfg, nil
}
```

### HTTP Server (Single Port)

```go
func SetupRouter(mcpHandler, metricsHandler http.Handler) http.Handler {
 mux := http.NewServeMux()

 // Required endpoints (no auth)
 mux.Handle("/health", HealthHandler())
 mux.Handle("/metrics", metricsHandler)

 // Application routes
 mux.Handle("/mcp", mcpHandler)
 mux.Handle("/graphql", graphqlHandler)

 return mux
}

func HealthHandler() http.Handler {
 return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
  w.WriteHeader(http.StatusOK)
  w.Write([]byte("ok"))
 })
}
```

### OpenTelemetry Tracing

```go
func InitTracing(ctx context.Context, endpoint, serviceName, version string) (trace.Tracer, func(context.Context) error, error) {
 // If no endpoint, use noop tracer
 if endpoint == "" {
  noopProvider := noop.NewTracerProvider()
  otel.SetTracerProvider(noopProvider)
  otel.SetTextMapPropagator(propagation.NewCompositeTextMapPropagator(
   propagation.TraceContext{},
   propagation.Baggage{},
  ))
  return noopProvider.Tracer(serviceName), func(context.Context) error { return nil }, nil
 }

 res, err := resource.New(ctx,
  resource.WithAttributes(
   semconv.ServiceName(serviceName),
   semconv.ServiceVersion(version),
  ),
 )
 if err != nil {
  return nil, nil, fmt.Errorf("creating resource: %w", err)
 }

 exporter, err := otlptracehttp.New(ctx,
  otlptracehttp.WithEndpoint(endpoint),
  otlptracehttp.WithInsecure(),
 )
 if err != nil {
  return nil, nil, fmt.Errorf("creating exporter: %w", err)
 }

 provider := sdktrace.NewTracerProvider(
  sdktrace.WithResource(res),
  sdktrace.WithBatcher(exporter),
  sdktrace.WithSampler(sdktrace.AlwaysSample()),
 )
 otel.SetTracerProvider(provider)
 otel.SetTextMapPropagator(propagation.NewCompositeTextMapPropagator(
  propagation.TraceContext{},
  propagation.Baggage{},
 ))

 return provider.Tracer(serviceName), provider.Shutdown, nil
}
```

### Prometheus Metrics

```go
func InitMetrics(ctx context.Context, endpoint, serviceName, version string) (*Metrics, http.Handler, func(context.Context) error, error) {
 res, _ := resource.New(ctx,
  resource.WithAttributes(
   semconv.ServiceName(serviceName),
   semconv.ServiceVersion(version),
  ),
 )

 prometheusExporter, _ := prometheus.New()

 provider := sdkmetric.NewMeterProvider(
  sdkmetric.WithResource(res),
  sdkmetric.WithReader(prometheusExporter),
 )
 otel.SetMeterProvider(provider)

 meter := provider.Meter(serviceName)

 metrics := &Metrics{}
 metrics.RequestsTotal, _ = meter.Int64Counter("requests_total")
 metrics.RequestDuration, _ = meter.Float64Histogram("request_duration_seconds")

 return metrics, promhttp.Handler(), provider.Shutdown, nil
}
```

### Logging (otelzap)

```go
func NewLogger(level string) *otelzap.Logger {
 var zapLevel zapcore.Level
 switch level {
 case "DEBUG":
  zapLevel = zapcore.DebugLevel
 case "WARN":
  zapLevel = zapcore.WarnLevel
 case "ERROR":
  zapLevel = zapcore.ErrorLevel
 default:
  zapLevel = zapcore.InfoLevel
 }

 config := zap.NewProductionConfig()
 config.Level = zap.NewAtomicLevelAt(zapLevel)
 config.Encoding = "json"

 zapLogger, _ := config.Build(zap.AddCallerSkip(1))
 return otelzap.New(zapLogger)
}

// Usage with context (includes trace IDs)
logger.Ctx(ctx).Info("message", zap.String("key", "value"))
```

### MCP Server

```go
import (
 "github.com/mark3labs/mcp-go/mcp"
 "github.com/mark3labs/mcp-go/server"
)

func NewMCPServer(client MyClient, logger *otelzap.Logger) (*server.MCPServer, error) {
 mcpServer := server.NewMCPServer(
  "my-service",
  "0.0.1",
  server.WithToolCapabilities(true),
 )

 // Register tool
 tool := mcp.NewTool("query_item",
  mcp.WithDescription("Query an item by ID"),
  mcp.WithString("id", mcp.Required(), mcp.Description("Item ID")),
 )

 mcpServer.AddTool(tool, func(ctx context.Context, req mcp.CallToolRequest) (*mcp.CallToolResult, error) {
  id := req.Params.Arguments["id"].(string)
  item, err := client.GetItem(ctx, id)
  if err != nil {
   return mcp.NewToolResultError(err.Error()), nil
  }
  return mcp.NewToolResultText(item.String()), nil
 })

 return mcpServer, nil
}
```

### Tracing Spans

```go
func (s *Service) DoWork(ctx context.Context, id string) error {
 ctx, span := s.tracer.Start(ctx, "Service.DoWork",
  trace.WithSpanKind(trace.SpanKindServer),
  trace.WithAttributes(
   attribute.String("item.id", id),
  ),
 )
 defer span.End()

 result, err := s.client.Get(ctx, id)
 if err != nil {
  span.SetStatus(codes.Error, err.Error())
  span.RecordError(err)
  return fmt.Errorf("getting item: %w", err)
 }

 span.SetAttributes(attribute.String("item.name", result.Name))
 return nil
}
```

### Testing with Interfaces

```go
// Define interface for external dependencies
type DataStore interface {
 Get(ctx context.Context, id string) (*Item, error)
 Put(ctx context.Context, item *Item) error
}

// Mock for testing
type MockStore struct {
 mock.Mock
}

func (m *MockStore) Get(ctx context.Context, id string) (*Item, error) {
 args := m.Called(ctx, id)
 if args.Get(0) == nil {
  return nil, args.Error(1)
 }
 return args.Get(0).(*Item), args.Error(1)
}

// Table-driven test
func TestDoSomething(t *testing.T) {
 tests := []struct {
  name    string
  input   string
  want    string
  wantErr bool
 }{
  {"valid", "foo", "bar", false},
  {"empty", "", "", true},
 }

 for _, tt := range tests {
  t.Run(tt.name, func(t *testing.T) {
   got, err := DoSomething(tt.input)
   if tt.wantErr {
    assert.Error(t, err)
    return
   }
   assert.NoError(t, err)
   assert.Equal(t, tt.want, got)
  })
 }
}
```

### GraphQL Server

```go
import "github.com/99designs/gqlgen/graphql/handler"

func NewGraphQLHandler(resolver *Resolver) http.Handler {
 srv := handler.NewDefaultServer(
  generated.NewExecutableSchema(generated.Config{
   Resolvers: resolver,
  }),
 )
 return srv
}
```
