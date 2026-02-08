#!/bin/bash
# test_runner.sh - Run Flutter tests with different options

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}=== $1 ===${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

print_header "Flutter Test Runner"

# Check if we're in the project root
if [ ! -f "pubspec.yaml" ]; then
    print_error "pubspec.yaml not found. Are you in the project root?"
    exit 1
fi

# Parse command line arguments
TEST_TYPE="all"
COVERAGE=false
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --unit)
            TEST_TYPE="unit"
            shift
            ;;
        --widget)
            TEST_TYPE="widget"
            shift
            ;;
        --integration)
            TEST_TYPE="integration"
            shift
            ;;
        --coverage)
            COVERAGE=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --help)
            echo "Usage: ./test_runner.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --unit         Run only unit tests"
            echo "  --widget       Run only widget tests"
            echo "  --integration  Run only integration tests"
            echo "  --coverage     Generate coverage report"
            echo "  --verbose      Show verbose output"
            echo "  --help         Show this help message"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Check Flutter installation
if ! command -v flutter &> /dev/null; then
    print_error "Flutter not found. Please install Flutter first."
    exit 1
fi

# Get Flutter version
print_info "Flutter Version:"
flutter --version

# Get dependencies
print_header "Getting dependencies..."
flutter pub get

# Run analyze
print_header "Analyzing code..."
if [ "$VERBOSE" = true ]; then
    flutter analyze
else
    flutter analyze --no-fatal-infos || print_info "Analysis completed with warnings"
fi

# Run tests based on type
case $TEST_TYPE in
    "unit")
        print_header "Running Unit Tests..."
        if [ "$COVERAGE" = true ]; then
            flutter test test/unit/ --coverage --coverage-path=coverage/unit
        else
            flutter test test/unit/
        fi
        ;;
    "widget")
        print_header "Running Widget Tests..."
        if [ "$COVERAGE" = true ]; then
            flutter test test/widget/ --coverage --coverage-path=coverage/widget
        else
            flutter test test/widget/
        fi
        ;;
    "integration")
        print_header "Running Integration Tests..."
        if [ "$COVERAGE" = true ]; then
            flutter test test/integration/ --coverage --coverage-path=coverage/integration
        else
            flutter test test/integration/
        fi
        ;;
    "all")
        print_header "Running All Tests..."
        if [ "$COVERAGE" = true ]; then
            flutter test --coverage --coverage-path=coverage/all
        else
            flutter test
        fi
        ;;
esac

# Generate coverage report if requested
if [ "$COVERAGE" = true ]; then
    print_header "Generating Coverage Report..."
    if command -v lcov &> /dev/null && [ -f "coverage/lcov.info" ]; then
        mkdir -p coverage/html
        genhtml coverage/lcov.info -o coverage/html
        print_success "HTML coverage report generated at coverage/html/index.html"
    else
        print_info "lcov not installed or coverage file not found. Install lcov to generate HTML report."
        print_info "Ubuntu/Debian: sudo apt-get install lcov"
        print_info "macOS: brew install lcov"
    fi
fi

print_header "Test Summary"
print_success "All tests completed!"
echo ""
print_info "Test Type: $TEST_TYPE"
print_info "Coverage: $([ "$COVERAGE" = true ] && echo "Enabled" || echo "Disabled")"
print_info "Verbose: $([ "$VERBOSE" = true ] && echo "Enabled" || echo "Disabled")"
echo ""
print_info "To view coverage report (if generated):"
echo "  open coverage/html/index.html"