# Testing Directive

**Triggers when:** Any function is considered "finished"

## Required Tests

Every finished function MUST have a corresponding `_test.go` file.

```go
// user_service.go
func (s *UserService) GetUser(ctx context.Context, id string) (*User, error)

// user_service_test.go - REQUIRED
func TestUserService_GetUser(t *testing.T)
func TestUserService_GetUser_NotFound(t *testing.T)
func TestUserService_GetUser_InvalidID(t *testing.T)
```

## Test Library

Use `github.com/stretchr/testify`:

```go
import (
    "testing"
    "github.com/stretchr/testify/require"
    "github.com/stretchr/testify/assert"
)

func TestGetUser(t *testing.T) {
    // Arrange
    repo := NewMockUserRepository()
    svc := NewUserService(repo)

    // Act
    user, err := svc.GetUser(context.Background(), "123")

    // Assert
    require.NoError(t, err)
    assert.Equal(t, "123", user.ID)
}
```

## Interface-Based Mocking

External clients (APIs, databases) MUST be interfaces with mock implementations:

```go
// client.go - Interface definition
type QuickBooksClient interface {
    GetInvoice(ctx context.Context, id string) (*Invoice, error)
}

// client_http.go - Real implementation
type HTTPQuickBooksClient struct { ... }
func (c *HTTPQuickBooksClient) GetInvoice(ctx context.Context, id string) (*Invoice, error)

// client_mock.go - Mock for testing
type MockQuickBooksClient struct {
    GetInvoiceFunc func(ctx context.Context, id string) (*Invoice, error)
}

func (m *MockQuickBooksClient) GetInvoice(ctx context.Context, id string) (*Invoice, error) {
    if m.GetInvoiceFunc != nil {
        return m.GetInvoiceFunc(ctx, id)
    }
    return nil, errors.New("GetInvoiceFunc not set")
}
```

## OTel-Instrumented Code (testkit)

For gokit apps, use `github.com/transform-ia/gokit/testkit` to assert on spans,
metrics, and logs without a running OTel collector.

```go
func TestMyService(t *testing.T) {
    tk := testkit.Setup(t)                                     // in-memory OTel providers
    ctx := testkit.NewContext[Config](t, tk, &Config{...})     // gokit context

    err := myCommandFn(ctx)
    require.NoError(t, err)

    // Spans
    ended := tk.Spans.Ended()
    require.Len(t, ended, 3)
    assert.Equal(t, "MyService.DoWork", ended[0].Name())
    assert.Equal(t, codes.Ok, ended[0].Status().Code)

    // Error span
    assert.Equal(t, codes.Error, ended[1].Status().Code)
    require.Len(t, ended[1].Events(), 1)
    assert.Equal(t, "exception", ended[1].Events()[0].Name)

    // Metrics
    var rm metricdata.ResourceMetrics
    require.NoError(t, tk.Metrics.Collect(context.Background(), &rm))
    sum := rm.ScopeMetrics[0].Metrics[0].Data.(metricdata.Sum[int64])
    assert.Equal(t, int64(1), sum.DataPoints[0].Value)

    // Logs (all levels including Info/Debug — testkit sets minLevel=Debug)
    assert.NotEmpty(t, tk.Logs.Records())
}
```

**Key behaviours:**
- `testkit.Setup(t)` replaces global OTel providers; no cross-test leakage
- `testkit.NewContext[T]` uses `otelzap.WithMinLevel(DebugLevel)` — Info/Debug
  logs flow to `tk.Logs`; without this they are silently dropped
- `tk.Metrics` is a `ManualReader` — call `Collect` to pull; metric state
  accumulates across the test, not reset between calls
- Attribute lookup in metric data requires `attribute.Key("name")`, not a string

## Test Coverage

Target: >80% coverage on business logic packages.

## Table-Driven Tests

For functions with multiple scenarios:

```go
func TestParseConfig(t *testing.T) {
    tests := []struct {
        name    string
        input   string
        want    *Config
        wantErr bool
    }{
        {"valid", "port=80", &Config{Port: 80}, false},
        {"invalid", "invalid", nil, true},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got, err := ParseConfig(tt.input)
            if tt.wantErr {
                require.Error(t, err)
                return
            }
            require.NoError(t, err)
            assert.Equal(t, tt.want, got)
        })
    }
}
```
