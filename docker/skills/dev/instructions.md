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

## CRITICAL: Forbidden Patterns

### ❌ NO UPX Binary Compression

**NEVER use UPX compression.** It causes issues with:
- Startup time (decompression overhead)
- Memory usage (decompressed in RAM)
- Debugging (can't attach debuggers)
- Binary signing (invalidates signatures)

```dockerfile
# ❌ WRONG - Never use UPX
FROM ghcr.io/transform-ia/upx-image:latest AS upx
RUN upx --best /app

# ✅ CORRECT - Use ldflags for size reduction only
RUN go build -ldflags="-s -w" -o app .
```

### ❌ NO ARG for Base Image Tags

**NEVER use ARG to parameterize base image versions.** Dependabot cannot parse ARG-based versions.

```dockerfile
# ❌ WRONG - Dependabot cannot track this
ARG NODE_VERSION=24.11.1
FROM node:${NODE_VERSION}-alpine

# ✅ CORRECT - Hardcoded tag, Dependabot can track
FROM node:24.11.1-alpine3.22
```

### ❌ NO Inline Package Installation with Versions

**NEVER install packages with inline versions.** Use dependency files instead.

```dockerfile
# ❌ WRONG - npm inline versions
RUN npm install -g markdownlint-cli@0.46.0 prettier@3.6.2

# ✅ CORRECT - Use package.json
COPY package.json ./
RUN npm install -g
```

```dockerfile
# ❌ WRONG - go install with version
RUN go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.55.0

# ✅ CORRECT - Use go.mod
COPY go.mod go.sum ./
RUN go mod download && go build -o /bin/tool ./cmd/tool
```

**Why use dependency files?**
- Dependabot can track and propose updates
- Cleaner Dockerfiles
- Reproducible builds with lock files

## Hadolint Configuration Policy

**You are NOT allowed to modify `.hadolint.yaml` without human approval.**

If lint rules seem too strict:
1. DO NOT disable rules in `.hadolint.yaml`
2. DO NOT add `# hadolint ignore=DLxxxx` inline comments
3. Report to user: "Rule DLxxxx is flagging [issue]. Reason: [justification]. Should I disable it?"
4. Wait for human approval before any config changes

**Exception - DL3018 is ALWAYS pre-approved:**
- Alpine package versions change frequently
- Use `apk add --no-cache pkg` WITHOUT version pinning

## Hadolint Common Fixes

| Rule | Issue | Fix |
|------|-------|-----|
| DL3006 | Missing tag on FROM | Add specific version tag |
| DL3007 | Using `latest` tag | Use specific version |
| DL3008 | Unpinned apt packages | Pin versions with `=version` |
| DL3013 | Unpinned pip packages | Use `pip install pkg==version` |
| DL3018 | Unpinned apk packages | **IGNORE** - use `apk add pkg` |
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
RUN go build -ldflags="-s -w" -o /app/binary

# Runtime stage
FROM alpine:3.20
COPY --from=builder /app/binary /usr/local/bin/
ENTRYPOINT ["binary"]
```

### Dependency Files for Versioning

**npm packages:** Create `package.json`:
```json
{
  "name": "tools",
  "dependencies": {
    "markdownlint-cli": "0.46.0",
    "prettier": "3.6.2"
  }
}
```

**Go tools:** Create `go.mod`:
```go
module build

go 1.23

require github.com/golangci/golangci-lint v1.55.0
```

### Dependency Caching
Copy dependency files first, then source code:
```dockerfile
COPY go.mod go.sum ./
RUN go mod download
COPY . .
```

### Layer Optimization

- **Combine RUN commands** with `&&` to reduce layers
- **Order from least to most frequently changing** (dependencies before code)
- **Use .dockerignore** to exclude unnecessary files

**.dockerignore example:**
```
.git/
.github/
*.md
LICENSE
.gitignore
.dockerignore
```

### Security Best Practices

**Non-root user:**
```dockerfile
RUN addgroup -g 1000 code && \
    adduser -D -u 1000 -G code code
USER code
```

**Key principles:**
- Run as non-root user (UID 1000)
- Use read-only root filesystem when possible
- Use `--no-cache` with package managers
- Minimize installed packages
- Use official/verified base images
- Don't include secrets in layers

## Out of Scope - Bail Out Immediately

**If the request does NOT involve Dockerfiles or .dockerignore, STOP and report:**

"This request is outside my scope. I handle Docker development only:
- Dockerfile
- .dockerignore

For other file types, use the appropriate agent."
