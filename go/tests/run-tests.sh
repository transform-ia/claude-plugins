#!/bin/bash
# Test suite for Go plugin scripts
# Run from plugin root: ./tests/run-tests.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SCRIPTS_DIR="$PLUGIN_DIR/scripts"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

passed=0
failed=0

# Test helper functions
pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((++passed))
}

fail() {
    echo -e "${RED}✗${NC} $1"
    echo "  Output: $2"
    ((++failed))
}

skip() {
    echo -e "${YELLOW}○${NC} $1 (skipped: $2)"
}

header() {
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo "$1"
    echo "═══════════════════════════════════════════════════════════════"
}

# Test: Script exists and is executable
test_script_exists() {
    local script="$1"
    if [[ -x "$SCRIPTS_DIR/$script" ]]; then
        pass "$script exists and is executable"
    else
        fail "$script exists and is executable" "Not found or not executable"
    fi
}

# Test: Script requires directory argument
test_requires_dir_arg() {
    local script="$1"
    local output
    output=$("$SCRIPTS_DIR/$script" 2>&1) || true
    if [[ "$output" == *"Directory argument required"* ]] || [[ "$output" == *"ERROR"* ]]; then
        pass "$script requires directory argument"
    else
        fail "$script requires directory argument" "$output"
    fi
}

# Test: find-git-root.sh with valid git dir
test_find_git_root_valid() {
    local output
    output=$("$SCRIPTS_DIR/find-git-root.sh" "$PLUGIN_DIR" 2>&1)
    if [[ -n "$output" ]] && [[ -d "$output/.git" ]]; then
        pass "find-git-root.sh finds git root"
    else
        fail "find-git-root.sh finds git root" "$output"
    fi
}

# Test: find-git-root.sh with invalid dir
test_find_git_root_invalid() {
    local output
    local exit_code=0
    output=$("$SCRIPTS_DIR/find-git-root.sh" "/tmp" 2>&1) || exit_code=$?
    if [[ $exit_code -eq 2 ]] && [[ "$output" == *"Not inside a git repository"* ]]; then
        pass "find-git-root.sh exits 2 for non-git dir"
    else
        fail "find-git-root.sh exits 2 for non-git dir" "exit=$exit_code output=$output"
    fi
}

# Test: find-dev-pod.sh shows helpful error
test_find_dev_pod_error() {
    local output
    local exit_code=0
    output=$("$SCRIPTS_DIR/find-dev-pod.sh" "/nonexistent/path" 2>&1) || exit_code=$?
    if [[ $exit_code -eq 2 ]] && [[ "$output" == *"Looking for pod with label"* ]]; then
        pass "find-dev-pod.sh shows label being searched"
    else
        fail "find-dev-pod.sh shows label being searched" "exit=$exit_code"
    fi

    if [[ "$output" == *"Existing golang-chart pods"* ]]; then
        pass "find-dev-pod.sh shows existing pods"
    else
        fail "find-dev-pod.sh shows existing pods" "Missing pods list"
    fi

    if [[ "$output" == *"To fix this"* ]]; then
        pass "find-dev-pod.sh shows fix instructions"
    else
        fail "find-dev-pod.sh shows fix instructions" "Missing instructions"
    fi
}

# Test: block-bash.sh allows plugin scripts
test_block_bash_allows_plugin() {
    local input='{"tool_input":{"command":"/path/to/claude-plugins/go/scripts/cmd-lint.sh /dir"}}'
    local output
    local exit_code=0
    output=$(echo "$input" | "$SCRIPTS_DIR/block-bash.sh" 2>&1) || exit_code=$?
    if [[ $exit_code -eq 0 ]]; then
        pass "block-bash.sh allows plugin scripts"
    else
        fail "block-bash.sh allows plugin scripts" "exit=$exit_code output=$output"
    fi
}

# Test: block-bash.sh blocks go commands (in plugin context)
test_block_bash_blocks_go() {
    local input='{"tool_input":{"command":"go build ."},"transcript_path":"/tmp/t.json","tool_use_id":"test-123"}'
    local output
    local exit_code=0
    output=$(echo "$input" | TEST_CALLER="/go:skill-dev" "$SCRIPTS_DIR/block-bash.sh" 2>&1) || exit_code=$?
    if [[ $exit_code -eq 2 ]] && [[ "$output" == *"BLOCKED"* ]]; then
        pass "block-bash.sh blocks 'go' commands"
    else
        fail "block-bash.sh blocks 'go' commands" "exit=$exit_code output=$output"
    fi
}

# Test: block-bash.sh blocks other bash (in plugin context)
test_block_bash_blocks_other() {
    local input='{"tool_input":{"command":"ls -la"},"transcript_path":"/tmp/t.json","tool_use_id":"test-123"}'
    local output
    local exit_code=0
    output=$(echo "$input" | TEST_CALLER="/go:skill-dev" "$SCRIPTS_DIR/block-bash.sh" 2>&1) || exit_code=$?
    if [[ $exit_code -eq 2 ]] && [[ "$output" == *"BLOCKED"* ]]; then
        pass "block-bash.sh blocks other bash commands"
    else
        fail "block-bash.sh blocks other bash commands" "exit=$exit_code output=$output"
    fi
}

# Test: enforce-go-files.sh allows .go files
test_enforce_go_allows_go() {
    local input='{"tool_name":"Write","tool_input":{"file_path":"/path/to/main.go"}}'
    local output
    local exit_code=0
    output=$(echo "$input" | "$SCRIPTS_DIR/enforce-go-files.sh" 2>&1) || exit_code=$?
    if [[ $exit_code -eq 0 ]]; then
        pass "enforce-go-files.sh allows .go files"
    else
        fail "enforce-go-files.sh allows .go files" "exit=$exit_code output=$output"
    fi
}

# Test: enforce-go-files.sh blocks .golangci.yaml (agent cannot modify linter config)
test_enforce_go_blocks_golangci() {
    local input='{"tool_name":"Write","tool_input":{"file_path":"/path/to/.golangci.yaml"},"transcript_path":"/tmp/t.json","tool_use_id":"test-123"}'
    local output
    local exit_code=0
    output=$(echo "$input" | TEST_CALLER="/go:skill-dev" "$SCRIPTS_DIR/enforce-go-files.sh" 2>&1) || exit_code=$?
    if [[ $exit_code -eq 2 ]] && [[ "$output" == *"BLOCKED"* ]] && [[ "$output" == *"linter"* ]]; then
        pass "enforce-go-files.sh blocks .golangci.yaml (protects linter config)"
    else
        fail "enforce-go-files.sh blocks .golangci.yaml" "exit=$exit_code output=$output"
    fi
}

# Test: enforce-go-files.sh blocks other files (in plugin context)
test_enforce_go_blocks_other() {
    local input='{"tool_name":"Write","tool_input":{"file_path":"/path/to/file.txt"},"transcript_path":"/tmp/t.json","tool_use_id":"test-123"}'
    local output
    local exit_code=0
    output=$(echo "$input" | TEST_CALLER="/go:skill-dev" "$SCRIPTS_DIR/enforce-go-files.sh" 2>&1) || exit_code=$?
    if [[ $exit_code -eq 2 ]] && [[ "$output" == *"BLOCKED"* ]]; then
        pass "enforce-go-files.sh blocks non-.go files"
    else
        fail "enforce-go-files.sh blocks non-.go files" "exit=$exit_code output=$output"
    fi
}

# Test: post-bash-check.sh allows successful plugin scripts
test_post_bash_allows_success() {
    local input='{"tool_input":{"command":"/path/to/claude-plugins/go/scripts/cmd-build.sh"},"tool_result":{"exit_code":0}}'
    local output
    local exit_code=0
    output=$(echo "$input" | "$SCRIPTS_DIR/post-bash-check.sh" 2>&1) || exit_code=$?
    if [[ $exit_code -eq 0 ]]; then
        pass "post-bash-check.sh allows successful plugin scripts"
    else
        fail "post-bash-check.sh allows successful plugin scripts" "exit=$exit_code"
    fi
}

# Test: post-bash-check.sh blocks failed plugin scripts
test_post_bash_blocks_failure() {
    local input='{"tool_input":{"command":"/path/to/claude-plugins/go/scripts/cmd-build.sh"},"tool_result":{"exit_code":2}}'
    local output
    local exit_code=0
    output=$(echo "$input" | "$SCRIPTS_DIR/post-bash-check.sh" 2>&1) || exit_code=$?
    if [[ $exit_code -eq 2 ]] && [[ "$output" == *"STOP"* ]]; then
        pass "post-bash-check.sh blocks failed plugin scripts"
    else
        fail "post-bash-check.sh blocks failed plugin scripts" "exit=$exit_code output=$output"
    fi
}

# Run tests
header "Testing script existence"
for script in block-bash.sh enforce-go-files.sh find-dev-pod.sh find-git-root.sh \
              cmd-lint.sh cmd-build.sh cmd-test.sh cmd-run.sh cmd-init.sh \
              cmd-tidy.sh post-bash-check.sh stop-lint-check.sh sync-go-mcp.sh; do
    test_script_exists "$script"
done

header "Testing find-git-root.sh"
test_requires_dir_arg "find-git-root.sh"
test_find_git_root_valid
test_find_git_root_invalid

header "Testing find-dev-pod.sh"
test_requires_dir_arg "find-dev-pod.sh"
test_find_dev_pod_error

header "Testing block-bash.sh (PreToolUse hook)"
test_block_bash_allows_plugin
test_block_bash_blocks_go
test_block_bash_blocks_other

header "Testing enforce-go-files.sh (PreToolUse hook)"
test_enforce_go_allows_go
test_enforce_go_blocks_golangci
test_enforce_go_blocks_other

header "Testing post-bash-check.sh (PostToolUse hook)"
test_post_bash_allows_success
test_post_bash_blocks_failure

header "Testing exec scripts require directory"
for script in cmd-lint.sh cmd-build.sh cmd-test.sh cmd-run.sh cmd-tidy.sh; do
    test_requires_dir_arg "$script"
done

header "Testing rm deletion permissions"

# Test: rm deletion - allows .go files
test_rm_allows_go() {
    local input='{"tool_input":{"command":"rm /tmp/main.go"},"transcript_path":"/tmp/t.json","tool_use_id":"test-123"}'
    local output
    local exit_code=0
    output=$(echo "$input" | TEST_CALLER="/go:skill-dev" "$SCRIPTS_DIR/block-bash.sh" 2>&1) || exit_code=$?
    if [[ $exit_code -eq 0 ]]; then
        pass "Allows rm *.go files"
    else
        fail "Allows rm *.go files" "exit=$exit_code output=$output"
    fi
}

# Test: rm deletion - allows go.mod
test_rm_allows_gomod() {
    local input='{"tool_input":{"command":"rm /tmp/go.mod"},"transcript_path":"/tmp/t.json","tool_use_id":"test-123"}'
    local output
    local exit_code=0
    output=$(echo "$input" | TEST_CALLER="/go:skill-dev" "$SCRIPTS_DIR/block-bash.sh" 2>&1) || exit_code=$?
    if [[ $exit_code -eq 0 ]]; then
        pass "Allows rm go.mod"
    else
        fail "Allows rm go.mod" "exit=$exit_code output=$output"
    fi
}

# Test: rm deletion - allows go.sum
test_rm_allows_gosum() {
    local input='{"tool_input":{"command":"rm /tmp/go.sum"},"transcript_path":"/tmp/t.json","tool_use_id":"test-123"}'
    local output
    local exit_code=0
    output=$(echo "$input" | TEST_CALLER="/go:skill-dev" "$SCRIPTS_DIR/block-bash.sh" 2>&1) || exit_code=$?
    if [[ $exit_code -eq 0 ]]; then
        pass "Allows rm go.sum"
    else
        fail "Allows rm go.sum" "exit=$exit_code output=$output"
    fi
}

# Test: rm deletion - blocks non-go files
test_rm_blocks_other() {
    local input='{"tool_input":{"command":"rm /tmp/test.txt"},"transcript_path":"/tmp/t.json","tool_use_id":"test-123"}'
    local output
    local exit_code=0
    output=$(echo "$input" | TEST_CALLER="/go:skill-dev" "$SCRIPTS_DIR/block-bash.sh" 2>&1) || exit_code=$?
    if [[ $exit_code -eq 2 ]] && [[ "$output" == *"BLOCKED"* ]]; then
        pass "Blocks rm non-Go files"
    else
        fail "Blocks rm non-Go files" "exit=$exit_code output=$output"
    fi
}

# Test: rm deletion - blocks .golangci.yaml (agent cannot delete linter config)
test_rm_blocks_golangci() {
    local input='{"tool_input":{"command":"rm /tmp/.golangci.yaml"},"transcript_path":"/tmp/t.json","tool_use_id":"test-123"}'
    local output
    local exit_code=0
    output=$(echo "$input" | TEST_CALLER="/go:skill-dev" "$SCRIPTS_DIR/block-bash.sh" 2>&1) || exit_code=$?
    if [[ $exit_code -eq 2 ]] && [[ "$output" == *"BLOCKED"* ]] && [[ "$output" == *"linter"* ]]; then
        pass "Blocks rm .golangci.yaml (protects linter config)"
    else
        fail "Blocks rm .golangci.yaml" "exit=$exit_code output=$output"
    fi
}

test_rm_allows_go
test_rm_allows_gomod
test_rm_allows_gosum
test_rm_blocks_golangci
test_rm_blocks_other

# Summary
header "Test Summary"
echo ""
echo -e "Passed: ${GREEN}$passed${NC}"
echo -e "Failed: ${RED}$failed${NC}"
echo ""

if [[ $failed -gt 0 ]]; then
    exit 1
fi
