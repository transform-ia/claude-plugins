# HTTP Server Directive

**Triggers when:** Application needs HTTP endpoints

## Use gokit.ServeCommand

ALL HTTP serving MUST use `gokit.ServeCommand()`. This automatically provides:

- `/health` endpoint (200 OK, JSON)
- `/metrics` endpoint (Prometheus)
- Graceful shutdown (30s timeout)
- Single port, single mux

    gokit.ServeCommand[ServeConfig]("serve", "Start server", func(ctx *gokit.Context[ServeConfig]) []gokit.Route {
        return []gokit.Route{
            {Pattern: "/api", Handler: apiHandler(ctx)},
            {Pattern: "/graphql", Handler: graphqlHandler(ctx)},
        }
    })

## Middleware Composition

    func RequireAuth(next http.Handler) http.Handler {
        return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
            // auth logic...
            next.ServeHTTP(w, r)
        })
    }

    // Usage in routes:
    {Pattern: "/api", Handler: RequireAuth(apiHandler(ctx))}
