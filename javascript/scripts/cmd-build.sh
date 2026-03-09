#!/bin/bash
# JavaScript build script for modern JavaScript applications

set -e

# Default values
WORKSPACE="${WORKSPACE:-.}"
BUILD_MODE="${BUILD_MODE:-production}"
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
JavaScript Build Script

Usage: $0 [OPTIONS]

Options:
  -w, --workspace DIR    Workspace directory (default: current directory)
  -m, --mode MODE        Build mode: development|production (default: production)
  -e, --env FILE         Environment file to load
  -o, --output DIR       Output directory for build artifacts
  -a, --analyze          Analyze bundle size after build
  -c, --clean            Clean output directory before building
  -w, --watch            Watch for changes and rebuild (development mode only)
  -h, --help             Show this help message

Environment Variables:
  WORKSPACE             Workspace directory
  NODE_ENV              Node environment (development|production)
  BUILD_SCRIPT          Custom build script name

Build Modes:
  development          Optimized for development with hot reloading
  production          Optimized for production with minification

Examples:
  # Production build
  $0

  # Development build
  $0 --mode development

  # Build with environment file
  $0 --env .env.production

  # Build and analyze bundle size
  $0 --analyze

  # Clean build directory first
  $0 --clean
EOF
}

# Parse command line arguments
CLEAN=false
ANALYZE=false
WATCH=false
OUTPUT_DIR=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -w|--workspace)
            WORKSPACE="$2"
            shift 2
            ;;
        -m|--mode)
            BUILD_MODE="$2"
            shift 2
            ;;
        -e|--env)
            ENV_FILE="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -a|--analyze)
            ANALYZE=true
            shift
            ;;
        -c|--clean)
            CLEAN=true
            shift
            ;;
        -w|--watch)
            WATCH=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Validate build mode
if [[ "$BUILD_MODE" != "development" && "$BUILD_MODE" != "production" ]]; then
    log_error "Invalid build mode: $BUILD_MODE. Must be 'development' or 'production'"
    exit 1
fi

# Validate watch mode
if [[ "$WATCH" == true && "$BUILD_MODE" == "production" ]]; then
    log_warn "Watch mode is typically used with development builds"
fi

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

# Set Node environment
export NODE_ENV="$BUILD_MODE"

# Determine build script
BUILD_SCRIPT="${BUILD_SCRIPT:-build}"
if [[ "$WATCH" == true ]]; then
    BUILD_SCRIPT="dev"
fi

# Check if build script exists
if ! npm run | grep -q "^  ${BUILD_SCRIPT}$"; then
    log_error "Build script '${BUILD_SCRIPT}' not found in package.json"
    log_info "Available scripts:"
    npm run
    exit 1
fi

# Set output directory if not specified
if [[ -z "$OUTPUT_DIR" ]]; then
    OUTPUT_DIR="dist"
    if [[ "$BUILD_MODE" == "development" ]]; then
        OUTPUT_DIR="build"
    fi
fi

# Clean output directory if requested
if [[ "$CLEAN" == true ]]; then
    log_step "Cleaning output directory: $OUTPUT_DIR"
    rm -rf "$OUTPUT_DIR"
fi

# Display build information
log_info "Building JavaScript application..."
log_info "Workspace: $WORKSPACE"
log_info "Mode: $BUILD_MODE"
log_info "Node Environment: $NODE_ENV"
log_info "Output Directory: $OUTPUT_DIR"
log_info "Build Script: $BUILD_SCRIPT"

# Install dependencies if node_modules doesn't exist
if [[ ! -d "node_modules" ]]; then
    log_step "Installing dependencies..."
    npm ci
fi

# Build timing
BUILD_START=$(date +%s)

# Run build
log_step "Running build script..."
if [[ "$WATCH" == true ]]; then
    log_info "Starting build in watch mode..."
    npm run "${BUILD_SCRIPT}"
else
    if npm run "${BUILD_SCRIPT}"; then
        BUILD_END=$(date +%s)
        BUILD_DURATION=$((BUILD_END - BUILD_START))
        log_info "Build completed successfully in ${BUILD_DURATION}s"

        # Check if output directory was created
        if [[ -d "$OUTPUT_DIR" ]]; then
            OUTPUT_SIZE=$(du -sh "$OUTPUT_DIR" | cut -f1)
            FILE_COUNT=$(find "$OUTPUT_DIR" -type f | wc -l)
            log_info "Output: $FILE_COUNT files, $OUTPUT_SIZE"

            # List main output files
            log_info "Main output files:"
            find "$OUTPUT_DIR" -maxdepth 1 -type f \( -name "*.js" -o -name "*.css" -o -name "*.html" \) | head -10
        else
            log_warn "No output directory created"
        fi

        # Analyze bundle size if requested
        if [[ "$ANALYZE" == true ]]; then
            log_step "Analyzing bundle size..."

            # Check for webpack-bundle-analyzer
            if npm list webpack-bundle-analyzer &> /dev/null; then
                if [[ -f "webpack-bundle-analyzer.config.js" ]] || grep -q "bundleAnalyzer" "webpack.config.js"; then
                    log_info "Running webpack-bundle-analyzer..."
                    npm run analyze 2>/dev/null || log_warn "Analyze script not found, skipping bundle analysis"
                else
                    log_warn "webpack-bundle-analyzer not configured"
                fi
            else
                log_warn "webpack-bundle-analyzer not installed. Install with: npm install --save-dev webpack-bundle-analyzer"
            fi

            # Simple size analysis
            if [[ -d "$OUTPUT_DIR" ]]; then
                echo ""
                log_info "Bundle Size Analysis:"
                find "$OUTPUT_DIR" -name "*.js" -o -name "*.css" | head -10 | while read file; do
                    size=$(du -h "$file" | cut -f1)
                    relative_path="${file#$OUTPUT_DIR/}"
                    echo "  $relative_path: $size"
                done
            fi
        fi
    else
        log_error "Build failed"
        exit 1
    fi
fi

log_info "JavaScript build process completed!"