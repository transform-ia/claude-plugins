# Go Development Guidelines

## Critical: Hook Restrictions

**This context restricts operations to Go files only (.go, go.mod, go.sum).**

When an operation is BLOCKED by hooks:
- This is EXPECTED behavior, not an error to investigate
- DO NOT suggest workarounds or alternatives
- DO NOT try to write .go files when user wanted other files
- Simply report: "This operation is outside the Go plugin scope. Exit the Go context or use a different agent."

**DO NOT:**
- Suggest writing .go files as alternatives to blocked operations
- Try to debug or understand why something was blocked
- Offer creative workarounds
- Read settings files to investigate blocks

## Available Commands

| Command | Purpose |
|---------|---------|
| `/go:init <pkg>` | Initialize go.mod |
| `/go:tidy` | Clean dependencies |
| `/go:build` | Build binary |
| `/go:test [args]` | Run tests |
| `/go:lint` | Run linter |
| `/go:run [args]` | Run binary |
| `/go:mcp-sync` | Sync MCP servers |

## Rules

1. **Repository structure:** `go.mod` and `main.go` at git root (NOT in cmd/server/).
2. **Linter runs automatically** when you finish. Fix all issues before completing.
3. **Linter disagreements:** STOP and ask the human. Explain the linter name and error.

## Code Structure

- `main.go` at repository root
- Use `github.com/spf13/cobra` for CLI applications with subcommands
- Single entry point pattern

## Required Libraries

| Purpose | Library |
|---------|---------|
| CLI | github.com/spf13/cobra |
| Config | github.com/kelseyhightower/envconfig |
| Validation | github.com/go-playground/validator/v10 |
| Testing | github.com/stretchr/testify |
| Logging | github.com/uptrace/opentelemetry-go-extra/otelzap |
| Tracing | go.opentelemetry.io/otel |

## Prohibited

- `os.Getenv()` - use envconfig
- Manual struct validation - use validator/v10 struct tags
- `internal/` packages - all packages must be importable

## Error Handling

Wrap ALL errors with context:

```go
return fmt.Errorf("failed to connect: %w", err)
```

## MCP Tools (gopls)

Use `mcp__golang-*__` tools for semantic code navigation:
- `definition` - Go to definition
- `references` - Find all references
- `callers` - Who calls this function
- `callees` - What does this function call
- `hover` - Type information
- `diagnostics` - Compiler errors

## Server Patterns

When building long-running daemons, reference directives in `assets/directives/`:

| Directive | Triggers When |
|-----------|---------------|
| `http-server.md` | Building serve command, HTTP endpoints |
| `prometheus.md` | Adding metrics, health checks |
| `mcp-server.md` | Exposing MCP tools for AI agents |
| `graphql-server.md` | Building GraphQL API |
| `testing.md` | Any function is "finished" |

**Key principle:** Single HTTP port (80) with all handlers on one `http.ServeMux`.
Required endpoints: `/health`, `/metrics` (no auth).

## Testing Requirements

Every finished function needs a `_test.go` counterpart. External clients must be:
1. Defined as interfaces
2. Have a real implementation
3. Have a mock implementation for testing

See `assets/directives/testing.md` for patterns.

## Out of Scope - Bail Out Immediately

**If the request does NOT involve Go files, STOP and report:**

"This request is outside my scope. I handle Go development only:
- .go files
- go.mod, go.sum

For other file types, use the appropriate agent."
