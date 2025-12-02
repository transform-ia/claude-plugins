# Docker Development

## Permissions

Unless specified, everything else is BLOCKED by hooks, in which cases:

- This is EXPECTED behavior for operations outside the plugin's purpose
- DO NOT suggest workarounds for intentional restrictions
- Report: "This operation is outside the docker plugin scope."

**Exception - Report as Bug:** Only escalate to the user if you encounter:
1. Documented features that don't work as described (e.g., can't edit Dockerfile despite docs saying you can)
2. Hooks blocking operations that instructions explicitly say are allowed
3. Direct contradictions between different documentation files

**Examples of EXPECTED blocks (do NOT escalate):**
- Editing Go source files (out of scope for this plugin)
- Modifying Helm charts (use helm plugin)
- Running docker build commands (security restriction)

### Tools Available

- **Read** - Read any file
- **Glob** - Find files by pattern
- **Grep** - Search file contents
- **Write/Edit** - to restricted files (see below)
- **Bash** - Restricted to:
  - `rm` to restricted files (see below)
- **SlashCommand**:
  - `/docker:cmd-lint [file]` - Run hadolint on Dockerfile
  - `/docker:cmd-image-tag <image> [count]` - Query available image tags
- **MCP Tools**:
  - `mcp__dockerhub__*` - Docker Hub API

### File Restrictions

Only the following file(s) can be written, edited or deleted:

- `Dockerfile`
- `Dockerfile.*`
- `.dockerignore`

## Out of Scope - Exit Immediately

**If the request does NOT involve allowed tools and/or files:**

1. **Immediately respond** with:
   ```
   Docker plugin cannot handle this request - it is outside the allowed scope.

   Allowed: Dockerfile, Dockerfile.*, .dockerignore files and /docker:* commands
   Requested: [describe what was requested]

   Use the appropriate plugin instead:
   - Go code → go:agent-dev
   - Helm charts → helm:agent-dev
   - Markdown → markdown:agent-dev
   ```

2. **Stop execution** - do not attempt workarounds or continue
3. **Do not make any tool calls** for the out-of-scope operation
4. **Wait for user** to rephrase or switch plugins

## Post processing

When you finish (Post), hooks will automatically:

- Run hadolint validation

Configuration is managed via `.hadolint.yaml` in repository root (see Configuration section below).

Fix all issues before completing the task.

### Configuration

`.hadolint.yaml` must be in repository root:
```yaml
---
ignored:
  - DL3018
```

**Why DL3018 is ignored:**
apk version pinning is optional as Alpine packages change frequently. Do NOT use `--ignore` flags in command line - all configuration is in `.hadolint.yaml`.

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
- Use ARG for base image versions - Dependabot cannot track ARG variables. Always use explicit version tags in FROM statements.

### ALWAYS

- Use multi-stage builds for compiled languages
- Run as non-root user (UID 1000)
- Copy dependency files before source code (layer caching)
- Use `.dockerignore` to exclude unnecessary files
- Use dependency files for package management when available (see Dependency Management section)

## Patterns

### Multi-stage Build

```dockerfile
# Build stage
FROM golang:<version> AS builder  # e.g., golang:1.23.4
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go build -ldflags="-s -w" -o /app/binary

# Runtime stage
FROM alpine:<version>  # e.g., alpine:3.21.0
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

## UPX Binary Compression

**Use UPX (Ultimate Packer for eXecutables) to compress Go binaries for smaller images.**

**CRITICAL: Transform-IA provides an upx-image for multi-stage builds.**

**Example with UPX compression:**

```dockerfile
# Build stage
FROM golang:<version>-alpine AS builder  # e.g., golang:1.23.4-alpine
WORKDIR /build
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o app .

# UPX compression stage
# NOTE: upx-image currently only provides 'latest' tag (non-compliant with standards)
FROM ghcr.io/transform-ia/upx-image:latest AS upx
COPY --from=builder /build/app /app
RUN upx --best --lzma /app

# Runtime stage - minimal image
FROM scratch
COPY --from=upx /app /app
ENTRYPOINT ["/app"]
```

**Build flags for optimal compression:**

- `-ldflags="-s -w"`: Strip debug info and symbol table
- `CGO_ENABLED=0`: Disable CGO for static binary
- `GOOS=linux`: Target Linux (for containers)

**UPX options:**

- `--best`: Best compression (slower build)
- `--lzma`: LZMA compression (smaller output)
- `--brute`: Maximum compression (very slow)
- `-1` to `-9`: Compression level (9 = best)

**Size reduction example:**

```
Original Go binary:  15 MB
With -ldflags:       10 MB
With UPX --best:     3.5 MB
With UPX --brute:    3.0 MB
```

**When to use UPX:**

- ✅ Go binaries (static linking)
- ✅ Rust binaries (static linking)
- ✅ Single-binary applications
- ❌ Dynamically linked binaries (may break)
- ❌ When startup time is critical (UPX adds decompression overhead)

## Dependency Management

**Use dependency files when the package manager supports them:**

- **Go**: `go.mod` + `go.sum` - Dependabot tracks
- **npm**: `package.json` + `package-lock.json` - Dependabot tracks
- **Python**: `requirements.txt` or `pyproject.toml` - Dependabot tracks

**Alpine apk: NO dependency file format exists**

Do NOT pin apk package versions - they change frequently and cause build failures:

```dockerfile
# Correct - unpinned (DL3018 ignored for apk)
RUN apk add --no-cache curl ca-certificates

# Incorrect - pinned versions break builds
RUN apk add --no-cache curl=8.5.0-r0
```
