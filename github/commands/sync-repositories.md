---
description: "Sync repositories: /github:sync-repositories"
allowed-tools: [Bash(${CLAUDE_PLUGIN_ROOT}/scripts/sync-repositories.sh *), Read, AskUserQuestion]
---

# GitHub Sync Repositories

## Permissions

This command is READ-ONLY with selective PULL operations. It scans git
repositories in ~/sandbox/, checks their sync status with GitHub, and
pulls remote changes when behind. Does not push or modify branches.

---

## Workflow

1. Scan all subdirectories in ~/sandbox/ for git repositories
2. For each git repo, check if it's connected to a GitHub organization we admin
3. Pull remote changes if local is behind
4. Analyze repos not on master/main branch
5. Analyze repos with unpushed local changes
6. Report findings and ask user for instructions

---

Execute sync:

```text
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/sync-repositories.sh $ARGUMENTS")
```

After the script completes, review the output and:

1. **Pulled repos**: Confirm which repos were updated
2. **Non-master branches**: Analyze why (feature work, stale branch, etc.)
3. **Unpushed changes**: Analyze what changed and why it wasn't pushed
4. **Ask user**: What to do with repos that have local-only changes
