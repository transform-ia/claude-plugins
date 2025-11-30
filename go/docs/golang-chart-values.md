# golang-chart Values Schema Reference

Complete reference for `golang-chart` values configuration (v0.0.17+).

## Overview

The `golang-chart` deploys a Go development environment with gopls MCP language
server. It creates a single pod with:

- gopls language server exposed via HTTP MCP endpoint (port 81)
- Shared `/workspace` volume for persistent code storage
- Optional code-server for browser-based editing
- Security-hardened container (read-only root, non-root user)
- Build tools: Go toolchain, golangci-lint, git

## Source Configuration

**Always use OCI registry** (not git repository):

```yaml
source:
  chart: golang-chart
  repoURL: oci://ghcr.io/transform-ia/golang-chart
  targetRevision: 0.0.17 # Or latest version
```

❌ **DEPRECATED** (old pattern):

```yaml
source:
  repoURL: https://github.com/transform-ia/golang-chart
  targetRevision: HEAD
  path: .
```

## Required Values

### Workspace Storage (REQUIRED)

```yaml
storage:
  workspace:
    existingClaim: claude-workspace-pvc # REQUIRED: Name of existing PVC
    mountPath: /workspace # Default, usually omit
```

**Note**: The chart does NOT create PVCs. You must provide an existing claim.

## Common Values

### Basic Configuration

```yaml
global:
  namespace: claude # Target namespace
  timezone: America/Montreal # Container timezone

fullnameOverride: "my-project-dev" # Release name override

workdir: /workspace/sandbox/myproject # Working directory for the app

replicaCount: 1 # Always 1 for dev environments
```

### Image Configuration

```yaml
image:
  repository: ghcr.io/transform-ia/golang-image
  tag: "" # Defaults to .Chart.AppVersion if empty
  pullPolicy: IfNotPresent
```

### Private Image Registry Authentication

```yaml
registry:
  username: "" # GitHub username
  password: "" # GitHub PAT (for private images)
```

⚠️ **SECURITY**: Never hardcode credentials in values. Use:

- Empty values (chart creates no secret)
- `secretRef` to reference existing secret
- ArgoCD/Kubernetes secrets management

### Environment Variables

```yaml
# Non-sensitive environment variables
env:
  - name: GOPRIVATE
    value: "github.com/transform-ia"
  - name: MY_VAR
    value: "my-value"

# Sensitive environment variables (managed by Helm in a Secret)
secretEnv:
  - name: API_KEY
    value: "secret-value"
  - name: GITHUB_TOKEN
    value: "ghp_..."

# Reference existing secret (recommended for sensitive data)
secretRef:
  enabled: true
  name: my-existing-secret # Secret in same namespace
```

### Resources

```yaml
resources:
  requests:
    cpu: 500m
    memory: 1Gi
  limits:
    cpu: 2000m
    memory: 4Gi
```

## Complete Example

### Minimal Configuration

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: myproject-dev
  namespace: argocd
spec:
  project: default
  source:
    chart: golang-chart
    repoURL: oci://ghcr.io/transform-ia/golang-chart
    targetRevision: 0.0.17
    helm:
      values: |
        global:
          namespace: claude

        fullnameOverride: "myproject-dev"

        storage:
          workspace:
            existingClaim: claude-workspace-pvc

        workdir: /workspace/sandbox/myproject

        env:
          - name: GOPRIVATE
            value: "github.com/transform-ia"

  destination:
    server: https://kubernetes.default.svc
    namespace: claude

  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

### Full Configuration (with all options)

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: myproject-dev
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default

  source:
    chart: golang-chart
    repoURL: oci://ghcr.io/transform-ia/golang-chart
    targetRevision: 0.0.17
    helm:
      values: |
        global:
          namespace: claude
          timezone: America/Montreal

        fullnameOverride: "myproject-dev"

        image:
          repository: ghcr.io/transform-ia/golang-image
          tag: "${LATEST_TAG}"
          pullPolicy: IfNotPresent

        storage:
          workspace:
            existingClaim: claude-workspace-pvc
          tmp:
            size: 5Gi
          cache:
            size: 2Gi
          goCache:
            size: 2Gi

        workdir: /workspace/sandbox/myproject

        env:
          - name: GOPRIVATE
            value: "github.com/transform-ia"
          - name: PROJECT_ENV
            value: "development"

        secretRef:
          enabled: true
          name: myproject-secrets

        resources:
          requests:
            cpu: 500m
            memory: 1Gi
          limits:
            cpu: 2000m
            memory: 4Gi

        networkPolicies:
          enabled: true
          allowDNS: true
          allowHTTPSEgress: true
          allowIngressFrom:
            - app: claude-code

        labels:
          project: myproject
          team: development
          environment: dev

        annotations:
          description: "MyProject development environment with gopls MCP server"
          maintained-by: "Transform IA"

  destination:
    server: https://kubernetes.default.svc
    namespace: claude

  syncPolicy:
    automated:
      prune: true
      selfHeal: true
      allowEmpty: false
    syncOptions:
      - CreateNamespace=true
      - PrunePropagationPolicy=foreground
      - PruneLast=true
    retry:
      limit: 5
      backoff:
        duration: 5s
        factor: 2
        maxDuration: 3m

  ignoreDifferences:
    - group: apps
      kind: Deployment
      jsonPointers:
        - /spec/replicas
```

## Advanced Values

### Service Configuration

```yaml
service:
  type: ClusterIP
  port: 81
  annotations: {}
```

### RBAC and Service Account

```yaml
serviceAccount:
  create: true
  name: "" # Defaults to release name
  automountToken: true

rbac:
  create: true
  rules:
    - apiGroups: ["", "apps", "batch"]
      resources:
        - pods
        - deployments
        - services
        - configmaps
        - jobs
      verbs: ["get", "list", "watch"]
```

### Security Context

```yaml
securityContext:
  fsGroup: 1000
  seccompProfile:
    type: RuntimeDefault

containerSecurityContext:
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: true
  runAsNonRoot: true
  runAsUser: 1000
  capabilities:
    drop:
      - ALL

podSecurityStandard: restricted
```

### Network Policies

```yaml
networkPolicies:
  enabled: true
  allowDNS: true
  allowHTTPSEgress: true
  allowIngressFrom:
    - app: claude-code
    - app: other-app
```

### Node Selection and Scheduling

```yaml
nodeSelector:
  kubernetes.io/arch: amd64

tolerations:
  - key: "dedicated"
    operator: "Equal"
    value: "development"
    effect: "NoSchedule"

affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
        - matchExpressions:
            - key: "node-role"
              operator: In
              values:
                - "development"
```

## Storage Volumes

The chart creates multiple volumes:

```yaml
storage:
  workspace:
    existingClaim: claude-workspace-pvc # REQUIRED: Persistent storage
    mountPath: /workspace

  tmp:
    size: 5Gi # Memory-backed tmpfs for /tmp

  cache:
    size: 2Gi # Writable cache at $HOME/.cache

  goCache:
    size: 2Gi # Go build cache at $HOME/.cache/go-build
```

**Volume Mounts:**

- `/workspace` - Persistent PVC (code, repos, artifacts)
- `/tmp` - EmptyDir (temporary files)
- `$HOME/.cache` - EmptyDir (golangci-lint, build cache)

## MCP Server Endpoint

After deployment, the MCP server is available at:

```text
http://<release-name>-golang-chart.<namespace>.svc.cluster.local:81/mcp
```

**Example:**

```text
http://myproject-dev-golang-chart.claude.svc.cluster.local:81/mcp
```

Add to `.mcp.json`:

```json
{
  "myproject-dev": {
    "type": "http",
    "url": "http://myproject-dev-golang-chart.claude.svc.cluster.local:81/mcp"
  }
}
```

## Migration from Old Values

### Deprecated Values (v0.0.16 and earlier)

❌ **OLD** (no longer supported):

```yaml
mcpServer:
  enabled: true
  workspace: /workspace/sandbox/myproject
  port: 81
```

✅ **NEW** (v0.0.17+):

```yaml
workdir: /workspace/sandbox/myproject
# Service port is always 81, no need to configure
```

### Breaking Changes

**v0.0.17:**

- Removed `mcpServer.*` values
- Renamed to `workdir` (simpler, clearer)
- MCP server always enabled (no toggle needed)
- Service port fixed at 81 (no configuration needed)

## Common Patterns

### Multi-Project Development

Deploy separate instances for each project:

```bash
# Project 1
helm install project1-dev oci://ghcr.io/transform-ia/golang-chart \
  --version 0.0.17 \
  --set workdir=/workspace/sandbox/project1 \
  --set fullnameOverride=project1-dev

# Project 2
helm install project2-dev oci://ghcr.io/transform-ia/golang-chart \
  --version 0.0.17 \
  --set workdir=/workspace/sandbox/project2 \
  --set fullnameOverride=project2-dev
```

### Private Repository Access

```yaml
env:
  - name: GOPRIVATE
    value: "github.com/transform-ia,gitlab.com/myorg"
  - name: GITHUB_TOKEN
    valueFrom:
      secretKeyRef:
        name: github-credentials
        key: token
```

**Or use secretRef:**

```yaml
secretRef:
  enabled: true
  name: github-credentials
```

### Resource Limits for CI/CD

```yaml
resources:
  requests:
    cpu: 1000m
    memory: 2Gi
  limits:
    cpu: 4000m
    memory: 8Gi

storage:
  cache:
    size: 5Gi # Larger cache for faster builds
  goCache:
    size: 5Gi
```

## Troubleshooting

### Pod Not Starting

```bash
# Check events
kubectl describe pod -n claude -l app.kubernetes.io/instance=myproject-dev

# Common issues:
# - Missing PVC (check storage.workspace.existingClaim)
# - Image pull errors (check registry credentials)
# - Resource limits too low
```

### MCP Server Not Responding

```bash
# Check service
kubectl get svc -n claude myproject-dev-golang-chart

# Check logs
kubectl logs -n claude -l app.kubernetes.io/instance=myproject-dev

# Test endpoint
kubectl run -it --rm debug --image=curlimages/curl --restart=Never -- \
  curl http://myproject-dev-golang-chart.claude.svc.cluster.local:81/mcp
```

### Permission Errors

```bash
# Check security context
kubectl get pod -n claude -l app.kubernetes.io/instance=myproject-dev \
  -o jsonpath='{.items[0].spec.securityContext}'

# Common issues:
# - ReadOnlyRootFilesystem prevents writes outside /workspace, /tmp, $HOME/.cache
# - runAsNonRoot requires user 1000
# - PVC ownership must match fsGroup: 1000
```

## Best Practices

1. **Always use OCI registry** - Faster, more reliable than git
2. **Pin chart version** - Explicit `targetRevision: 0.0.17`
3. **Use fullnameOverride** - Predictable release names
4. **Never hardcode secrets** - Use secretRef or Kubernetes secrets
5. **Set GOPRIVATE** - For private Go module dependencies
6. **Configure resources** - Set appropriate limits for your workload
7. **Enable network policies** - Security best practice
8. **Use automated sync** - GitOps with ArgoCD

## See Also

- Chart source: <https://github.com/transform-ia/golang-chart>
- Chart registry: oci://ghcr.io/transform-ia/golang-chart
- Go developer agent: `/workspace/.claude/agents/go-developer.md`
- k8s-manager agent: `/workspace/.claude/agents/k8s-manager.md`
