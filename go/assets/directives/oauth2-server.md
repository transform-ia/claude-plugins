# OAuth2 Server Patterns (transformia/oauth2)

## Overview
fosite + go-graphql-client multi-tenant OAuth2/OIDC server.

## Multi-tenant routing
- Pattern: `/{org-slug}/oauth2/*`
- Org slug extracted from URL via `r.PathValue("org")`
- Per-org signing keys loaded from Hasura

## Hasura GraphQL client (go-graphql-client)
```go
type headerTransport struct {
    base   http.RoundTripper
    secret string
}
func (t *headerTransport) RoundTrip(req *http.Request) (*http.Response, error) {
    req.Header.Set("x-hasura-admin-secret", t.secret)
    req.Header.Set("x-hasura-role", "oauth2-server")
    return t.base.RoundTrip(req)
}
```

## JWT issuance pattern (HS256, Hasura claims)
```go
claims := jwt.MapClaims{
    "sub": userID,
    "exp": time.Now().Add(time.Hour).Unix(),
    "iat": time.Now().Unix(),
    "https://hasura.io/jwt/claims": map[string]interface{}{
        "x-hasura-default-role":  "user",
        "x-hasura-allowed-roles": []string{"user"},
        "x-hasura-user-id":       userID,
        "x-hasura-org-id":        orgSlug,
    },
}
token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
signed, err := token.SignedString([]byte(cfg.AdminJWTSecret))
```

## PKCE enforcement
- Always enforce S256 method
- Plain PKCE method rejected

## Hasura JWT secret
- `{"type":"HS256","key":"${ADMIN_JWT_SECRET:-dev-admin-jwt-secret}"}`
- Both OAuth2 and invoices Hasura share the same secret — one JWT works for both

## POST /{org}/oauth2/hasura-token
- Exchanges OAuth2 Bearer access token for Hasura JWT
- Verifies via `provider.IntrospectToken` (fosite)
- Issues HS256 JWT with x-hasura-user-id, x-hasura-org-id, x-hasura-default-role
- If org role = admin/owner: include "org-admin" in allowed roles

## Reserved Hasura roles
- `admin` is RESERVED by Hasura — NEVER define permissions for it
- Use `admin-ui` for admin dashboard role

## After docker compose down -v
- Metadata is wiped — always run `task hasura:apply` to restore
- Hasura CLI `metadata apply` fails with "key tables not found" — use Python API script
