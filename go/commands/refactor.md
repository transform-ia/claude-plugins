---
description: "Refactor Go codebase: /go:refactor <directory>"
allowed-tools:
  [
    Read,
    Glob,
    Grep,
    Edit(*.go),
    Edit(go.mod),
    Write(*.go),
    Bash(go *),
    Bash(mkdir *),
    Bash(mv *),
    Bash(rm *.go),
    Bash(rm -rf */internal),
    Task,
    TodoWrite,
    AskUserQuestion,
    SlashCommand(/go:*),
  ]
---

# Go Refactor

Structured workflow for refactoring Go codebases to comply with organizational
standards. Use for updating legacy code, migrating dependencies, or
standardizing project structure.

---

## Parameter Validation

**REQUIRED**: If `$ARGUMENTS` is empty, respond with: "Error: directory
required. Usage: /go:refactor DIRECTORY" and STOP.

---

## Refactoring Workflow

### Phase 1: Analysis

1. Read `go.mod` (module name, Go version, dependencies)
2. Identify main entry point and all packages
3. Identify violations against Go plugin standards:

   | Standard             | Violation Pattern                 |
   | -------------------- | --------------------------------- |
   | No `internal/`       | `internal/` directories exist     |
   | No `os.Getenv()`     | Direct env variable access        |
   | No manual validation | Missing validator/v10 tags        |
   | No `cmd/` for main   | `main.go` in `cmd/` subdirectory  |
   | Error wrapping       | `return err` without `fmt.Errorf` |

4. Check for missing required libraries (cobra, envconfig, validator/v10,
   testify, otelzap)
5. Create refactoring plan using TodoWrite

### Phase 2: Package Migration

If `internal/` packages exist:

1. Create `pkg/` mirroring `internal/` structure
2. Move packages: `internal/<name>` → `pkg/<name>`
3. Update all import paths across entire codebase
4. Verify no remaining `internal/` references
5. Delete empty `internal/` directory

### Phase 3: Dependency Updates

1. Check for breaking changes in major dependency updates (read changelogs,
   migration guides, compare API signatures)
2. Update `go.mod` with new versions
3. Run `go mod tidy`
4. Fix compilation errors from API changes

### Phase 4: Code Standards

Apply these transformations:

- `os.Getenv()` → envconfig struct with tags
- Add `validator/v10` tags to request structs
- Bare `return err` → `fmt.Errorf("context: %w", err)`
- `log.Printf()` → `logger.Ctx(ctx).Info()` (otelzap)

### Phase 5: Verification

1. `/go:gotest $ARGUMENTS`
2. `/go:golint $ARGUMENTS`
3. `/go:compile $ARGUMENTS`

### Phase 6: Cleanup

Remove unused packages, imports, and empty directories.

## Output

After refactoring, report: changes made, remaining work (if any), build/test/lint
status (pass/fail).

## Notes

- Always use git before major refactoring
- Run tests after each phase to catch regressions early
- Use TodoWrite to track progress
- Ask user for clarification on architectural decisions
