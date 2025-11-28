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
echo "============================"

# Test: Scripts exist and are executable
for script in detect-exec.sh block-bash.sh enforce-no-files.sh; do
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

# Test: Hook scoping - should allow when not in plugin context
echo '{"tool_name":"Write","tool_input":{"file_path":"/tmp/test.go"}}' | \
    CLAUDE_PLUGIN_ROOT="" "$SCRIPTS_DIR/enforce-no-files.sh" && \
    pass "Allows writes when not in plugin context" || \
    fail "Hook scoping" "Should allow when CLAUDE_PLUGIN_ROOT is empty"

# Test: enforce-no-files.sh blocks Write in plugin context
result=$(echo '{"tool_name":"Write","tool_input":{"file_path":"/tmp/test.go"}}' | \
    CLAUDE_PLUGIN_ROOT="$PLUGIN_DIR" "$SCRIPTS_DIR/enforce-no-files.sh" 2>&1 || true)
if [[ "$result" == *"BLOCKED"* ]]; then
    pass "Blocks Write in plugin context"
else
    fail "File restriction" "Should block Write"
fi

# Test: enforce-no-files.sh blocks Edit in plugin context
result=$(echo '{"tool_name":"Edit","tool_input":{"file_path":"/tmp/test.go"}}' | \
    CLAUDE_PLUGIN_ROOT="$PLUGIN_DIR" "$SCRIPTS_DIR/enforce-no-files.sh" 2>&1 || true)
if [[ "$result" == *"BLOCKED"* ]]; then
    pass "Blocks Edit in plugin context"
else
    fail "File restriction" "Should block Edit"
fi

# Test: block-bash.sh allows plugin scripts
echo '{"tool_input":{"command":"/path/to/claude-plugins/orchestrator/scripts/detect-exec.sh /repo"}}' | \
    CLAUDE_PLUGIN_ROOT="$PLUGIN_DIR" "$SCRIPTS_DIR/block-bash.sh" && \
    pass "Allows plugin scripts" || \
    fail "Script access" "Should allow plugin scripts"

# Test: block-bash.sh blocks git commands
result=$(echo '{"tool_input":{"command":"git status"}}' | \
    CLAUDE_PLUGIN_ROOT="$PLUGIN_DIR" "$SCRIPTS_DIR/block-bash.sh" 2>&1 || true)
if [[ "$result" == *"BLOCKED"* ]]; then
    pass "Blocks git commands"
else
    fail "Git restriction" "Should block git"
fi

# Test: block-bash.sh blocks cat/head/tail
result=$(echo '{"tool_input":{"command":"cat /tmp/file.txt"}}' | \
    CLAUDE_PLUGIN_ROOT="$PLUGIN_DIR" "$SCRIPTS_DIR/block-bash.sh" 2>&1 || true)
if [[ "$result" == *"BLOCKED"* ]]; then
    pass "Blocks cat command"
else
    fail "Read restriction" "Should block cat"
fi

# Test: block-bash.sh blocks arbitrary bash
result=$(echo '{"tool_input":{"command":"ls -la /tmp"}}' | \
    CLAUDE_PLUGIN_ROOT="$PLUGIN_DIR" "$SCRIPTS_DIR/block-bash.sh" 2>&1 || true)
if [[ "$result" == *"BLOCKED"* ]]; then
    pass "Blocks arbitrary bash commands"
else
    fail "Bash restriction" "Should block ls"
fi

echo ""
echo "Results: $passed passed, $failed failed"
[[ $failed -eq 0 ]] && exit 0 || exit 1
