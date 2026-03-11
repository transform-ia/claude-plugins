#!/bin/bash
# Test suite for Markdown plugin
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

# Helpers: switch plugin scope context
in_scope()  { export CLAUDE_PLUGIN_ROOT="$PLUGIN_DIR"; }
out_scope() { export CLAUDE_PLUGIN_ROOT="/tmp/other-plugin"; }

# Start out of scope by default
out_scope

echo "Testing Markdown Plugin"
echo "========================"

# Test: Scripts exist and are executable
for script in enforce-md-files.sh block-bash.sh mdlint.sh stop-lint-check.sh; do
    if [[ -x "$SCRIPTS_DIR/$script" ]]; then
        pass "$script exists and is executable"
    else
        fail "$script" "Not found or not executable"
    fi
done

# Test: Config and validator files exist
if [[ -f "$SCRIPTS_DIR/config.sh" ]]; then
    pass "config.sh exists"
else
    fail "config.sh" "Not found"
fi

if [[ -f "$SCRIPTS_DIR/lib/validators.sh" ]]; then
    pass "lib/validators.sh exists"
else
    fail "lib/validators.sh" "Not found"
fi

# Test: Hook scoping - allows writes when not in markdown plugin scope
out_scope
echo '{"tool_name":"Write","tool_input":{"file_path":"/tmp/test.go"}}' | \
    "$SCRIPTS_DIR/enforce-md-files.sh" && \
    pass "Allows writes when not in markdown plugin scope" || \
    fail "Hook scoping" "Should allow when CLAUDE_PLUGIN_ROOT is not markdown"

# Test: Blocks .go files when in markdown plugin scope
in_scope
result=$(echo '{"tool_name":"Write","tool_input":{"file_path":"/tmp/test.go"}}' | \
    "$SCRIPTS_DIR/enforce-md-files.sh" 2>&1 || true)
if [[ "$result" == *"BLOCKED"* ]]; then
    pass "Blocks .go files when in markdown plugin scope"
else
    fail "File restriction" "Should block .go files when in scope"
fi

# Test: Allows .md files when in markdown plugin scope
in_scope
echo '{"tool_name":"Write","tool_input":{"file_path":"/tmp/test.md"}}' | \
    "$SCRIPTS_DIR/enforce-md-files.sh" && \
    pass "Allows .md files when in markdown plugin scope" || \
    fail "File restriction" "Should allow .md files"

# Test: rm deletion - allows exact allowlist patterns when in scope
in_scope
for pattern in "rm *.md" "rm **/*.md" "rm -f *.md" "rm -rf *.md"; do
    if echo "{\"tool_input\":{\"command\":\"$pattern\"}}" | \
        "$SCRIPTS_DIR/block-bash.sh" 2>&1 | grep -q "BLOCKED"; then
        fail "Allowlist" "Pattern '$pattern' should be allowed but was blocked"
    else
        pass "Allowlist allows: '$pattern'"
    fi
done

# Test: rm deletion - blocks non-exact patterns when in scope
in_scope
result=$(echo '{"tool_input":{"command":"rm /tmp/test.md"}}' | \
    "$SCRIPTS_DIR/block-bash.sh" 2>&1 || true)
if [[ "$result" == *"BLOCKED"* ]]; then
    pass "Blocks 'rm /tmp/test.md' (not in allowlist)"
else
    fail "Deletion security" "Should block commands not in exact allowlist"
fi

# Test: blocks non-md file deletion when in scope
in_scope
result=$(echo '{"tool_input":{"command":"rm /tmp/test.go"}}' | \
    "$SCRIPTS_DIR/block-bash.sh" 2>&1 || true)
if [[ "$result" == *"BLOCKED"* ]]; then
    pass "Blocks 'rm /tmp/test.go' (not in allowlist)"
else
    fail "Deletion security" "Should block deleting non-.md files"
fi

# Test: Plugin own scripts are allowed when in scope
in_scope
echo "{\"tool_input\":{\"command\":\"${CLAUDE_PLUGIN_ROOT}/scripts/mdlint.sh README.md\"}}" | \
    "$SCRIPTS_DIR/block-bash.sh" && \
    pass "Allows plugin's own scripts" || \
    fail "Plugin scripts" "Should allow \${CLAUDE_PLUGIN_ROOT}/scripts/*"

# Test: Nothing is blocked when out of scope (even normally-blocked commands)
out_scope
echo '{"tool_input":{"command":"go build ./..."}}' | \
    "$SCRIPTS_DIR/block-bash.sh" && \
    pass "Allows any Bash command when not in markdown plugin scope" || \
    fail "Scope check" "Should allow all commands when not in scope"

echo ""
echo "Results: $passed passed, $failed failed"
[[ $failed -eq 0 ]] && exit 0 || exit 1
