#!/bin/bash
# Test suite for GitHub plugin
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

echo "Testing GitHub Plugin"
echo "====================="

# Test: Scripts exist and are executable
for script in enforce-github-files.sh block-bash.sh lint-exec.sh status-exec.sh logs-exec.sh stop-lint-check.sh; do
    if [[ -x "$SCRIPTS_DIR/$script" ]]; then
        pass "$script exists and is executable"
    else
        fail "$script" "Not found or not executable"
    fi
done

# Test: Hook scoping - should allow when not in plugin context
echo '{"tool_name":"Write","tool_input":{"file_path":"/tmp/test.go"}}' | \
    CLAUDE_PLUGIN_ROOT="" "$SCRIPTS_DIR/enforce-github-files.sh" && \
    pass "Allows writes when not in plugin context" || \
    fail "Hook scoping" "Should allow when CLAUDE_PLUGIN_ROOT is empty"

# Test: Hook scoping - should block .go files in plugin context
result=$(echo '{"tool_name":"Write","tool_input":{"file_path":"/tmp/test.go"}}' | \
    CLAUDE_PLUGIN_ROOT="$PLUGIN_DIR" "$SCRIPTS_DIR/enforce-github-files.sh" 2>&1 || true)
if [[ "$result" == *"BLOCKED"* ]]; then
    pass "Blocks .go files in plugin context"
else
    fail "File restriction" "Should block .go files"
fi

# Test: Allows .github/workflows files in plugin context
echo '{"tool_name":"Write","tool_input":{"file_path":"/tmp/.github/workflows/ci.yml"}}' | \
    CLAUDE_PLUGIN_ROOT="$PLUGIN_DIR" "$SCRIPTS_DIR/enforce-github-files.sh" && \
    pass "Allows .github/workflows/*.yml in plugin context" || \
    fail "File restriction" "Should allow .github/workflows files"

# Test: Allows .github/dependabot.yml in plugin context
echo '{"tool_name":"Write","tool_input":{"file_path":"/tmp/.github/dependabot.yml"}}' | \
    CLAUDE_PLUGIN_ROOT="$PLUGIN_DIR" "$SCRIPTS_DIR/enforce-github-files.sh" && \
    pass "Allows .github/dependabot.yml in plugin context" || \
    fail "File restriction" "Should allow dependabot.yml"

# Test: gh CLI restrictions - should block gh repo delete
result=$(echo '{"tool_input":{"command":"gh repo delete owner/repo --yes"}}' | \
    CLAUDE_PLUGIN_ROOT="$PLUGIN_DIR" "$SCRIPTS_DIR/block-bash.sh" 2>&1 || true)
if [[ "$result" == *"BLOCKED"* ]]; then
    pass "Blocks gh repo delete (security)"
else
    fail "gh security" "Should block gh repo delete"
fi

# Test: gh CLI restrictions - should block gh release delete
result=$(echo '{"tool_input":{"command":"gh release delete v1.0.0"}}' | \
    CLAUDE_PLUGIN_ROOT="$PLUGIN_DIR" "$SCRIPTS_DIR/block-bash.sh" 2>&1 || true)
if [[ "$result" == *"BLOCKED"* ]]; then
    pass "Blocks gh release delete (security)"
else
    fail "gh security" "Should block gh release delete"
fi

# Test: gh CLI restrictions - should block gh secret set
result=$(echo '{"tool_input":{"command":"gh secret set MY_SECRET"}}' | \
    CLAUDE_PLUGIN_ROOT="$PLUGIN_DIR" "$SCRIPTS_DIR/block-bash.sh" 2>&1 || true)
if [[ "$result" == *"BLOCKED"* ]]; then
    pass "Blocks gh secret set (security)"
else
    fail "gh security" "Should block gh secret set"
fi

# Test: gh CLI restrictions - should block gh run cancel
result=$(echo '{"tool_input":{"command":"gh run cancel 12345"}}' | \
    CLAUDE_PLUGIN_ROOT="$PLUGIN_DIR" "$SCRIPTS_DIR/block-bash.sh" 2>&1 || true)
if [[ "$result" == *"BLOCKED"* ]]; then
    pass "Blocks gh run cancel (security)"
else
    fail "gh security" "Should block gh run cancel"
fi

# Test: gh CLI restrictions - should allow gh run list
echo '{"tool_input":{"command":"gh run list --limit 5"}}' | \
    CLAUDE_PLUGIN_ROOT="$PLUGIN_DIR" "$SCRIPTS_DIR/block-bash.sh" && \
    pass "Allows gh run list (read-only)" || \
    fail "gh read" "Should allow gh run list"

# Test: gh CLI restrictions - should allow gh run view
echo '{"tool_input":{"command":"gh run view 12345"}}' | \
    CLAUDE_PLUGIN_ROOT="$PLUGIN_DIR" "$SCRIPTS_DIR/block-bash.sh" && \
    pass "Allows gh run view (read-only)" || \
    fail "gh read" "Should allow gh run view"

# Test: gh CLI restrictions - should allow gh api (GET)
echo '{"tool_input":{"command":"gh api repos/owner/repo/actions/runs"}}' | \
    CLAUDE_PLUGIN_ROOT="$PLUGIN_DIR" "$SCRIPTS_DIR/block-bash.sh" && \
    pass "Allows gh api GET (read-only)" || \
    fail "gh read" "Should allow gh api GET"

# Test: gh CLI restrictions - should block gh api POST
result=$(echo '{"tool_input":{"command":"gh api --method POST repos/owner/repo/issues"}}' | \
    CLAUDE_PLUGIN_ROOT="$PLUGIN_DIR" "$SCRIPTS_DIR/block-bash.sh" 2>&1 || true)
if [[ "$result" == *"BLOCKED"* ]]; then
    pass "Blocks gh api POST (security)"
else
    fail "gh security" "Should block gh api POST"
fi

echo ""
echo "Results: $passed passed, $failed failed"
[[ $failed -eq 0 ]] && exit 0 || exit 1
