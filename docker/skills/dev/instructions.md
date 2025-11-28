# Dockerfile Development Guidelines

## Critical: Hook Restrictions

**This context restricts operations to Dockerfile and .dockerignore only.**

When an operation is BLOCKED by hooks:
- This is EXPECTED behavior
- DO NOT suggest workarounds
- Report: "This operation is outside the docker plugin scope."

## Available Commands

| Command | Purpose |
|---------|---------|
| `/docker:lint [file]` | Run hadolint on Dockerfile |
| `/docker:image-tag <image>` | Query available image tags |

## Rules

1. **Linter runs automatically** when you finish. Fix all issues before completing.
2. **File restrictions:** Only Dockerfile and .dockerignore can be modified.
3. **Pin versions:** Always use specific image tags, never `latest`.

## Hadolint Common Fixes

| Rule | Issue | Fix |
|------|-------|-----|
| DL3006 | Missing tag on FROM | Add specific version tag |
| DL3007 | Using `latest` tag | Use specific version |
| DL3008 | Unpinned apt packages | Pin versions with `=version` |
| DL3013 | Unpinned pip packages | Use `pip install pkg==version` |
| DL3018 | Unpinned apk packages | Use `apk add pkg=version` |
| DL3025 | Use JSON for CMD/ENTRYPOINT | Use `["cmd", "arg"]` format |
| DL4006 | SHELL not defined | Add `SHELL ["/bin/bash", "-o", "pipefail", "-c"]` |

## Image Tag Discovery

Use `/docker:image-tag` to find available versions:

```
/docker:image-tag python           # Docker Hub official
/docker:image-tag alpine/kubectl   # Docker Hub org
/docker:image-tag ghcr.io/org/pkg  # GHCR
```

Or use MCP tools directly:
```typescript
mcp__dockerhub__listRepositoryTags({
  namespace: "library",
  repository: "python",
  page_size: 10
})
```

## Best Practices

### Multi-stage Builds
```dockerfile
# Build stage
FROM golang:1.23-alpine AS builder
WORKDIR /app
COPY . .
RUN go build -o /app/binary

# Runtime stage
FROM alpine:3.20
COPY --from=builder /app/binary /usr/local/bin/
ENTRYPOINT ["binary"]
```

### Dependency Caching
Copy dependency files first, then source code:
```dockerfile
COPY go.mod go.sum ./
RUN go mod download
COPY . .
```

### Security
- Run as non-root user
- Use read-only root filesystem when possible
- Minimize installed packages
- Use official/verified base images
