#!/bin/bash
# Test suite for Helm plugin
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

echo "Testing Helm Plugin"
echo "==================="

# Test: Scripts exist and are executable
for script in enforce-helm-files.sh block-bash.sh lint-exec.sh format-exec.sh template-exec.sh stop-lint-check.sh; do
    if [[ -x "$SCRIPTS_DIR/$script" ]]; then
        pass "$script exists and is executable"
    else
        fail "$script" "Not found or not executable"
    fi
done

# Test: Hook scoping - should allow when not in plugin context
echo '{"tool_name":"Write","tool_input":{"file_path":"/tmp/test.go"}}' | \
    CLAUDE_PLUGIN_ROOT="" "$SCRIPTS_DIR/enforce-helm-files.sh" && \
    pass "Allows writes when not in plugin context" || \
    fail "Hook scoping" "Should allow when CLAUDE_PLUGIN_ROOT is empty"

# Test: Hook scoping - should block .go files in plugin context
result=$(echo '{"tool_name":"Write","tool_input":{"file_path":"/tmp/test.go"}}' | \
    CLAUDE_PLUGIN_ROOT="$PLUGIN_DIR" "$SCRIPTS_DIR/enforce-helm-files.sh" 2>&1 || true)
if [[ "$result" == *"BLOCKED"* ]]; then
    pass "Blocks .go files in plugin context"
else
    fail "File restriction" "Should block .go files"
fi

# Test: Allows Chart.yaml in plugin context
echo '{"tool_name":"Write","tool_input":{"file_path":"/tmp/Chart.yaml"}}' | \
    CLAUDE_PLUGIN_ROOT="$PLUGIN_DIR" "$SCRIPTS_DIR/enforce-helm-files.sh" && \
    pass "Allows Chart.yaml in plugin context" || \
    fail "File restriction" "Should allow Chart.yaml"

# Test: Allows values.yaml in plugin context
echo '{"tool_name":"Write","tool_input":{"file_path":"/tmp/values.yaml"}}' | \
    CLAUDE_PLUGIN_ROOT="$PLUGIN_DIR" "$SCRIPTS_DIR/enforce-helm-files.sh" && \
    pass "Allows values.yaml in plugin context" || \
    fail "File restriction" "Should allow values.yaml"

# Test: Allows templates/ files in plugin context
echo '{"tool_name":"Write","tool_input":{"file_path":"/tmp/templates/deployment.yaml"}}' | \
    CLAUDE_PLUGIN_ROOT="$PLUGIN_DIR" "$SCRIPTS_DIR/enforce-helm-files.sh" && \
    pass "Allows templates/*.yaml in plugin context" || \
    fail "File restriction" "Should allow templates files"

# Test: rm deletion - allows Chart.yaml
echo '{"tool_input":{"command":"rm /tmp/Chart.yaml"}}' | \
    CLAUDE_PLUGIN_ROOT="$PLUGIN_DIR" "$SCRIPTS_DIR/block-bash.sh" && \
    pass "Allows rm Chart.yaml" || \
    fail "Deletion" "Should allow deleting Chart.yaml"

# Test: rm deletion - allows values.yaml
echo '{"tool_input":{"command":"rm /tmp/values.yaml"}}' | \
    CLAUDE_PLUGIN_ROOT="$PLUGIN_DIR" "$SCRIPTS_DIR/block-bash.sh" && \
    pass "Allows rm values.yaml" || \
    fail "Deletion" "Should allow deleting values.yaml"

# Test: rm deletion - allows templates/*.yaml
echo '{"tool_input":{"command":"rm /tmp/templates/deployment.yaml"}}' | \
    CLAUDE_PLUGIN_ROOT="$PLUGIN_DIR" "$SCRIPTS_DIR/block-bash.sh" && \
    pass "Allows rm templates/*.yaml" || \
    fail "Deletion" "Should allow deleting template files"

# Test: rm deletion - blocks non-helm files
result=$(echo '{"tool_input":{"command":"rm /tmp/test.go"}}' | \
    CLAUDE_PLUGIN_ROOT="$PLUGIN_DIR" "$SCRIPTS_DIR/block-bash.sh" 2>&1 || true)
if [[ "$result" == *"BLOCKED"* ]]; then
    pass "Blocks rm non-helm files"
else
    fail "Deletion security" "Should block deleting non-helm files"
fi

# Test: Blocks Write to .yamllint.yaml (protects linter config)
result=$(echo '{"tool_name":"Write","tool_input":{"file_path":"/tmp/.yamllint.yaml"}}' | \
    CLAUDE_PLUGIN_ROOT="$PLUGIN_DIR" "$SCRIPTS_DIR/enforce-helm-files.sh" 2>&1 || true)
if [[ "$result" == *"BLOCKED"* ]] && [[ "$result" == *"linter"* ]]; then
    pass "Blocks Write .yamllint.yaml (protects linter config)"
else
    fail "Linter protection" "Should block .yamllint.yaml modification"
fi

# Test: Blocks rm .yamllint.yaml (protects linter config)
result=$(echo '{"tool_input":{"command":"rm /tmp/.yamllint.yaml"}}' | \
    CLAUDE_PLUGIN_ROOT="$PLUGIN_DIR" "$SCRIPTS_DIR/block-bash.sh" 2>&1 || true)
if [[ "$result" == *"BLOCKED"* ]] && [[ "$result" == *"linter"* ]]; then
    pass "Blocks rm .yamllint.yaml (protects linter config)"
else
    fail "Linter protection" "Should block .yamllint.yaml deletion"
fi

echo ""
echo "Results: $passed passed, $failed failed"
[[ $failed -eq 0 ]] && exit 0 || exit 1
