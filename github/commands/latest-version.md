---
description:
  "Get latest semantic version from local git: /github:latest-version
  <directory>"
allowed-tools: [Bash(${CLAUDE_PLUGIN_ROOT}/scripts/latest-version.sh *)]
---

# GitHub Latest Version

## Permissions

This command is READ-ONLY. It queries git tags from a local repository on the
filesystem. No file modifications are made.

**Important**: This command reads tags from a LOCAL git repository on the
filesystem. It does NOT query GitHub directly. To get versions from a remote
GitHub repository, clone it first or use `gh release list`.

---

## Parameter Validation

**Required argument:**

- `<directory>`: Local filesystem path to a git repository (required)

Examples of valid paths:

- `~/my-project`
- `.` (current directory)
- `../other-repo`

**NOT valid** (these are GitHub repository paths, not filesystem paths):

- `owner/repo`
- `transform-ia/claude-image`

If validation fails, respond with: "Error: Not a git repository: [directory]"

DO NOT proceed with tool calls if directory is invalid.

---

Query latest semantic version tag from git repository.

```text
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/latest-version.sh $ARGUMENTS")
```
