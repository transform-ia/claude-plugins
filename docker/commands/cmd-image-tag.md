---
description: "Query image tags: /docker:cmd-image-tag <image> [count]"
allowed-tools: [Bash, mcp__dockerhub__*]
---

# Docker Image Tag

## Permissions

This command is READ-ONLY. It queries image tags from registries without
modifying any files.

---

## Parameter Validation

**REQUIRED**: If `$ARGUMENTS` is empty, respond with: "Error: image required.
Usage: /docker:cmd-image-tag `<image>` [count]" and STOP. Do not proceed with any
tool calls.

---

Query available tags for a Docker image.

For GHCR images (ghcr.io/\*), use the script:

```text
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/cmd-image-tag.sh $ARGUMENTS")
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

- `/docker:cmd-image-tag python` - Docker Hub official image
- `/docker:cmd-image-tag alpine/kubectl` - Docker Hub user/org image
- `/docker:cmd-image-tag ghcr.io/transform-ia/claude-image` - GHCR image
