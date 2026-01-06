---
description: "Manage dependabot PRs: /github:cmd-dependabot [REPONAME]"
allowed-tools: [Bash, Read]
---

# GitHub Dependabot Management

## Permissions

This command can:

- READ: List and view pull requests (via MCP GitHub tools)
- WRITE: Merge dependabot PRs with passing builds (via MCP tools)
- WRITE: Update/rebase dependabot PR branches (via MCP tools)

**Security**: Uses MCP tools for write operations. Bash write operations (gh pr
merge, gh api -X PUT) are blocked by hooks.

---

## Parameter Validation

**Optional**: `[REPONAME]` in format `owner/repo`

- If provided: Process only that repository
- If omitted: Auto-discover all repos in `/workspace/sandbox/*/`

**Valid formats**:

- `transform-ia/claude-plugins` ✓
- `transform-ia/hooks` ✓
- `invalid-format` ✗ (must have owner/repo)

---

Automatically manage dependabot pull requests across repositories. Merges PRs
with passing builds, rebases PRs with failing builds, and reports all other PRs.

**Usage**: `/github:cmd-dependabot [REPONAME]`

**Examples**:

```text
/github:cmd-dependabot transform-ia/claude-plugins  # Process single repo
/github:cmd-dependabot                              # Process all repos
```

## Workflow

### Phase 1: Repository Discovery

**Step 1.1**: Determine repositories to process

**If REPONAME provided**:

1. Validate format contains `/` (owner/repo pattern)
2. If invalid, respond: "Error: Invalid format. Use 'owner/repo' (e.g.,
   transform-ia/claude-plugins)" and STOP
3. Set repositories list to single repo: `[REPONAME]`

**If REPONAME not provided**:

1. Discover all GitHub repositories in `/workspace/sandbox/`:

```bash
find /workspace/sandbox -maxdepth 3 -name ".git" -type d 2>/dev/null | while read -r git_dir; do
    repo_dir=$(dirname "$git_dir")
    cd "$repo_dir" || continue
    remote=$(git remote get-url origin 2>/dev/null || echo "")
    if [[ "$remote" == *"github.com"* ]]; then
        echo "$remote" | sed -E 's|.*github\.com[:/]([^/]+/[^/.]+)(\.git)?$|\1|'
    fi
done | sort -u
```

1. Parse output to create list of `owner/repo` pairs
2. If no repositories found, respond: "No GitHub repositories found in
   /workspace/sandbox/" and STOP

**Step 1.2**: Display scan information

Output:

```text
Scanning repositories for dependabot PRs...
Found N repositories to process
```

### Phase 2: Process Each Repository

For each repository in the list:

**Step 2.1**: Display repository header

Output:

```text
============================================
Repository: owner/repo
============================================
```

**Step 2.2**: List all open pull requests

Use MCP tool:

```javascript
mcp__github__list_pull_requests(
  owner: owner,
  repo: repo,
  state: "open",
  perPage: 100
)
```

**Error handling**:

- If repository not found: Output "Repository not accessible or doesn't exist.
  Skipping..." and continue to next repo
- If permission denied: Output "No access to repository. Skipping..." and
  continue to next repo
- If API error: Output error message and continue to next repo

**Step 2.3**: Categorize pull requests

Separate PRs into two categories:

- **Dependabot PRs**: Where `author.login` equals `"dependabot[bot]"`
  (case-insensitive)
- **Other PRs**: All other PRs

If no open PRs found:

- Output: "No open pull requests found."
- Continue to next repository

**Step 2.4**: Process each dependabot PR

For each dependabot PR:

**2.4a**: Get PR status

Use MCP tool:

```javascript
mcp__github__pull_request_read(
  method: "get_status",
  owner: owner,
  repo: repo,
  pullNumber: pr.number
)
```

**2.4b**: Determine build status

Parse the status response:

- **All checks successful**: `state: "success"` or no required checks
- **Any check failed**: `state: "failure"` or any check has
  `conclusion: "failure"`
- **Checks pending**: `state: "pending"` or any check still running

**Important**: If the PR has no required checks (empty status), treat as
**passing** (GitHub allows merge).

**2.4c**: Take action based on status

**IF PASSING → Auto-merge**:

1. Use MCP tool:

   ```javascript
   mcp__github__merge_pull_request(
     owner: owner,
     repo: repo,
     pullNumber: pr.number,
     merge_method: "squash"
   )
   ```

2. If merge succeeds:
   - Output: `✓ MERGED: #NNN - <PR title>`
   - Add to merged count

3. If merge fails:
   - Check error message:
     - If "already merged" or "closed": Skip silently (idempotent)
     - If "merge conflicts": Output
       `✗ MERGE CONFLICT: #NNN - <PR title> (needs manual resolution)`
     - If "required reviews": Output
       `✗ NEEDS REVIEW: #NNN - <PR title> (awaiting approvals)`
     - Other errors: Output `✗ MERGE FAILED: #NNN - <PR title> (<error reason>)`
   - Continue processing

**IF FAILING → Request rebase**:

1. Use MCP tool:

   ```javascript
   mcp__github__update_pull_request_branch(
     owner: owner,
     repo: repo,
     pullNumber: pr.number
   )
   ```

2. If rebase succeeds:
   - Output:
     `↻ REBASED: #NNN - <PR title> (builds were failing, requested update)`
   - Add to rebased count

3. If rebase fails:
   - Output: `✗ REBASE FAILED: #NNN - <PR title> (<error reason>)`
   - Continue processing

**IF PENDING → Skip**:

1. Output: `⏳ PENDING: #NNN - <PR title> (checks still running)`
2. Add to pending count
3. Continue to next PR

**Step 2.5**: Report non-dependabot PRs

If there are other (non-dependabot) PRs:

Output section header:

```text
Other Open PRs:
```

For each non-dependabot PR:

```text
  → #NNN - <PR title> (@<author>)
    <PR URL>
```

**Step 2.6**: Display repository summary

Output:

```text
Summary: N PRs (X dependabot, Y other) | A merged, B rebased, C pending
```

Where:

- N = total PRs
- X = dependabot PRs
- Y = other PRs
- A = merged count
- B = rebased count
- C = pending count

### Phase 3: Final Summary

**Step 3.1**: Display overall summary

Output:

```text
============================================
SCAN COMPLETE
============================================

Total: N repositories processed
Actions: A merged, B rebased, C pending
```

**Step 3.2**: Provide guidance

If any actions were taken (merged or rebased):

```text
Dependabot PRs have been automatically managed.
- Merged PRs will appear in your repository shortly
- Rebased PRs will trigger new builds
```

If no actions taken:

```text
No dependabot PRs required action at this time.
```

## Error Handling

**Repository-level errors**:

- Repository not found → Skip and continue
- No access permissions → Skip and continue
- API rate limit → Pause and warn user
- Network timeout → Retry up to 3 times

**PR-level errors**:

- Merge conflict → Report and skip (manual resolution needed)
- Required reviews not met → Report and skip
- Protected branch rules → Report and skip
- PR already merged → Skip silently
- API errors → Report and continue

**General principle**: Continue processing on errors. Don't fail the entire
batch.

## Notes

- **Idempotent**: Safe to run multiple times. Already-merged PRs are skipped.
- **Squash merge**: Uses squash merge to keep clean history for dependency
  updates.
- **Security**: Only merges when ALL required checks pass. Never force-merges.
- **Rate limiting**: Be mindful of GitHub API rate limits with many repos/PRs.
- **MCP tools**: All write operations use MCP tools (bash gh commands blocked by
  hooks).

## Troubleshooting

**"Repository not accessible"**:

- Check repository exists and you have access
- Verify repository name format (owner/repo)

**"Merge failed - required reviews"**:

- Repository has branch protection requiring reviews
- Manual approval needed before merge

**"API rate limit exceeded"**:

- Wait 1 hour or use token with higher limits
- Process fewer repositories at a time

**"No repositories found"**:

- Check that git repositories exist in /workspace/sandbox/
- Verify repositories have GitHub remotes configured
