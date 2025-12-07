#!/bin/bash
set -euo pipefail

# cmd-bootstrap.sh - Assemble CI workflow and dependabot from templates
#
# Usage: cmd-bootstrap.sh <directory> <claude_image_tag> <golang_image_tag> <chart_name> [--go] [--docker] [--helm]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="${SCRIPT_DIR}/../assets/templates"

if [[ $# -lt 4 ]]; then
    echo "Usage: cmd-bootstrap.sh <directory> <claude_image_tag> <golang_image_tag> <chart_name> [--go] [--docker] [--helm]"
    exit 1
fi

TARGET_DIR="$1"
CLAUDE_IMAGE_TAG="$2"
GOLANG_IMAGE_TAG="$3"
CHART_NAME="$4"
shift 4

# Parse feature flags
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

# Build CI workflow
CI_FILE="${TARGET_DIR}/.github/workflows/ci.yaml"

# Start with header
sed "s/<<CLAUDE_IMAGE_TAG>>/${CLAUDE_IMAGE_TAG}/g" "${TEMPLATE_DIR}/ci-header.yaml.tmpl" > "${CI_FILE}"

# Add jobs section and base lint job
cat >> "${CI_FILE}" << 'EOF'
jobs:
  lint:
    runs-on: ubuntu-latest
    container:
EOF

cat >> "${CI_FILE}" << EOF
      image: ghcr.io/transform-ia/claude-image:${CLAUDE_IMAGE_TAG}
EOF

cat >> "${CI_FILE}" << 'EOF'
      options: --user 0
      credentials:
        username: ${{ github.actor }}
        password: ${{ secrets.GH_PAT }}
    steps:
      - uses: actions/checkout@v4

      - name: Lint YAML
        run: yamllint .

      - name: Lint Markdown
        run: markdownlint '**/*.md' --ignore node_modules --ignore .npm-cache
EOF

# Add hadolint step if Docker enabled
if [[ "${ENABLE_DOCKER}" == "true" ]]; then
    cat "${TEMPLATE_DIR}/step-lint-hadolint.yaml.tmpl" >> "${CI_FILE}"
fi

# Add helm lint step if Helm enabled
if [[ "${ENABLE_HELM}" == "true" ]]; then
    cat "${TEMPLATE_DIR}/step-lint-helm.yaml.tmpl" >> "${CI_FILE}"
fi

echo "" >> "${CI_FILE}"

# Collect lint job names for needs
LINT_JOBS="lint"

# Add Go lint job if enabled
if [[ "${ENABLE_GO}" == "true" ]]; then
    sed "s/<<GOLANG_IMAGE_TAG>>/${GOLANG_IMAGE_TAG}/g" "${TEMPLATE_DIR}/job-lint-go.yaml.tmpl" >> "${CI_FILE}"
    LINT_JOBS="lint, lint-go"
fi

# Add Docker build job if enabled
if [[ "${ENABLE_DOCKER}" == "true" ]]; then
    sed "s/<<NEEDS_JOBS>>/${LINT_JOBS}/g" "${TEMPLATE_DIR}/job-build-docker.yaml.tmpl" >> "${CI_FILE}"
fi

# Add Helm package job if enabled
if [[ "${ENABLE_HELM}" == "true" ]]; then
    sed -e "s/<<NEEDS_JOBS>>/${LINT_JOBS}/g" \
        -e "s/<<CLAUDE_IMAGE_TAG>>/${CLAUDE_IMAGE_TAG}/g" \
        -e "s/<<CHART_NAME>>/${CHART_NAME}/g" \
        "${TEMPLATE_DIR}/job-package-helm.yaml.tmpl" >> "${CI_FILE}"
fi

# Build dependabot.yaml
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
echo "  - ${CI_FILE}"
echo "  - ${DEPENDABOT_FILE}"
echo "  - ${TARGET_DIR}/.yamllint.yaml"
