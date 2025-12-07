---
description:
  "Delete tag and artifacts: /github:cmd-delete-tag <tag> [directory]"
allowed-tools: [Bash]
---

# GitHub Delete Tag

## Permissions

This command can modify:

- Local git repository (delete local tag)
- Remote git repository (delete remote tag)
- GitHub Container Registry (delete Docker images)
- GitHub Releases (delete release if exists)

This is a DESTRUCTIVE operation that cannot be undone.

## Parameter Validation

**REQUIRED**: `<tag>` must be provided (with or without 'v' prefix)

**OPTIONAL**: `[directory]` - Path to repository (defaults to current directory)

---

Delete a git tag locally, remotely, and clean up associated artifacts (Docker
images, Helm charts).

**Usage**: `/github:cmd-delete-tag <tag> [directory]`

**Examples**:

```text
/github:cmd-delete-tag v1.0.0                    # Delete v1.0.0 in current directory
/github:cmd-delete-tag 1.0.0                     # Delete v1.0.0 (auto-adds 'v' prefix)
/github:cmd-delete-tag v1.0.0 /path/to/repo      # Delete tag in specific directory
```

## Delete Tag Workflow

### Phase 1: Repository Detection

1. **Change to directory** (if provided)
2. **Detect repository from git remote**:
   - Extract `owner/repo` from remote URL
   - Validate it's a GitHub repository

### Phase 2: Tag Validation

1. **Check if tag exists**:
   - Locally: `git tag -l <tag>`
   - Remotely: `git ls-remote --tags origin <tag>`
2. **If tag doesn't exist**: Warn and exit (not an error)

### Phase 3: Delete Tag

1. **Delete remote tag first**:

   ```bash
   git push --delete origin <tag>
   ```

2. **Delete local tag**:

   ```bash
   git tag -d <tag>
   ```

3. **Delete GitHub release** (if exists):

   ```bash
   gh release delete <tag> --repo <owner>/<repo> --yes
   ```

### Phase 4: Delete Artifacts (Docker/Helm only)

1. **Detect project type**:
   - Check for `Dockerfile` → Docker project
   - Check for `Chart.yaml` → Helm project
   - Otherwise → No artifacts to delete

2. **For Docker projects**:
   - Find image version ID in GHCR
   - Delete the image version
   - Extract version without 'v' prefix for image tag

3. **For Helm projects**:
   - Find chart version ID in GHCR
   - Delete the chart version
   - Extract version without 'v' prefix for chart tag

4. **Report results**:
   - ✅ Artifacts deleted successfully
   - ⚠️ Artifacts not found (may have been already deleted)
   - ℹ️ No artifacts (not a Docker/Helm project)

## Error Handling

- **Tag doesn't exist**: Warning message, exit successfully
- **Not a git repository**: Error and stop
- **No remote configured**: Error and stop
- **Artifact not found**: Warning (continue, may have been manually deleted)
- **Permission denied**: Error with instructions

## Notes

- Always deletes remote tag before local tag (safer)
- GitHub release deletion is best-effort (no error if doesn't exist)
- Artifact deletion only for Docker/Helm projects
- Requires `packages: write` permission for artifact deletion

## Execution

```text
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/cmd-delete-tag.sh $ARGUMENTS")
```
