# GraphQL Server Directive

**Triggers when:** Application exposes GraphQL API

## Library

`github.com/99designs/gqlgen`

## Setup

1. Define schema in `schema.graphql`
2. Generate: `go run github.com/99designs/gqlgen generate`
3. Implement resolvers

```go
import "github.com/99designs/gqlgen/graphql/handler"

func NewGraphQLHandler(resolvers *Resolver) http.Handler {
    return handler.NewDefaultServer(
        generated.NewExecutableSchema(generated.Config{Resolvers: resolvers}),
    )
}
```

## Integration

```go
mux.Handle("/graphql", graphqlHandler)
```
