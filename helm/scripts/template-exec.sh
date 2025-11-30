#!/bin/bash
# Execute helm template to preview rendered manifests
# Usage: template-exec.sh <directory> [release-name]
set -euo pipefail

if [[ -z "${1:-}" ]]; then
    echo "Usage: /helm:cmd-template <directory> [release-name]" >&2
    echo "" >&2
    echo "Examples:" >&2
    echo "  /helm:cmd-template /path/to/chart" >&2
    echo "  /helm:cmd-template . my-release" >&2
    exit 1
fi

TARGET="$1"
RELEASE="${2:-test}"

if [[ ! -d "$TARGET" ]]; then
    echo "Error: $TARGET is not a directory" >&2
    exit 1
fi

if [[ ! -f "$TARGET/Chart.yaml" ]]; then
    echo "Error: $TARGET/Chart.yaml not found" >&2
    exit 1
fi

# Check helm availability
if ! command -v helm >/dev/null 2>&1; then
    echo "" >&2
    echo "═══════════════════════════════════════════════════════════════" >&2
    echo "ERROR: helm not found" >&2
    echo "═══════════════════════════════════════════════════════════════" >&2
    echo "" >&2
    echo "The Helm CLI is required for template rendering." >&2
    echo "" >&2
    exit 2
fi

# Render template with error handling
if ! helm template "$RELEASE" "$TARGET" --debug 2>&1; then
    echo "" >&2
    echo "ERROR: helm template failed" >&2
    echo "Review template syntax errors above." >&2
    echo "" >&2
    exit 1
fi
