#!/bin/bash
# JavaScript testing script for Jest, Vitest, and other testing frameworks

set -e

# Default values
WORKSPACE="${WORKSPACE:-.}"
TEST_PATTERN="${TEST_PATTERN:-}"
COVERAGE="${COVERAGE:-false}"
WATCH="${WATCH:-false}"
ENV_FILE="${ENV_FILE:-/.env}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Help function
show_help() {
    cat << EOF
JavaScript Testing Script

Usage: $0 [OPTIONS] [PATTERN]

Arguments:
  PATTERN               Test file pattern (e.g., src/**/*.test.js)

Options:
  -w, --workspace DIR    Workspace directory (default: current directory)
  -c, --coverage         Generate coverage report
  -w, --watch            Watch mode for continuous testing
  -e, --env FILE         Environment file to load
  -t, --test-runner RUNNER  Test runner to use (auto|jest|vitest|mocha)
  -r, --reporter REPORTER  Test reporter (default|spec|dot)
  -u, --update-snapshot  Update snapshots
  -h, --help             Show this help message

Environment Variables:
  WORKSPACE             Workspace directory
  CI                    Set to true for CI mode
  TEST_TIMEOUT          Test timeout in milliseconds

Test Runners:
  auto                  Auto-detect available test runner
  jest                  Use Jest testing framework
  vitest                Use Vitest testing framework
  mocha                 Use Mocha testing framework

Examples:
  # Run all tests
  $0

  # Run tests with coverage
  $0 --coverage

  # Run tests in watch mode
  $0 --watch

  # Run specific test pattern
  $0 src/components/**/*.test.js

  # Use specific test runner
  $0 --test-runner jest

  # Run tests and update snapshots
  $0 --update-snapshot
EOF
}

# Parse command line arguments
TEST_RUNNER="auto"
REPORTER="default"
UPDATE_SNAPSHOT=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -w|--workspace)
            WORKSPACE="$2"
            shift 2
            ;;
        -c|--coverage)
            COVERAGE=true
            shift
            ;;
        -w|--watch)
            WATCH=true
            shift
            ;;
        -e|--env)
            ENV_FILE="$2"
            shift 2
            ;;
        -t|--test-runner)
            TEST_RUNNER="$2"
            shift 2
            ;;
        -r|--reporter)
            REPORTER="$2"
            shift 2
            ;;
        -u|--update-snapshot)
            UPDATE_SNAPSHOT=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        -*)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
        *)
            TEST_PATTERN="$1"
            shift
            ;;
    esac
done

# Check if workspace exists
if [[ ! -d "$WORKSPACE" ]]; then
    log_error "Workspace directory does not exist: $WORKSPACE"
    exit 1
fi

# Change to workspace directory
cd "$WORKSPACE"

# Check if Node.js is available
if ! command -v node &> /dev/null; then
    log_error "Node.js is not installed or not in PATH"
    exit 1
fi

# Check if npm is available
if ! command -v npm &> /dev/null; then
    log_error "npm is not installed or not in PATH"
    exit 1
fi

# Check if package.json exists
if [[ ! -f "package.json" ]]; then
    log_error "package.json not found in workspace"
    exit 1
fi

# Load environment file if specified
if [[ -f "$ENV_FILE" ]]; then
    log_info "Loading environment from: $ENV_FILE"
    set -a
    source "$ENV_FILE"
    set +a
fi

# Auto-detect test runner if needed
if [[ "$TEST_RUNNER" == "auto" ]]; then
    log_info "Auto-detecting test runner..."

    if npm list jest &> /dev/null || npm list --depth=0 jest &> /dev/null; then
        TEST_RUNNER="jest"
    elif npm list vitest &> /dev/null || npm list --depth=0 vitest &> /dev/null; then
        TEST_RUNNER="vitest"
    elif npm list mocha &> /dev/null || npm list --depth=0 mocha &> /dev/null; then
        TEST_RUNNER="mocha"
    else
        log_error "No supported test runner found (jest, vitest, mocha)"
        exit 1
    fi

    log_info "Detected test runner: $TEST_RUNNER"
fi

# Install dependencies if node_modules doesn't exist
if [[ ! -d "node_modules" ]]; then
    log_step "Installing dependencies..."
    npm ci
fi

# Display test configuration
log_info "Running JavaScript tests..."
log_info "Workspace: $WORKSPACE"
log_info "Test Runner: $TEST_RUNNER"
log_info "Coverage: $COVERAGE"
log_info "Watch Mode: $WATCH"
if [[ -n "$TEST_PATTERN" ]]; then
    log_info "Test Pattern: $TEST_PATTERN"
fi

# Build test command based on test runner
case "$TEST_RUNNER" in
    "jest")
        run_jest_tests
        ;;
    "vitest")
        run_vitest_tests
        ;;
    "mocha")
        run_mocha_tests
        ;;
    *)
        log_error "Unsupported test runner: $TEST_RUNNER"
        exit 1
        ;;
esac

# Jest test runner
run_jest_tests() {
    log_step "Running Jest tests..."

    # Check if Jest is available
    if ! npx jest --version &> /dev/null; then
        log_error "Jest is not available"
        exit 1
    fi

    # Build Jest command
    JEST_CMD="npx jest"

    # Add test pattern if specified
    if [[ -n "$TEST_PATTERN" ]]; then
        JEST_CMD="$JEST_CMD $TEST_PATTERN"
    fi

    # Add coverage flag
    if [[ "$COVERAGE" == true ]]; then
        JEST_CMD="$JEST_CMD --coverage"
    fi

    # Add watch flag
    if [[ "$WATCH" == true ]]; then
        JEST_CMD="$JEST_CMD --watch"
    fi

    # Add reporter
    if [[ "$REPORTER" != "default" ]]; then
        JEST_CMD="$JEST_CMD --reporter=$REPORTER"
    fi

    # Add update snapshots flag
    if [[ "$UPDATE_SNAPSHOT" == true ]]; then
        JEST_CMD="$JEST_CMD --updateSnapshot"
    fi

    # Add CI flag if in CI environment
    if [[ "$CI" == true ]]; then
        JEST_CMD="$JEST_CMD --ci --passWithNoTests"
    fi

    log_info "Running: $JEST_CMD"
    eval "$JEST_CMD"
}

# Vitest test runner
run_vitest_tests() {
    log_step "Running Vitest tests..."

    # Check if Vitest is available
    if ! npx vitest --version &> /dev/null; then
        log_error "Vitest is not available"
        exit 1
    fi

    # Build Vitest command
    VITEST_CMD="npx vitest run"

    # Add test pattern if specified
    if [[ -n "$TEST_PATTERN" ]]; then
        VITEST_CMD="$VITEST_CMD $TEST_PATTERN"
    fi

    # Add coverage flag
    if [[ "$COVERAGE" == true ]]; then
        VITEST_CMD="$VITEST_CMD --coverage"
    fi

    # Add watch flag
    if [[ "$WATCH" == true ]]; then
        VITEST_CMD="npx vitest"
        if [[ -n "$TEST_PATTERN" ]]; then
            VITEST_CMD="$VITEST_CMD $TEST_PATTERN"
        fi
    fi

    # Add reporter
    if [[ "$REPORTER" != "default" ]]; then
        VITEST_CMD="$VITEST_CMD --reporter=$REPORTER"
    fi

    # Add update snapshots flag
    if [[ "$UPDATE_SNAPSHOT" == true ]]; then
        VITEST_CMD="$VITEST_CMD --update-snapshots"
    fi

    log_info "Running: $VITEST_CMD"
    eval "$VITEST_CMD"
}

# Mocha test runner
run_mocha_tests() {
    log_step "Running Mocha tests..."

    # Check if Mocha is available
    if ! npx mocha --version &> /dev/null; then
        log_error "Mocha is not available"
        exit 1
    fi

    # Build Mocha command
    MOCHA_CMD="npx mocha"

    # Add test pattern if specified
    if [[ -n "$TEST_PATTERN" ]]; then
        MOCHA_CMD="$MOCHA_CMD $TEST_PATTERN"
    else
        # Default test pattern for Mocha
        MOCHA_CMD="$MOCHA_CMD test/**/*.js"
    fi

    # Add reporter
    if [[ "$REPORTER" != "default" ]]; then
        MOCHA_CMD="$MOCHA_CMD --reporter=$REPORTER"
    fi

    # Add coverage flag (with nyc)
    if [[ "$COVERAGE" == true ]]; then
        if npx nyc --version &> /dev/null; then
            MOCHA_CMD="npx nyc $MOCHA_CMD"
        else
            log_warn "nyc not available, coverage report skipped"
        fi
    fi

    log_info "Running: $MOCHA_CMD"
    eval "$MOCHA_CMD"
}

log_info "JavaScript testing completed!"