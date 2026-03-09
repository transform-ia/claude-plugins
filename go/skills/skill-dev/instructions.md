# Go Development

## Standards

### NEVER

- Use `os.Getenv()` - use envconfig
- Use manual struct validation - use validator/v10 struct tags
- Use `internal/` packages - all packages must be importable
- Put `main.go` in `cmd/` - keep at repository root
- Ship code without tests - every package MUST have `_test.go` files
- Depend on concrete implementations for external resources (databases, APIs,
  message queues) - always depend on interfaces
- Ship a long-running application without OTel metrics - see
  `assets/directives/prometheus.md`

### ALWAYS

- Wrap ALL errors: `fmt.Errorf("context: %w", err)`
- Use MCP tools for semantic navigation (not grep)
- Put `go.mod` and `main.go` at git root (required for tool discovery, hook
  automation, and single-module consistency)
- Single HTTP port with all handlers on one `http.ServeMux`
- **Expose OTel metrics** for every long-running application (servers, workers,
  consumers, daemons) via `/metrics` on the shared HTTP port - if the app has no
  HTTP server, create one for `/health` and `/metrics`. See
  `assets/directives/prometheus.md`
- **Ship tests with every change** - no PR is complete without tests
- Define interfaces for external dependencies (database, HTTP clients, APIs,
  message brokers) and accept them as constructor parameters

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
| main.go structure    | `assets/examples/main.go`       |
| envconfig setup      | `assets/examples/config.go`     |
| service layer        | `assets/examples/service.go`    |
| repository + testing | `assets/examples/repository.go` |
| HTTP serve command   | `assets/examples/cmd-serve.go`  |
| Worker command       | `assets/examples/cmd-worker.go` |
| main.go template     | `assets/templates/main.go.tmpl` |
| cobra cmd template   | `assets/templates/cmd.go.tmpl`  |

For domain-specific patterns, see `assets/directives/`:

- `http-server.md` - HTTP server setup
- `graphql-server.md` - GraphQL with gqlgen
- `mcp-server.md` - MCP server with mcp-go
- `prometheus.md` - Prometheus metrics
- `testing.md` - Testing patterns

## Testing Requirements

**Every package MUST have tests.** Code without tests is incomplete code.

- Write table-driven tests using `testify/assert` and `testify/require`
- Test both success and error paths
- Use `testify/mock` or hand-written fakes for external dependencies

### Interface-Driven Design for Testability

All components that connect to external resources (databases, APIs, message
queues, file systems, caches) MUST be accessed through interfaces. This enables
testing with mocks/fakes without real infrastructure.

```go
// Define the interface where it is USED (consumer package), not where
// it is implemented.
type UserRepository interface {
    GetByID(ctx context.Context, id string) (*User, error)
    Create(ctx context.Context, user *User) error
}

// Service depends on the interface, not the concrete implementation.
type UserService struct {
    repo UserRepository
}

func NewUserService(repo UserRepository) *UserService {
    return &UserService{repo: repo}
}
```

```go
// In tests, use a mock or fake implementation.
type mockUserRepo struct {
    mock.Mock
}

func (m *mockUserRepo) GetByID(ctx context.Context, id string) (*User, error) {
    args := m.Called(ctx, id)
    return args.Get(0).(*User), args.Error(1)
}

func TestUserService_GetByID(t *testing.T) {
    repo := new(mockUserRepo)
    repo.On("GetByID", mock.Anything, "123").
        Return(&User{ID: "123", Name: "Alice"}, nil)

    svc := NewUserService(repo)
    user, err := svc.GetByID(context.Background(), "123")

    require.NoError(t, err)
    assert.Equal(t, "Alice", user.Name)
    repo.AssertExpectations(t)
}
```

**Rule of thumb:** If `NewXxx()` takes a concrete struct that talks to the
network or disk, refactor it to accept an interface instead.

### Key Patterns (Quick Reference)

**Configuration (envconfig):**

```go
type Config struct {
 Port     int    `envconfig:"PORT" default:"8080"`
 LogLevel string `envconfig:"LOG_LEVEL" default:"info"`
}
```

**Validation (validator/v10):**

Common tags: `required`, `email`, `url`, `min=N,max=N`, `gte=N,lte=N`,
`alphanum`, `omitempty`.

**Error wrapping:** Always `fmt.Errorf("context: %w", err)`, never bare
`return err`.

**Logging (otelzap):** `logger.Ctx(ctx).Info("msg", zap.String("key", "val"))`

## Troubleshooting

### "Go not found" or "golangci-lint not found"

Go toolchain not installed locally. Install from [go.dev](https://go.dev/dl/)
and [golangci-lint.run](https://golangci-lint.run/welcome/install/).

### "BLOCKED: Bash not allowed in Go plugin context"

Use `/go:cmd-*` slash commands instead of direct shell commands.

### "BLOCKED: Go plugin cannot modify linter configuration"

`.golangci.yaml` is read-only. Discuss lint rule changes with the user.

### "LINT ERRORS: Please fix the issues above"

golangci-lint found errors during Stop hook. Review errors, fix code, and the
hook will re-format and re-lint on next completion.

### MCP server not accessible

Verify gopls installed (`gopls version`), check `.mcp.json`, restart MCP server.
