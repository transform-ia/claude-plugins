#!/bin/bash
# Test suite for MCP plugin
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

echo "Testing MCP Plugin"
echo "=================="

# Test: Scripts exist and are executable
for script in enforce-mcp-files.sh block-bash.sh; do
    if [[ -x "$SCRIPTS_DIR/$script" ]]; then
        pass "$script exists and is executable"
    else
        fail "$script" "Not found or not executable"
    fi
done

# Test: Hook scoping - should allow when not in plugin context (no transcript_path)
echo '{"tool_name":"Write","tool_input":{"file_path":"/tmp/test.go"}}' | \
    "$SCRIPTS_DIR/enforce-mcp-files.sh" && \
    pass "Allows writes when not in plugin context" || \
    fail "Hook scoping" "Should allow when transcript_path is missing"

# Test: Hook scoping - should block .go files in plugin context
result=$(echo '{"tool_name":"Write","tool_input":{"file_path":"/tmp/test.go"},"transcript_path":"/tmp/t.json","tool_use_id":"test-123"}' | \
    TEST_CALLER="/mcp:skill-dev" "$SCRIPTS_DIR/enforce-mcp-files.sh" 2>&1 || true)
if [[ "$result" == *"BLOCKED"* ]]; then
    pass "Blocks .go files in plugin context"
else
    fail "File restriction" "Should block .go files"
fi

# Test: Allows .mcp.json in plugin context
echo '{"tool_name":"Write","tool_input":{"file_path":"/tmp/test/.mcp.json"},"transcript_path":"/tmp/t.json","tool_use_id":"test-123"}' | \
    TEST_CALLER="/mcp:skill-dev" "$SCRIPTS_DIR/enforce-mcp-files.sh" && \
    pass "Allows .mcp.json in plugin context" || \
    fail "File restriction" "Should allow .mcp.json"

# Test: kubectl should be blocked entirely
result=$(echo '{"tool_input":{"command":"kubectl get svc -n claude"},"transcript_path":"/tmp/t.json","tool_use_id":"test-123"}' | \
    TEST_CALLER="/mcp:skill-dev" "$SCRIPTS_DIR/block-bash.sh" 2>&1 || true)
if [[ "$result" == *"BLOCKED"* ]]; then
    pass "Blocks kubectl commands"
else
    fail "kubectl security" "Should block all kubectl commands"
fi

# Test: nslookup should be blocked
result=$(echo '{"tool_input":{"command":"nslookup example.com"},"transcript_path":"/tmp/t.json","tool_use_id":"test-123"}' | \
    TEST_CALLER="/mcp:skill-dev" "$SCRIPTS_DIR/block-bash.sh" 2>&1 || true)
if [[ "$result" == *"BLOCKED"* ]]; then
    pass "Blocks nslookup commands"
else
    fail "nslookup security" "Should block nslookup commands"
fi

# Test: allows curl for connectivity testing
echo '{"tool_input":{"command":"curl -v --max-time 5 http://localhost:3000/mcp"},"transcript_path":"/tmp/t.json","tool_use_id":"test-123"}' | \
    TEST_CALLER="/mcp:skill-dev" "$SCRIPTS_DIR/block-bash.sh" && \
    pass "Allows curl (connectivity testing)" || \
    fail "curl access" "Should allow curl"

# Test: allows ss for port checking
echo '{"tool_input":{"command":"ss -tlnp"},"transcript_path":"/tmp/t.json","tool_use_id":"test-123"}' | \
    TEST_CALLER="/mcp:skill-dev" "$SCRIPTS_DIR/block-bash.sh" && \
    pass "Allows ss (port checking)" || \
    fail "ss access" "Should allow ss"

# Test: allows lsof for port checking
echo '{"tool_input":{"command":"lsof -i :3000"},"transcript_path":"/tmp/t.json","tool_use_id":"test-123"}' | \
    TEST_CALLER="/mcp:skill-dev" "$SCRIPTS_DIR/block-bash.sh" && \
    pass "Allows lsof (port checking)" || \
    fail "lsof access" "Should allow lsof"

# Test: rm deletion - allows .mcp.json
echo '{"tool_input":{"command":"rm /tmp/test/.mcp.json"},"transcript_path":"/tmp/t.json","tool_use_id":"test-123"}' | \
    TEST_CALLER="/mcp:skill-dev" "$SCRIPTS_DIR/block-bash.sh" && \
    pass "Allows rm .mcp.json" || \
    fail "Deletion" "Should allow deleting .mcp.json"

# Test: rm deletion - blocks non-.mcp.json files
result=$(echo '{"tool_input":{"command":"rm /tmp/test.go"},"transcript_path":"/tmp/t.json","tool_use_id":"test-123"}' | \
    TEST_CALLER="/mcp:skill-dev" "$SCRIPTS_DIR/block-bash.sh" 2>&1 || true)
if [[ "$result" == *"BLOCKED"* ]]; then
    pass "Blocks rm non-.mcp.json files"
else
    fail "Deletion security" "Should block deleting non-.mcp.json files"
fi

echo ""
echo "Results: $passed passed, $failed failed"
[[ $failed -eq 0 ]] && exit 0 || exit 1
