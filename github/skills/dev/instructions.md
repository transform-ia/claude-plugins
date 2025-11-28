# GitHub CI/CD Development Guidelines

## Critical: Hook Restrictions

**This context restricts operations to .github directory files only.**

Allowed files:
- `.github/workflows/*.yaml`, `.github/workflows/*.yml`
- `.github/dependabot.yml`
- `.github/PULL_REQUEST_TEMPLATE/*.md`

When an operation is BLOCKED by hooks:
- This is EXPECTED behavior
- For other files, exit the plugin context

## Available Commands

| Command | Purpose |
|---------|---------|
| `/github:lint [dir]` | Run yamllint + prettier on .github |
| `/github:status [repo]` | Check workflow status |
| `/github:logs <run-id>` | Get workflow logs |

## Rules

1. **Linter runs automatically** when you finish. Fix all issues before completing.
2. **File restrictions:** Only .github files can be modified.
3. **YAML validation:** All workflow files must pass yamllint.
4. **No path filters:** CI should run on ALL changes.

## Standard CI Workflow

**Every repository uses a single `.github/workflows/ci.yaml`:**

```yaml
---
name: CI

on:
  push:
    branches: [main, master]
  pull_request:

permissions:
  contents: read

jobs:
  lint:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/transform-ia/claude-image:latest
      options: --user 0
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Lint
        run: task lint-ci
```

**Key principles:**
- Single workflow file: `ci.yaml`
- No path filters: Run on every push and PR
- Claude image: Same tools as local development
- `--user 0` required for claude-image containers

## Dependabot Configuration

**Every repository should have `.github/dependabot.yml`:**

### Go Projects
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

### Helm Chart Projects
```yaml
---
version: 2
updates:
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "daily"
```

### Docker Image Projects
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

## Docker Build Workflow

```yaml
---
name: Build and Push Docker Image

on:
  push:
    tags:
      - 'v*'

permissions:
  contents: read
  packages: write

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up QEMU
        uses: docker/setup-qemu-action@v3

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Extract version from tag
        id: version
        run: |
          echo "VERSION=${GITHUB_REF#refs/tags/v}" >> $GITHUB_OUTPUT

      - name: Login to GitHub Container Registry
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          platforms: linux/amd64,linux/arm64
          push: true
          tags: |
            ghcr.io/${{ github.repository_owner }}/${{ github.event.repository.name }}:${{ steps.version.outputs.VERSION }}
            ghcr.io/${{ github.repository_owner }}/${{ github.event.repository.name }}:latest
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

## Helm Chart Package Workflow

```yaml
---
name: Package and Push Helm Chart

on:
  push:
    tags:
      - 'v*'

permissions:
  contents: read
  packages: write

jobs:
  package-and-push:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Helm
        uses: azure/setup-helm@v4
        with:
          version: '3.16.4'

      - name: Extract version
        id: version
        run: echo "VERSION=${GITHUB_REF#refs/tags/v}" >> $GITHUB_OUTPUT

      - name: Update Chart version
        run: sed -i "s/^version:.*/version: ${{ steps.version.outputs.VERSION }}/" Chart.yaml

      - name: Package chart
        run: helm package .

      - name: Login to GHCR
        run: echo ${{ secrets.GITHUB_TOKEN }} | helm registry login ghcr.io -u ${{ github.actor }} --password-stdin

      - name: Push to GHCR
        run: |
          CHART_NAME=$(yq -r .name Chart.yaml)
          helm push ${CHART_NAME}-${{ steps.version.outputs.VERSION }}.tgz oci://ghcr.io/${{ github.repository_owner }}
```

## Best Practices

1. **Minimal permissions:** Only request what's needed
2. **Use caching:** Enable build caches for faster runs
3. **Single workflow:** Consolidate lint tasks into one file
4. **No secrets in code:** Use repository secrets
5. **Pin action versions:** Use specific versions (@v4, not @main)
