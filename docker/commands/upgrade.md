---
description: "Upgrade Docker images: /docker:upgrade [directory]"
allowed-tools:
  [
    Bash(${CLAUDE_PLUGIN_ROOT}/scripts/image-tag.sh *),
    Read,
    Edit(Dockerfile),
    Edit(Dockerfile.*),
    Edit(values.yaml),
    Edit(values-*.yaml),
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

---

## Parameter Handling

- `$ARGUMENTS` specifies the directory to scan (default: `.`)
- Scan recursively for all supported file types

---

## Upgrade Workflow

### Phase 1: Discovery

Scan the target directory for Dockerfiles (`FROM` statements) and Helm values
files (image/repository/tag fields).

### Phase 2: Version Lookup

For each unique image, query the latest available version:

- **Docker Hub**: Use `mcp__dockerhub__listRepositoryTags`
- **GHCR**: Use `${CLAUDE_PLUGIN_ROOT}/scripts/image-tag.sh`

### Phase 3: Report

Present a table of all images with current vs latest versions and recommended
action (Upgrade / Up-to-date).

### Phase 4: User Confirmation

Use AskUserQuestion to confirm scope: all outdated, critical only, select
manually, or report only.

### Phase 5: Apply Updates

Edit `FROM` statements in Dockerfiles and `tag:` fields in Helm values files
using the Edit tool.

## Image Version Standards

### NEVER

- Use `latest` tag - always pin to specific versions
- Use ARG for base image versions (Dependabot cannot track)
- Use floating tags like `alpine:3` or `node:22` without patch version

### ALWAYS

- Pin to full semantic versions: `alpine:3.22.2`, `golang:1.25.5-alpine3.22`
- Use LTS versions for Node.js (even numbers: 18, 20, 22)
- Match Alpine versions across multi-stage builds

### Version Selection Priority

1. **Security patches**: Always upgrade patch versions (x.x.PATCH)
2. **Minor versions**: Upgrade if changelog shows no breaking changes
3. **Major versions**: Require explicit user confirmation

## Error Handling

- **Network errors**: Retry up to 3 times
- **Invalid/unfound versions**: Skip and report as warning
- **Parse errors**: Report file path and continue with other files

## Output Format

After completion, provide summary with: files scanned count, updates applied,
skipped (up-to-date), failed with errors, and next steps (lint, commit).
