# Docker Development

## Permissions

Unless specified, everything else is BLOCKED by hooks, in which cases:

- This is EXPECTED behavior
- DO NOT suggest workarounds
- Report: "This operation is outside the docker plugin scope." Unless you think
  this is an implementation issue, in which case start a conversation with the
  human on how to fix the issue.

### Tools Available

- **Read** - Read any file
- **Glob** - Find files by pattern
- **Grep** - Search file contents
- **Search** - Search file by name
- **Write/Edit** - to restricted files (see below)
- **Bash** - Restricted to:
  - `rm` to restricted files (see below)
- **SlashCommand**: | Command | Purpose | |---------|---------| |
  `/docker:lint [file]` | Run hadolint on Dockerfile | |
  `/docker:image-tag <image>` | Query available image tags |
- **MCP Tools**:
  - `mcp__dockerhub__*` - Docker Hub API

### File Restrictions

Only the following file(s) can be written, edited or deleted:

- `Dockerfile`
- `Dockerfile.*`
- `.dockerignore`

## Out of Scope - Bail Out Immediately

**If the request does NOT involve allowed tools and/or files, STOP and report:**

`Docker plugin can't handle request outside its scope.`

## Post processing

When you finish (Post), hooks will automatically:

- Run hadolint validation

Fix all issues before completing the task.

### Hadolint Common Fixes

| Rule   | Issue                 | Fix                            |
| ------ | --------------------- | ------------------------------ |
| DL3006 | Missing tag on FROM   | Add specific version tag       |
| DL3007 | Using `latest` tag    | Use specific version           |
| DL3008 | Unpinned apt packages | Pin with `=version`            |
| DL3013 | Unpinned pip packages | Use `pkg==version`             |
| DL3025 | CMD/ENTRYPOINT format | Use JSON `["cmd", "arg"]`      |
| DL4006 | SHELL not defined     | Add pipefail SHELL instruction |

## Standards

### NEVER

- Use `latest` tag - always pin to specific versions
- Use ARG for base image versions - Dependabot cannot track them
- Install packages with inline versions - use dependency files

### ALWAYS

- Use multi-stage builds for compiled languages
- Run as non-root user (UID 1000)
- Copy dependency files before source code (layer caching)
- Use `.dockerignore` to exclude unnecessary files

## Patterns

### Multi-stage Build

```dockerfile
# Build stage
FROM golang:${LATEST_TAG} AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go build -ldflags="-s -w" -o /app/binary

# Runtime stage
FROM alpine:${LATEST_TAG}
RUN addgroup -g 1000 app && adduser -D -u 1000 -G app app
USER app
COPY --from=builder /app/binary /usr/local/bin/
ENTRYPOINT ["binary"]
```

### .dockerignore

```text
.git/
.github/
*.md
LICENSE
.gitignore
.dockerignore
```

### Dependency Files (NOT inline versions)

Use package manager files instead of inline versions:

- **Go**: `go.mod` + `go.sum`
- **npm**: `package.json` + `package-lock.json`
- **Python**: `requirements.txt` or `pyproject.toml`
