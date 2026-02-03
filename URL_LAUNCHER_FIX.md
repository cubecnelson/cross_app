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
