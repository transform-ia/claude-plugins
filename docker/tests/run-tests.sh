#!/bin/bash
# Test suite for Docker plugin
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

echo "Testing Docker Plugin"
echo "====================="

# Test: Scripts exist and are executable
for script in enforce-docker-files.sh block-bash.sh lint-exec.sh image-tag-exec.sh stop-lint-check.sh; do
    if [[ -x "$SCRIPTS_DIR/$script" ]]; then
        pass "$script exists and is executable"
    else
        fail "$script" "Not found or not executable"
    fi
done

# Test: Hook scoping - should allow when not in plugin context (no transcript_path)
echo '{"tool_name":"Write","tool_input":{"file_path":"/tmp/test.go"}}' | \
    "$SCRIPTS_DIR/enforce-docker-files.sh" && \
    pass "Allows writes when not in plugin context" || \
    fail "Hook scoping" "Should allow when transcript_path is missing"

# Test: Hook scoping - should block .go files in plugin context
result=$(echo '{"tool_name":"Write","tool_input":{"file_path":"/tmp/test.go"},"transcript_path":"/tmp/t.json","tool_use_id":"test-123"}' | \
    TEST_CALLER="/docker:skill-dev" "$SCRIPTS_DIR/enforce-docker-files.sh" 2>&1 || true)
if [[ "$result" == *"BLOCKED"* ]]; then
    pass "Blocks .go files in plugin context"
else
    fail "File restriction" "Should block .go files"
fi

# Test: Allows Dockerfile in plugin context
echo '{"tool_name":"Write","tool_input":{"file_path":"/tmp/Dockerfile"},"transcript_path":"/tmp/t.json","tool_use_id":"test-123"}' | \
    TEST_CALLER="/docker:skill-dev" "$SCRIPTS_DIR/enforce-docker-files.sh" && \
    pass "Allows Dockerfile in plugin context" || \
    fail "File restriction" "Should allow Dockerfile"

# Test: Allows .dockerignore in plugin context
echo '{"tool_name":"Write","tool_input":{"file_path":"/tmp/.dockerignore"},"transcript_path":"/tmp/t.json","tool_use_id":"test-123"}' | \
    TEST_CALLER="/docker:skill-dev" "$SCRIPTS_DIR/enforce-docker-files.sh" && \
    pass "Allows .dockerignore in plugin context" || \
    fail "File restriction" "Should allow .dockerignore"

# Test: rm deletion - allows Dockerfile
echo '{"tool_input":{"command":"rm /tmp/Dockerfile"},"transcript_path":"/tmp/t.json","tool_use_id":"test-123"}' | \
    TEST_CALLER="/docker:skill-dev" "$SCRIPTS_DIR/block-bash.sh" && \
    pass "Allows rm Dockerfile" || \
    fail "Deletion" "Should allow deleting Dockerfile"

# Test: rm deletion - allows .dockerignore
echo '{"tool_input":{"command":"rm /tmp/.dockerignore"},"transcript_path":"/tmp/t.json","tool_use_id":"test-123"}' | \
    TEST_CALLER="/docker:skill-dev" "$SCRIPTS_DIR/block-bash.sh" && \
    pass "Allows rm .dockerignore" || \
    fail "Deletion" "Should allow deleting .dockerignore"

# Test: rm deletion - blocks non-docker files
result=$(echo '{"tool_input":{"command":"rm /tmp/test.go"},"transcript_path":"/tmp/t.json","tool_use_id":"test-123"}' | \
    TEST_CALLER="/docker:skill-dev" "$SCRIPTS_DIR/block-bash.sh" 2>&1 || true)
if [[ "$result" == *"BLOCKED"* ]]; then
    pass "Blocks rm non-docker files"
else
    fail "Deletion security" "Should block deleting non-docker files"
fi

echo ""
echo "Results: $passed passed, $failed failed"
[[ $failed -eq 0 ]] && exit 0 || exit 1
