#!/bin/bash
# Detect frameworks/technologies in a repository
# Returns JSON with detected plugins to activate
set -euo pipefail

TARGET="${1:-.}"

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
if [[ -d ".github/workflows" ]] || [[ -f ".github/dependabot.yml" ]]; then
    DETECTED+=("github")
fi

# Markdown detection (significant .md files, not just README)
MD_COUNT=$(find . -maxdepth 2 -name "*.md" -type f 2>/dev/null | wc -l)
if [[ $MD_COUNT -gt 1 ]]; then
    DETECTED+=("markdown")
fi

# Output results
echo "Repository: $TARGET"
echo "Detected frameworks:"
echo "---"

if [[ ${#DETECTED[@]} -eq 0 ]]; then
    echo "  (none detected)"
else
    for framework in "${DETECTED[@]}"; do
        case "$framework" in
            go)
                echo "  - go (go.mod found)"
                echo "    Plugins: /go:dev, /go:lint, /go:test, /go:build"
                ;;
            helm)
                echo "  - helm (Chart.yaml found)"
                echo "    Plugins: /helm:dev, /helm:lint, /helm:ops"
                ;;
            docker)
                echo "  - docker (Dockerfile found)"
                echo "    Plugins: /docker:dev, /docker:lint, /docker:image-tag"
                ;;
            github)
                echo "  - github (.github/ found)"
                echo "    Plugins: /github:dev, /github:lint, /github:status"
                ;;
            markdown)
                echo "  - markdown (multiple .md files found)"
                echo "    Plugins: /markdown:dev, /markdown:lint"
                ;;
        esac
    done
fi

echo ""
echo "Recommended workflow:"
if [[ " ${DETECTED[*]} " =~ " go " ]]; then
    echo "  1. /go:lint - Lint Go code"
fi
if [[ " ${DETECTED[*]} " =~ " docker " ]]; then
    echo "  2. /docker:lint - Lint Dockerfile"
fi
if [[ " ${DETECTED[*]} " =~ " helm " ]]; then
    echo "  3. /helm:lint - Lint Helm chart"
fi
if [[ " ${DETECTED[*]} " =~ " github " ]]; then
    echo "  4. /github:lint - Lint CI/CD workflows"
fi
if [[ " ${DETECTED[*]} " =~ " markdown " ]]; then
    echo "  5. /markdown:lint - Lint documentation"
fi
