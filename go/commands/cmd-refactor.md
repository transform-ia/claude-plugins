---
description: "Refactor Go codebase: /go:cmd-refactor <directory>"
allowed-tools:
  [Read, Glob, Grep, Edit, Write, Bash, Task, TodoWrite, AskUserQuestion]
---

# Go Refactor

## Overview

This command provides a structured workflow for refactoring Go codebases to
comply with organizational standards. Use this when updating legacy code,
migrating dependencies, or standardizing project structure.

---

## Parameter Validation

**REQUIRED**: If `$ARGUMENTS` is empty, respond with: "Error: directory
required. Usage: /go:cmd-refactor DIRECTORY" and STOP. Do not proceed with any
tool calls.

---

## Refactoring Workflow

### Phase 1: Analysis

1. **Read project structure**
   - Check `go.mod` for module name, Go version, dependencies
   - Identify main entry point (`main.go` location)
   - List all packages in the project

2. **Identify violations** against Go plugin standards:

   | Standard             | Violation Pattern                 |
   | -------------------- | --------------------------------- |
   | No `internal/`       | `internal/` directories exist     |
   | No `os.Getenv()`     | Direct env variable access        |
   | No manual validation | Missing validator/v10 tags        |
   | No `cmd/` for main   | `main.go` in `cmd/` subdirectory  |
   | Error wrapping       | `return err` without `fmt.Errorf` |
   | No `pkg/errors`      | Using `github.com/pkg/errors`     |

3. **Check for dependency issues**
   - Outdated major versions with breaking changes
   - **Legacy error package**: Using `github.com/pkg/errors` (superseded by
     stdlib since Go 1.13)
   - Missing required libraries (cobra, envconfig, validator/v10, testify,
     otelzap)
   - Unused or vendored dependencies

4. **Create refactoring plan** using TodoWrite with specific tasks

### Phase 2: Package Migration

**If `internal/` packages exist:**

1. Create `pkg/` directory structure mirroring `internal/`
2. Move each package: `internal/<name>` → `pkg/<name>`
3. Update ALL import paths across entire codebase:

   ```bash
   # Find all files with old import path
   grep -r "module-name/internal/" --include="*.go"
   ```

4. Verify no remaining `internal/` references
5. Delete empty `internal/` directory

**Import path update pattern:**

```text
OLD: github.com/org/project/internal/mypackage
NEW: github.com/org/project/pkg/mypackage
```

### Phase 3: Dependency Updates

1. **Check for breaking changes** in major dependency updates:
   - Read release notes / changelogs
   - Search for migration guides
   - Compare API signatures between versions

2. **Common breaking change patterns:**

   | Library      | v1 → v2 Changes                                    |
   | ------------ | -------------------------------------------------- |
   | Google ADK   | `llmagent.New()` returns interface not pointer     |
   | ADK Tools    | `tool.Tool` is interface, use `functiontool.New()` |
   | ADK Model    | `model.Generate()` → `model.GenerateContent()`     |
   | ADK Launcher | `launcher.Parse()` + `Run()` → `Execute()`         |

3. **Update go.mod** with new versions
4. **Run `go mod tidy`** to resolve dependencies
5. **Fix compilation errors** from API changes

### Phase 4: Code Standards

1. **Configuration**: Replace `os.Getenv()` with envconfig

   ```go
   // Before
   port := os.Getenv("PORT")

   // After
   type Config struct {
       Port int `envconfig:"PORT" default:"8080"`
   }
   ```

2. **Validation**: Add validator/v10 tags to structs

   ```go
   type Request struct {
       Email string `json:"email" validate:"required,email"`
   }
   ```

3. **Error wrapping**: Migrate from `pkg/errors` to standard library

   Since Go 1.13, the standard library provides native error wrapping with
   `fmt.Errorf` and the `%w` verb. The `github.com/pkg/errors` package is now
   superseded and should be replaced.

   **Migration patterns:**

   ```go
   // Before (pkg/errors)
   import "github.com/pkg/errors"

   return errors.Wrap(err, "failed to process")
   return errors.Wrapf(err, "failed to process %s", item)
   return errors.New("something failed")
   return errors.Errorf("invalid value: %s", val)

   // After (standard library)
   import "fmt"

   return fmt.Errorf("failed to process: %w", err)
   return fmt.Errorf("failed to process %s: %w", item, err)
   return fmt.Errorf("something failed")
   return fmt.Errorf("invalid value: %s", val)
   ```

   **Steps:**
   1. Search for all `github.com/pkg/errors` imports
   2. Replace `errors.Wrap(err, "msg")` → `fmt.Errorf("msg: %w", err)`
   3. Replace `errors.Wrapf(err, "fmt", args)` → `fmt.Errorf("fmt: %w", args, err)`
   4. Replace `errors.New("msg")` → `fmt.Errorf("msg")`
   5. Replace `errors.Errorf(...)` → `fmt.Errorf(...)`
   6. Remove `pkg/errors` from imports and `go.mod`
   7. Run `go mod tidy` to clean up

4. **Logging**: Migrate to otelzap

   ```go
   // Before
   log.Printf("message: %s", msg)

   // After
   logger.Ctx(ctx).Info("message", zap.String("key", msg))
   ```

### Phase 5: Testing

1. **Run tests**: `/go:cmd-test $ARGUMENTS`
2. **Run linter**: `/go:cmd-lint $ARGUMENTS`
3. **Build**: `/go:cmd-build $ARGUMENTS`

### Phase 6: Cleanup

1. Remove unused packages
2. Remove unused imports
3. Delete empty directories
4. Update documentation

---

## Common Refactoring Tasks

### Task: Remove `internal/` packages

```bash
# 1. List internal packages
find $DIRECTORY -type d -name "internal" -exec ls -la {} \;

# 2. Create pkg structure
mkdir -p $DIRECTORY/pkg

# 3. Move packages
mv $DIRECTORY/internal/* $DIRECTORY/pkg/

# 4. Update imports
# Use sed or manual Edit tool for each file

# 5. Verify
grep -r "internal/" $DIRECTORY --include="*.go"

# 6. Delete internal
rm -rf $DIRECTORY/internal
```

### Task: Migrate from `pkg/errors` to standard library

Replace `github.com/pkg/errors` with standard library `fmt.Errorf`:

```bash
# 1. Find all files using pkg/errors
grep -r "github.com/pkg/errors" $DIRECTORY --include="*.go"

# 2. Find all error wrapping calls
grep -r "errors\.Wrap\|errors\.Wrapf" $DIRECTORY --include="*.go"

# 3. Replace each file using Edit tool:
# - Remove: import "github.com/pkg/errors"
# - Add (if not present): import "fmt"
# - Replace: errors.Wrap(err, "msg") → fmt.Errorf("msg: %w", err)
# - Replace: errors.Wrapf(err, "fmt", args) → fmt.Errorf("fmt: %w", args, err)
# - Replace: errors.New("msg") → fmt.Errorf("msg")
# - Replace: errors.Errorf(...) → fmt.Errorf(...)

# 4. Clean up dependencies
go mod tidy

# 5. Verify no pkg/errors remains
grep -r "pkg/errors" $DIRECTORY --include="*.go"
```

### Task: Add error wrapping context

Search for bare error returns:

```text
pattern: return err$
```

Wrap with context:

```go
return fmt.Errorf("operation name: %w", err)
```

### Task: Add CLI framework (Cobra)

1. Create `cmd/root.go`:

```go
var rootCmd = &cobra.Command{
    Use:   "appname",
    Short: "Application description",
}

func Execute() error {
    return rootCmd.Execute()
}
```

1. Update `main.go`:

```go
func main() {
    if err := cmd.Execute(); err != nil {
        os.Exit(1)
    }
}
```

### Task: Update ADK v0.1.0 → v0.2.0

Key changes:

1. `*llmagent.Agent` → `agent.Agent` (interface)
2. `tool.Tool{}` struct → `functiontool.New()` factory
3. Tool handlers: `func(ctx context.Context, args map[string]any)` →
   `func(ctx tool.Context, args TypedStruct)`
4. `agent.NewMultiLoader(agents...)` →
   `agent.NewMultiLoader(agents[0], agents[1:]...)`
5. `launcher.Config` instead of `adk.Config`
6. `full.NewLauncher().Execute()` instead of `launcher.Parse()` + `Run()`

---

## Output

After refactoring, report:

1. **Changes made**: List of modifications
2. **Remaining work**: Tasks not completed and why
3. **Build status**: Pass/fail from `/go:cmd-build`
4. **Test status**: Pass/fail from `/go:cmd-test`
5. **Lint status**: Pass/fail from `/go:cmd-lint`

---

## Notes

- Always backup or use git before major refactoring
- Run tests after each phase to catch regressions early
- Use TodoWrite to track progress on complex refactoring
- Ask user for clarification on architectural decisions
