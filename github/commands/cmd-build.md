---
description: "Push and wait for builds: /github:cmd-build [owner/repo]"
allowed-tools: [Bash(${CLAUDE_PLUGIN_ROOT}/scripts/cmd-build.sh *)]
---

# GitHub Build

## Permissions

This command performs git operations (push) and monitors GitHub Actions. It does
NOT modify local files, only pushes existing commits.

## Parameter Validation

**Default values:**

- `[owner/repo]`: Auto-detect from git remote if not provided

**Validation**:

- If auto-detection fails and no repo provided: Error message and stop
- Check for uncommitted changes before pushing

---

Push code and monitor ALL workflow runs until completion.

**Usage**: `/github:cmd-build [owner/repo]`

**Examples**:

```text
/github:cmd-build transform-ia/claude-image
/github:cmd-build  # Auto-detect from git remote
```

## Build Monitoring Workflow

### Phase 1: Pre-flight Checks

1. **Check for uncommitted changes**:
   - If changes exist: Error and stop (user must commit first)
   - If clean: Proceed to push

### Phase 2: Push Code

1. **Push to remote**:

   ```bash
   git push origin HEAD
   ```

### Phase 3: Monitor All Workflows

1. **Wait for GitHub Actions trigger** (10 second delay)

2. **Find all workflow runs** for the pushed commit:

   ```bash
   gh run list --repo <repo> --commit <sha> --json databaseId,workflowName,status,conclusion
   ```

3. **Monitor all runs in parallel**:
   - Watch each workflow using `gh run watch <run-id> --exit-status`
   - No timeout - waits indefinitely for completion
   - Monitors ALL workflows simultaneously

4. **Report results**:
   - ✅ All workflows passed: Success message
   - ❌ Any workflow failed: Show which workflows failed and their logs

## Error Handling

- **Uncommitted changes**: Show git status and stop
- **No workflows found**: Warning (repository might not use Actions)
- **Workflow failures**: Display failed job logs for each failed workflow
- **Repository not detected**: Clear error with usage instructions

## Execution

```text
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/cmd-build.sh $ARGUMENTS")
```
