---
description: "Cleanup branches: /github:cleanup-branches <scope>"
allowed-tools: [Bash(gh api *), Bash(gh repo *), Bash(git *), Read]
---

# GitHub Branch Cleanup

Delete branches not linked to any open pull request across repositories in the
specified scope.

## Minimal Output Guidelines

Always use `gh` CLI with `--json`, `--jq`, and `--limit 20` for minimal context
usage.

## Permissions

- READ: List repositories, branches, pull requests
- WRITE: Delete branches via `gh api -X DELETE`

---

## Parameter: Scope (Required)

Accepts flexible scope descriptions: `org:tournevent`, `transform-ia/hooks`,
`tournevent and transform-ia orgs`, `all repos with a Dockerfile`, `my
repositories`.

If scope not provided, respond with error and STOP.

---

**Usage**: `/github:cleanup-branches <scope>`

## Workflow

### Phase 1: Repository Discovery

Interpret scope and resolve to repository list using `gh repo list` or
`gh search code`. Confirm with user if more than 5 repositories.

### Phase 2: Process Each Repository

For each repository:

1. Get default branch (`gh repo view --json defaultBranchRef`)
2. List all branches (`gh api repos/OWNER/REPO/branches --paginate`)
3. List open PR head branches (`gh pr list --state open --json headRefName`)
4. Delete branches not in protected set (default branch + PR branches) using
   `gh api -X DELETE "repos/OWNER/REPO/git/refs/heads/BRANCH"`
5. Report: `DELETED`, `FAILED`, or `SKIPPED` per branch

### Phase 3: Summary

Report total repositories processed, branches deleted, and failures.

## Protected Branches

NEVER delete: `main`, `master`, or any branch with an open pull request.

## Error Handling

- Repository not found / no access → Skip and continue
- Branch protected by rules / already deleted → Report and skip
- API rate limit → Warn and continue
- **General principle**: Continue on errors, report failures, never stop the
  batch

## Notes

- **Idempotent**: Safe to run multiple times
- **Conservative**: Only deletes branches with NO open PRs
- **Default branch safe**: Never deletes main/master
