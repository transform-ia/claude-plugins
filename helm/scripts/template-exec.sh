#!/bin/bash
# Execute helm template to preview rendered manifests
set -euo pipefail

TARGET="${1:-.}"
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
