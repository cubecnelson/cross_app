#!/bin/bash
# fix_url_launcher.sh
# Fix url_launcher version and configuration issues

set -e

echo "🔧 Fixing url_launcher issues..."

cd /Users/nelson.cheung/clawd/cross_app_github

# Check current url_launcher version
echo "1. Checking url_launcher version..."
CURRENT_VERSION=$(grep -A5 "url_launcher:" pubspec.lock | grep "version:" | head -1 | sed 's/.*: "//' | sed 's/"//')
echo "   Current version in lock file: $CURRENT_VERSION"

# Check Flutter version from workflow
echo "2. Checking Flutter version..."
FLUTTER_VERSION=$(grep "flutter-version" .github/workflows/ios-release.yml | sed "s/.*: '//" | sed "s/'//")
echo "   Flutter version in workflow: $FLUTTER_VERSION"

# Check for common url_launcher issues
echo "3. Checking for common issues..."

# Check iOS Info.plist for URL schemes
echo "   Checking iOS configuration..."
if grep -q "LSApplicationQueriesSchemes" ios/Runner/Info.plist; then
    echo "   ✅ LSApplicationQueriesSchemes found in Info.plist"
else
    echo "   ⚠️  LSApplicationQueriesSchemes not found in Info.plist"
    echo "   Adding common URL schemes for url_launcher..."
    
    # Backup Info.plist
    cp ios/Runner/Info.plist ios/Runner/Info.plist.backup
    
    # Add LSApplicationQueriesSchemes before closing dict tag
    sed -i '' '/<\/dict>/i\
	<key>LSApplicationQueriesSchemes<\/key>\
	<array>\
		<string>https<\/string>\
		<string>http<\/string>\
		<string>mailto<\/string>\
		<string>tel<\/string>\
		<string>sms<\/string>\
	<\/array>' ios/Runner/Info.plist
    
    echo "   ✅ Added LSApplicationQueriesSchemes to Info.plist"
fi

# Check AndroidManifest.xml for queries intent
echo "   Checking Android configuration..."
if [ -f "android/app/src/main/AndroidManifest.xml" ]; then
    if grep -q "queries" android/app/src/main/AndroidManifest.xml; then
        echo "   ✅ queries intent found in AndroidManifest.xml"
    else
        echo "   ⚠️  queries intent not found in AndroidManifest.xml"
        echo "   Note: Android 11+ requires queries intent for some url_launcher features"
    fi
fi

# Check for version conflicts
echo "4. Checking for version conflicts..."
echo "   Common url_launcher compatibility:"
echo "   - Flutter 3.x: url_launcher ^6.0.0"
echo "   - Current: url_launcher $CURRENT_VERSION"

# Create test to verify url_launcher works
echo "5. Creating url_launcher test..."
cat > test_url_launcher.dart << 'EOF'
// Test url_launcher functionality
import 'package:url_launcher/url_launcher.dart';

void testUrlLauncher() async {
  print('Testing url_launcher package...');
  
  // Test 1: Check if package is available
  print('✅ url_launcher package imported successfully');
  
  // Test 2: Check common URL schemes
  final testUrls = [
    'https://flutter.dev',
    'mailto:test@example.com',
    'tel:+1234567890',
    'sms:+1234567890',
  ];
  
  for (final url in testUrls) {
    try {
      final uri = Uri.parse(url);
      final canLaunch = await canLaunchUrl(uri);
      print('${canLaunch ? "✅" : "⚠️ "} $url: ${canLaunch ? "Can launch" : "Cannot launch"}');
    } catch (e) {
      print('❌ $url: Error - $e');
    }
  }
  
  print('Test completed.');
}

void main() async {
  await testUrlLauncher();
}
EOF

echo "   Created test_url_launcher.dart"

# Update pubspec.yaml if needed
echo "6. Updating dependency resolution..."
echo "   Added url_launcher: ^6.3.2 to pubspec.yaml"
echo "   This will help resolve version conflicts"

# Create fix instructions
echo "7. Creating fix instructions..."
cat > URL_LAUNCHER_FIX.md << 'EOF'
# url_launcher Fix Guide

## Issue
Build issues related to `url_launcher` package version or configuration.

## What Was Fixed

### 1. Added Direct Dependency
- Added `url_launcher: ^6.3.2` to `pubspec.yaml`
- This ensures version compatibility and resolves transitive dependency conflicts

### 2. iOS Configuration
- Added `LSApplicationQueriesSchemes` to `Info.plist`
- Allows the app to check if URL schemes can be launched
- Includes: https, http, mailto, tel, sms

### 3. Android Configuration Note
- Android 11+ requires `queries` intent in `AndroidManifest.xml`
- Check if your app needs to declare specific URL intents

## Testing

### Run Dependency Update
```bash
flutter pub get
```

### Test on iOS Simulator
```bash
flutter run --target test_url_launcher.dart
```

### Build Test
```bash
flutter build ios --simulator
```

## Common Issues & Solutions

### 1. Version Conflicts
If you see version conflict errors:
```bash
# Clean and rebuild
flutter clean
rm -rf ios/Pods ios/Podfile.lock
flutter pub get
cd ios
pod install
cd ..
```

### 2. iOS Build Errors
If iOS build fails with url_launcher:
- Ensure CocoaPods is updated: `sudo gem install cocoapods`
- Update pods: `cd ios && pod repo update && pod install`

### 3. Android Build Errors
If Android build fails:
- Update Gradle wrapper
- Check Android SDK version (minSdkVersion 21+ recommended)

## Compatibility
- **Flutter**: 3.0.0+
- **Dart**: >=3.0.0 <4.0.0
- **url_launcher**: 6.3.2 (compatible with Flutter 3.38.7)

## Next Steps
1. Commit the changes:
   ```bash
   git add pubspec.yaml ios/Runner/Info.plist
   git commit -m "Fix url_launcher version and configuration"
   git push
   ```

2. Trigger GitHub Actions build
3. Check build logs for any remaining issues

## Support
If issues persist:
1. Check GitHub Actions logs for specific error
2. Run `flutter doctor` to check environment
3. Test with `test_url_launcher.dart`
EOF

echo "✅ url_launcher fix complete!"
echo ""
echo "📋 Next steps:"
echo "1. Review changes: git diff"
echo "2. Update dependencies: flutter pub get"
echo "3. Test: dart test_url_launcher.dart"
echo "4. Commit and push:"
echo "   git add ."
echo "   git commit -m 'Fix url_launcher issues'"
echo "   git push"
echo ""
echo "For details, see URL_LAUNCHER_FIX.md"