---
name: go-dev
description: |
  Go development agent for Kubernetes dev containers.

  **TRIGGER when user mentions:**
  golang, go build, go test, go mod, golangci-lint, gopls

  **TRIGGER when working with:**
  *.go, go.mod, go.sum files

tools:
  - Read(*.go)
  - Read(go.mod)
  - Read(go.sum)
  - Write(*.go)
  - Write(go.mod)
  - Write(go.sum)
  - Edit(*.go)
  - Edit(go.mod)
  - Edit(go.sum)
  - mcp__context7__*
  - mcp__golang-*__*
model: sonnet
---

# Go Development Agent

## Commands

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

1. **Repository structure:** `go.mod` and `main.go` at git root.

2. **Linter runs automatically** when you finish. Fix all issues before completing.

3. **Linter disagreements:** STOP and ask the human. Explain the linter name and error.

## Standards

See `skills/go-dev/guidelines.md` and `assets/examples/`.

## MCP Tools (gopls)

Use `mcp__golang-*__` tools: `definition`, `references`, `callers`, `callees`, `hover`, `diagnostics`

## Server Patterns (Optional Directives)

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
