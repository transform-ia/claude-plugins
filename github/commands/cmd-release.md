---
description: "Full release workflow: /github:cmd-release <version>"
allowed-tools: [Bash(${CLAUDE_PLUGIN_ROOT}/scripts/cmd-release.sh *), SlashCommand(/github:cmd-build)]
---

# GitHub Release

## Permissions

This command can modify:

- `.github/workflows/ci.yaml`
- `.github/dependabot.yaml`
- `.github/PULL_REQUEST_TEMPLATE/*.md`
- Git repository state (commits and tags via git commands)

Note: Version files (package.json, Chart.yaml, go.mod) are NOT modified by this
command. The git tag itself serves as the version source.

This is the ONLY command that can execute git operations in the GitHub plugin.

---

## Parameter Validation

**REQUIRED**: If `$ARGUMENTS` is empty or does not contain a version, respond
with: "Error: version required. Usage: /github:cmd-release `<version>`" and STOP.
Do not proceed with any tool calls.

---

Execute a full release workflow with version bump, build monitoring, and
deployment.

**Usage**: `/github:cmd-release [directory] <version>`

**Examples**:

```text
/github:cmd-release 1.2.0                                    # Explicit version in current dir
/github:cmd-release patch                                    # Auto-bump patch version
/github:cmd-release minor                                    # Auto-bump minor version
/github:cmd-release major                                    # Auto-bump major version
/github:cmd-release auto                                     # Auto-detect from files or commits
/github:cmd-release /path/to/project patch                   # Release project in specific directory
/github:cmd-release ~/my-app auto                            # Auto-detect version for specific project
```

## Full Release Workflow

### Phase 1: Auto-commit Changes

**This command automatically handles uncommitted files for you.**

1. **Check for uncommitted changes**:
   - If changes exist: Automatically stage all files with `git add .`
   - Generate descriptive commit message based on changed files
   - Commit: `git commit -m "Release v$VERSION: <description>"`
   - If no changes: Skip commit and proceed to tagging

No need to commit manually before running this command - it handles that for
you.

### Phase 2: Determine Version

**The command first determines the current version from the latest git tag**,
then bumps it based on your argument.

1. **Current version detection**:
   - Finds latest git tag (e.g., `v1.2.3`)
   - Strips `v` prefix to get version number
   - If no tags exist, assumes `0.0.0`

2. **Version bump based on argument**:
   - `patch`: Bumps `1.2.3` → `1.2.4` (bug fixes)
   - `minor`: Bumps `1.2.3` → `1.3.0` (new features)
   - `major`: Bumps `1.2.3` → `2.0.0` (breaking changes)
   - `auto`: Smart detection (see below)
   - Explicit (e.g., `1.5.0`): Uses exactly what you provide

3. **Auto-detection priority** (when using `auto`):
   - **Priority 1**: If `Chart.yaml` or `package.json` has a version different
     from current tag, use that
   - **Priority 2**: Analyze conventional commits since last tag (`feat:` =
     minor, `fix:` = patch, `BREAKING:` = major)
   - **Priority 3**: Ask user if cannot determine

4. **Note**: Version files (Chart.yaml, package.json) are NOT modified by this
   command. If you want to use the version from those files, update them first,
   then run `/github:cmd-release auto`.

### Phase 3: Create and Push Tag

1. **Validate version**:
   - Check that tag doesn't already exist
   - Fail early if tag exists

2. **Create and push tag**:

   ```bash
   git tag "v$VERSION"
   git push origin HEAD --tags
   ```

### Phase 4: Monitor Build

**Automatically calls `/github:cmd-build` to wait for all workflows to
complete.**

1. **Build monitoring** (via `/github:cmd-build`):
   - Pushes code and tags to origin
   - Waits for GitHub Actions to trigger workflows
   - Monitors ALL workflows for this commit in parallel
   - Waits indefinitely (no timeout) until all complete
   - Shows real-time status of each workflow

2. **Report result**:
   - ✅ All workflows passed: Success with tag and repository info
   - ❌ Any workflow failed: Shows which workflows failed, their logs, and exits
     with error

### Post-Release Actions

**The GitHub plugin stops here.** For downstream releases:

- **Helm chart updates**: Use `/helm:cmd-release` in chart repository
- **Deployment**: Use standard deployment workflow
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

- Uses `gh` CLI for Actions monitoring
- Calls `/github:cmd-build` for build monitoring
- Respects `.github/workflows/` configuration
- Does not force push or modify protected branches
- Version files should be updated manually before running this command

## Execution

```text
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/cmd-release.sh $ARGUMENTS")
```

Where `$ARGUMENTS` can be:

- Just `<version>` (operates in current directory)
- `<directory> <version>` (changes to directory first)
