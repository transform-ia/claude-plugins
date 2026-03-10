# GraphQL + Hasura Development

## Standards

### NEVER

- Expose password_hash, private_key_enc, client_secret_hash in select permissions
- Use SELECT * equivalent in queries — always specify fields explicitly
- Use admin secret in frontend code — server-side only
- Create deeply nested queries without depth limits configured
- Perform N+1 queries — use Hasura relationships instead
- Use HTTP GET for mutations

### ALWAYS

- Use snake_case for all field names (Hasura default from PostgreSQL)
- Paginate queries: use `limit` and `offset` or cursor-based pagination
- Specify exact columns in queries (no wildcard)
- Handle the `errors` array in every GraphQL response
- Use variables instead of inline literals in queries
- Apply row-level permissions per role in Hasura metadata
- Use `_by_pk` mutations for single-row operations
- Use `_many` mutations for bulk operations

## Hasura Metadata Structure (v3)

```
hasura/metadata/
  databases/
    databases.yaml        -- database connections
    default/
      tables/
        tables.yaml       -- list of !include directives
        public_*.yaml     -- one file per table
```

## Permission Model

- Roles defined in Hasura metadata, enforced on every request
- Use x-hasura-role header to specify role
- Use x-hasura-admin-secret to bypass all permissions (server-only)
- Row-level filter conditions: `{org_id: {_eq: "X-Hasura-Org-Id"}}`
- Column-level: specify allowed columns in select/insert/update permissions
- Never expose sensitive columns to non-admin roles

## Mutation Naming Conventions

| Operation      | Pattern                                                                          |
| -------------- | -------------------------------------------------------------------------------- |
| Insert single  | `insert_{table}_one(object: $obj)`                                               |
| Insert many    | `insert_{table}(objects: $objs)`                                                 |
| Update by PK   | `update_{table}_by_pk(pk_columns: {id: $id}, _set: $changes)`                   |
| Update many    | `update_{table}(where: $filter, _set: $changes)`                                 |
| Delete by PK   | `delete_{table}_by_pk(pk_columns: {id: $id})`                                   |
| Upsert         | `insert_{table}_one(object: $obj, on_conflict: {constraint: ..., update_columns: [...]})` |

## Query Patterns

```graphql
# Always paginate
query ListOrgs($limit: Int = 20, $offset: Int = 0) {
  organizations(limit: $limit, offset: $offset, order_by: {created_at: desc}) {
    id slug name created_at
  }
  organizations_aggregate { aggregate { count } }
}

# Always use variables
query GetClient($clientId: String!) {
  applications(where: {client_id: {_eq: $clientId}}) {
    id org_id client_id name redirect_uris allowed_scopes grant_types
  }
}
```

## Relationship Usage (Avoid N+1)

```graphql
# GOOD: use Hasura relationships
query GetOrgWithApps($slug: String!) {
  organizations(where: {slug: {_eq: $slug}}) {
    id slug name
    applications { id client_id name }  # relationship, single query
  }
}

# BAD: N+1
# First query orgs, then loop and query apps for each org
```

## Error Handling

Always check errors in the response:

```json
{
  "data": {...},
  "errors": [{"message": "...", "extensions": {...}}]
}
```

## GraphQL Codegen (TypeScript)

- Use @graphql-codegen/cli with typed-document-node preset
- Generate types from schema + operation documents
- Config file: codegen.yml at project root
- Run: `graphql-codegen --config codegen.yml`

## Subscriptions

- Use WebSocket transport for subscriptions
- Hasura supports real-time subscriptions on any tracked table
- Use `subscription` keyword instead of `query`

## Admin Secret Usage

```
# Server-side (Go): header in every request
x-hasura-admin-secret: <secret>

# Never in browser/frontend — use role-based permissions instead
```

## Troubleshooting

### "BLOCKED: Bash not allowed in GraphQL plugin context"

Use `/graphql:*` slash commands instead of direct shell commands.

### Query returns null but no error

Check Hasura permissions — the role may not have select access to the requested
columns or rows. Verify metadata in `hasura/metadata/databases/default/tables/`.

### N+1 detected in query patterns

Replace individual queries with Hasura object/array relationships. Define
relationships in table metadata files.

## Hasura JWT + Multi-tenancy Patterns

- `admin` is a RESERVED Hasura role — NEVER define permissions for it; use `admin-ui` for admin dashboard
- `HASURA_GRAPHQL_JWT_SECRET`: `{"type":"HS256","key":"${ADMIN_JWT_SECRET:-dev-jwt-secret}"}`
- After `docker compose down -v`, metadata is wiped — run `task hasura:apply` to restore (Python script, not Hasura CLI)
- Hasura CLI `hasura metadata apply` fails with "key tables not found" — use `replace_metadata` API endpoint instead
- Row-level vars in permission filters: `X-Hasura-User-Id`, `X-Hasura-Org-Id` (no quotes needed in YAML)
- JWT claims namespace: `https://hasura.io/jwt/claims`
- Multiple Hasura instances can share the same JWT secret → same token works for all of them
- Remote schema pattern: link two Hasura instances via `remote_schemas.yaml`
- Remote relationships `lhs_fields: [org_id]` → `remote_field.organizations.where.slug._eq: $org_id`
- Remote schema auth: forward admin secret via `value_from_env` (not inline value)
- Permissions `set:` block for insert presets: `user_id: X-Hasura-User-Id` (no quotes around session var)
- `allow_aggregations: true` needed for `_aggregate` queries in permissions
- Multi-tenancy: `org_id` column (TEXT, org slug) on every table, filtered in every permission
