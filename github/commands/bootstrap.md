---
description:
  "Bootstrap new project: /github:bootstrap <org> <name> [--go] [--docker]
  [--helm]"
allowed-tools:
  - Task
  - AskUserQuestion
  - TodoWrite
  - Bash(${CLAUDE_PLUGIN_ROOT}/scripts/bootstrap.sh *)
  - Bash(gh repo create *)
  - SlashCommand(/github:release)
---

# /github:bootstrap - Bootstrap New GitHub Repository

**Command:** `/github:bootstrap <org> <name> [--go] [--docker] [--helm]`

## Purpose

Bootstrap a new GitHub repository with CI/CD infrastructure. This command
dispatches specialized work to domain agents via the Task tool.

## Usage

```bash
# Interactive mode (prompts for features)
/github:bootstrap transform-ia my-new-service

# With explicit features
/github:bootstrap transform-ia my-go-api --go --docker
/github:bootstrap transform-ia my-helm-chart --helm
/github:bootstrap transform-ia full-stack --go --docker --helm
```

## Arguments

- `<org>` - GitHub organization name (required)
- `<name>` - Repository name (required)
- `--go` - Include Go module initialization (optional)
- `--docker` - Include Dockerfile (optional)
- `--helm` - Include Helm chart (optional)

---

## Workflow

### Phase 0: Input Collection

If feature flags not provided, use `AskUserQuestion`:

```yaml
AskUserQuestion:
  questions:
    - header: "Features"
      question: "Which features should this repository include?"
      multiSelect: true
      options:
        - label: "Go"
          description: "Go module and application code"
        - label: "Docker"
          description: "Dockerfile and container build"
        - label: "Helm"
          description: "Helm chart for Kubernetes deployment"

    - header: "Go Type"
      question: "What type of Go application?" # Only if Go selected
      multiSelect: false
      options:
        - label: "otel"
          description: "OpenTelemetry instrumented service"
        - label: "MCP"
          description: "Model Context Protocol server"
        - label: "graphql"
          description: "GraphQL API server"
        - label: "daemon"
          description: "Background service/daemon"
```

Store responses: `$ENABLE_GO`, `$ENABLE_DOCKER`, `$ENABLE_HELM`, `$GO_APP_TYPE`

### Phase 1: Repository Setup

```bash
# Create GitHub repository
gh repo create $org/$name --private --description "Bootstrapped by /github:bootstrap"

# Create local workspace
mkdir -p ~/sandbox/$org/$name
cd ~/sandbox/$org/$name
git init
git remote add origin git@github.com:$org/$name.git
```

### Phase 2: Feature Implementation (Dispatch to Agents)

**CRITICAL: Use Task tool to dispatch - do NOT implement directly.**

#### If Go Selected

```yaml
Task:
  subagent_type: "go:gocode"
  prompt: |
    Initialize Go module for new repository:
    - Directory: ~/sandbox/$org/$name
    - Module path: github.com/$org/$name
    - Application type: $GO_APP_TYPE
    - Create scaffold using /go:mod-init with scaffold type
    - Validate: go build, go test must pass
```

#### If Docker Selected

```yaml
Task:
  subagent_type: "docker:container"
  prompt: |
    Create Dockerfile for repository:
    - Directory: ~/sandbox/$org/$name
    - Use Go template if go.mod exists, otherwise default
    - Include .dockerignore
    - Validate: hadolint must pass
```

#### If Helm Selected

```yaml
Task:
  subagent_type: "helm:agent-dev"
  prompt: |
    Create Helm chart for repository:
    - Directory: ~/sandbox/$org/$name/chart
    - Chart name: $name
    - Image: ghcr.io/$org/$name (if Docker enabled)
    - Validate: helm lint must pass
```

### Phase 3: CI/CD Setup

Assemble workflow using templates:

```bash
Bash("${CLAUDE_PLUGIN_ROOT}/scripts/bootstrap.sh ~/sandbox/$org/$name latest $name $FLAGS")
```

Create dependabot.yaml based on features:

```yaml
version: 2
updates:
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
  # Add gomod if Go
  # Add docker if Docker
```

### Phase 4: Finalization

```bash
cd ~/sandbox/$org/$name
git add .
git commit -m "chore: initial bootstrap via /github:bootstrap

Features: Go=$ENABLE_GO, Docker=$ENABLE_DOCKER, Helm=$ENABLE_HELM"

git push -u origin master
```

Release initial version:

```bash
SlashCommand("/github:release 0.0.0")
```

---

## Validation

After completion, verify:

1. Repository exists: `gh repo view $org/$name`
2. Workflow valid: `yamllint .github/workflows/ci.yaml`
3. Initial release created: `gh release view v0.0.0 -R $org/$name`
4. Build triggered: `gh run list -R $org/$name`

## Error Handling

| Error                | Action                                   |
| -------------------- | ---------------------------------------- |
| Repo creation fails  | Abort, report error                      |
| Agent dispatch fails | Ask user: continue without that feature? |
| Git operations fail  | Check SSH keys, report error             |
| Validation fails     | Fix and retry                            |

## Notes

- This command delegates all domain work to specialized agents via Task tool
- Never implement Go/Docker/Helm logic directly
- All generated files must pass their respective linters
- Initial v0.0.0 release triggers first CI build
