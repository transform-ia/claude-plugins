---
description: "Upgrade Helm charts: /helm:cmd-upgrade [directory]"
allowed-tools:
  [
    Bash,
    Read,
    Edit,
    Glob,
    Grep,
    Task,
    TodoWrite,
    AskUserQuestion,
    mcp__dockerhub__*,
    mcp__github__*,
  ]
---

# Helm Chart Upgrade

## Permissions

This command can modify:

- `Chart.yaml` - appVersion, version, and dependency versions
- `values.yaml`, `values-*.yaml` - image tags and repository references

---

## Parameter Handling

- `$ARGUMENTS` specifies the directory to scan (default: `/workspace/sandbox`)
- Scan recursively for all Helm chart directories

---

## Upgrade Workflow

### Phase 1: Discovery

Scan the target directory for Helm charts:

```text
Glob("**/Chart.yaml", path="$ARGUMENTS")
```

For each Chart.yaml found, identify the chart directory and related files:

- `Chart.yaml` - Chart metadata, appVersion, dependencies
- `values.yaml` - Default values with image references
- `values-*.yaml` - Environment-specific overrides

### Phase 2: Analysis

For each discovered chart, extract current versions:

**Chart.yaml - appVersion and dependencies:**

```text
Read(file_path="<chart>/Chart.yaml")
```

Extract:

- `appVersion` - Application/image version
- `version` - Chart version
- `dependencies[].version` - Dependency chart versions
- `dependencies[].repository` - Dependency sources

**values.yaml - Image references:**

```text
Grep(pattern="(image:|repository:|tag:)", path="<chart>/values.yaml", output_mode="content", -C=2)
```

Look for patterns:

```yaml
image:
  repository: ghcr.io/org/app
  tag: "1.0.0"
```

### Phase 3: Version Lookup

For each unique image/chart, query the latest available version:

**Docker Hub images:**

```javascript
mcp__dockerhub__listRepositoryTags({
  namespace: "<namespace>",
  repository: "<image>",
  page_size: 5,
});
```

**GHCR images:**

```text
Bash("${CLAUDE_PLUGIN_ROOT}/../docker/scripts/cmd-image-tag.sh ghcr.io/<org>/<repo>")
```

**GitHub releases (for chart dependencies):**

```javascript
mcp__github__list_tags({
  owner: "<org>",
  repo: "<repo>",
  perPage: 5,
});
```

**Helm repository charts:**

```text
Bash("helm search repo <repo>/<chart> --versions | head -5")
```

### Phase 4: Report Generation

Create a structured report showing:

**Chart Versions:**

| Chart        | Field      | Current | Latest | Action     |
| ------------ | ---------- | ------- | ------ | ---------- |
| myapp-chart  | appVersion | 1.0.0   | 1.2.0  | Upgrade    |
| myapp-chart  | version    | 0.1.0   | 0.1.0  | Up-to-date |
| common-chart | dependency | 0.5.0   | 0.6.0  | Upgrade    |

**Image References in values.yaml:**

| Chart       | Image           | Current | Latest | Action  |
| ----------- | --------------- | ------- | ------ | ------- |
| redis-chart | redis           | 7.2.0   | 7.4.0  | Upgrade |
| app-chart   | ghcr.io/org/app | v1.0.0  | v1.2.0 | Upgrade |

### Phase 5: User Confirmation

Use AskUserQuestion to confirm upgrade scope:

```javascript
AskUserQuestion({
  questions: [
    {
      question: "Which versions should be upgraded?",
      header: "Scope",
      options: [
        {
          label: "All outdated",
          description: "Upgrade appVersion, dependencies, and image tags",
        },
        {
          label: "appVersion only",
          description: "Only upgrade application versions in Chart.yaml",
        },
        {
          label: "Dependencies only",
          description: "Only upgrade chart dependency versions",
        },
        {
          label: "Images only",
          description: "Only upgrade image tags in values.yaml",
        },
        { label: "None", description: "Generate report only, no changes" },
      ],
      multiSelect: false,
    },
    {
      question: "Should chart version be bumped after upgrades?",
      header: "Versioning",
      options: [
        {
          label: "Patch bump",
          description: "Increment patch version (0.1.0 → 0.1.1)",
        },
        {
          label: "Minor bump",
          description: "Increment minor version (0.1.0 → 0.2.0)",
        },
        { label: "No bump", description: "Keep current chart version" },
      ],
      multiSelect: false,
    },
  ],
});
```

### Phase 6: Apply Updates

Based on user selection, apply updates using the Edit tool:

**Chart.yaml appVersion:**

```text
Edit(file_path="<path>", old_string="appVersion: \"<old>\"", new_string="appVersion: \"<new>\"")
```

**Chart.yaml version (bump):**

```text
Edit(file_path="<path>", old_string="version: <old>", new_string="version: <new>")
```

**Chart.yaml dependencies:**

```text
Edit(file_path="<path>", old_string="version: \"<old>\"", new_string="version: \"<new>\"")
```

**values.yaml image tags:**

```text
Edit(file_path="<path>", old_string="tag: \"<old>\"", new_string="tag: \"<new>\"")
```

---

## Version Standards

Follow these rules from the helm:skill-dev instructions:

### NEVER

- Use `latest` tag - always pin to specific versions
- Use `pullPolicy: Always` - use `IfNotPresent`
- Leave appVersion empty when a specific version is known

### ALWAYS

- Pin to full semantic versions: `1.2.3`, `v1.2.3`
- Use `.Chart.AppVersion` as default image tag in templates
- Bump chart `version` when making changes
- Keep values.yaml minimal - only user-overridable values

### Version Formats

**appVersion (application/image version):**

- Semantic version: `1.2.3` or `v1.2.3`
- Must match the Docker image tag
- Quoted string in YAML: `appVersion: "1.2.3"`

**version (chart version):**

- Semantic version: `0.1.0`
- Unquoted in YAML: `version: 0.1.0`
- Bump on any chart change

**Dependency versions:**

- Match the dependency chart's version field
- Use `~X.Y.0` for minor version ranges if needed
- Prefer exact versions for reproducibility

---

## Supported Patterns

### Chart.yaml

```yaml
apiVersion: v2
name: myapp
version: 0.1.0
appVersion: "1.2.3"
dependencies:
  - name: common
    version: "0.5.0"
    repository: "https://charts.example.com"
  - name: redis
    version: "18.0.0"
    repository: "https://charts.bitnami.com/bitnami"
```

### values.yaml

```yaml
# Standard image block
image:
  repository: ghcr.io/org/myapp
  tag: "" # Defaults to .Chart.AppVersion
  pullPolicy: IfNotPresent

# External service images
redis:
  image:
    repository: redis
    tag: "7.2.0"

postgres:
  image:
    repository: postgres
    tag: "16.0"

# Inline image reference
sidecar:
  image: busybox:1.36.0
```

### Environment-specific values (values-prod.yaml)

```yaml
image:
  tag: "1.2.3-prod"

redis:
  image:
    tag: "7.2.0-alpine"
```

---

## Dependency Upgrade Workflow

For charts with dependencies:

1. **List current dependencies:**

   ```text
   Grep(pattern="dependencies:", path="<chart>/Chart.yaml", -A=20, output_mode="content")
   ```

2. **Check Helm repository for updates:**

   ```text
   Bash("helm repo update && helm search repo <repo>/<chart> --versions | head -3")
   ```

3. **Update dependency version in Chart.yaml**

4. **Rebuild dependency lock:**

   ```text
   Bash("helm dependency update <chart-path>")
   ```

---

## Post-Upgrade Validation

After applying upgrades:

1. **Lint the chart:**

   ```text
   /helm:cmd-lint <chart-path>
   ```

2. **Template validation:**

   ```text
   /helm:cmd-template <chart-path>
   ```

3. **Check for unused values:**

   ```text
   /helm:cmd-check-unused-values <chart-path>
   ```

---

## Error Handling

- **Network errors**: Retry version queries up to 3 times
- **Invalid versions**: Skip and report as warning
- **Missing Chart.yaml**: Skip directory, not a Helm chart
- **Dependency resolution**: Report if helm dependency update fails
- **Parse errors**: Report file path and continue with other charts

---

## Output Format

After completion, provide summary:

```
## Helm Chart Upgrade Summary

### Charts Scanned
- Total charts: 15
- With dependencies: 8

### Updates Applied
- appVersion upgrades: 6
- Dependency upgrades: 4
- Image tag upgrades: 12
- Chart version bumps: 10

### Skipped
- Already up-to-date: 5
- User declined: 2

### Errors
- path/to/chart: Dependency 'common' not found in repository
- path/to/other: Invalid version format in values.yaml

### Next Steps
1. Run `/helm:cmd-lint` on updated charts
2. Run `helm dependency update` for charts with updated dependencies
3. Test with `/helm:cmd-template` to verify rendering
4. Commit changes to git
5. Monitor ArgoCD sync for deployed charts
```

---

## Integration with Docker Upgrade

For comprehensive image upgrades across the codebase, combine with:

```text
/docker:cmd-upgrade <directory>
```

This ensures both Dockerfiles and Helm charts reference the same image versions.
