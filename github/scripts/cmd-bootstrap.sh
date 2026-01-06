#!/bin/bash
set -euo pipefail

# cmd-bootstrap.sh - Create CI workflow and dependabot for new repository
#
# Usage: cmd-bootstrap.sh <directory> [--go] [--docker] [--helm]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASSETS_DIR="${SCRIPT_DIR}/../assets"
TEMPLATE_DIR="${ASSETS_DIR}/templates"

if [[ $# -lt 1 ]]; then
    echo "Usage: cmd-bootstrap.sh <directory> [--go] [--docker] [--helm]"
    exit 1
fi

TARGET_DIR="$1"
shift

# Parse feature flags (for dependabot only - CI auto-detects)
ENABLE_GO=false
ENABLE_DOCKER=false
ENABLE_HELM=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --go) ENABLE_GO=true ;;
        --docker) ENABLE_DOCKER=true ;;
        --helm) ENABLE_HELM=true ;;
        *) echo "Unknown flag: $1"; exit 1 ;;
    esac
    shift
done

# Create directories
mkdir -p "${TARGET_DIR}/.github/workflows"

# Copy universal CI workflow (auto-detects features via hashFiles)
cp "${ASSETS_DIR}/ci.yaml" "${TARGET_DIR}/.github/workflows/ci.yaml"

# Build dependabot.yaml based on features
DEPENDABOT_FILE="${TARGET_DIR}/.github/dependabot.yaml"

cat > "${DEPENDABOT_FILE}" << 'EOF'
---
version: 2
updates:
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
EOF

if [[ "${ENABLE_GO}" == "true" ]]; then
    cat "${TEMPLATE_DIR}/dependabot-gomod.yaml.tmpl" >> "${DEPENDABOT_FILE}"
fi
if [[ "${ENABLE_DOCKER}" == "true" ]]; then
    cat "${TEMPLATE_DIR}/dependabot-docker.yaml.tmpl" >> "${DEPENDABOT_FILE}"
fi

# Create .yamllint.yaml if it doesn't exist
if [[ ! -f "${TARGET_DIR}/.yamllint.yaml" ]]; then
    cat > "${TARGET_DIR}/.yamllint.yaml" << 'EOF'
---
extends: default
rules:
  line-length:
    max: 140
EOF
fi

echo "Created:"
echo "  - ${TARGET_DIR}/.github/workflows/ci.yaml"
echo "  - ${DEPENDABOT_FILE}"
echo "  - ${TARGET_DIR}/.yamllint.yaml"
