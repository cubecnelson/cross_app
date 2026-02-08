#!/bin/bash
# test_android_build.sh - Test Android build locally

set -e

echo "=== Testing Android Build Locally ==="
echo ""

# Check if we're in the project root
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Not in project root. Run from cross_app directory."
    exit 1
fi

# Check Flutter installation
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found. Install Flutter first."
    exit 1
fi

echo "✅ Flutter found"
flutter --version

# Check Android SDK
echo ""
echo "=== Checking Android Setup ==="
if [ -d "android" ]; then
    echo "✅ Android directory exists"
else
    echo "⚠️ Android directory not found"
    echo "Creating Android project..."
    flutter create --platforms=android --no-overwrite .
    if [ -d "android" ]; then
        echo "✅ Android project created"
    else
        echo "❌ Failed to create Android project"
        exit 1
    fi
fi

# Check Android licenses
echo ""
echo "=== Checking Android Licenses ==="
flutter doctor --android-licenses || echo "⚠️ License check may need manual intervention"

# Try a simple build
echo ""
echo "=== Testing Debug Build ==="
flutter build apk --debug --no-tree-shake-icons || {
    echo "❌ Debug build failed"
    echo "Trying without dart-defines..."
    flutter build apk --debug
}

# Check if APK was created
echo ""
echo "=== Checking for APK ==="
if [ -f "build/app/outputs/flutter-apk/app-debug.apk" ]; then
    APK_PATH="build/app/outputs/flutter-apk/app-debug.apk"
    echo "✅ Debug APK found: $APK_PATH"
    echo "Size: $(du -h "$APK_PATH" | cut -f1)"
elif [ -f "build/app/outputs/apk/debug/app-debug.apk" ]; then
    APK_PATH="build/app/outputs/apk/debug/app-debug.apk"
    echo "✅ Debug APK found: $APK_PATH"
    echo "Size: $(du -h "$APK_PATH" | cut -f1)"
else
    echo "❌ Debug APK not found"
    echo "Searching..."
    find build -name "*.apk" -type f 2>/dev/null || echo "No APK files found"
fi

echo ""
echo "=== Summary ==="
echo "Android project: $(if [ -d "android" ]; then echo "✅ Ready"; else echo "❌ Missing"; fi)"
echo "Flutter doctor: $(flutter doctor | grep -q "Doctor summary" && echo "✅ OK" || echo "⚠️ Issues")"
echo "Debug build: $(if [ -n "$APK_PATH" ]; then echo "✅ Success"; else echo "❌ Failed"; fi)"

if [ -n "$APK_PATH" ]; then
    echo ""
    echo "🎉 Android build test passed!"
    echo "APK location: $APK_PATH"
else
    echo ""
    echo "⚠️ Android build test had issues"
    echo "Run 'flutter doctor' for more details"
    exit 1
fi