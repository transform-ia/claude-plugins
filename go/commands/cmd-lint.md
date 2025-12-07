---
description: "Run golangci-lint: /go:cmd-lint <directory>"
allowed-tools: [Bash]
---

# Go Lint

## Permissions

This command modifies `*.go` files via auto-formatting (`golangci-lint fmt`) and
auto-fixes (`golangci-lint run --fix`).

---

## Parameter Validation

**REQUIRED**: If `$ARGUMENTS` is empty, respond with: "Error: directory
required. Usage: /go:cmd-lint <directory>" and STOP. Do not proceed with any
tool calls.

---

Run the lint script using absolute path. Do NOT cd or change directory.

```text
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/cmd-lint.sh $ARGUMENTS")
```
