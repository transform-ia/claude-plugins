#!/bin/bash
# Debug hook - dumps environment and input to /tmp for analysis

set -euo pipefail

OUTPUT="/tmp/hook-debug-$(date +%s%N).txt"

{
    echo "=== TIMESTAMP ==="
    date -Iseconds

    echo ""
    echo "=== ENVIRONMENT VARIABLES ==="
    env | sort

    echo ""
    echo "=== STDIN INPUT ==="
    cat
} > "$OUTPUT"

echo "Debug output written to: $OUTPUT" >&2
exit 0
