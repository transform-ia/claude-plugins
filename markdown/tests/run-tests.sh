#!/bin/bash
# Test suite for Markdown plugin
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SCRIPTS_DIR="$PLUGIN_DIR/scripts"
PARENT_SCRIPTS_DIR="$(cd "$PLUGIN_DIR/../scripts" && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

passed=0
failed=0

pass() { echo -e "${GREEN}✓${NC} $1"; ((++passed)); }
fail() { echo -e "${RED}✗${NC} $1: $2"; ((++failed)); }

# Setup: Export CLAUDE_PLUGIN_ROOT for the hooks
export CLAUDE_PLUGIN_ROOT="$PLUGIN_DIR"

# Helper: Backup original detect-caller.py before tests
backup_original_caller() {
    if [ -f "$PARENT_SCRIPTS_DIR/detect-caller.py" ]; then
        cp "$PARENT_SCRIPTS_DIR/detect-caller.py" "$PARENT_SCRIPTS_DIR/detect-caller.py.backup"
    fi
}

# Helper: Restore original detect-caller.py after tests
restore_original_caller() {
    if [ -f "$PARENT_SCRIPTS_DIR/detect-caller.py.backup" ]; then
        mv "$PARENT_SCRIPTS_DIR/detect-caller.py.backup" "$PARENT_SCRIPTS_DIR/detect-caller.py"
    fi
}

# Ensure original file is restored even if tests fail
trap restore_original_caller EXIT

# Helper: Create mock detect-caller.py that returns specific caller
setup_mock_caller() {
    local caller="$1"

    # Create temporary mock detect-caller.py
    cat > "$PARENT_SCRIPTS_DIR/detect-caller.py" <<EOF
#!/usr/bin/env python3
import sys
print("$caller")
sys.exit(0)
EOF
    chmod +x "$PARENT_SCRIPTS_DIR/detect-caller.py"
}

# Helper: Cleanup mock
cleanup_mock_caller() {
    rm -f "$PARENT_SCRIPTS_DIR/detect-caller.py"
}

echo "Testing Markdown Plugin"
echo "========================"

# Backup original detect-caller.py before running tests
backup_original_caller

# Test: Scripts exist and are executable
for script in enforce-md-files.sh block-bash.sh cmd-lint.sh stop-lint-check.sh; do
    if [[ -x "$SCRIPTS_DIR/$script" ]]; then
        pass "$script exists and is executable"
    else
        fail "$script" "Not found or not executable"
    fi
done

# Test: New config and validator files exist
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

# Test: Hook scoping - should allow when caller is NOT /markdown:*
setup_mock_caller "/other:command"
echo '{"tool_name":"Write","tool_input":{"file_path":"/tmp/test.go"},"transcript_path":"/tmp/transcript.json","tool_use_id":"test-123"}' | \
    "$SCRIPTS_DIR/enforce-md-files.sh" && \
    pass "Allows writes when caller is not /markdown:*" || \
    fail "Hook scoping" "Should allow when caller is not /markdown:*"
cleanup_mock_caller

# Test: Hook scoping - should block .go files when caller is /markdown:*
setup_mock_caller "/markdown:skill-dev"
result=$(echo '{"tool_name":"Write","tool_input":{"file_path":"/tmp/test.go"},"transcript_path":"/tmp/transcript.json","tool_use_id":"test-123"}' | \
    "$SCRIPTS_DIR/enforce-md-files.sh" 2>&1 || true)
if [[ "$result" == *"BLOCKED"* ]]; then
    pass "Blocks .go files when caller is /markdown:*"
else
    fail "File restriction" "Should block .go files when caller is /markdown:*"
fi
cleanup_mock_caller

# Test: Allows .md files when caller is /markdown:*
setup_mock_caller "/markdown:skill-dev"
echo '{"tool_name":"Write","tool_input":{"file_path":"/tmp/test.md"},"transcript_path":"/tmp/transcript.json","tool_use_id":"test-123"}' | \
    "$SCRIPTS_DIR/enforce-md-files.sh" && \
    pass "Allows .md files when caller is /markdown:*" || \
    fail "File restriction" "Should allow .md files"
cleanup_mock_caller

# Test: Fail-closed behavior - missing transcript_path
setup_mock_caller "/markdown:skill-dev"
result=$(echo '{"tool_name":"Write","tool_input":{"file_path":"/tmp/test.md"},"tool_use_id":"test-123"}' | \
    "$SCRIPTS_DIR/enforce-md-files.sh" 2>&1 || true)
if [[ "$result" == *"BLOCKED"* ]] && [[ "$result" == *"Missing transcript metadata"* ]]; then
    pass "Fail-closed: blocks when transcript_path missing"
else
    fail "Fail-closed security" "Should block when transcript_path missing"
fi
cleanup_mock_caller

# Test: Fail-closed behavior - caller detection fails
setup_mock_caller "__DETECTION_FAILED__"
result=$(echo '{"tool_name":"Write","tool_input":{"file_path":"/tmp/test.md"},"transcript_path":"/tmp/transcript.json","tool_use_id":"test-123"}' | \
    "$SCRIPTS_DIR/enforce-md-files.sh" 2>&1 || true)
if [[ "$result" == *"BLOCKED"* ]] && [[ "$result" == *"Caller detection failed"* ]]; then
    pass "Fail-closed: blocks when caller detection fails"
else
    fail "Fail-closed security" "Should block when caller detection fails"
fi
cleanup_mock_caller

# Test: rm deletion - allows .md files with exact match
setup_mock_caller "/markdown:skill-dev"
echo '{"tool_input":{"command":"rm *.md"},"transcript_path":"/tmp/transcript.json","tool_use_id":"test-123"}' | \
    "$SCRIPTS_DIR/block-bash.sh" && \
    pass "Allows 'rm *.md' (exact allowlist match)" || \
    fail "Deletion" "Should allow 'rm *.md'"
cleanup_mock_caller

# Test: rm deletion - blocks non-exact patterns
setup_mock_caller "/markdown:skill-dev"
result=$(echo '{"tool_input":{"command":"rm /tmp/test.md"},"transcript_path":"/tmp/transcript.json","tool_use_id":"test-123"}' | \
    "$SCRIPTS_DIR/block-bash.sh" 2>&1 || true)
if [[ "$result" == *"BLOCKED"* ]]; then
    pass "Blocks 'rm /tmp/test.md' (not in allowlist)"
else
    fail "Deletion security" "Should block commands not in exact allowlist"
fi
cleanup_mock_caller

# Test: rm deletion - blocks non-md files
setup_mock_caller "/markdown:skill-dev"
result=$(echo '{"tool_input":{"command":"rm /tmp/test.go"},"transcript_path":"/tmp/transcript.json","tool_use_id":"test-123"}' | \
    "$SCRIPTS_DIR/block-bash.sh" 2>&1 || true)
if [[ "$result" == *"BLOCKED"* ]]; then
    pass "Blocks 'rm /tmp/test.go' (not in allowlist)"
else
    fail "Deletion security" "Should block deleting non-.md files"
fi
cleanup_mock_caller

# Test: Allowlist includes all expected patterns
setup_mock_caller "/markdown:skill-dev"
for pattern in "rm *.md" "rm **/*.md" "rm -f *.md" "rm -rf *.md"; do
    if echo "{\"tool_input\":{\"command\":\"$pattern\"},\"transcript_path\":\"/tmp/transcript.json\",\"tool_use_id\":\"test-123\"}" | \
        "$SCRIPTS_DIR/block-bash.sh" 2>&1 | grep -q "BLOCKED"; then
        fail "Allowlist" "Pattern '$pattern' should be allowed but was blocked"
    else
        pass "Allowlist allows: '$pattern'"
    fi
done
cleanup_mock_caller

# Test: Plugin scripts are allowed
setup_mock_caller "/markdown:skill-dev"
echo "{\"tool_input\":{\"command\":\"${CLAUDE_PLUGIN_ROOT}/scripts/cmd-lint.sh README.md\"},\"transcript_path\":\"/tmp/transcript.json\",\"tool_use_id\":\"test-123\"}" | \
    "$SCRIPTS_DIR/block-bash.sh" && \
    pass "Allows plugin's own scripts" || \
    fail "Plugin scripts" "Should allow ${CLAUDE_PLUGIN_ROOT}/scripts/*"
cleanup_mock_caller

# Restore original detect-caller.py
restore_original_caller

echo ""
echo "Results: $passed passed, $failed failed"
[[ $failed -eq 0 ]] && exit 0 || exit 1
