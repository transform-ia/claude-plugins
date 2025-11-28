---
description: "Full release workflow: /github:release <version>"
allowed-tools: [Bash, Read, Edit, Write]
---
Execute a full release workflow with version bump, build monitoring, and deployment.

**Usage**: `/github:release <version>`

**Examples**:
```
/github:release 1.2.0
/github:release patch    # Auto-bump patch version
/github:release minor    # Auto-bump minor version
```

## Full Release Workflow

### Phase 1: Prepare Release

1. **Determine version**:
   - If `patch`/`minor`/`major`: Calculate from current version
   - If explicit version: Use provided value

2. **Update version files** (detect project type):
   - **Go**: Update `version` in relevant files
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

5. **Wait for GitHub Actions**:
   ```bash
   # Get workflow run ID
   gh run list --limit 1 --json databaseId --jq '.[0].databaseId'

   # Watch build progress
   gh run watch <run-id>
   ```

6. **Verify build success**:
   ```bash
   gh run view <run-id> --json conclusion --jq '.conclusion'
   ```

### Phase 3: Update Dependencies (if applicable)

7. **Check for related Helm chart**:
   - Look for chart that uses this image
   - Common patterns:
     - `<project>-chart` for `<project>-image`
     - Charts in same organization

8. **If Helm chart exists**:
   ```bash
   # Update image tag in values.yaml or Chart.yaml appVersion
   # Update Chart.yaml version
   # Commit, tag, push
   # Wait for chart build
   ```

### Phase 4: Deploy (if ArgoCD Application exists)

9. **Check for ArgoCD Application**:
   ```bash
   ls /workspace/applications/<project>*.yaml
   ```

10. **If Application exists**:
    ```bash
    # Update targetRevision in Application
    # Commit and push
    # ArgoCD auto-syncs
    ```

## Version Detection

| Project Type | Version Location |
|--------------|------------------|
| Go | `go.mod` module version, or constants file |
| Node.js | `package.json` "version" field |
| Helm | `Chart.yaml` "version" and "appVersion" |
| Generic | Git tags |

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

- **Build fails**: Show failed job logs, do not proceed
- **No workflow found**: Warn but continue (might not use Actions)
- **Network timeout**: Retry with backoff

## Notes

- Uses MCP GitHub tools where possible
- Falls back to `gh` CLI for Actions monitoring
- Respects `.github/workflows/` configuration
- Does not force push or modify protected branches
