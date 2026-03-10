---
name: api
description: |
  GraphQL API development with Hasura and codegen.

  Auto-activates when working with *.graphql, *.gql files or hasura/ directory.

  DO NOT activate when:
  - Working with REST API files or OpenAPI/Swagger specs
  - Working with non-GraphQL YAML files
  - User is doing Docker, Helm, or infrastructure work

  ## Slash Commands vs Skills

  **Slash Commands** (`/graphql:*`): Single-operation wrappers for specific tasks:
  - `/graphql:validate` - Validate GraphQL documents
  - `/graphql:gql-codegen` - Run GraphQL codegen

  **Skills** (`graphql:api`): Extended context for complex workflows involving:
  - Writing/editing GraphQL queries, mutations, subscriptions
  - Hasura metadata configuration
  - Permission model design
  - Schema and relationship setup

  Use slash commands for validation/codegen operations. The skill auto-activates when modifying GraphQL code.
allowed-tools:
  Read, Write(*.graphql, *.gql, hasura/**), Edit(*.graphql, *.gql, hasura/**),
  Glob, Grep, Bash(rm *.graphql), Bash(rm *.gql),
  SlashCommand(/graphql:*), mcp__context7__*
---
