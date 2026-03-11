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
  and record errors with `span.RecordError()` — see Telemetry section below
- Define metrics for key operations using `otel.Meter()` — see Telemetry
  section below
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

| Variable                               | Backend         | Notes |
| -------------------------------------- | --------------- | --- |
| `OTEL_EXPORTER_OTLP_ENDPOINT`         | All signals     | Full URL with scheme required (e.g., `http://host:port`) |
| `OTEL_EXPORTER_OTLP_TRACES_ENDPOINT`  | VictoriaTraces  | Full URL with path (e.g., `http://victoriatraces:9428/insert/opentelemetry/v1/traces`) |
| `OTEL_EXPORTER_OTLP_METRICS_ENDPOINT` | VictoriaMetrics | Full URL with path (e.g., `http://victoriametrics:8428/opentelemetry/v1/metrics`) |
| `OTEL_EXPORTER_OTLP_LOGS_ENDPOINT`    | VictoriaLogs    | Full URL with path (e.g., `http://victorialogs:9428/insert/opentelemetry/v1/logs`) |
| `OTEL_EXPORTER_OTLP_HEADERS`          | Auth            | Comma-separated `key=value` pairs (e.g., `"authorization=Bearer <token>"`) |

**Transport:** OTLP uses **HTTP** (not gRPC). The URL scheme controls TLS: `http://` for
plain HTTP (internal Docker network), `https://` for TLS (external). The SDK reads
`OTEL_EXPORTER_OTLP_HEADERS` automatically — no code changes needed to add auth.

**External ingestion endpoint:** `https://otel.robotinfra.com` (bearer token required).
**Internal Docker network:** use container hostnames directly (e.g., `victoriametrics:8428`).

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
