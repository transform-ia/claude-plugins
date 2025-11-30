# HTTP Server Directive

**Triggers when:** Application needs HTTP endpoints (serve command, API,
webhooks)

## Single Port, Multiple Handlers

ALL handlers MUST bind to a single HTTP port (default: 80). Use Go's
`http.NewServeMux()`:

```go
mux := http.NewServeMux()

mux.Handle("/health", healthHandler)      // No auth
mux.Handle("/metrics", metricsHandler)    // No auth
mux.Handle("/graphql", authMiddleware(graphqlHandler))
mux.Handle("/mcp", authMiddleware(mcpHandler))

server := &http.Server{
    Addr:    fmt.Sprintf(":%d", cfg.HTTPPort),
    Handler: mux,
}
```

## Required Endpoints for Daemons

- `/health` - Health check (no auth, returns 200 OK, JSON)
- `/metrics` - Prometheus metrics (no auth)

## Middleware Composition

```go
func RequireAuth(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        // auth logic...
        next.ServeHTTP(w, r)
    })
}

// Chain: mux.Handle("/api", RequireAuth(RequireOAuth(apiHandler)))
```

## Graceful Shutdown

```go
ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
defer stop()

go func() {
    if err := server.ListenAndServe(); err != http.ErrServerClosed {
        logger.Error(ctx, "server error", map[string]any{"error": err})
    }
}()

<-ctx.Done()
shutdownCtx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
defer cancel()
server.Shutdown(shutdownCtx)
```
