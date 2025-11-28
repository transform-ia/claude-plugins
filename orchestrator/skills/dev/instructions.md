# Orchestrator Plugin Guidelines

## Purpose

The orchestrator plugin detects frameworks in a repository and coordinates plugin activation.

## Available Commands

| Command | Purpose |
|---------|---------|
| `/orchestrator:detect [dir]` | Detect frameworks in repository |

## Detection Rules

| File/Directory | Framework | Plugin |
|----------------|-----------|--------|
| `go.mod` | Go | go |
| `Chart.yaml` | Helm chart | helm |
| `Dockerfile` | Docker | docker |
| `.github/workflows/` | GitHub Actions | github |
| Multiple `.md` files | Documentation | markdown |

## Workflow

1. **Run detection:** `/orchestrator:detect /path/to/repo`
2. **Review results:** See which plugins apply
3. **Activate plugins:** Use the appropriate `/plugin:command`

## Orchestration Pattern

When reviewing a repository:

1. First run `/orchestrator:detect` to understand the repository
2. Dispatch to appropriate plugins based on detection:
   - Go code → `/go:lint`
   - Dockerfile → `/docker:lint`
   - Helm chart → `/helm:lint`
   - GitHub workflows → `/github:lint`
   - Documentation → `/markdown:lint`

## ONLY Dispatch - Never Implement

The orchestrator:
- **DOES:** Detect frameworks, coordinate plugins
- **DOES NOT:** Edit files, write code, make implementation decisions

For actual work, always delegate to the appropriate plugin.

## Mandatory Plugins

**Always dispatch these, even if files don't exist yet:**

| Plugin | Reason |
|--------|--------|
| `github` | CI/CD required for all repos |

## Phase Ordering

Execute plugins in this order:

```
PHASE 1: CI/CD Setup (Sequential)
└── github (creates .github/ if missing)

PHASE 2: Domain Plugins (Parallel)
├── go (if *.go exists)
├── docker (if Dockerfile exists)
├── helm (if Chart.yaml exists)
└── markdown (if *.md files exist)
```

Each plugin runs its own linter automatically when finished.

## Iterate Until Done

Don't stop after one dispatch. Keep going until:
- ✅ All requested changes are implemented
- ✅ All plugins report success
- ✅ No fixable errors remain
