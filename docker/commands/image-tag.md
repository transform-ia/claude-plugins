---
description: "Query image tags: /docker:image-tag <image> [count]"
allowed-tools: [Bash, mcp__dockerhub__*]
---
Query available tags for a Docker image.

For GHCR images (ghcr.io/*), use the script:
```
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/image-tag-exec.sh $ARGUMENTS")
```

For Docker Hub images, prefer the MCP tool:
```
mcp__dockerhub__listRepositoryTags({
  namespace: "library",  // or org/user name
  repository: "image-name",
  page_size: 10
})
```

Examples:
- `/docker:image-tag python` - Docker Hub official image
- `/docker:image-tag alpine/kubectl` - Docker Hub user/org image
- `/docker:image-tag ghcr.io/transform-ia/claude-image` - GHCR image
