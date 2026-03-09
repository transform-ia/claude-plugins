---
description: "Detect frameworks: /orchestrator:cmd-detect [directory]"
allowed-tools: [Bash(${CLAUDE_PLUGIN_ROOT}/scripts/cmd-detect.sh *)]
---

# Orchestrator Detect

## Permissions

This command is READ-ONLY. It cannot modify any files.

---

Scan a repository and detect which frameworks/technologies are present. Returns
the list of plugins that should be activated.

```text
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/cmd-detect.sh $ARGUMENTS")
```

Detection rules:

- `go.mod` → Go plugin
- `Chart.yaml` or `helm/Chart.yaml` → Helm plugin
- `Dockerfile` or `Dockerfile.*` → Docker plugin
- `.github/workflows/` or `.github/dependabot.yaml` → GitHub plugin
- `package.json` → Node.js (for npm dependabot)
- Multiple `.md` files → Markdown plugin
