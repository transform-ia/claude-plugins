#!/bin/bash
# Execute prettier + yamllint + helm lint on a chart directory
# Usage: lint-exec.sh <directory>
set -euo pipefail

if [[ -z "${1:-}" ]]; then
    echo "Usage: /helm:cmd-lint <directory>" >&2
    echo "" >&2
    echo "Examples:" >&2
    echo "  /helm:cmd-lint /path/to/chart" >&2
    echo "  /helm:cmd-lint ." >&2
    exit 1
fi

TARGET="$1"

if [[ ! -d "$TARGET" ]]; then
    echo "Error: $TARGET is not a directory" >&2
    exit 1
fi

if [[ ! -f "$TARGET/Chart.yaml" ]]; then
    echo "Error: $TARGET/Chart.yaml not found" >&2
    exit 1
fi

cd "$TARGET"

# Check tool availability
for tool in prettier yamllint helm; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "" >&2
        echo "═══════════════════════════════════════════════════════════════" >&2
        echo "ERROR: Required tool not found: $tool" >&2
        echo "═══════════════════════════════════════════════════════════════" >&2
        echo "" >&2
        echo "The /helm:cmd-lint requires:" >&2
        echo "  - prettier (YAML formatting)" >&2
        echo "  - yamllint (YAML linting)" >&2
        echo "  - helm (Helm CLI)" >&2
        echo "" >&2
        exit 2
    fi
done

ERRORS=0

# Format first (prettier)
echo "=== prettier ==="
if ! prettier --write 'Chart.yaml' 'values.yaml' 2>&1; then
    echo "" >&2
    echo "ERROR: prettier formatting failed" >&2
    echo "Fix YAML syntax errors above before continuing." >&2
    echo "" >&2
    exit 1
fi
echo "Formatting completed."
# Note: templates/ is not formatted - contains Go template syntax

# Run yamllint on Chart.yaml and values.yaml
echo ""
echo "=== yamllint ==="
if [[ -f ".yamllint.yaml" ]]; then
    if ! yamllint -c .yamllint.yaml Chart.yaml values.yaml 2>&1; then
        echo "" >&2
        echo "yamllint found issues. Fix them and run /helm:cmd-lint again." >&2
        ERRORS=1
    fi
else
    if ! yamllint Chart.yaml values.yaml 2>&1; then
        echo "" >&2
        echo "yamllint found issues. Fix them and run /helm:cmd-lint again." >&2
        ERRORS=1
    fi
fi

# Run helm lint
echo ""
echo "=== helm lint ==="
if ! helm lint . 2>&1; then
    echo "" >&2
    echo "helm lint found issues. Fix them and run /helm:cmd-lint again." >&2
    ERRORS=1
fi

# Exit with summary
if [[ $ERRORS -eq 1 ]]; then
    echo "" >&2
    echo "Linting failed. Review errors above." >&2
    exit 1
else
    echo "" >&2
    echo "All linting checks passed." >&2
    exit 0
fi
