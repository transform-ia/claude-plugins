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

# Test: Hook scoping - should allow when not in plugin context
echo '{"tool_name":"Write","tool_input":{"file_path":"/tmp/test.go"}}' | \
    CLAUDE_PLUGIN_ROOT="" "$SCRIPTS_DIR/enforce-mcp-files.sh" && \
    pass "Allows writes when not in plugin context" || \
    fail "Hook scoping" "Should allow when CLAUDE_PLUGIN_ROOT is empty"

# Test: Hook scoping - should block .go files in plugin context
result=$(echo '{"tool_name":"Write","tool_input":{"file_path":"/tmp/test.go"}}' | \
    CLAUDE_PLUGIN_ROOT="$PLUGIN_DIR" "$SCRIPTS_DIR/enforce-mcp-files.sh" 2>&1 || true)
if [[ "$result" == *"BLOCKED"* ]]; then
    pass "Blocks .go files in plugin context"
else
    fail "File restriction" "Should block .go files"
fi

# Test: Allows .mcp.json in plugin context
echo '{"tool_name":"Write","tool_input":{"file_path":"/workspace/.mcp.json"}}' | \
    CLAUDE_PLUGIN_ROOT="$PLUGIN_DIR" "$SCRIPTS_DIR/enforce-mcp-files.sh" && \
    pass "Allows .mcp.json in plugin context" || \
    fail "File restriction" "Should allow .mcp.json"

# Test: kubectl restrictions - should block kubectl create
result=$(echo '{"tool_input":{"command":"kubectl create job test --image=alpine"}}' | \
    CLAUDE_PLUGIN_ROOT="$PLUGIN_DIR" "$SCRIPTS_DIR/block-bash.sh" 2>&1 || true)
if [[ "$result" == *"BLOCKED"* ]]; then
    pass "Blocks kubectl create (security)"
else
    fail "kubectl security" "Should block kubectl create"
fi

# Test: kubectl restrictions - should block kubectl apply
result=$(echo '{"tool_input":{"command":"kubectl apply -f /tmp/job.yaml"}}' | \
    CLAUDE_PLUGIN_ROOT="$PLUGIN_DIR" "$SCRIPTS_DIR/block-bash.sh" 2>&1 || true)
if [[ "$result" == *"BLOCKED"* ]]; then
    pass "Blocks kubectl apply (security)"
else
    fail "kubectl security" "Should block kubectl apply"
fi

# Test: kubectl restrictions - should block kubectl exec
result=$(echo '{"tool_input":{"command":"kubectl exec -it pod -- sh"}}' | \
    CLAUDE_PLUGIN_ROOT="$PLUGIN_DIR" "$SCRIPTS_DIR/block-bash.sh" 2>&1 || true)
if [[ "$result" == *"BLOCKED"* ]]; then
    pass "Blocks kubectl exec (security)"
else
    fail "kubectl security" "Should block kubectl exec"
fi

# Test: kubectl restrictions - should allow kubectl get
echo '{"tool_input":{"command":"kubectl get svc -n claude"}}' | \
    CLAUDE_PLUGIN_ROOT="$PLUGIN_DIR" "$SCRIPTS_DIR/block-bash.sh" && \
    pass "Allows kubectl get (read-only)" || \
    fail "kubectl read" "Should allow kubectl get"

# Test: kubectl restrictions - should allow kubectl describe
echo '{"tool_input":{"command":"kubectl describe svc context7 -n claude"}}' | \
    CLAUDE_PLUGIN_ROOT="$PLUGIN_DIR" "$SCRIPTS_DIR/block-bash.sh" && \
    pass "Allows kubectl describe (read-only)" || \
    fail "kubectl read" "Should allow kubectl describe"

# Test: rm deletion - allows .mcp.json
echo '{"tool_input":{"command":"rm /workspace/.mcp.json"}}' | \
    CLAUDE_PLUGIN_ROOT="$PLUGIN_DIR" "$SCRIPTS_DIR/block-bash.sh" && \
    pass "Allows rm .mcp.json" || \
    fail "Deletion" "Should allow deleting .mcp.json"

# Test: rm deletion - blocks non-.mcp.json files
result=$(echo '{"tool_input":{"command":"rm /tmp/test.go"}}' | \
    CLAUDE_PLUGIN_ROOT="$PLUGIN_DIR" "$SCRIPTS_DIR/block-bash.sh" 2>&1 || true)
if [[ "$result" == *"BLOCKED"* ]]; then
    pass "Blocks rm non-.mcp.json files"
else
    fail "Deletion security" "Should block deleting non-.mcp.json files"
fi

echo ""
echo "Results: $passed passed, $failed failed"
[[ $failed -eq 0 ]] && exit 0 || exit 1
