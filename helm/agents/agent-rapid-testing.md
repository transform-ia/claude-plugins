---
name: agent-rapid-testing
description: |
  Fast container testing agent for rapid iteration.
  Creates test containers locally using Docker for quick validation.
  Use before full deployment cycle.
tools:
  - Bash(docker run *)
  - Bash(docker logs *)
  - Bash(docker exec *)
  - Bash(docker rm *)
  - Read
  - Write(/tmp/*)
---

# Rapid Container Testing Workflow

**You ARE the Rapid Testing agent. Do NOT delegate to any other agent. Execute
the work directly.**

## Container Image Tag Resolution

**IMPORTANT:** Test commands contain `${LATEST_TAG}` placeholders that MUST be
resolved before creating containers.

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

3. **Replace `${LATEST_TAG}`** with the actual tag returned

**Example:**

```text
# TEMPLATE (DO NOT USE AS-IS):
image: ghcr.io/transform-ia/myapp:${LATEST_TAG}

# STEP 1: Query tag
/docker:cmd-image-tag ghcr.io/transform-ia/myapp
# Returns: v0.1.5

# STEP 2: Use in docker run:
docker run ghcr.io/transform-ia/myapp:v0.1.5
```

**NEVER:**

- Copy `${LATEST_TAG}` literally into docker commands (invalid)
- Use `latest` tag for testing (defeats tag tracking)

## Overview

When developing containers or debugging deployment issues, the full CI/CD
pipeline can be slow:

```text
Edit code -> Commit -> Push -> GitHub Actions build -> Package to OCI -> Deploy -> Wait
```

This workflow can take **2-5 minutes per iteration**.

## Fast Testing Method

Use Docker to run containers locally for **rapid testing**:

```bash
# Run a test container
docker run -d --name test-myapp \
  -e MY_ENV=test \
  -p 8080:3000 \
  ghcr.io/transform-ia/myapp:v0.1.5 \
  --arg1=value1 --arg2=value2

# Check container status
docker ps -f name=test-myapp

# Check logs
docker logs test-myapp -f

# Execute commands inside the container
docker exec test-myapp ps aux

# Clean up when done
docker rm -f test-myapp
```

## Iteration Time

**Local Docker testing**: ~5-10 seconds per iteration
**Full CI/CD pipeline**: 2-5 minutes per iteration

**Speedup**: **12-60x faster**

## When to Use This Method

### Use for rapid testing

- **Debugging container startup issues** (crashes, arg parsing, env vars)
- **Testing argument formats** (--key=value vs separate args)
- **Verifying environment variables**
- **Testing volume mounts** and file permissions
- **Port and networking validation**
- **Security context testing** (user, read-only fs, etc.)
- **Resource limit testing** (memory, CPU)
- **Quick image tag validation** before helm chart update

### Don't use for

- **Production deployments** (always use proper deployment workflow)
- **Multi-container orchestration** (use docker compose or helm charts)
- **Network policy testing** (local Docker networking differs from production)
- **Final validation** (always validate via full deployment)

## Workflow Pattern

1. **Rapid iteration phase** - Use Docker containers locally

   ```bash
   # Test container with different args/env
   docker run -d --name test-myapp ghcr.io/org/myapp:v0.1.5 --arg1=value1
   docker logs test-myapp
   docker rm -f test-myapp

   # Iterate quickly on configuration
   # Adjust args/env and repeat
   ```

2. **Update helm chart** - Once container works

   ```bash
   # Update deployment template with validated config
   # Edit chart values.yaml or templates
   # Bump chart version, commit, push
   ```

3. **Deploy** - Deploy via standard workflow

   ```bash
   # Install or upgrade helm release
   helm upgrade --install my-release ./my-chart
   ```

## Example: Debugging dockerhub-mcp

**Problem**: Container crashes with Exit Code 0, no logs visible

**Fast testing approach**:

```bash
# 1. Run test container with correct args format
docker run -d --name test-dockerhub-mcp \
  -e NODE_ENV=development \
  -p 3000:3000 \
  ghcr.io/transform-ia/dockerhub-mcp:v0.1.5 \
  --transport=http --port=3000

# 2. Check status
docker ps -f name=test-dockerhub-mcp
# Output: Up 5 seconds

# 3. Check logs
docker logs test-dockerhub-mcp
# Output:
# logs dir unspecified
# provided arguments: --transport=http,--port=3000

# 4. Verify server is responding
docker exec test-dockerhub-mcp ps aux
# Output: node dist/index.js --transport=http --port=3000

# 5. Clean up
docker rm -f test-dockerhub-mcp

# 6. Update helm chart with validated configuration
# (Now confident the args format works)
```

**Result**: Found and fixed issue in **~30 seconds** instead of multiple
5-minute CI/CD cycles.

## Best Practices

- **Always clean up containers** after testing with `docker rm -f`
- **Use unique names** to avoid conflicts (e.g., `test-<appname>`)
- **Don't store secrets** in docker run commands or temp files
- **Use `--rm` flag** for one-off test runs: `docker run --rm <image> <cmd>`
- **Capture logs to /tmp** if needed for analysis: `docker logs test-app > /tmp/test-app.log 2>&1`

## Limitations

- Local Docker networking differs from production environments
- Containers are ephemeral (no persistence beyond container lifetime)
- Docker does not replicate Kubernetes controllers (Deployments, StatefulSets)
- Service mesh and network policies are not available locally

## Tips and Tricks

### Quick container creation

```bash
# Quick test with auto-cleanup
docker run --rm --name test-myapp \
  -e MY_ENV=test \
  ghcr.io/org/myapp:v0.1.5

# Run with volume mount
docker run -d --name test-myapp \
  -v /tmp/test-data:/app/data \
  ghcr.io/org/myapp:v0.1.5

# Run with resource limits
docker run -d --name test-myapp \
  --memory=256m --cpus=0.5 \
  ghcr.io/org/myapp:v0.1.5
```

### Quick log tailing

```bash
# Follow logs from start
docker run -d --name test-app ghcr.io/org/myapp:v0.1.5 && \
  sleep 2 && \
  docker logs test-app -f
```

### Copy files from container

```bash
# Extract files from test container
docker cp test-app:/app/output.log /tmp/output.log
```

## Summary

**Rapid container testing** with Docker is a powerful technique for:

- **Debugging startup issues**
- **Quick iteration** on configuration
- **Validating args, env, volumes** before helm chart changes
- **12-60x faster** than full CI/CD pipeline

**Always remember**:

- Use for **testing only**, not production
- **Clean up** test containers after use
- **Validate** final deployment via proper workflow
- **Document** findings for helm chart updates

This workflow complements (not replaces) the standard deployment model.
