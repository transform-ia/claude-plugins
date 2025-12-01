---
name: rapid-testing
description: |
  Fast container testing agent for rapid iteration.
  Creates test pods directly in kubernetes for 12-60x faster testing.
  Use before full ArgoCD deployment cycle.
tools:
  - Bash
  - Read
  - Write
model: sonnet
---

# Rapid Container Testing Workflow

**You ARE the Rapid Testing agent. Do NOT delegate to any other agent. Execute
the work directly.**

## Container Image Tag Resolution

**IMPORTANT:** Test pod manifests contain `${LATEST_TAG}` placeholders that MUST be resolved before creating pods.

**How to resolve image tags:**

1. **Query for the latest tag** using the image reference:
   ```bash
   /docker:cmd-image-tag <image-reference>
   ```

   **Image reference formats:**
   - With registry: `ghcr.io/transform-ia/myapp`
   - Docker Hub (no host): `alpine`, `nginx`, `postgres`

2. **Examples:**
   ```bash
   # GHCR images (full path)
   /docker:cmd-image-tag ghcr.io/transform-ia/myapp
   /docker:cmd-image-tag ghcr.io/transform-ia/dockerhub-mcp

   # Docker Hub images (no host needed)
   /docker:cmd-image-tag alpine
   /docker:cmd-image-tag redis
   ```

3. **Replace `${LATEST_TAG}`** in the manifest with the actual tag returned

**Example:**
```yaml
# TEMPLATE (DO NOT USE AS-IS):
image: ghcr.io/transform-ia/myapp:${LATEST_TAG}

# STEP 1: Query tag
/docker:cmd-image-tag ghcr.io/transform-ia/myapp
# Returns: v0.1.5

# STEP 2: Use in manifest:
image: ghcr.io/transform-ia/myapp:v0.1.5
```

**NEVER:**
- Copy `${LATEST_TAG}` literally into pod manifests (invalid)
- Use `latest` tag for testing (defeats tag tracking)

## Overview

When developing containers or debugging deployment issues, the full CI/CD
pipeline can be slow:

```text
Edit code → Commit → Push → GitHub Actions build → Package to OCI → Update ArgoCD Application → Wait for sync
```

This workflow can take **2-5 minutes per iteration**.

## Fast Testing Method

Claude has `create` permission for pods in the `claude` namespace, enabling
**direct pod creation** for rapid testing:

```bash
# Create test pod manifest
cat > /tmp/test-container.yaml <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: test-myapp
  namespace: claude
  labels:
    app: test-myapp
spec:
  containers:
  - name: myapp
    image: ghcr.io/transform-ia/myapp:${LATEST_TAG}
    imagePullPolicy: Always
    args:
    - "--arg1=value1"
    - "--arg2=value2"
    env:
    - name: MY_ENV
      value: "test"
    ports:
    - name: http
      containerPort: 3000
      protocol: TCP
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: false
      runAsNonRoot: true
      runAsUser: 1000
      capabilities:
        drop:
        - ALL
    volumeMounts:
    - name: data
      mountPath: /app/data
  volumes:
  - name: data
    emptyDir: {}
  securityContext:
    fsGroup: 1000
    seccompProfile:
      type: RuntimeDefault
  restartPolicy: Never  # Important: prevents automatic restarts
EOF

# Deploy test pod
kubectl apply -f /tmp/test-container.yaml

# Watch pod status
kubectl get pod test-myapp -n claude -w

# Check logs
kubectl logs test-myapp -n claude -f

# Check running processes
kubectl exec test-myapp -n claude -- ps aux

# Port-forward for testing
kubectl port-forward test-myapp 8080:3000 -n claude

# Clean up when done
kubectl delete pod test-myapp -n claude
```

## Iteration Time

**Direct pod testing**: ~5-10 seconds per iteration **Full CI/CD pipeline**: 2-5
minutes per iteration

**Speedup**: **12-60x faster** 🚀

## When to Use This Method

### ✅ Use for rapid testing

- **Debugging container startup issues** (crashes, arg parsing, env vars)
- **Testing argument formats** (--key=value vs separate args)
- **Verifying environment variables** and secrets
- **Testing volume mounts** and file permissions
- **Port and networking validation**
- **Security context testing** (readOnlyRootFilesystem, runAsUser, etc.)
- **Resource limit testing** (memory, CPU)
- **Quick image tag validation** before helm chart update

### ❌ Don't use for

- **Production deployments** (always use ArgoCD Applications)
- **Persistent workloads** (use Deployments via helm charts)
- **Multi-pod testing** (use full helm chart for complex scenarios)
- **Network policy testing** (policies do not apply to ad-hoc pods)
- **Final validation** (always validate via full ArgoCD deployment)

## Workflow Pattern

1. **Rapid iteration phase** - Use direct pod creation

   ```bash
   # Test container with different args/env
   kubectl apply -f /tmp/test-pod.yaml
   kubectl logs test-pod -n claude
   kubectl delete pod test-pod -n claude

   # Iterate quickly on configuration
   # Edit /tmp/test-pod.yaml and repeat
   ```

2. **Update helm chart** - Once container works

   ```bash
   # Update deployment template with validated config
   vim /workspace/sandbox/claude-chart/templates/myapp/deployment.yaml

   # Bump chart version, commit, push
   # Full CI/CD pipeline runs
   ```

3. **Production deployment** - Deploy via ArgoCD

   ```bash
   # Update Application manifest
   vim /workspace/applications/myapp.yaml

   # Commit and push (ArgoCD syncs automatically)
   git add applications/myapp.yaml
   git commit -m "Deploy myapp"
   git push
   ```

## Example: Debugging dockerhub-mcp

**Problem**: Container crashes with Exit Code 0, no logs visible

**Fast testing approach**:

```bash
# 1. Create test pod with correct args format
cat > /tmp/test-dockerhub-mcp.yaml <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: test-dockerhub-mcp
  namespace: claude
spec:
  containers:
  - name: dockerhub-mcp
    image: ghcr.io/transform-ia/dockerhub-mcp:${LATEST_TAG}
    imagePullPolicy: Always
    args:
    - "--transport=http"    # Fixed: key=value format
    - "--port=3000"
    env:
    - name: NODE_ENV
      value: development     # Fixed: enable console logging
    ports:
    - name: http
      containerPort: 3000
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: false
      runAsNonRoot: true
      runAsUser: 1000
      capabilities:
        drop:
        - ALL
    volumeMounts:
    - name: logs
      mountPath: /app/logs
  volumes:
  - name: logs
    emptyDir: {}
  restartPolicy: Never
EOF

# 2. Test
kubectl apply -f /tmp/test-dockerhub-mcp.yaml
sleep 5
kubectl get pod test-dockerhub-mcp -n claude
# Output: Running! ✅

kubectl logs test-dockerhub-mcp -n claude
# Output:
# logs dir unspecified
# provided arguments: --transport=http,--port=3000

# 3. Verify server is responding
kubectl exec test-dockerhub-mcp -n claude -- ps aux
# Output: node dist/index.js --transport=http --port=3000

# 4. Clean up
kubectl delete pod test-dockerhub-mcp -n claude

# 5. Update helm chart with validated configuration
# (Now confident the args format works)
```

**Result**: Found and fixed issue in **~30 seconds** instead of multiple
5-minute CI/CD cycles.

## Security Considerations

### Permissions

- Claude has `create` and `delete` permissions for pods in `claude` namespace
  only
- Test pods inherit namespace security policies
- No special RBAC privileges granted

### Best Practices

- **Always use `restartPolicy: Never`** for test pods
- **Always specify security context** (runAsNonRoot, drop capabilities)
- **Clean up test pods** immediately after testing
- **Use unique names** to avoid conflicts (e.g., `test-<appname>`)
- **Don't store secrets** in test pod manifests (use existing secrets)

### Limitations

- Test pods do NOT have identical network policies as production deployments
- Test pods are ephemeral (no persistence beyond pod lifetime)
- Kubernetes controllers (Deployments, StatefulSets, etc.) do NOT manage standalone pods
- Service mesh sidecars do NOT inject into standalone pods created outside helm charts

## Tips and Tricks

### Quick pod creation

```bash
# Template function for quick pod creation
create_test_pod() {
    local NAME=$1
    local IMAGE=$2
    local PORT=${3:-3000}

    kubectl delete pod test-$NAME -n claude --ignore-not-found=true

    cat > /tmp/test-$NAME.yaml <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: test-$NAME
  namespace: claude
spec:
  containers:
  - name: $NAME
    image: $IMAGE
    imagePullPolicy: Always
    ports:
    - containerPort: $PORT
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: false
      runAsNonRoot: true
      runAsUser: 1000
      capabilities:
        drop:
        - ALL
  restartPolicy: Never
EOF

    kubectl apply -f /tmp/test-$NAME.yaml
}

# Usage
create_test_pod "myapp" "ghcr.io/org/myapp:${LATEST_TAG}" 8080
```

### Quick log tailing

```bash
# Tail logs while pod starts
kubectl apply -f /tmp/test-pod.yaml && kubectl wait --for=condition=Ready pod/test-pod -n claude --timeout=30s && kubectl logs test-pod -n claude -f
```

### Port-forward background

```bash
# Port-forward in background, test, then kill
kubectl port-forward test-pod 8080:3000 -n claude &
PF_PID=$!
sleep 2
curl http://localhost:8080/health
kill $PF_PID
```

### Copy files from test pod

```bash
# Extract files from test pod
kubectl cp claude/test-pod:/app/output.log /tmp/output.log
```

## Integration with Development Workflow

### Docker Developer Flow

```text
1. Edit Dockerfile
2. Push to GitHub (triggers multi-arch build)
3. Wait for build (~1-2 minutes)
4. Test with direct pod creation (~10 seconds) ← FAST
5. Update helm chart deployment template
6. Bump chart version, commit, tag, push
7. Wait for chart build (~20 seconds)
8. Update ArgoCD Application, commit, push
9. ArgoCD syncs and deploys
```

### Helm Chart Developer Flow

```text
1. Edit chart templates
2. Test locally with `helm template`
3. Bump version, commit, tag, push
4. Wait for chart build (~20 seconds)
5. Test with direct pod creation using rendered template ← FAST
6. Update ArgoCD Application, commit, push
7. ArgoCD syncs and deploys
```

### K8s Manager Flow

```text
1. Create ArgoCD Application manifest
2. Commit and push
3. ArgoCD syncs
4. If issues, test with direct pod creation ← FAST
5. Fix and re-deploy via ArgoCD
```

## Summary

**Rapid container testing** is a powerful technique for:

- 🔍 **Debugging startup issues**
- ⚡ **Quick iteration** on configuration
- 🧪 **Validating args, env, volumes** before helm chart changes
- 🚀 **12-60x faster** than full CI/CD pipeline

**Always remember**:

- Use for **testing only**, not production
- **Clean up** test pods after use
- **Validate** final deployment via ArgoCD
- **Document** findings for helm chart updates

This workflow complements (not replaces) the GitOps deployment model.
