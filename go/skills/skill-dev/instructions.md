# Go Development

## Post Processing

When you stop, hooks will automatically:

- Run `golangci-lint fmt` to auto-format Go code
- Run `golangci-lint run --fix` to apply auto-fixes and validate

A Stop hook runs both formatting and linting after completion. The `fmt` command
runs first for optimal results. If lint errors occur, address them in a
follow-up iteration.

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

### Git Root Requirement Rationale

**Why go.mod and main.go must be at git root:**

1. **golang-chart discovery**: The chart uses `workdir` value to set pod labels
   for discovery. All commands (build, test, lint) execute relative to this
   workdir, which must match the git root.

2. **Workspace mounting**: The `/workspace` PVC is mounted with git repositories
   as the organizational unit. Pod discovery via `golang.dev/workdir` label
   requires git root paths.

3. **Hook automation**: The stop-lint-check hook finds the git root to determine
   which pod to use for linting. Nested modules would require separate pods and
   separate Helm chart installations.

**Monorepo Support**: While this seems restrictive, the infrastructure supports
ONE Go service per repository. If you need multiple services, use separate
repositories with separate Helm chart installations.

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

### Examples

**Find where a function is defined:**

```text
mcp__golang-*__definition("mypackage.MyFunction")
→ Returns file path, line number, and full function definition
```

**Find all uses of a type:**

```text
mcp__golang-*__references("MyType")
→ Returns every location where MyType is referenced
```

**Understand a function's call graph:**

```text
mcp__golang-*__callers("mypackage.ProcessOrder")
→ Shows which functions call ProcessOrder

mcp__golang-*__callees("mypackage.ProcessOrder")
→ Shows which functions ProcessOrder calls
```

**Get type information:**

```text
mcp__golang-*__hover(file_path, line, column)
→ Returns type signature and documentation
```

**Check for compile errors:**

```text
mcp__golang-*__diagnostics(file_path)
→ Returns compilation errors, unused variables, etc.
```

**When to use MCP tools:**

- Renaming symbols across files → use `references`
- Understanding code flow → use `callers` and `callees`
- Finding implementations → use `definition`
- Checking errors before lint → use `diagnostics`

**When to use grep/glob:**

- Searching string literals or comments
- Finding file patterns
- Searching across non-Go files

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

### Validation (validator/v10)

```go
import "github.com/go-playground/validator/v10"

type CreateUserRequest struct {
 Email    string `json:"email" validate:"required,email"`
 Username string `json:"username" validate:"required,min=3,max=32,alphanum"`
 Age      int    `json:"age" validate:"required,gte=13,lte=120"`
 Website  string `json:"website" validate:"omitempty,url"`
}

var validate = validator.New()

func (r *CreateUserRequest) Validate() error {
 if err := validate.Struct(r); err != nil {
  return fmt.Errorf("validation failed: %w", err)
 }
 return nil
}

// Usage in HTTP handler
func CreateUserHandler(w http.ResponseWriter, r *http.Request) {
 var req CreateUserRequest
 if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
  http.Error(w, "invalid JSON", http.StatusBadRequest)
  return
 }

 if err := req.Validate(); err != nil {
  http.Error(w, err.Error(), http.StatusBadRequest)
  return
 }

 // Process valid request...
}
```

**Common validation tags:**

- `required` - field cannot be empty
- `email` - valid email format
- `url` - valid URL format
- `min=N,max=N` - string/slice length or numeric range
- `gte=N,lte=N` - numeric greater/less than or equal
- `alphanum` - alphanumeric characters only
- `omitempty` - skip validation if field is empty

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
 res, err := resource.New(ctx,
  resource.WithAttributes(
   semconv.ServiceName(serviceName),
   semconv.ServiceVersion(version),
  ),
 )
 if err != nil {
  return nil, nil, nil, fmt.Errorf("creating resource: %w", err)
 }

 prometheusExporter, err := prometheus.New()
 if err != nil {
  return nil, nil, nil, fmt.Errorf("creating prometheus exporter: %w", err)
 }

 provider := sdkmetric.NewMeterProvider(
  sdkmetric.WithResource(res),
  sdkmetric.WithReader(prometheusExporter),
 )
 otel.SetMeterProvider(provider)

 meter := provider.Meter(serviceName)

 metrics := &Metrics{}
 metrics.RequestsTotal, err = meter.Int64Counter("requests_total")
 if err != nil {
  return nil, nil, nil, fmt.Errorf("creating requests counter: %w", err)
 }
 metrics.RequestDuration, err = meter.Float64Histogram("request_duration_seconds")
 if err != nil {
  return nil, nil, nil, fmt.Errorf("creating duration histogram: %w", err)
 }

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

## Troubleshooting

### "No Go development pod found"

**Cause**: golang-chart not installed or workdir label missing.

**Fix**:

1. Install golang-chart:

   ```bash
   gh auth token | helm registry login ghcr.io -u $(gh api user -q .login) --password-stdin
   helm install golang-dev oci://ghcr.io/transform-ia/charts/golang-chart
   ```

2. Verify deployment: `kubectl get pods -l app.kubernetes.io/name=golang-chart`
3. Check pod has label: `kubectl get pods -l golang.dev/workdir --show-labels`

### "BLOCKED: Bash not allowed in Go plugin context"

**Cause**: Trying to run shell commands while in Go plugin scope.

**Fix**: Use `/go:cmd-*` slash commands instead:

- `go build` → `/go:cmd-build <dir>`
- `go test` → `/go:cmd-test <dir>`
- `golangci-lint` → `/go:cmd-lint <dir>`

### "BLOCKED: Go plugin cannot modify linter configuration"

**Cause**: Attempting to edit `.golangci.yaml`.

**Fix**: Linter config is intentionally read-only. Discuss lint rule changes
with the user instead of modifying config.

### "Not inside a git repository"

**Cause**: Working directory is not a git repository.

**Fix**: Navigate to a git repository or initialize one with `git init` (outside
plugin scope).

### "LINT ERRORS: Please fix the issues above"

**Cause**: golangci-lint found errors during Stop hook validation.

**Fix**:

1. Review lint errors in the output
2. Fix reported issues in the Go code
3. The hook will auto-format and re-lint on next completion
4. Some auto-fixes may have been applied already

### MCP server not accessible

**Cause**: golang-chart not installed or MCP server not running.

**Fix**:

1. Verify golang-chart installed: `kubectl get pods -l app.kubernetes.io/name=golang-chart`
2. Check MCP service: `kubectl get svc | grep golang`
3. Check MCP server logs: `kubectl logs deployment/golang-chart`
4. MCP servers are automatically configured when golang-chart is detected
