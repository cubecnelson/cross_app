# 📱 Screenshot Capture for Cross App

This guide explains how to capture actual screenshots from the Cross Flutter app for app store submissions and marketing materials.

## 🎯 Overview

We've set up an automated screenshot capture system using Flutter's `integration_test` framework. The system can capture screenshots of key app screens in simulated iPhone sizes.

## 🚀 Quick Start

### Capture Screenshots Locally

1. **Ensure Flutter is installed**:
   ```bash
   flutter --version  # Should be 3.0.0+
   ```

2. **Run the screenshot capture script**:
   ```bash
   ./screenshot_capture.sh
   ```

3. **Find your screenshots** in the `screenshots/` directory.

### Manual Capture (More Control)

```bash
# Install dependencies
flutter pub get

# Run screenshot tests
CAPTURE_SCREENSHOTS=true flutter test integration_test/screenshot_test.dart \
  --dart-define=CAPTURE_SCREENSHOTS=true \
  (runs in default VM - omit --platform for integration tests) \
  --timeout 60s
```

## 📂 File Structure

```
cross_app/
├── integration_test/
│   ├── screenshot_test.dart      # Main screenshot capture tests
│   └── screenshot_helper.dart    # Screenshot capture utilities
├── screenshots/                  # Output directory (gitignored)
├── screenshot_capture.sh         # Convenience script
└── .github/workflows/screenshots.yml  # GitHub Actions automation
```

## 🧪 Available Screenshots

Currently configured to capture:

1. **Login Screen** - App entry point (always works)
2. **Dashboard Screen** - Main app dashboard (requires auth mocks)

### Screenshot Naming Convention

Screenshots are named with pattern: `{screen_name}_{device_size}_{timestamp}.png`

Example: `login_phone_1700000000000.png`

## ⚙️ Configuration

### Device Sizes

Configure device sizes in `integration_test/screenshot_helper.dart`:

```dart
static const List<DeviceSize> appStoreIphoneSizes = [
  DeviceSize.iphone14ProMax,  // 6.7" (1290×2796)
  DeviceSize.iphone14,        // 6.1" (1170×2532)  
  DeviceSize.iphone8Plus,     // 5.5" (1242×2208)
];
```

### Environment Variables

- `CAPTURE_SCREENSHOTS=true` - Enable screenshot capture
- `SCREENSHOT_MODE=true` - Screenshot-only mode (skips assertions)

## 🤖 GitHub Actions Automation

Screenshots can be captured automatically via GitHub Actions:

1. Go to **Actions** → **Capture App Screenshots** → **Run workflow**
2. Screenshots will be available as an artifact
3. Download and use for app store submissions

## 🔧 Extending the System

### Add New Screenshots

1. **Create a new test** in `screenshot_test.dart`:
   ```dart
   testWidgets('Capture {Screen Name}', (WidgetTester tester) async {
     // Setup app state
     // Navigate to screen
     // Capture screenshot
   });
   ```

2. **Update navigation** if needed (tap buttons, etc.)

3. **Add mocks** for required providers (auth, data, etc.)

### Improve Mocking

For better dashboard/authenticated screenshots:

1. **Create proper mocks** for Supabase Session/User
2. **Mock data providers** (workouts, routines, etc.)
3. **Use real test data** from `test/` directory

## 📱 App Store Requirements

### iOS App Store
- **iPhone 6.7"**: 1290×2796 pixels
- **iPhone 6.1"**: 1170×2532 pixels  
- **iPhone 5.5"**: 1242×2208 pixels

### Google Play Store
- **Phone**: 1080×1920 pixels
- **Tablet 7"**: 1200×1920 pixels
- **Tablet 10"**: 1600×2560 pixels

## 🎨 Post-Processing

After capturing screenshots:

1. **Add device frames** using:
   - [AppStoreScreenshot.com](https://appstorescreenshot.com/)
   - [Mockuphone](https://mockuphone.com/)
   - [DeviceFrames.com](https://deviceframes.com/)

2. **Update website** (`docs/assets/`):
   ```bash
   cp screenshots/*.png docs/assets/
   ```

3. **Update app store listings** with actual screenshots

## 🐛 Troubleshooting

### "No screenshots captured"
- Check `CAPTURE_SCREENSHOTS=true` is set
- Verify test is not failing before capture
- Check console for error messages

### "Session/User constructor errors"
- Dashboard screenshots require proper mocks
- Use login screenshots as fallback
- Implement proper Session.fromJson() mocking

### "Tests timeout"
- Increase timeout: `--timeout 120s`
- Check for infinite loading states
- Ensure mocks provide data quickly

## 📝 Notes

- Screenshots are saved to `screenshots/` (gitignored)
- Multiple device sizes can be captured in one run
- Actual screenshots better represent app than SVG mockups
- Consider running on CI for consistent results

## 🔗 Resources

- [Flutter Integration Testing](https://flutter.dev/docs/testing/integration-tests)
- [App Store Screenshot Requirements](https://help.apple.com/app-store-connect/#/devd274dd925)
- [Google Play Screenshot Requirements](https://support.google.com/googleplay/android-developer/answer/9866151)
- [Fastlane Snapshot](https://docs.fastlane.tools/actions/snapshot/) (alternative)

---

**Next Steps**: 
1. Run screenshot capture locally
2. Review captured screenshots  
3. Update website with actual screenshots
4. Use for app store submissions