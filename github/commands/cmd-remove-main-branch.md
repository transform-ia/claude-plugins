---
description: "Remove main branch: /github:cmd-remove-main-branch [scope]"
allowed-tools: [Bash, Read, AskUserQuestion]
---

# GitHub Remove Main Branch

Migrate repositories from `main` to `master` as the default branch. This command
identifies repositories with `main` as default, merges any changes into `master`,
changes the default branch, and deletes `main`.

## Minimal Output Guidelines

**CRITICAL**: Use `gh` CLI with `--json` and `--jq` for minimal context usage.

**Required patterns:**

- `--limit 200` for all list operations
- `--json` with specific fields only
- `--jq` to filter/transform output

## Permissions

This command can:

- READ: List repositories, branches, compare commits
- WRITE: Create branches, merge branches, change default branch, delete branches

---

## Parameter: Scope (Optional)

The `<scope>` parameter defines which repositories to process. Defaults to all
accessible repositories (personal + all organizations).

**Scope Examples**:

- `org:tournevent` - All repositories in the tournevent organization
- `org:transform-ia` - All repositories in the transform-ia organization
- `transform-ia/hooks` - Single specific repository
- `my repositories` - User's personal repositories only
- _(no argument)_ - All personal + all org repositories

---

**Usage**: `/github:cmd-remove-main-branch [scope]`

**Examples**:

```text
/github:cmd-remove-main-branch
/github:cmd-remove-main-branch org:transform-ia
/github:cmd-remove-main-branch transform-ia/hooks
/github:cmd-remove-main-branch my repositories
```

## Workflow

### Phase 1: Repository Discovery

**Step 1.1**: Run the discovery script

```bash
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/cmd-remove-main-branch.sh discover $ARGUMENTS")
```

This outputs a JSON list of repositories with `main` as the default branch.

**Step 1.2**: Display discovered repositories

Show the user which repositories will be processed and ask for confirmation
if more than 5 repositories.

### Phase 2: Interactive Migration

For each repository in the discovered list:

**Step 2.1**: Display repository status

```text
============================================
Repository: owner/repo
============================================
Default branch: main
Master exists: yes/no
Divergence: identical/ahead/behind/diverged
Open PRs targeting main: N
```

**Step 2.2**: Use AskUserQuestion for confirmation

Ask the user:

```text
Proceed with migration for owner/repo?
Options:
- Yes: Migrate this repository
- No: Skip this repository
- All: Migrate all remaining without asking
- Abort: Stop the entire operation
```

**Step 2.3**: Execute migration (if confirmed)

```bash
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/cmd-remove-main-branch.sh migrate <owner/repo>")
```

The script handles:

1. Creating backup tag
2. Creating master branch (if needed)
3. Merging main into master (if diverged)
4. Changing default branch to master
5. Deleting main branch
6. Verification

### Phase 3: Summary

After processing all repositories, display:

```text
============================================
MIGRATION COMPLETE
============================================

Repositories processed: N
Successfully migrated: X
Skipped: Y
Failed: Z

Failed repositories (if any):
  - owner/repo1: Merge conflict
  - owner/repo2: No admin access

Rollback instructions:
  To restore main branch for a repo, run:
  gh api repos/OWNER/REPO/git/refs -f ref="refs/heads/main" -f sha="BACKUP_SHA"
  gh repo edit OWNER/REPO --default-branch main
```

## Error Handling

**Repository-level errors**:

- No admin access: Skip and report
- Merge conflict: Skip and report with resolution steps
- API errors: Retry once, then skip and report

**Branch-level errors**:

- Branch protection: Report and skip
- Open PRs: Warn user, still proceed if confirmed

**General principle**: Continue processing on errors. Report failures but don't
stop the batch.

## Safety Features

- **Backup tags**: Created before any modifications (`backup-main-YYYYMMDD-HHMMSS`)
- **Interactive mode**: Prompts for each repository by default
- **Verification**: Confirms default branch changed before deleting main
- **Rollback support**: Backup tags allow full recovery

## Troubleshooting

**"No admin access"**:

- You need admin rights to change default branch
- Contact repository owner for access

**"Merge conflict"**:

- main and master have diverged with conflicting changes
- Resolve manually: `git checkout master && git merge main`

**"Branch protection blocks deletion"**:

- Temporarily disable branch protection on main
- Re-run the migration for that repository
