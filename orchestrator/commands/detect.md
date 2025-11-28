---
description: "Detect frameworks: /orchestrator:detect [directory]"
allowed-tools: [Bash]
---
Scan a repository and detect which frameworks/technologies are present.
Returns the list of plugins that should be activated.

```
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/detect-exec.sh $ARGUMENTS")
```

Detection rules:
- `go.mod` → Go plugin
- `Chart.yaml` or `helm/Chart.yaml` → Helm plugin
- `Dockerfile` or `Dockerfile.*` → Docker plugin
- `.github/workflows/` or `.github/dependabot.yml` → GitHub plugin
- Multiple `.md` files → Markdown plugin
