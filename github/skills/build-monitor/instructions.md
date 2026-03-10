# GitHub Build Monitoring

## Available

- **Read** - `.github/**/*` files
- **Glob/Grep** - File search
- **Bash** - `gh run/workflow` (list, view, watch), `gh pr` (view, list,
  checks), `gh api` (GET only)

## Not Available

Write/Edit, `gh api` mutations (POST/PUT/DELETE)

## Purpose

Monitor GitHub Actions workflow runs, check build status, and debug CI/CD
failures.

## Available Commands

| Command                     | Purpose                   |
| --------------------------- | ------------------------- |
| `/github:workflow-status [repo]` | List recent workflow runs |
| `/github:logs <run-id>`         | Get logs for a run        |

## gh CLI Commands

```bash
# List recent workflow runs
gh run list --repo OWNER/REPO --limit 5

# Filter by status
gh run list --repo OWNER/REPO --status failure

# Filter by workflow
gh run list --repo OWNER/REPO --workflow "CI"

# View specific run
gh run view RUN_ID --repo OWNER/REPO

# View logs
gh run view RUN_ID --repo OWNER/REPO --log

# View failed logs only
gh run view RUN_ID --repo OWNER/REPO --log-failed

# Watch running workflow
gh run watch RUN_ID --repo OWNER/REPO
```

## Output Format

Present workflow status clearly:

```text
Repository: transform-ia/hooks
Latest Workflow Runs:

✓ #123 - CI (main) - success - 2m ago
  Commit: abc1234 "Update dependencies"

✗ #122 - CI (feature/auth) - failure - 1h ago
  Commit: def5678 "Add authentication"
  Error: golangci-lint failed

◷ #121 - Build (main) - in_progress - running
  Commit: ghi9012 "Bump version"
```

## Common Debugging Steps

1. **List recent runs:** `gh run list --repo OWNER/REPO --limit 5`
2. **Find failed runs:** `gh run list --repo OWNER/REPO --status failure`
3. **Get run details:** `gh run view RUN_ID --repo OWNER/REPO`
4. **View failed logs:** `gh run view RUN_ID --repo OWNER/REPO --log-failed`
5. **Analyze errors:** Look for specific lint/test failures
6. **Suggest fixes:** Based on error patterns

## Error Patterns

| Error Pattern       | Likely Cause          |
| ------------------- | --------------------- |
| `golangci-lint`     | Go code issues        |
| `hadolint`          | Dockerfile issues     |
| `yamllint`          | YAML formatting       |
| `helm lint`         | Chart structure       |
| `npm test`          | Node.js test failures |
| `permission denied` | GITHUB_TOKEN scope    |

## Repository Detection

When user doesn't specify a repository, detect from git remote:

```bash
cd ~/sandbox/transform-ia/hooks
git remote get-url origin
# https://github.com/transform-ia/hooks
# → Use transform-ia/hooks
```

## Auto-Watch After Tag Push

After pushing a tag, automatically watch the triggered workflow:

```bash
# Tag and push
git tag v1.0.0
git push origin v1.0.0

# Wait for workflow trigger
sleep 10

# Get latest run ID and watch
RUN_ID=$(gh run list --repo OWNER/REPO --limit 1 --json databaseId --jq '.[0].databaseId')
gh run watch $RUN_ID --repo OWNER/REPO --exit-status
```

## Out of Scope - Bail Out Immediately

**If the request does NOT involve build status or workflow monitoring, STOP and
report:**

"This request is outside my scope. I handle GitHub Actions monitoring only:

- Querying workflow runs
- Checking build status
- Viewing workflow logs

For workflow file editing, use `/github:cicd`. For other operations, use
the appropriate plugin."
