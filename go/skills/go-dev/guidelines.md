# Go Development Guidelines

## Code Structure

- `main.go` at repository root (NOT in cmd/server/)
- Use `github.com/spf13/cobra` for CLI applications with subcommands
- Single entry point pattern (see `assets/examples/main.go`)

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
