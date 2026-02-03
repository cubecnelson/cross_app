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
