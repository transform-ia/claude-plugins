# GitHub CI/CD Development

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

Query latest tag before creating workflows:

```bash
/docker:cmd-image-tag ghcr.io/transform-ia/golang-image
/docker:cmd-image-tag ghcr.io/transform-ia/claude-image
```

NEVER use `latest` tag or copy outdated versions from examples.

**claude-image** contains: yamllint, hadolint, helm lint, prettier, markdownlint

**golang-image** contains: golangci-lint (ONLY here), yamllint, hadolint, helm
lint, markdownlint. Note: prettier is NOT in golang-image.

**Configuration files must be in repository root.**

`.yamllint.yaml`:

```yaml
---
extends: default
rules:
  line-length:
    max: 140
```

### Required Action Versions

Use these exact rolling major version tags. Do NOT change major versions.

| Action                       | Version |
| ---------------------------- | ------- |
| `actions/checkout`           | `@v4`   |
| `docker/setup-qemu-action`   | `@v3`   |
| `docker/setup-buildx-action` | `@v3`   |
| `docker/login-action`        | `@v3`   |
| `docker/build-push-action`   | `@v6`   |
| `azure/setup-helm`           | `@v4`   |

## Canonical Workflow Files

**Only `ci.yaml` should exist.** All project types use a single combined
workflow with lint and build jobs (`needs: lint`).

### Cleanup Procedure

Before creating or updating workflows, check for non-canonical files:

1. `Glob: .github/workflows/*.y*ml`
2. **DELETE immediately** (no confirmation needed): any `.yml` file, `build.yaml`,
   or any non-`ci.yaml` file
3. Then create/update `ci.yaml`

## Deleting Container Images

Find version ID then delete:

```bash
# Find version ID
gh api /orgs/<org>/packages/container/<image>/versions \
  --jq '.[] | select(.metadata.container.tags[]? == "<tag>") | .id'

# Delete version
gh api --method DELETE /orgs/<org>/packages/container/<image>/versions/<id>
```

Complete cleanup (release + tag + image):

```bash
gh release delete <tag> --repo <owner>/<repo> --yes
git push --delete origin <tag>
git tag -d <tag>
VERSION_ID=$(gh api /orgs/<org>/packages/container/<image>/versions \
  --jq '.[] | select(.metadata.container.tags[]? == "<version>") | .id')
gh api --method DELETE /orgs/<org>/packages/container/<image>/versions/$VERSION_ID
```

Requires `packages: write` permission. This is one of the few DELETE operations
allowed through `gh api`.

## Release Workflow

Use `/github:cmd-release <version>` after updating workflows or for any changes
requiring a new version. Version formats: explicit (`1.2.3`), `patch`, `minor`,
`major`.

Always wait for the build result before reporting completion.

## Workflows by Project Type

### Go Projects

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

Single workflow with `needs: lint` and tag-triggered build:

```yaml
---
name: CI

"on":
  push:
  pull_request:

permissions:
  contents: read
  packages: write

jobs:
  lint:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/transform-ia/claude-image:0.1.0
      options: --user 0
    steps:
      - uses: actions/checkout@v4
      - name: Lint Dockerfile
        run: hadolint Dockerfile
      - name: Lint YAML
        run: yamllint .
      - name: Lint Markdown
        run: markdownlint .

  build:
    needs: lint
    if: startsWith(github.ref, 'refs/tags/v')
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

Lint:

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

Package and push on tag:

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

Use templates from `assets/templates/` as base. Always include `github-actions`
ecosystem.

### Dependabot for Go

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

### Dependabot for Docker

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

### Dependabot for Helm

```yaml
---
version: 2
updates:
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "daily"
```

### Dependabot for Node.js

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

## .gitignore

Keep `.gitignore` at repository root.

### Organization

- Use comments (`#`) to organize sections by category
- Group related patterns under descriptive headers

### OS Artifacts

```gitignore
# OS
.DS_Store
Thumbs.db
```

### Editor Artifacts

```gitignore
# Editor
.idea/
.vscode/
*.swp
*.swo
```

### Language-Specific

**Go**:

```gitignore
# Go
*.test
*.out
coverage.txt
```

**Node.js**:

```gitignore
# Node
node_modules/
dist/
.env
```

### Secrets

Never commit secrets. Always ignore:

```gitignore
# Secrets
.env
*.key
*.pem
```

### Negation

Use `!` to re-include specific files that would otherwise be ignored:

```gitignore
*.env
!.env.example
```

## Common yamllint Fixes

| Issue                    | Fix                                      |
| ------------------------ | ---------------------------------------- |
| `line too long`          | Break lines or use YAML multiline syntax |
| `wrong indentation`      | Use 2-space indentation                  |
| `missing document start` | Add `---` at file start                  |
| `trailing spaces`        | Remove trailing whitespace               |
| `truthy value`           | Use `true`/`false` not `yes`/`no`        |
