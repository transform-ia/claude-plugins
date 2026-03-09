# GitHub Plugin

Automate GitHub workflows, CI/CD, releases, and dependency management.

## Commands

### /github:cmd-status

Check GitHub Actions workflow status for a repository.

**Usage:**

```bash
/github:cmd-status [owner/repo] [limit]
```

**Examples:**

```bash
/github:cmd-status transform-ia/hooks
/github:cmd-status transform-ia/hooks 10
```

**What it does:**

- Lists recent workflow runs using `gh run list`
- Shows status, conclusion, and timing
- Auto-detects repo from git remote if not specified

---

### /github:cmd-logs

Get workflow logs for a specific GitHub Actions run.

**Usage:**

```bash
/github:cmd-logs <run-id> [owner/repo]
```

**Examples:**

```bash
/github:cmd-logs 123456789
/github:cmd-logs 123456789 transform-ia/hooks
```

**What it does:**

- Retrieves logs for failed workflows
- Auto-detects repo from git remote if not specified
- Falls back to `gh run view` if logs unavailable

---

### /github:cmd-lint

Lint `.github/` workflow files using yamllint and prettier.

**Usage:**

```bash
/github:cmd-lint [directory]
```

**Examples:**

```bash
/github:cmd-lint .github/workflows
/github:cmd-lint
```

**What it does:**

- Validates YAML syntax with yamllint
- Formats files with prettier
- Reports any linting errors

---

### /github:cmd-latest-version

Get the latest semantic version tag from a git repository.

**Usage:**

```bash
/github:cmd-latest-version <path>
```

**Examples:**

```bash
/github:cmd-latest-version ~/projects/my-project
/github:cmd-latest-version .
```

**What it does:**

- Returns highest semantic version tag (e.g., v0.2.0 from v0.1.0, v0.1.1,
  v0.2.0)
- Uses proper semantic version sorting (v0.10.0 > v0.9.0)
- Returns v0.0.0 if no semantic version tags exist
- Only considers tags matching pattern: v?X.Y.Z
- READ-ONLY operation, no modifications made

---

### /github:cmd-release

Execute a full release workflow with version bump, tagging, and build
monitoring.

**Usage:**

```bash
/github:cmd-release <version>
```

**Examples:**

```bash
/github:cmd-release 1.2.0
/github:cmd-release patch    # Auto-bump patch version
/github:cmd-release minor    # Auto-bump minor version
```

**What it does:**

- Determines version (explicit or auto-bump)
- Updates version files (go.mod, package.json, Chart.yaml)
- Creates git commit and tag
- Pushes to remote and triggers build
- Monitors build progress until completion
- Reports build success or failure

**Note:** Only command that can execute git operations in GitHub plugin.

---

### /github:cmd-dependabot

Automatically manage dependabot pull requests across repositories.

**Usage:**

```bash
/github:cmd-dependabot [REPONAME]
```

**Examples:**

```bash
/github:cmd-dependabot transform-ia/claude-plugins  # Process single repo
/github:cmd-dependabot                              # Process all repos
```

**What it does:**

- Discovers all GitHub repositories (or processes specified repo)
- Identifies dependabot PRs
- **Auto-merges** PRs with passing builds (squash merge)
- **Rebases** PRs with failing builds to trigger new builds
- **Reports** PRs with pending builds
- **Lists** all other open PRs with links

**Safety:**

- Only merges when ALL required checks pass
- Uses `gh` CLI for GitHub API operations
- Idempotent (safe to run multiple times)
- Continues processing on errors

**When to use:**

- Daily dependabot maintenance
- After CI fixes to clear backlog
- Before releases to ensure dependencies are current

---

## Skills

### github:skill-dev

GitHub CI/CD workflow development and maintenance.

**Capabilities:**

- Create and modify `.github/workflows/*.yaml` files
- Configure Dependabot
- Set up CI/CD pipelines
- Implement build, test, and deployment workflows

**Tools:** Read, Write(.github/*), Edit(.github/*), Bash(gh *), Bash(rm .github/*)

---

### github:skill-builder

GitHub Actions build monitoring and status checking.

**Capabilities:**

- Monitor build progress
- Check workflow status
- Retrieve build logs
- Diagnose build failures

**Tools:** Read, Bash(gh run \*), Bash(gh workflow \*), Bash(gh pr \*), Bash(gh api \*)

---

## Agents

### github:agent-dev

Development agent for GitHub workflows and CI/CD.

**When activated:**

- Creating new GitHub workflows
- Modifying existing CI/CD pipelines
- Setting up Dependabot configuration
- Implementing build automation

---

### github:agent-builder

Build monitoring agent for GitHub Actions.

**When activated:**

- Checking build status
- Investigating build failures
- Monitoring releases
- Tracking deployment progress

---

## Architecture

### Security Model

**File Restrictions:**

- Can ONLY modify files in `.github/` directory
- Enforced by `enforce-github-files.sh` hook

**Bash Command Restrictions:**

- Git commands ONLY allowed in `/github:cmd-release`
- `gh` write operations (merge, create, edit) blocked
- Only read operations allowed: list, view, watch, status
- Enforced by `block-bash.sh` hook

**gh CLI:**

- Used for all GitHub API operations
- Provides structured JSON output with `--json` flag

### Workflow Pattern

**Simple commands** (status, logs, lint):

- Use dedicated bash scripts in `scripts/`
- Read-only `gh` CLI operations
- Fast execution

**Complex commands** (release, dependabot):

- Embed workflow in command .md file
- `gh` CLI operations
- Multi-phase orchestration

### Hook System

**Pre-tool-use hooks:**

- `enforce-github-files.sh` - File write restrictions
- `block-bash.sh` - Bash command restrictions

**Purpose:**

- Security enforcement
- Prevent accidental modifications outside scope
- Ensure proper tool usage

---

## Development

### Adding a New Command

1. Create `/commands/cmd-<name>.md`:

   ```yaml
   ---
   description: "Brief description: /github:cmd-<name> <args>"
   allowed-tools: [Bash(${CLAUDE_PLUGIN_ROOT}/scripts/cmd-<name>.sh *), Read]
   ---
   # Command Title

   [Instructions for Claude]
   ```

2. For simple commands, create `/scripts/cmd-<name>.sh`:

   ```bash
   #!/bin/bash
   set -euo pipefail

   # Script implementation
   ```

3. For complex commands, embed workflow in .md file

4. Test command invocation

5. Update this README

### Testing

Run individual commands:

```bash
/github:cmd-status transform-ia/hooks
/github:cmd-lint .github/workflows
/github:cmd-dependabot transform-ia/claude-plugins
```

Run tests:

```bash
cd github/tests
./run-tests.sh
```

---

## Integration

### With Other Plugins

- **helm**: `/helm:cmd-release` for chart releases after GitHub release
- **docker**: Docker image builds triggered by GitHub workflows

### With GitHub

- **Authentication**: Uses `gh` CLI authentication
- **API**: `gh api` provides direct GitHub API access
- **Actions**: Monitors workflows via GitHub Actions API
- **Dependabot**: Manages PRs via GitHub API

---

## Troubleshooting

### "Unknown slash command"

**Cause:** Plugin not loaded or command file not discovered **Solution:**
Restart Claude Code to reload plugins

### "BLOCKED: git commands only allowed in /github:cmd-release"

**Cause:** Attempting git operations outside release workflow **Solution:** Use
`/github:cmd-release` for version tagging and releases

### "Repository not accessible"

**Cause:** Repository doesn't exist or no access **Solution:** Check repo name
format (owner/repo) and permissions

### "API rate limit exceeded"

**Cause:** Too many GitHub API calls **Solution:** Wait 1 hour or use
authenticated token with higher limits

---

## References

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Dependabot Documentation](https://docs.github.com/en/code-security/dependabot)
- [GitHub CLI Documentation](https://cli.github.com/)
- [Claude Code Plugin Framework](../../GLOSSARY.md)
