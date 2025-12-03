#!/bin/bash
# Detect frameworks/technologies in a repository
# Returns: "Detected plugins: go, helm, docker, ..." or "Detected plugins: none"
# Usage: cmd-detect.sh <directory>
set -euo pipefail

if [[ -z "${1:-}" ]]; then
    echo "Usage: /orchestrator:cmd-detect <directory>" >&2
    echo "" >&2
    echo "Examples:" >&2
    echo "  /orchestrator:cmd-detect /path/to/repo" >&2
    echo "  /orchestrator:cmd-detect ." >&2
    exit 1
fi

TARGET="$1"

if [[ ! -d "$TARGET" ]]; then
    echo "Error: $TARGET is not a directory" >&2
    exit 1
fi

cd "$TARGET"

# Initialize detection results
DETECTED=()

# Go detection
if [[ -f "go.mod" ]]; then
    DETECTED+=("go")
fi

# Helm chart detection
if [[ -f "Chart.yaml" ]] || [[ -f "helm/Chart.yaml" ]]; then
    DETECTED+=("helm")
fi

# Dockerfile detection
if [[ -f "Dockerfile" ]] || ls Dockerfile.* 1>/dev/null 2>&1; then
    DETECTED+=("docker")
fi

# GitHub Actions detection
if [[ -d ".github/workflows" ]] || [[ -f ".github/dependabot.yaml" ]]; then
    DETECTED+=("github")
fi

# Node.js detection
if [[ -f "package.json" ]]; then
    DETECTED+=("nodejs")
fi

# Markdown detection (any .md files)
MD_COUNT=$(find . -maxdepth 2 -name "*.md" -type f 2>/dev/null | wc -l)
if [[ $MD_COUNT -gt 0 ]]; then
    DETECTED+=("markdown")
fi

# Output results - single line for Claude consumption
if [[ ${#DETECTED[@]} -eq 0 ]]; then
    echo "Detected plugins: none"
else
    # Join array with comma-space
    printf "Detected plugins: %s" "${DETECTED[0]}"
    for plugin in "${DETECTED[@]:1}"; do
        printf ", %s" "$plugin"
    done
    echo
fi
