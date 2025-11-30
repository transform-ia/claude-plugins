---
description: "Query image tags: /docker:image-tag <image> [count]"
allowed-tools: [Bash, mcp__dockerhub__*]
---

# Docker Image Tag

## Permissions

This command can only modify: `Dockerfile`, `Dockerfile.*`, `.dockerignore`

---

## Parameter Validation

**REQUIRED**: If `$ARGUMENTS` is empty, respond with: "Error: image required.
Usage: /docker:image-tag <image> [count]" and STOP. Do not proceed with any tool
calls.

---

Query available tags for a Docker image.

For GHCR images (ghcr.io/\*), use the script:

```text
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/image-tag-exec.sh $ARGUMENTS")
```

For Docker Hub images, prefer the MCP tool:

```javascript
mcp__dockerhub__listRepositoryTags({
  namespace: "library", // or org/user name
  repository: "image-name",
  page_size: 10,
});
```

Examples:

- `/docker:image-tag python` - Docker Hub official image
- `/docker:image-tag alpine/kubectl` - Docker Hub user/org image
- `/docker:image-tag ghcr.io/transform-ia/claude-image` - GHCR image
