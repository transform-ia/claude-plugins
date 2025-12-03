#!/bin/bash
# Check for unused values in Helm chart
# Usage: check-unused-values-exec.sh <directory>

set -euo pipefail

if [[ -z "${1:-}" ]]; then
    echo "Usage: /helm:cmd-check-unused-values <directory>" >&2
    echo "" >&2
    echo "Examples:" >&2
    echo "  /helm:cmd-check-unused-values /path/to/chart" >&2
    echo "  /helm:cmd-check-unused-values ." >&2
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
# Match both dot notation (.Values.foo) and bracket notation (.Values["foo"] or .Values['foo'])
if ! template_refs=$(grep -rho '\\.Values\\.[a-zA-Z0-9_-]*\\|\\.Values\\[["'"'"'][^]]*["'"'"']\\]' "templates/" 2>&1 | \
    sed 's/\\.Values\\.//g; s/\\["//g; s/"\\]//g; s/'"'"'\\]//g' | sort -u); then
    # grep returns 1 if no matches (OK), but >1 means actual error
    if [[ $? -gt 1 ]]; then
        echo "ERROR: Failed to scan templates/ directory" >&2
        exit 2
    fi
    template_refs=""
fi

if [[ -z "$template_refs" ]]; then
    echo "No .Values references found in templates/"
    exit 0
fi

echo "Found $(echo "$template_refs" | wc -l | tr -d ' ') unique value references in templates"
echo ""

# Extract top-level keys from values.yaml
echo "--- Values.yaml Top-Level Keys ---"
# Allow dashes in key names (common in Helm: image-pull-secrets, service-account)
values_keys=$(grep -E '^[a-zA-Z_][a-zA-Z0-9_-]*:' "values.yaml" 2>/dev/null | sed 's/:.*$//' | sort -u || echo "")
echo "$values_keys"
echo ""

# Find unused top-level keys
echo "--- Analysis ---"
unused_count=0

for key in $values_keys; do
    # Check if this key or any sub-key is referenced in templates
    # Use -F for fixed string matching of key, then check for key.subkey pattern
    if ! echo "$template_refs" | grep -qF "${key}" && ! echo "$template_refs" | grep -q "^${key}\."; then
        echo "POTENTIALLY UNUSED: $key"
        unused_count=$((unused_count + 1))
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
