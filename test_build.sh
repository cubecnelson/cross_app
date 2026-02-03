#!/bin/bash
# Test build script for Cross app

echo "🧪 Testing Cross app build..."

# Check Flutter version
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found in PATH"
    echo "Install Flutter: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✅ Flutter found: $(flutter --version | head -1)"

# Check dependencies
echo "📦 Checking dependencies..."
if [ ! -f "pubspec.lock" ]; then
    echo "Running flutter pub get..."
    flutter pub get
else
    echo "✅ Dependencies already fetched"
fi

# Analyze code
echo "🔍 Analyzing Dart code..."
flutter analyze lib/

# Try building for iOS (simulator)
echo "🏗️  Building for iOS simulator..."
if [ "$1" = "--full" ]; then
    flutter build ios --simulator --no-codesign \
        --dart-define=SUPABASE_URL="dummy" \
        --dart-define=SUPABASE_ANON_KEY="dummy"
else
    echo "Skipping full build. Use './test_build.sh --full' to test build"
fi

echo "✅ Build test complete!"
