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
    local input='{"tool_input":{"command":"/path/to/claude-plugins/go/scripts/lint-exec.sh /dir"}}'
    local output
    local exit_code=0
    output=$(echo "$input" | "$SCRIPTS_DIR/block-bash.sh" 2>&1) || exit_code=$?
    if [[ $exit_code -eq 0 ]]; then
        pass "block-bash.sh allows plugin scripts"
    else
        fail "block-bash.sh allows plugin scripts" "exit=$exit_code output=$output"
    fi
}

# Test: block-bash.sh blocks go commands
test_block_bash_blocks_go() {
    local input='{"tool_input":{"command":"go build ."}}'
    local output
    local exit_code=0
    output=$(echo "$input" | "$SCRIPTS_DIR/block-bash.sh" 2>&1) || exit_code=$?
    if [[ $exit_code -eq 2 ]] && [[ "$output" == *"BLOCKED"* ]]; then
        pass "block-bash.sh blocks 'go' commands"
    else
        fail "block-bash.sh blocks 'go' commands" "exit=$exit_code output=$output"
    fi
}

# Test: block-bash.sh blocks other bash
test_block_bash_blocks_other() {
    local input='{"tool_input":{"command":"ls -la"}}'
    local output
    local exit_code=0
    output=$(echo "$input" | "$SCRIPTS_DIR/block-bash.sh" 2>&1) || exit_code=$?
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

# Test: enforce-go-files.sh blocks other files
test_enforce_go_blocks_other() {
    local input='{"tool_name":"Write","tool_input":{"file_path":"/path/to/file.txt"}}'
    local output
    local exit_code=0
    output=$(echo "$input" | "$SCRIPTS_DIR/enforce-go-files.sh" 2>&1) || exit_code=$?
    if [[ $exit_code -eq 2 ]] && [[ "$output" == *"BLOCKED"* ]]; then
        pass "enforce-go-files.sh blocks non-.go files"
    else
        fail "enforce-go-files.sh blocks non-.go files" "exit=$exit_code output=$output"
    fi
}

# Test: post-bash-check.sh allows successful plugin scripts
test_post_bash_allows_success() {
    local input='{"tool_input":{"command":"/path/to/claude-plugins/go/scripts/build-exec.sh"},"tool_result":{"exit_code":0}}'
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
    local input='{"tool_input":{"command":"/path/to/claude-plugins/go/scripts/build-exec.sh"},"tool_result":{"exit_code":2}}'
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
              lint-exec.sh build-exec.sh test-exec.sh run-exec.sh init-exec.sh \
              tidy-exec.sh post-bash-check.sh stop-lint-check.sh sync-go-mcp.sh; do
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
test_enforce_go_blocks_other

header "Testing post-bash-check.sh (PostToolUse hook)"
test_post_bash_allows_success
test_post_bash_blocks_failure

header "Testing exec scripts require directory"
for script in lint-exec.sh build-exec.sh test-exec.sh run-exec.sh tidy-exec.sh; do
    test_requires_dir_arg "$script"
done

# Summary
header "Test Summary"
echo ""
echo -e "Passed: ${GREEN}$passed${NC}"
echo -e "Failed: ${RED}$failed${NC}"
echo ""

if [[ $failed -gt 0 ]]; then
    exit 1
fi
