#!/bin/bash
# Check for unused values in Helm chart
# Usage: check-unused-values-exec.sh <directory>

set -euo pipefail

if [[ -z "${1:-}" ]]; then
    echo "Usage: /helm:check-unused-values <directory>" >&2
    echo "" >&2
    echo "Examples:" >&2
    echo "  /helm:check-unused-values /path/to/chart" >&2
    echo "  /helm:check-unused-values ." >&2
    exit 1
fi

CHART_DIR="$1"

if [[ ! -d "$CHART_DIR" ]]; then
    echo "Error: Directory not found: $CHART_DIR" >&2
    exit 1
fi

cd "$CHART_DIR"

if [[ ! -f "values.yaml" ]]; then
    echo "Error: values.yaml not found in $CHART_DIR" >&2
    exit 1
fi

if [[ ! -d "templates" ]]; then
    echo "Error: templates/ directory not found in $CHART_DIR" >&2
    exit 1
fi

echo "=== Analyzing Helm Chart: $(basename "$CHART_DIR") ==="
echo ""

# Get all .Values references from templates
echo "--- Template References ---"
template_refs=$(grep -rho '\.Values\.[a-zA-Z0-9_.-]*' templates/ 2>/dev/null | sed 's/\.Values\.//' | sort -u || true)

if [[ -z "$template_refs" ]]; then
    echo "No .Values references found in templates/"
    exit 0
fi

echo "Found $(echo "$template_refs" | wc -l | tr -d ' ') unique value references in templates"
echo ""

# Extract top-level keys from values.yaml
echo "--- Values.yaml Top-Level Keys ---"
values_keys=$(grep -E '^[a-zA-Z_][a-zA-Z0-9_]*:' values.yaml | sed 's/:.*$//' | sort -u)
echo "$values_keys"
echo ""

# Find unused top-level keys
echo "--- Analysis ---"
unused_count=0

for key in $values_keys; do
    # Check if this key or any sub-key is referenced in templates
    if ! echo "$template_refs" | grep -q "^${key}\|^${key}\."; then
        echo "POTENTIALLY UNUSED: $key"
        ((unused_count++)) || true
    fi
done

echo ""
if [[ $unused_count -eq 0 ]]; then
    echo "All top-level values appear to be used in templates."
else
    echo "Found $unused_count potentially unused top-level values."
    echo ""
    echo "Note: Some values may be used via:"
    echo "  - 'index' function for dynamic access"
    echo "  - _helpers.tpl includes"
    echo "  - Conditional blocks that weren't matched"
    echo ""
    echo "Review each before removing."
fi
