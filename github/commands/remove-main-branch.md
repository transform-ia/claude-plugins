---
description: "Remove main branch: /github:remove-main-branch [scope]"
allowed-tools: [Bash(${CLAUDE_PLUGIN_ROOT}/scripts/remove-main-branch.sh *), Read, AskUserQuestion]
---

# GitHub Remove Main Branch

Migrate repositories from `main` to `master` as the default branch. Identifies
repos with `main` as default, merges changes into `master`, changes default
branch, and deletes `main`.

## Minimal Output Guidelines

Always use `gh` CLI with `--json`, `--jq`, and `--limit 200`.

## Permissions

- READ: List repositories, branches, compare commits
- WRITE: Create/merge branches, change default branch, delete branches

---

## Parameter: Scope (Optional)

Defaults to all accessible repositories. Examples: `org:transform-ia`,
`transform-ia/hooks`, `my repositories`.

---

**Usage**: `/github:remove-main-branch [scope]`

## Workflow

### Phase 1: Discovery

```bash
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/remove-main-branch.sh discover $ARGUMENTS")
```

Show discovered repos. Confirm with user if more than 5.

### Phase 2: Interactive Migration

For each repository, display status (default branch, master exists, divergence,
open PRs) then use AskUserQuestion (Yes / No / All / Abort).

If confirmed:

```bash
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/remove-main-branch.sh migrate <owner/repo>")
```

The script handles: backup tag, create master (if needed), merge main into
master, change default branch, delete main, verify.

### Phase 3: Summary

Report: processed, migrated, skipped, failed (with reasons). Include rollback
instructions.

## Error Handling

- No admin access / merge conflict → Skip and report
- Branch protection → Report and skip
- API errors → Retry once, then skip
- **General principle**: Continue on errors, report failures

## Safety Features

- **Backup tags**: `backup-main-YYYYMMDD-HHMMSS` created before modifications
- **Interactive**: Prompts for each repository by default
- **Verification**: Confirms default branch changed before deleting main
