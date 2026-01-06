---
description: "Upgrade Docker images: /docker:cmd-upgrade [directory]"
allowed-tools:
  [
    Bash,
    Read,
    Edit,
    Glob,
    Grep,
    Task,
    TodoWrite,
    AskUserQuestion,
    mcp__dockerhub__*,
  ]
---

# Docker Image Upgrade

## Permissions

This command can modify:

- `Dockerfile`, `Dockerfile.*` - Base image versions
- `values.yaml`, `values-*.yaml` - Helm chart image tags
- ArgoCD Application manifests (`.yaml` files with `image:` or `tag:` fields)

---

## Parameter Handling

- `$ARGUMENTS` specifies the directory to scan (default: `/workspace/sandbox`)
- Scan recursively for all supported file types

---

## Upgrade Workflow

### Phase 1: Discovery

Scan the target directory for files containing Docker image references:

1. **Dockerfiles** - Find all `FROM` statements

   ```text
   Glob("**/Dockerfile", path="$ARGUMENTS")
   Glob("**/Dockerfile.*", path="$ARGUMENTS")
   ```

2. **Helm Charts** - Find values files with image configuration

   ```text
   Glob("**/values.yaml", path="$ARGUMENTS")
   Glob("**/values-*.yaml", path="$ARGUMENTS")
   ```

3. **ArgoCD Applications** - Find Application manifests

   ```text
   Glob("**/applications/**/*.yaml", path="$ARGUMENTS")
   Grep(pattern="kind:\\s*Application", path="$ARGUMENTS", glob="*.yaml")
   ```

### Phase 2: Analysis

For each discovered file, extract current image versions:

**Dockerfiles:**

```text
Grep(pattern="^FROM\\s+", path="<file>", output_mode="content")
```

**Helm values.yaml:**

```text
Grep(pattern="(image:|repository:|tag:)", path="<file>", output_mode="content", -C=2)
```

**ArgoCD Applications:**

```text
Grep(pattern="(image:|targetRevision:)", path="<file>", output_mode="content", -C=2)
```

### Phase 3: Version Lookup

For each unique image, query the latest available version:

**Docker Hub images:**

```javascript
mcp__dockerhub__listRepositoryTags({
  namespace: "<namespace>", // 'library' for official images
  repository: "<image>",
  page_size: 5,
});
```

**GHCR images:**

```text
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/cmd-image-tag.sh ghcr.io/<org>/<repo>")
```

### Phase 4: Report Generation

Create a structured report showing:

| File                 | Image  | Current | Latest | Action     |
| -------------------- | ------ | ------- | ------ | ---------- |
| path/Dockerfile      | golang | 1.24    | 1.25.5 | Upgrade    |
| path/values.yaml     | nginx  | 1.25.0  | 1.27.0 | Upgrade    |
| path/Application.yml | my-app | v1.0.0  | v1.2.0 | Upgrade    |
| path/Dockerfile      | alpine | 3.22.2  | 3.22.2 | Up-to-date |

### Phase 5: User Confirmation

Use AskUserQuestion to confirm upgrade scope:

```javascript
AskUserQuestion({
  questions: [
    {
      question: "Which images should be upgraded?",
      header: "Scope",
      options: [
        {
          label: "All outdated",
          description: "Upgrade all images with newer versions available",
        },
        {
          label: "Critical only",
          description: "Only upgrade images with security patches",
        },
        {
          label: "Select manually",
          description: "Review and select each image individually",
        },
        { label: "None", description: "Generate report only, no changes" },
      ],
      multiSelect: false,
    },
  ],
});
```

### Phase 6: Apply Updates

Based on user selection, apply updates using the Edit tool:

**Dockerfile FROM statements:**

```text
Edit(file_path="<path>", old_string="FROM <image>:<old>", new_string="FROM <image>:<new>")
```

**Helm values.yaml:**

```text
Edit(file_path="<path>", old_string="tag: \"<old>\"", new_string="tag: \"<new>\"")
```

**ArgoCD targetRevision:**

```text
Edit(file_path="<path>", old_string="targetRevision: <old>", new_string="targetRevision: <new>")
```

---

## Image Version Standards

Follow these rules from the docker:skill-dev instructions:

### NEVER

- Use `latest` tag - always pin to specific versions
- Use ARG for base image versions (Dependabot cannot track)
- Use floating tags like `alpine:3` or `node:22` without patch version

### ALWAYS

- Pin to full semantic versions: `alpine:3.22.2`, `golang:1.25.5-alpine3.22`
- Use LTS versions for Node.js: `node:22-alpine3.22` (not node:23 or node:25)
- Match Alpine versions across multi-stage builds
- Use non-root user (UID 1000)

### Version Selection Priority

1. **Security patches**: Always upgrade patch versions (x.x.PATCH)
2. **Minor versions**: Upgrade if changelog shows no breaking changes
3. **Major versions**: Require explicit user confirmation
4. **LTS preference**: For Node.js, prefer LTS releases (even numbers: 18,
   20, 22)

---

## Supported Image Patterns

### Dockerfiles

```dockerfile
FROM alpine:3.22.2
FROM golang:1.25.5-alpine3.22 AS builder
FROM node:22-alpine3.22
FROM ghcr.io/transform-ia/upx-image:5.0.2 AS compressor
```

### Helm values.yaml

```yaml
image:
  repository: nginx
  tag: "1.27.0"
  pullPolicy: IfNotPresent

# Or flat format
image: nginx:1.27.0
```

### ArgoCD Applications

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
spec:
  source:
    targetRevision: v1.2.0
    helm:
      values: |
        image:
          tag: "1.2.0"
```

---

## Error Handling

- **Network errors**: Retry image tag queries up to 3 times
- **Invalid versions**: Skip and report as warning
- **Parse errors**: Report file path and continue with other files
- **Permission errors**: Report and skip file

---

## Output Format

After completion, provide summary:

```text
## Docker Image Upgrade Summary

### Files Scanned
- Dockerfiles: 28
- Helm values: 15
- ArgoCD apps: 12

### Updates Applied
- Upgraded: 18 images
- Skipped: 5 (already up-to-date)
- Failed: 2 (see errors below)

### Errors
- path/to/file.yaml: Parse error on line 42
- path/to/other.yaml: Image not found: custom/image

### Next Steps
1. Run `/docker:cmd-lint` on updated Dockerfiles
2. Run `/helm:cmd-lint` on updated Helm charts
3. Commit changes to git
4. Monitor ArgoCD sync status
```
