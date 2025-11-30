#!/bin/bash
# Execute helm template to preview rendered manifests
# Usage: template-exec.sh <directory> [release-name]
set -euo pipefail

if [[ -z "${1:-}" ]]; then
    echo "Usage: /helm:template <directory> [release-name]" >&2
    echo "" >&2
    echo "Examples:" >&2
    echo "  /helm:template /path/to/chart" >&2
    echo "  /helm:template . my-release" >&2
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

helm template "$RELEASE" "$TARGET" --debug
