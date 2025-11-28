#!/bin/bash
# Test suite for Orchestrator plugin
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SCRIPTS_DIR="$PLUGIN_DIR/scripts"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

passed=0
failed=0

pass() { echo -e "${GREEN}✓${NC} $1"; ((++passed)); }
fail() { echo -e "${RED}✗${NC} $1: $2"; ((++failed)); }

echo "Testing Orchestrator Plugin"
echo "==========================="

# Test: Scripts exist and are executable
for script in detect-exec.sh; do
    if [[ -x "$SCRIPTS_DIR/$script" ]]; then
        pass "$script exists and is executable"
    else
        fail "$script" "Not found or not executable"
    fi
done

# Test: detect-exec.sh runs without error on current directory
output=$("$SCRIPTS_DIR/detect-exec.sh" "$PLUGIN_DIR" 2>&1) && \
    pass "detect-exec.sh runs successfully" || \
    fail "detect-exec.sh" "Script failed to run"

# Test: detect-exec.sh returns expected output format
if [[ "$output" == *"Repository:"* ]] && [[ "$output" == *"Detected frameworks:"* ]]; then
    pass "detect-exec.sh returns expected format"
else
    fail "detect-exec.sh output" "Missing expected sections"
fi

echo ""
echo "Results: $passed passed, $failed failed"
[[ $failed -eq 0 ]] && exit 0 || exit 1
