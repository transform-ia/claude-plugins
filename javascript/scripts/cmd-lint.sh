#!/bin/bash
# JavaScript linting script for ESLint integration

set -e

# Default values
WORKSPACE="${WORKSPACE:-/workspace}"
ENV_FILE="${ENV_FILE:-/.env}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# Help function
show_help() {
    cat << EOF
JavaScript ESLint Linting Script

Usage: $0 [OPTIONS] [FILES...]

Arguments:
  FILES                 JavaScript files to lint (default: all JS/JSX files)

Options:
  -w, --workspace DIR    Workspace directory (default: /workspace)
  -f, --fix             Automatically fix fixable issues
  -q, --quiet           Only show errors, no warnings
  -c, --config FILE     Custom ESLint configuration file
  --ext EXTENSIONS      File extensions to lint (default: js,jsx,ts,tsx)
  --max-warnings NUM    Maximum number of warnings before failing
  -h, --help            Show this help message

Environment Variables:
  WORKSPACE             Workspace directory
  ESLINT_CONFIG         Path to ESLint configuration

Examples:
  # Lint all JavaScript files in workspace
  $0

  # Lint specific files
  $0 src/components/Button.jsx src/utils/helpers.js

  # Auto-fix fixable issues
  $0 --fix

  # Lint with custom configuration
  $0 --config .eslintrc.custom.js

  # Quiet mode (errors only)
  $0 --quiet
EOF
}

# Parse command line arguments
FILES=()
FIX=false
QUIET=false
CONFIG_FILE=""
EXTENSIONS="js,jsx,ts,tsx"
MAX_WARNINGS=10

while [[ $# -gt 0 ]]; do
    case $1 in
        -w|--workspace)
            WORKSPACE="$2"
            shift 2
            ;;
        -f|--fix)
            FIX=true
            shift
            ;;
        -q|--quiet)
            QUIET=true
            shift
            ;;
        -c|--config)
            CONFIG_FILE="$2"
            shift 2
            ;;
        --ext)
            EXTENSIONS="$2"
            shift 2
            ;;
        --max-warnings)
            MAX_WARNINGS="$2"
            shift 2
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
            FILES+=("$1")
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

# Check if ESLint is available
if ! command -v eslint &> /dev/null; then
    log_error "ESLint is not installed or not in PATH"
    exit 1
fi

# Prepare ESLint command
ESLINT_CMD="eslint"

# Add configuration file if specified
if [[ -n "$CONFIG_FILE" ]]; then
    ESLINT_CMD="$ESLINT_CMD --config $CONFIG_FILE"
elif [[ -n "$ESLINT_CONFIG" ]]; then
    ESLINT_CMD="$ESLINT_CMD --config $ESLINT_CONFIG"
fi

# Add extensions
ESLINT_CMD="$ESLINT_CMD --ext $EXTENSIONS"

# Add max warnings
ESLINT_CMD="$ESLINT_CMD --max-warnings $MAX_WARNINGS"

# Add fix flag if requested
if [[ "$FIX" == true ]]; then
    ESLINT_CMD="$ESLINT_CMD --fix"
    log_info "Running ESLint with auto-fix enabled..."
fi

# Add quiet flag if requested
if [[ "$QUIET" == true ]]; then
    ESLINT_CMD="$ESLINT_CMD --quiet"
    log_info "Running ESLint in quiet mode (errors only)..."
fi

# Determine files to lint
if [[ ${#FILES[@]} -eq 0 ]]; then
    log_info "No files specified, discovering JavaScript files..."

    # Find all JS/JSX files, excluding common directories
    FILES=($(find . -type f \( -name "*.js" -o -name "*.jsx" -o -name "*.ts" -o -name "*.tsx" \) \
        ! -path "./node_modules/*" \
        ! -path "./dist/*" \
        ! -path "./build/*" \
        ! -path "./coverage/*" \
        ! -path "./.git/*" \
        ! -path "./tmp/*" \
        ! -path "./temp/*"))

    if [[ ${#FILES[@]} -eq 0 ]]; then
        log_warn "No JavaScript files found to lint"
        exit 0
    fi

    log_info "Found ${#FILES[@]} files to lint"
fi

# Run ESLint
log_info "Running ESLint on ${#FILES[@]} files..."
log_info "Command: $ESLINT_CMD ${FILES[*]}"

if ESLINT_RESULT=$(eval "$ESLINT_CMD" "${FILES[@]}" 2>&1); then
    log_info "ESLint passed successfully!"
    if [[ -n "$ESLINT_RESULT" ]]; then
        echo "$ESLINT_RESULT"
    fi
    exit 0
else
    EXIT_CODE=$?
    log_error "ESLint failed with exit code $EXIT_CODE"
    echo "$ESLINT_RESULT"

    # Provide helpful suggestions
    if [[ "$ESLINT_RESULT" =~ "No ESLint configuration found" ]]; then
        log_warn "No ESLint configuration found. Consider creating .eslintrc.js"
        echo "Example configuration:"
        echo "module.exports = {"
        echo "  env: {"
        echo "    browser: true,"
        echo "    es2021: true"
        echo "  },"
        echo "  extends: ['eslint:recommended'],"
        echo "  parserOptions: {"
        echo "    ecmaVersion: 'latest',"
        echo "    sourceType: 'module'"
        echo "  }"
        echo "};"
    fi

    if [[ "$FIX" == false ]]; then
        log_info "Try running with --fix to auto-fix fixable issues"
    fi

    exit $EXIT_CODE
fi