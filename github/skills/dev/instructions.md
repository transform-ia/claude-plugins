# GitHub CI/CD Development

## Permissions

Unless specified, everything else is BLOCKED by hooks, in which cases:

- This is EXPECTED behavior
- DO NOT suggest workarounds
- Report: "This operation is outside the github plugin scope." Unless you think
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
  - `gh` read-only: `list`, `view`, `watch`, `status`, `diff`
  - `gh api` GET requests only
- **SlashCommand**:
  | Command | Purpose |
  |---------|---------|
  | `/github:lint [dir]` | Run yamllint + prettier |
  | `/github:status [repo]` | Check workflow status |
  | `/github:logs <run-id>` | Get workflow logs |
  | `/github:release <version>` | Full release workflow with build monitoring |
  | `/orchestrator:detect [dir]` | Detect project type for CI config |
- **MCP Tools**:
  - `mcp__github__*` - GitHub API

### File Restrictions

Only the following file(s) can be written, edited or deleted:

- `.github/workflows/ci.yaml`
- `.github/workflows/build.yaml`
- `.github/dependabot.yaml`
- `.github/PULL_REQUEST_TEMPLATE/*.md`
- `.github/workflows/*.yml` (delete only - wrong extension)
- `.github/workflows/*.yaml` (delete only - non-canonical names)

**Convention:** Use `.yaml` not `.yml`. Delete any non-canonical workflow files.

## Out of Scope - Bail Out Immediately

**If the request does NOT involve allowed tools and/or files, STOP and report:**

`GitHub plugin can't handle request outside its scope.`

## Post processing

When you finish (Post), hooks will automatically:

- Run yamllint + prettier validation

Fix all issues before completing the task.

## Standards

### NEVER

- Use path filters - CI should run on ALL changes
- Use `@main` or `@master` for actions - pin to specific versions
- Put secrets in code - use repository secrets
- Deviate from template versions - use EXACT versions shown below

### ALWAYS

- Use `.yaml` extension (not `.yml`)
- Add `---` document start marker
- Request minimal permissions
- Run `/orchestrator:detect` first to know what CI needs
- Use claude-image or golang-image containers with raw commands
- **Copy workflow templates EXACTLY** - do not change action versions

### Required Action Versions

**CRITICAL: Use these EXACT versions. Do NOT use older versions.**

| Action | Version |
|--------|---------|
| `actions/checkout` | `@v4` |
| `docker/setup-qemu-action` | `@v3` |
| `docker/setup-buildx-action` | `@v3` |
| `docker/login-action` | `@v3` |
| `docker/build-push-action` | `@v6` |
| `azure/setup-helm` | `@v4` |

## Canonical Workflow Files

**Single source of truth - only these files should exist:**

| File | Purpose |
|------|---------|
| `ci.yaml` | Linting and testing (push/PR) |
| `build.yaml` | Build and publish (tags) |

### CRITICAL: Workflow Cleanup Procedure

**BEFORE creating or updating workflows, you MUST:**

1. **Find ALL existing workflows** (both `.yaml` and `.yml`):
   ```bash
   # Use Glob to find all workflow files
   Glob: .github/workflows/*.y*ml
   ```

2. **Delete EVERY file that is NOT `ci.yaml` or `build.yaml`:**
   - Delete `*.yml` files (wrong extension)
   - Delete any other `*.yaml` files (non-canonical names)
   - Use `rm` command for each file to delete

3. **Only then** create/update the canonical files

**Example cleanup:**
```bash
# If you find: build-and-push.yml, lint.yml, build-docker-image.yaml
rm .github/workflows/build-and-push.yml
rm .github/workflows/lint.yml
rm .github/workflows/build-docker-image.yaml
# Then create ci.yaml and build.yaml
```

**DO NOT skip cleanup** - orphan workflows cause confusion and duplicate runs.

## Release Workflow

After updating workflows, use `/github:release` to handle the full release cycle:

### When to Use /github:release

Use after:
- Creating or updating workflow files
- Any changes that require a new version/tag

### Release Procedure

1. **Commit all changes** (workflow files, etc.)
2. **Run `/github:release <version>`** which will:
   - Create and push the git tag
   - Push commits to remote
   - Wait for GitHub Actions build to complete
   - Report build success or failure
3. **If build fails**: Check logs with `/github:logs <run-id>` and fix issues

### Version Formats

```text
/github:release 1.2.3     # Explicit version
/github:release patch     # Auto-bump patch (0.0.1 -> 0.0.2)
/github:release minor     # Auto-bump minor (0.1.0 -> 0.2.0)
/github:release major     # Auto-bump major (1.0.0 -> 2.0.0)
```

**IMPORTANT**: Always wait for the build result before reporting completion.

## Workflows by Project Type

### Go Projects

**Lint workflow:**

```yaml
---
name: CI

"on":
  push:
    branches: [main, master]
  pull_request:

permissions:
  contents: read

jobs:
  lint:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/transform-ia/golang-image:${LATEST_TAG}
      options: --user 0
    steps:
      - uses: actions/checkout@v4

      - name: Lint Go
        run: golangci-lint run --fix ./...

      - name: Test
        run: go test -v -race ./...
```

### Docker Projects

**Lint workflow:**

```yaml
---
name: CI

"on":
  push:
    branches: [main, master]
  pull_request:

permissions:
  contents: read

jobs:
  lint:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/transform-ia/claude-image:${LATEST_TAG}
      options: --user 0
    steps:
      - uses: actions/checkout@v4

      - name: Lint Dockerfile
        run: hadolint --ignore DL3018 Dockerfile
```

**Build and push on tag:**

```yaml
---
name: Build and Push

"on":
  push:
    tags: ["v*"]

permissions:
  contents: read
  packages: write

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: docker/setup-qemu-action@v3

      - uses: docker/setup-buildx-action@v3

      - name: Extract version
        id: version
        run: echo "VERSION=${GITHUB_REF#refs/tags/v}" >> $GITHUB_OUTPUT

      - uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - uses: docker/build-push-action@v6
        with:
          context: .
          platforms: linux/amd64
          push: true
          tags: |
            ghcr.io/${{ github.repository }}:${{ steps.version.outputs.VERSION }}
            ghcr.io/${{ github.repository }}:latest
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

### Helm Projects

**Lint workflow:**

```yaml
---
name: CI

"on":
  push:
    branches: [main, master]
    tags: ["v*"]
  pull_request:

permissions:
  contents: read
  packages: write

jobs:
  lint:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/transform-ia/claude-image:${LATEST_TAG}
      options: --user 0
    steps:
      - uses: actions/checkout@v4

      - name: Lint
        run: |
          helm lint .
          yamllint -c .yamllint .
```

**Package and push on tag:**

```yaml
---
name: Package and Push

"on":
  push:
    tags: ["v*"]

permissions:
  contents: read
  packages: write

jobs:
  package:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: azure/setup-helm@v4
        with:
          version: "3.16.4"

      - name: Extract version
        id: version
        run: echo "VERSION=${GITHUB_REF#refs/tags/v}" >> $GITHUB_OUTPUT

      - name: Extract chart name
        id: chart
        run: echo "NAME=$(grep '^name:' Chart.yaml | awk '{print $2}')" >> $GITHUB_OUTPUT

      - name: Update Chart version
        run: sed -i "s/^version:.*/version: ${{ steps.version.outputs.VERSION }}/" Chart.yaml

      - name: Package chart
        run: helm package .

      - name: Login to GHCR
        run: echo "${{ secrets.GITHUB_TOKEN }}" | helm registry login ghcr.io -u ${{ github.actor }} --password-stdin

      - name: Push to GHCR
        run: helm push ${{ steps.chart.outputs.NAME }}-${{ steps.version.outputs.VERSION }}.tgz oci://ghcr.io/${{ github.repository_owner }}
```

## Dependabot Configuration

### Dependabot for Go Projects

```yaml
---
version: 2
updates:
  - package-ecosystem: "gomod"
    directory: "/"
    schedule:
      interval: "daily"
    groups:
      go-dependencies:
        patterns:
          - "*"

  - package-ecosystem: "docker"
    directory: "/"
    schedule:
      interval: "daily"

  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "daily"
```

### Dependabot for Docker Projects

```yaml
---
version: 2
updates:
  - package-ecosystem: "docker"
    directory: "/"
    schedule:
      interval: "daily"

  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "daily"
```

### Dependabot for Helm Projects

```yaml
---
version: 2
updates:
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "daily"
```

### Node.js Projects

```yaml
---
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "daily"
    groups:
      dependencies:
        patterns:
          - "*"

  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "daily"
```

## Common yamllint Fixes

| Issue                    | Fix                                      |
| ------------------------ | ---------------------------------------- |
| `line too long`          | Break lines or use YAML multiline syntax |
| `wrong indentation`      | Use 2-space indentation                  |
| `missing document start` | Add `---` at file start                  |
| `trailing spaces`        | Remove trailing whitespace               |
| `truthy value`           | Use `true`/`false` not `yes`/`no`        |
