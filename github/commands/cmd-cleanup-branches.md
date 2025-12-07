---
description: "Cleanup branches: /github:cmd-cleanup-branches <scope>"
allowed-tools: [Bash, Read]
---

# GitHub Branch Cleanup

## Minimal Output Guidelines

**CRITICAL**: Use `gh` CLI with `--json` and `--jq` for minimal context usage.

**Required patterns:**

- `--limit 20` for all list operations
- `--json` with specific fields only
- `--jq` to filter/transform output
- `--state open` for PR lists

## Permissions

This command can:

- READ: List repositories, branches, and pull requests (via `gh` CLI)
- WRITE: Delete branches not linked to any PR (via `gh api -X DELETE`)

---

## Parameter: Scope (Required)

The `<scope>` parameter defines which repositories to process. It accepts
flexible, natural language descriptions that Claude interprets.

**Scope Examples**:

- `org:tournevent` - All repositories in the tournevent organization
- `org:transform-ia` - All repositories in the transform-ia organization
- `transform-ia/hooks` - Single specific repository
- `tournevent and transform-ia orgs` - Multiple organizations
- `all repos with a Dockerfile` - Repos containing specific file
- `repos in transform-ia with go.mod` - Filtered by file presence
- `my repositories` - User's personal repositories
- `repos I have access to in tournevent` - Access-based filtering

**Scope Interpretation**:

Claude will interpret the scope and determine the appropriate repositories by:

1. Parsing organization names, repo names, or descriptive filters
2. Using GitHub search/list APIs to discover matching repositories
3. Applying any additional filters mentioned (file presence, language, etc.)

---

Delete branches that are not linked to any existing pull request across
repositories in the specified scope.

**Usage**: `/github:cmd-cleanup-branches <scope>`

**Examples**:

```text
/github:cmd-cleanup-branches org:tournevent
/github:cmd-cleanup-branches org:transform-ia
/github:cmd-cleanup-branches transform-ia/hooks
/github:cmd-cleanup-branches tournevent and transform-ia orgs
/github:cmd-cleanup-branches all repos in tournevent with a README
```

## Workflow

### Phase 1: Scope Interpretation and Repository Discovery

**Step 1.1**: Validate scope parameter

**If scope not provided**:

- Respond: "Error: Scope is required. Examples: 'org:tournevent',
  'transform-ia/hooks', 'all repos in transform-ia org'" and STOP

**Step 1.2**: Interpret and resolve scope to repository list

Analyze the scope string and use `gh` CLI to discover repositories:

**For organization scopes** (e.g., "org:tournevent", "tournevent org",
"repositories in tournevent"):

```bash
gh repo list ORG --limit 50 --json nameWithOwner --jq '.[].nameWithOwner'
```

**For multiple organizations** (e.g., "tournevent and transform-ia orgs"):

Run list for each organization and combine results.

**For single repository** (e.g., "transform-ia/hooks"):

Add directly to repository list without search.

**For filtered scopes** (e.g., "repos with go.mod in transform-ia"):

Use code search to find repositories matching criteria:

```bash
gh search code "filename:go.mod org:transform-ia" --limit 20 \
  --json repository --jq '[.[].repository.nameWithOwner] | unique[]'
```

**For user repositories** (e.g., "my repos"):

Get authenticated user and list their repos:

```bash
gh api user --jq '.login'
gh repo list --limit 50 --json nameWithOwner --jq '.[].nameWithOwner'
```

**Step 1.3**: Display discovered repositories

Output:

```
Scope: <original scope>
Discovered N repositories:
  - owner/repo1
  - owner/repo2
  ...
```

Ask for confirmation before proceeding if more than 5 repositories.

### Phase 2: Process Each Repository

For each repository in the list:

**Step 2.1**: Display repository header

Output:

```
============================================
Repository: owner/repo
============================================
```

**Step 2.2**: Get default branch

Use `gh` CLI to get repository info:

```bash
gh repo view owner/repo --json defaultBranchRef --jq '.defaultBranchRef.name'
```

The default branch is typically `main` or `master`. If unavailable, assume
`main`.

**Step 2.3**: List all branches

Use `gh` API with minimal output:

```bash
gh api repos/owner/repo/branches --paginate --jq '.[].name'
```

**Error handling**:

- If repository not found: Output "Repository not accessible. Skipping..." and
  continue
- If permission denied: Output "No access to repository. Skipping..." and
  continue
- If API error: Output error message and continue

**Step 2.4**: List all open pull requests

Use `gh` CLI with minimal output:

```bash
gh pr list --repo owner/repo --state open --limit 100 \
  --json headRefName --jq '.[].headRefName'
```

Extract the head branch names from the output.

Create a set of "protected branches" that includes:

- The default branch (main/master)
- All branches with open PRs

**Step 2.5**: Identify branches to delete

For each branch from Step 2.3:

- Skip if branch name equals default branch
- Skip if branch name is in the "branches with open PRs" set
- Otherwise, add to "branches to delete" list

**Step 2.6**: Delete orphan branches

For each branch in "branches to delete" list:

1. Delete using GitHub API via gh CLI:

   ```bash
   gh api -X DELETE "repos/<owner>/<repo>/git/refs/heads/<branch_name>"
   ```

2. If successful:
   - Output: `✓ DELETED: <branch_name>`
   - Increment deleted count

3. If failed:
   - Output: `✗ FAILED: <branch_name> - <error>`
   - Increment failed count
   - Continue to next branch

**Step 2.7**: Display repository summary

Output:

```
Branches: N total, X protected (default + PRs), Y deleted, Z failed
```

### Phase 3: Final Summary

**Step 3.1**: Display overall summary

Output:

```
============================================
CLEANUP COMPLETE
============================================

Scope: <scope>
Repositories processed: N
Branches deleted: X
Branches failed: Y
```

**Step 3.2**: If any deletions failed due to hook blocking

Output:

```
Note: Some deletions may have been blocked. To delete manually, run:
gh api -X DELETE "repos/OWNER/REPO/git/refs/heads/BRANCH"
```

## Protected Branches

The following branches are NEVER deleted:

- `main` - Default branch
- `master` - Legacy default branch
- Any branch with an open pull request

## Error Handling

**Repository-level errors**:

- Repository not found → Skip and continue
- No access permissions → Skip and continue
- API rate limit → Warn user and continue
- Empty repository → Skip (no branches)

**Branch-level errors**:

- Branch protected by rules → Report and skip
- Branch already deleted → Skip silently
- API errors → Report and continue

**General principle**: Continue processing on errors. Report failures but don't
stop the batch.

## Notes

- **Idempotent**: Safe to run multiple times. Already-deleted branches are
  skipped.
- **Conservative**: Only deletes branches with NO open PRs.
- **Default branch safe**: Never deletes main/master regardless of PR status.
- **Rate limiting**: Be mindful of GitHub API rate limits with many repos.
- **Confirmation**: Lists branches before deletion for visibility.

## Troubleshooting

**"Repository not accessible"**:

- Check repository exists and you have access
- Verify you have write access to delete branches

**"Branch deletion failed - protected"**:

- Repository has branch protection rules
- Admin access needed to delete protected branches

**"API rate limit exceeded"**:

- Wait 1 hour or use token with higher limits
- Process fewer repositories at a time

**"No repositories found in org"**:

- Verify organization name is correct
- Check you have access to the organization
