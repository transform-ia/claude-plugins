# GitHub Build Monitoring Guidelines

## Purpose

Monitor GitHub Actions workflow runs, check build status, and debug CI/CD failures.

## Available Commands

| Command | Purpose |
|---------|---------|
| `/github:status [repo]` | List recent workflow runs |
| `/github:logs <run-id>` | Get logs for a run |

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

## MCP GitHub Tools

Use MCP tools when available:

```
mcp__github__list_pull_requests
mcp__github__pull_request_read
mcp__github__search_issues
```

Note: MCP GitHub doesn't currently support Actions API, so use gh CLI for workflow queries.

## Output Format

Present workflow status clearly:

```
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

| Error Pattern | Likely Cause |
|---------------|--------------|
| `golangci-lint` | Go code issues |
| `hadolint` | Dockerfile issues |
| `yamllint` | YAML formatting |
| `helm lint` | Chart structure |
| `npm test` | Node.js test failures |
| `permission denied` | GITHUB_TOKEN scope |
