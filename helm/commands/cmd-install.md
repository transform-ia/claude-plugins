---
description: "Install Helm charts from OCI registry: /helm:cmd-install <chart-name> [release-name]"
allowed-tools: [Bash, Read, AskUserQuestion]
---

# Helm Chart Install

## Permissions

This command installs Helm charts from OCI registry. Does not modify chart files.

---

## Parameter Handling

- `$ARGUMENTS` specifies the chart name and optional release name
- Format: `<chart-name>` or `<chart-name> <release-name>`
- If release name not provided, uses chart name as release name

---

## Installation Workflow

### Phase 1: Authenticate to Registry

Authenticate to GitHub Container Registry (GHCR):

```bash
gh auth token | helm registry login ghcr.io \
  -u $(gh api user -q .login) --password-stdin
```

### Phase 2: Parse Arguments

Extract chart name and release name from `$ARGUMENTS`:

- Chart name: Required (e.g., `golang-chart`, `typescript-chart`)
- Release name: Optional (defaults to chart name without `-chart` suffix)

**Examples:**
- `/helm:cmd-install golang-chart` → installs as `golang-dev`
- `/helm:cmd-install typescript-chart ts-dev` → installs as `ts-dev`
- `/helm:cmd-install graphql-chart` → installs as `graphql-dev`

### Phase 3: Chart Information

Show chart information before installing:

```bash
helm show chart oci://ghcr.io/transform-ia/charts/<chart-name>
```

Display:
- Chart version
- App version
- Description
- Dependencies

### Phase 4: User Confirmation

Use AskUserQuestion to confirm installation:

```javascript
AskUserQuestion({
  questions: [
    {
      question: "Install this chart?",
      header: "Install",
      options: [
        {
          label: "Install with defaults",
          description: "Install chart using default values"
        },
        {
          label: "Specify values file",
          description: "Install with custom values.yaml file"
        },
        {
          label: "Set values inline",
          description: "Provide --set key=value parameters"
        },
        {
          label: "Cancel",
          description: "Do not install"
        }
      ],
      multiSelect: false
    }
  ]
});
```

### Phase 5: Install Chart

Based on user selection:

**Default installation:**

```bash
helm install <release-name> oci://ghcr.io/transform-ia/charts/<chart-name>
```

**With values file:**

```bash
helm install <release-name> oci://ghcr.io/transform-ia/charts/<chart-name> \
  -f /workspace/<path-to-values.yaml>
```

**With inline values:**

```bash
helm install <release-name> oci://ghcr.io/transform-ia/charts/<chart-name> \
  --set key1=value1 --set key2=value2
```

### Phase 6: Verify Installation

After installation, verify the deployment:

```bash
# Check Helm release
helm list

# Check pods
kubectl get pods -l app.kubernetes.io/instance=<release-name>

# Check services
kubectl get svc -l app.kubernetes.io/instance=<release-name>
```

---

## Available Charts

The following charts are available from `oci://ghcr.io/transform-ia/charts/`:

- **golang-chart** - Go development environment with gopls and MCP server
- **typescript-chart** - TypeScript/Node.js environment with language server
- **ansible-chart** - Ansible automation platform with SSH integration
- **graphql-chart** - Hasura GraphQL Engine with PostGIS database

---

## Output Format

After installation, provide summary:

```text
## Helm Chart Installation

### Chart Details
- Chart: <chart-name>
- Version: <version>
- Release: <release-name>
- Namespace: <namespace>

### Installation Status
✓ Chart pulled from OCI registry
✓ Release installed successfully
✓ Pods are running

### Resources Created
- Deployment: <release-name>
- Service: <release-name>
- ConfigMap: <release-name>-config (if applicable)

### Access Information
- Pod: kubectl exec -it deployment/<release-name> -- /bin/sh
- Logs: kubectl logs deployment/<release-name>
- Port-forward: kubectl port-forward deployment/<release-name> <port>:<port>

### Next Steps
1. Verify pod is running: kubectl get pods -l app.kubernetes.io/instance=<release-name>
2. Check logs for errors: kubectl logs deployment/<release-name>
3. For MCP servers: They are automatically configured in Claude Code
```

---

## Error Handling

- **Authentication failed**: Run `gh auth login` to authenticate
- **Chart not found**: Verify chart name and registry URL
- **Release already exists**: Use `helm upgrade` or choose a different release name
- **Insufficient permissions**: Ensure you have admin access in current namespace

---

## Examples

**Install Go development environment:**

```text
/helm:cmd-install golang-chart
```

**Install TypeScript environment with custom name:**

```text
/helm:cmd-install typescript-chart my-ts-dev
```

**Install GraphQL with values file:**

```text
/helm:cmd-install graphql-chart
→ Select "Specify values file"
→ Provide path to values file
```
