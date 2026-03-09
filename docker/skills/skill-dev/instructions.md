# Docker Development

## Configuration

`.hadolint.yaml` must be in repository root:

```yaml
---
ignored:
  - DL3018
```

**Why DL3018 is ignored:** apk version pinning is optional as Alpine packages
change frequently. Do NOT use `--ignore` flags in command line - all
configuration is in `.hadolint.yaml`.

## Hadolint Common Fixes

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
- Use ARG for base image versions - Dependabot cannot track ARG variables.
  Always use explicit version tags in FROM statements.
- Use YAML flow/inline sequences (`[a, b, c]`) - always use block style
  (one item per line)

### ALWAYS

- Use multi-stage builds for compiled languages
- Run as non-root user (UID 1000)
- Copy dependency files before source code (layer caching)
- Use `.dockerignore` to exclude unnecessary files
- Use dependency files for package management when available (see Dependency
  Management section)
- Use YAML block-style sequences for lists (one item per line, prefixed with
  `-`)

## Getting Latest Image Versions

- **Docker Hub images**: `/docker:cmd-image-tag <image>`
- **GHCR images**: `/docker:cmd-image-tag ghcr.io/<org>/<repo>`
- **GHCR from git tags**: `/github:cmd-latest-version <path>`

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

Transform-IA provides an upx-image for multi-stage builds to compress static
binaries (Go, Rust).

```dockerfile
# Build stage
FROM golang:<version>-alpine AS builder
WORKDIR /build
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o app .

# UPX compression stage
FROM ghcr.io/transform-ia/upx-image:<<QUERY_LATEST_TAG>> AS upx
COPY --from=builder /build/app /app
RUN upx --best --lzma /app

# Runtime stage
FROM scratch
COPY --from=upx /app /app
ENTRYPOINT ["/app"]
```

**Build flags**: `-ldflags="-s -w"` (strip debug), `CGO_ENABLED=0` (static
binary), `GOOS=linux` (container target).

**UPX options**: `--best` (best compression), `--lzma` (smaller output),
`--brute` (maximum, very slow).

Do NOT use UPX on dynamically linked binaries or when startup time is critical.

## Dependency Management

**Use dependency files when the package manager supports them:**

- **Go**: `go.mod` + `go.sum` - Dependabot tracks
- **npm**: `package.json` + `package-lock.json` - Dependabot tracks
- **Python**: `requirements.txt` or `pyproject.toml` - Dependabot tracks

### Alpine apk Packages

**NO dependency file format exists for Alpine apk packages.**

Do NOT pin apk package versions - they change frequently and cause build
failures:

```dockerfile
# Correct - unpinned (DL3018 ignored for apk)
RUN apk add --no-cache curl ca-certificates

# Incorrect - pinned versions break builds
RUN apk add --no-cache curl=8.5.0-r0
```

## Node.js Package Installation

Use yarn with package.json for npm packages in Docker images:

```dockerfile
COPY package.json /usr/local/
WORKDIR /usr/local
RUN yarn install && \
    yarn cache clean && \
    rm package.json
ENV PATH=${PATH}:/usr/local/node_modules/.bin/
WORKDIR /workspace
```

- Copy only `package.json` for layer caching, not full source
- Always `yarn cache clean` after install to reduce image size
- Use a dedicated directory (`/usr/local/`) to avoid conflicts

## YAML List Format

**Always use block-style sequences (one item per line), never inline/flow
style.** This applies to all YAML files: `docker-compose.yaml`, CI workflows,
`.yamllint.yaml`, Helm values, etc.

```yaml
# CORRECT - block style
ports:
  - "8080:8080"
  - "9090:9090"

volumes:
  - ./data:/data
  - ./config:/config

# WRONG - inline/flow style (NEVER use this)
ports: ["8080:8080", "9090:9090"]
volumes: [./data:/data, ./config:/config]
```

## Docker Compose

- Always use `.yaml` extension (not `.yml`)
- Always use `depends_on` with `condition: service_healthy` for service
  dependencies
- Always define healthchecks for all services using `test`, `interval`,
  `timeout`, `retries`, `start_period`
- Use named volumes for persistent data storage
- Use `env_file` for environment variables when multiple services share config
- Never hardcode secrets - use environment variables from .env files
- Use `healthcheck` for PostgreSQL: `pg_isready -U <user> -d <db>`
- Use `healthcheck` for Hasura: `curl -sf http://localhost:8080/healthz`
- Apply Hasura metadata automatically using init containers or CLI migrations
  image
