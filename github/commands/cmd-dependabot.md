---
description: "Manage dependabot PRs: /github:cmd-dependabot [REPONAME]"
allowed-tools: [Bash(gh pr *), Bash(gh api *), Read]
---

# GitHub Dependabot Management

Automatically manage dependabot PRs across repositories. Merges PRs with passing
builds, rebases PRs with failing builds, and reports all other PRs.

## Permissions

- READ: List and view pull requests
- WRITE: Merge dependabot PRs, update/rebase PR branches

---

## Parameter Validation

- `[REPONAME]` optional, format `owner/repo`
- If provided: process single repo
- If omitted: auto-discover all GitHub repos in `~/sandbox/*/` via git remotes

---

**Usage**: `/github:cmd-dependabot [REPONAME]`

## Workflow

### Phase 1: Repository Discovery

If REPONAME provided, validate `owner/repo` format. Otherwise, scan
`~/sandbox/` for git repositories with GitHub remotes.

### Phase 2: Process Each Repository

For each repository:

1. List open PRs: `gh pr list --repo REPO --state open --limit 100 --json
   number,title,author,headRefName,statusCheckRollup`
2. Categorize: dependabot PRs (`author.login == "dependabot[bot]"`) vs other PRs
3. For each dependabot PR, check build status via `gh pr checks`

**Action by status:**

- **PASSING** (all checks success or no required checks) → squash merge:
  `gh pr merge NUM --repo REPO --squash`
  - Output: `MERGED: #NNN - title`
  - Handle: already merged (skip), conflicts (report), reviews needed (report)
- **FAILING** → request rebase:
  `gh api repos/REPO/pulls/NUM/update-branch -X PUT`
  - Output: `REBASED: #NNN - title`
- **PENDING** → skip, output: `PENDING: #NNN - title`

1. Report non-dependabot PRs with number, title, author, URL
2. Per-repo summary: total PRs, merged, rebased, pending

### Phase 3: Summary

Total repositories processed, actions taken (merged, rebased, pending).

## Error Handling

- Repository not found / no access → Skip and continue
- Merge conflict / required reviews / protected branch → Report and skip
- PR already merged → Skip silently
- API rate limit → Pause and warn
- **General principle**: Continue on errors, never fail the batch

## Notes

- **Idempotent**: Safe to run multiple times
- **Squash merge**: Clean history for dependency updates
- **Security**: Only merges when ALL required checks pass
