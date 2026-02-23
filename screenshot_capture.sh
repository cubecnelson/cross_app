#!/bin/bash
# screenshot_capture.sh - Capture screenshots from the Cross Flutter app

set -e  # Exit on error

echo "📱 Cross App Screenshot Capture"
echo "=================================="

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    echo "   Visit: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Check if in the correct directory
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Please run this script from the project root directory."
    exit 1
fi

# Create screenshots directory
SCREENSHOT_DIR="screenshots"
echo "📁 Creating output directory: $SCREENSHOT_DIR"
mkdir -p "$SCREENSHOT_DIR"

# Clean previous screenshots
echo "🧹 Cleaning previous screenshots..."
rm -rf "$SCREENSHOT_DIR"/*.png 2>/dev/null || true

# Get Flutter version
echo "🔧 Flutter version:"
flutter --version

# Install dependencies
echo "📦 Installing dependencies..."
flutter pub get

# Run screenshot tests with environment variable
echo "🚀 Running screenshot tests..."
echo "   Set CAPTURE_SCREENSHOTS=true to enable screenshot capture"
echo "   Set SCREENSHOT_MODE=true for screenshot-only mode"

# Run the integration test
CAPTURE_SCREENSHOTS=true SCREENSHOT_MODE=true flutter test \
  integration_test/screenshot_test.dart \
  --dart-define=CAPTURE_SCREENSHOTS=true \
  --dart-define=SCREENSHOT_MODE=true \
  --no-track-widget-creation \
  --platform ios \
  --timeout 60s

# Check if screenshots were captured
SCREENSHOT_COUNT=$(find "$SCREENSHOT_DIR" -name "*.png" -type f | wc -l)

if [ "$SCREENSHOT_COUNT" -gt 0 ]; then
    echo "✅ Successfully captured $SCREENSHOT_COUNT screenshots:"
    find "$SCREENSHOT_DIR" -name "*.png" -type f | while read -r file; do
        echo "   📸 $(basename "$file")"
    done
    
    echo ""
    echo "📋 Next steps:"
    echo "   1. Review screenshots in the '$SCREENSHOT_DIR' directory"
    echo "   2. Update website with actual screenshots"
    echo "   3. Use for app store submission"
    echo "   4. Consider adding device frames using:"
    echo "      - https://appstorescreenshot.com/"
    echo "      - https://mockuphone.com/"
else
    echo "⚠️  No screenshots were captured."
    echo "   Make sure:"
    echo "   - CAPTURE_SCREENSHOTS=true is set"
    echo "   - The test is properly navigating to screens"
    echo "   - The app is rendering correctly"
fi

echo ""
echo "🎉 Screenshot capture complete!"