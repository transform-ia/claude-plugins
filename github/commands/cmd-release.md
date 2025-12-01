---
description: "Full release workflow: /github:cmd-release <version>"
allowed-tools: [Read, Edit, Write, Bash, Bash(git *), Bash(tree *)]
---

# GitHub Release

## Permissions

This command can modify:
- `.github/workflows/ci.yaml`
- `.github/workflows/build.yaml`
- `.github/dependabot.yaml`
- `.github/PULL_REQUEST_TEMPLATE/*.md`
- Git repository state (commits and tags via git commands)

Note: Version files (package.json, Chart.yaml, go.mod) are NOT modified by this command.
The git tag itself serves as the version source.

This is the ONLY command that can execute git operations in the GitHub plugin.

---

## Parameter Validation

**REQUIRED**: If `$ARGUMENTS` is empty or does not contain a version, respond
with: "Error: version required. Usage: /github:cmd-release <version>" and STOP. Do
not proceed with any tool calls.

---

Execute a full release workflow with version bump, build monitoring, and
deployment.

**Usage**: `/github:cmd-release <version>`

**Examples**:

```text
/github:cmd-release 1.2.0
/github:cmd-release patch    # Auto-bump patch version
/github:cmd-release minor    # Auto-bump minor version
```

## Full Release Workflow

### Phase 1: Prepare Release

1. **Determine version**:
   - If `patch`/`minor`/`major`: Calculate from current version
   - If explicit version: Use provided value

2. **Update version files** (if applicable to current project):
   - **Go**: Update version constants/files
   - **Node.js**: Update `package.json` version
   - **Helm**: Update `Chart.yaml` version
   - **Docker**: Tag will be created from git tag

3. **Commit version bump**:

   ```bash
   git add -A
   git commit -m "Bump version to $VERSION"
   ```

4. **Create and push tag**:

   ```bash
   git tag "v$VERSION"
   git push origin HEAD --tags
   ```

### Phase 2: Monitor Build

1. **Wait for GitHub Actions trigger** (10 second delay)

2. **Watch build progress**:

   ```bash
   # Get latest workflow run ID
   gh run list --limit 1 --json databaseId --jq '.[0].databaseId'

   # Watch build progress
   gh run watch <run-id> --exit-status
   ```

3. **Report result**:
   - ✅ Build succeeded: Report tag and image/artifact location
   - ❌ Build failed: Show failure logs and exit

### Post-Release Actions

**The GitHub plugin stops here.** For downstream releases:
- **Helm chart updates**: Use `/helm:cmd-release` in chart repository
- **ArgoCD deployment**: Use orchestrator plugin or manual Application update
- **Multi-repo orchestration**: Use orchestrator plugin workflows

This keeps each plugin focused on its domain and prevents coupling.

## Version Detection

**For the current project only:**

| Project Type | Version Location                           |
| ------------ | ------------------------------------------ |
| Go           | `go.mod` module version, or constants file |
| Node.js      | `package.json` "version" field             |
| Helm         | `Chart.yaml` "version" and "appVersion"    |
| Generic      | Git tags                                   |

## Build Monitoring

The command monitors GitHub Actions builds using the `gh` CLI:

```bash
# List recent workflow runs
gh run list --limit 5

# Watch specific run
gh run watch <run-id>

# Get run status
gh run view <run-id> --json status,conclusion

# Get failed job logs
gh run view <run-id> --log-failed
```

## Error Handling

- **Build fails**: Show failed job logs and exit with error
- **No workflow found**: Warn but continue (project might not use Actions)
- **Network timeout**: Retry with backoff
- **Tag already exists**: Fail with clear error message

## Notes

- Uses MCP GitHub tools where possible
- Falls back to `gh` CLI for Actions monitoring
- Respects `.github/workflows/` configuration
- Does not force push or modify protected branches
