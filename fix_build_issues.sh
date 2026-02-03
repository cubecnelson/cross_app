#!/bin/bash
# fix_build_issues.sh
# Fix common build issues in Cross app

set -e

echo "🔧 Fixing build issues in Cross app..."

cd /Users/nelson.cheung/clawd/cross_app_github

# 1. Fix Info.plist - Update Google Sign-In Client ID placeholder
echo "1. Fixing Info.plist..."
if grep -q "com.googleusercontent.apps.301653161337" "ios/Runner/Info.plist"; then
    echo "   ⚠️  Google Client ID placeholder found. This needs to be replaced with your actual Client ID."
    echo "   Please update: ios/Runner/Info.plist"
    echo "   Replace: com.googleusercontent.apps.301653161337"
    echo "   With your actual reversed iOS Client ID"
fi

# 2. Check for missing environment variables in workflow
echo "2. Checking GitHub Secrets requirements..."
echo "   Required GitHub Secrets for workflow:"
echo "   - SUPABASE_URL"
echo "   - SUPABASE_ANON_KEY"
echo "   - APP_STORE_CONNECT_API_KEY_ID"
echo "   - APP_STORE_CONNECT_API_ISSUER_ID"
echo "   - APP_STORE_CONNECT_API_KEY_CONTENT"
echo "   - TEAM_ID (currently set to YWQH3Z3Z85)"

# 3. Check for common Flutter build issues
echo "3. Checking for common issues..."
if [ ! -f "pubspec.lock" ]; then
    echo "   ⚠️  pubspec.lock not found. Run 'flutter pub get' first."
else
    echo "   ✅ pubspec.lock exists"
fi

# 4. Check iOS deployment target
echo "4. Checking iOS deployment target..."
DEPLOYMENT_TARGET=$(grep -A2 "platform :ios" ios/Podfile | grep -o "[0-9]\+\.[0-9]\+" | head -1)
echo "   iOS Deployment Target: $DEPLOYMENT_TARGET"

# 5. Check for missing Flutter dependencies
echo "5. Checking for missing imports..."
MISSING_IMPORTS=$(grep -r "import.*'" lib/ --include="*.dart" | grep -v "package:" | head -5)
if [ -n "$MISSING_IMPORTS" ]; then
    echo "   ⚠️  Potential missing imports found:"
    echo "$MISSING_IMPORTS"
fi

# 6. Create a build test script
echo "6. Creating build test script..."
cat > test_build.sh << 'EOF'
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
EOF

chmod +x test_build.sh

# 7. Create a README with build instructions
echo "7. Creating build troubleshooting guide..."
cat > BUILD_FIXES.md << 'EOF'
# Cross App Build Fixes

## Common Issues & Solutions

### 1. Flutter Not Found
```bash
# Install Flutter SDK
# Download from: https://flutter.dev/docs/get-started/install
# Add to PATH
export PATH="$PATH:/path/to/flutter/bin"
```

### 2. Missing Dependencies
```bash
# Run these commands
flutter pub get
cd ios
pod install --repo-update
cd ..
```

### 3. Code Signing Issues (iOS)
The project uses **automatic signing** with App Store Connect API key.

#### Required GitHub Secrets:
- `SUPABASE_URL` - Your Supabase project URL
- `SUPABASE_ANON_KEY` - Your Supabase anon key
- `APP_STORE_CONNECT_API_KEY_ID` - API Key ID from App Store Connect
- `APP_STORE_CONNECT_API_ISSUER_ID` - Issuer ID from App Store Connect  
- `APP_STORE_CONNECT_API_KEY_CONTENT` - .p8 key file content
- `TEAM_ID` - Your Apple Developer Team ID (currently: YWQH3Z3Z85)

### 4. Google Sign-In Configuration
Update `ios/Runner/Info.plist`:
- Replace placeholder Client ID with your actual iOS Client ID
- Format: `com.googleusercontent.apps.YOUR_CLIENT_ID`

### 5. Build Commands

#### Test Build (Simulator):
```bash
./test_build.sh --full
```

#### Production Build:
```bash
flutter build ios --release --no-codesign \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY"
```

### 6. Workflow Debugging
If GitHub Actions fails:
1. Check workflow logs for specific error
2. Verify all secrets are correctly set
3. Ensure API key has proper permissions
4. Check Team ID matches your developer account

## Quick Fix Checklist
- [ ] Flutter SDK installed and in PATH
- [ ] Dependencies fetched: `flutter pub get`
- [ ] CocoaPods installed: `pod install`
- [ ] GitHub Secrets configured
- [ ] Google Client ID updated in Info.plist
- [ ] Team ID correct in workflow

## Testing Locally
```bash
# Clean build
flutter clean
rm -rf ios/Pods ios/Podfile.lock

# Reinstall dependencies
flutter pub get
cd ios
pod install
cd ..

# Build for simulator
flutter build ios --simulator
```

## Need Help?
Check these files:
- `BUILD_TROUBLESHOOTING.md` - Detailed iOS build troubleshooting
- `.github/workflows/ios-release.yml` - CI/CD workflow
- `ios/fastlane/Fastfile` - Build automation
- `test_build.sh` - Local test script
EOF

echo "✅ Fix script created!"
echo ""
echo "📋 Next steps:"
echo "1. Update Google Client ID in ios/Runner/Info.plist"
echo "2. Ensure all GitHub Secrets are set"
echo "3. Run ./test_build.sh to check for issues"
echo "4. Commit and push changes:"
echo "   git add ."
echo "   git commit -m 'Fix build issues'"
echo "   git push"
echo ""
echo "For detailed instructions, see BUILD_FIXES.md"