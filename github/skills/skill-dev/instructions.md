# GitHub CI/CD Development

## Permissions

All operations not explicitly listed in "Tools Available" and "File Restrictions"
below are BLOCKED by hooks. When blocked:

- This is EXPECTED behavior for operations outside the plugin's purpose
- DO NOT suggest workarounds for intentional restrictions
- Report: "This operation is outside the github plugin scope."

### Prohibited Tools

- **Bash(find)** - NEVER use `find` command. Use **Glob** and **Grep** instead for file discovery and content search.

### When Tools Are Unavailable

If you need access to a tool that is not in your allowed list:

1. **Do NOT hallucinate** or pretend the tool is available
2. **Use AskUserQuestion** to clearly specify what tool you need and why
3. Wait for user guidance before proceeding

### Tools Available

- **Read** - Read any file
- **Glob** - Find files by pattern
- **Grep** - Search file contents
- **Write/Edit** - to restricted files (see below)
- **Bash** - Restricted to:
  - `rm` to restricted files (see below)
  - `gh` commands: ONLY read-only operations (`list`, `view`, `watch`, `status`, `diff`) - hooks block write operations (`create`, `delete`, `edit`, `merge`, etc.)
  - `gh api`: ONLY GET requests - hooks block POST/PUT/PATCH/DELETE methods
  - **Exception**: Deleting container registry images (see "Deleting Container Images" section below)
- **SlashCommand**:
  | Command | Purpose |
  |---------|---------|
  | `/github:cmd-lint [dir]` | Run yamllint + prettier |
  | `/github:cmd-status [repo]` | Check workflow status |
  | `/github:cmd-logs <run-id>` | Get workflow logs |
  | `/github:cmd-release <version>` | Full release workflow with build monitoring |
  | `/orchestrator:cmd-detect [dir]` | Detect project type for CI config |
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

## Out of Scope - Exit Immediately

**If the request does NOT involve allowed tools and/or files:**

1. **Immediately respond** with:
   ```
   GitHub plugin cannot handle this request - it is outside the allowed scope.

   Allowed: .github/workflows/*.yaml, .github/dependabot.yaml and /github:* commands
   Requested: [describe what was requested]

   Use the appropriate plugin instead:
   - Go code → go:agent-dev
   - Dockerfile → docker:agent-dev
   - Helm charts → helm:agent-dev
   ```

2. **Stop execution** - do not attempt workarounds or continue
3. **Do not make any tool calls** for the out-of-scope operation
4. **Wait for user** to rephrase or switch plugins

## Post processing

When you finish (Post), hooks will automatically:

- Run yamllint + prettier validation

Fix all issues before completing the task.

## Standards

### NEVER

- Use path filters - CI MUST run on ALL changes
- Use `@main` or `@master` for actions - pin to specific versions
- Put secrets in code - use repository secrets
- Deviate from template versions - use EXACT versions shown below

### ALWAYS

- Use `.yaml` extension (not `.yml`)
- Add `---` document start marker
- Request minimal permissions
- Run `/orchestrator:cmd-detect` first to know what CI needs
- Use claude-image or golang-image containers with raw commands

### Container Images

**Use specific version tags for all container images:**

Query latest tag before creating workflows:
```bash
/docker:cmd-image-tag ghcr.io/transform-ia/golang-image
/docker:cmd-image-tag ghcr.io/transform-ia/claude-image
```

Then use the returned tag in workflow files:
```yaml
container:
  image: ghcr.io/transform-ia/golang-image:v1.23.5  # Use specific version from query
```

**NEVER:**
- Use `latest` tag
- Copy outdated versions from examples

### Linting Tools Available

**claude-image** contains:
- yamllint
- hadolint
- helm lint
- prettier
- markdownlint

**golang-image** contains:
- golangci-lint (ONLY available here)
- yamllint
- hadolint
- helm lint
- markdownlint
- **Note:** prettier is NOT in golang-image

**Configuration files must be in repository root:**

`.yamllint.yaml`:
```yaml
---
extends: default
rules:
  line-length:
    max: 140
```

### Required Action Versions

**CRITICAL: Use these specific rolling version tags. Do NOT use different major versions.**

These are rolling major version tags (e.g., @v4 = latest v4.x release) maintained by
action authors. They automatically receive patch and minor updates while maintaining
backward compatibility within the major version. This balances security updates with
stability.

| Action | Rolling Version Tag |
|--------|---------------------|
| `actions/checkout` | `@v4` |
| `docker/setup-qemu-action` | `@v3` |
| `docker/setup-buildx-action` | `@v3` |
| `docker/login-action` | `@v3` |
| `docker/build-push-action` | `@v6` |
| `azure/setup-helm` | `@v4` |

**When copying workflow templates:**
- Use these exact version tags
- Do NOT downgrade to older major versions (e.g., @v3 when @v4 is specified)
- Do NOT upgrade to newer major versions unless tested and approved
- Do NOT pin to specific SHA commits unless security requires it

## Canonical Workflow Files

**Single source of truth - only these files MUST exist:**

| File | Purpose |
|------|---------|
| `ci.yaml` | Linting and testing (push/PR) |
| `build.yaml` | Build and publish (tags) |

### CRITICAL: Workflow Cleanup Procedure

**Perform cleanup BEFORE creating or updating workflows IF non-canonical files exist.**

#### Step 1: Discovery

Find ALL existing workflow files:
```bash
Glob: .github/workflows/*.y*ml
```

#### Step 2: Classify Files

Categorize each file found:

**KEEP (canonical files):**
- `ci.yaml` - Linting and testing
- `build.yaml` - Build and publish

**DELETE (non-canonical files):**
- Any file with `.yml` extension (wrong extension, must be `.yaml`)
- Any `.yaml` file NOT named `ci.yaml` or `build.yaml` (non-canonical names)

Examples to DELETE:
- `build-and-push.yml` ❌ (wrong extension)
- `lint.yaml` ❌ (non-canonical name)
- `docker-build.yaml` ❌ (non-canonical name)
- `test.yml` ❌ (wrong extension)

#### Step 3: Delete Non-Canonical Files

**If non-canonical files exist, delete them immediately:**

Show the user which files will be deleted:
```
Deleting non-canonical workflows:
- lint.yml (wrong extension)
- build-and-push.yaml (non-canonical name)
```

Delete files:
```bash
rm .github/workflows/lint.yml
rm .github/workflows/build-and-push.yaml
```

NO CONFIRMATION NEEDED - these are policy violations that must be cleaned up.

#### Step 4: Create/Update Canonical Files

Only after cleanup is complete, proceed to create or update `ci.yaml` and `build.yaml`.

**If ONLY canonical files exist** (`ci.yaml`, `build.yaml`), skip Steps 2-3 and proceed directly to Step 4.

## Deleting Container Images

When you need to delete a Docker image from GitHub Container Registry (GHCR):

### Step 1: Find the Version ID

Use the GitHub API to find the version ID for the specific tag:

```bash
# For organization-owned packages
gh api /orgs/<org-name>/packages/container/<image-name>/versions --jq '.[] | select(.metadata.container.tags[]? == "<tag>") | .id'

# Example:
gh api /orgs/transform-ia/packages/container/claude-image/versions --jq '.[] | select(.metadata.container.tags[]? == "1.0.0") | .id'
# Output: 595754170
```

### Step 2: Delete the Version

Use the version ID to delete the image:

```bash
# For organization-owned packages
gh api --method DELETE /orgs/<org-name>/packages/container/<image-name>/versions/<version-id>

# Example:
gh api --method DELETE /orgs/transform-ia/packages/container/claude-image/versions/595754170
```

### Complete Cleanup Example

To completely remove a release and its artifacts:

```bash
# 1. Delete the GitHub release (if it exists)
gh release delete <tag> --repo <owner>/<repo> --yes

# 2. Delete the remote git tag
git push --delete origin <tag>

# 3. Delete the local git tag
git tag -d <tag>

# 4. Find and delete the Docker image
VERSION_ID=$(gh api /orgs/<org-name>/packages/container/<image-name>/versions --jq '.[] | select(.metadata.container.tags[]? == "<version>") | .id')
gh api --method DELETE /orgs/<org-name>/packages/container/<image-name>/versions/$VERSION_ID
```

**Note:** Deleting container images requires `packages: write` permission. This is one of the few DELETE operations allowed through `gh api` in the github plugin.

## Release Workflow

After updating workflows, use `/github:cmd-release` to handle the full release cycle:

### When to Use /github:cmd-release

Use after:
- Creating or updating workflow files
- Any changes that require a new version/tag

### Release Procedure

1. **Commit all changes** (workflow files, etc.)
2. **Run `/github:cmd-release <version>`** which will:
   - Create and push the git tag
   - Push commits to remote
   - Wait for GitHub Actions build to complete
   - Report build success or failure
3. **If build fails**: Check logs with `/github:cmd-logs <run-id>` and fix issues

### Version Formats

```text
/github:cmd-release 1.2.3     # Explicit version
/github:cmd-release patch     # Auto-bump patch (0.0.1 -> 0.0.2)
/github:cmd-release minor     # Auto-bump minor (0.1.0 -> 0.2.0)
/github:cmd-release major     # Auto-bump major (1.0.0 -> 2.0.0)
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
      image: ghcr.io/transform-ia/golang-image:<<QUERY_LATEST_TAG>>
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
      image: ghcr.io/transform-ia/claude-image:<<QUERY_LATEST_TAG>>
      options: --user 0
    steps:
      - uses: actions/checkout@v4

      - name: Lint
        run: |
          hadolint Dockerfile
          prettier --check .
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
      image: ghcr.io/transform-ia/claude-image:<<QUERY_LATEST_TAG>>
      options: --user 0
    steps:
      - uses: actions/checkout@v4

      - name: Lint
        run: |
          helm lint .
          yamllint .
          prettier --check .
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
