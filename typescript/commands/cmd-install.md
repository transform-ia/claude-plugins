---
description: "Install npm dependencies: /typescript:cmd-install <directory>"
allowed-tools: [Bash(${CLAUDE_PLUGIN_ROOT}/scripts/cmd-install.sh *)]
---

# Install Dependencies

## Permissions

**Permission Level**: 1 (Artifact Creation)

This command installs dependencies from package.json.

**Created artifacts**:

- `node_modules/` directory
- `package-lock.json` (may be updated)

---

## Parameter Validation

**REQUIRED**: If `$ARGUMENTS` is empty, respond with: "Error: directory
required. Usage: /typescript:cmd-install DIRECTORY" and STOP. Do not proceed
with any tool calls.

---

Run the install script using absolute path. Do NOT cd or change directory.

```text
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/cmd-install.sh $ARGUMENTS")
```
