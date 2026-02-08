# Android Release to QR Workflow

This workflow builds an Android APK from your Flutter project and generates a QR code that links to the downloadable artifact.

## Features

- 🏗️ **Builds Android APK** (debug or release)
- 📱 **Auto-generates Android project** if needed (Flutter will create it)
- 🔗 **Generates QR code** linking to artifact download page
- 📦 **Uploads artifacts** (APK, build logs, QR code)
- 🔒 **Manual trigger only** for security
- ⚙️ **Configurable build options**

## How to Use

### 1. Trigger the Workflow
1. Go to GitHub → Actions → "Android Release to QR"
2. Click "Run workflow"
3. Configure options:
   - **Build Type**: `debug` (for testing) or `release` (for distribution)
   - **Flutter Version**: Default `3.38.7` (matches your project)
   - **Generate QR**: `true` (recommended) to create QR code
4. Click "Run workflow"

### 2. Required GitHub Secrets
The workflow requires these secrets for Supabase integration:

```
SUPABASE_URL
SUPABASE_ANON_KEY
```

Add these in GitHub → Settings → Secrets and variables → Actions

### 3. Locate Artifacts
After workflow completes:
1. Go to the workflow run
2. Scroll to "Artifacts" section
3. Download:
   - `cross-android-apk-{id}`: APK file and build logs
   - `cross-apk-qr-{id}`: QR code PNG file

## Build Types

### Debug APK
- **Use**: Testing and development
- **Features**: Debug symbols, hot reload, development tools
- **Size**: Larger due to debug symbols
- **Security**: Not suitable for production

### Release APK
- **Use**: Distribution and testing
- **Features**: Optimized, smaller size
- **Note**: Unsigned release APK (for testing only)
- **For production**: Need signing configuration

## QR Code Feature

The QR code contains a direct link to the workflow run page where the APK can be downloaded.

**To use:**
1. Scan QR code with smartphone camera
2. Opens GitHub Actions page
3. Download APK from artifacts

## Local Setup (Optional)

If you want to build Android locally:

```bash
# Make setup scripts executable
chmod +x android_setup.sh generate_apk_qr.sh

# Setup Android project (if needed)
./android_setup.sh

# Build APK locally
flutter build apk --debug          # Debug APK
flutter build apk --release        # Release APK

# Generate QR code for any URL
./generate_apk_qr.sh "https://your-apk-url.com"
```

## Notes

### Android Project Creation
If the `android/` directory doesn't exist, Flutter will automatically create it during the build process. No manual setup needed for CI.

### Production Signing
For production releases, you need to:
1. Create a keystore
2. Add signing configuration to `android/app/build.gradle`
3. Store keystore credentials in GitHub Secrets
4. Update workflow to use signing

### Security
- Debug APKs are for testing only
- Release APKs should be properly signed for distribution
- Always verify APK sources before installation

## Troubleshooting

### "Android directory not found"
- Workflow will create it automatically
- Or run locally: `flutter create --platforms=android .`

### Build failures
- Check build logs in artifacts
- Ensure Flutter version matches project
- Verify Supabase secrets are set correctly

### QR code not generated
- Ensure `qrencode` is installed (workflow handles this)
- Check workflow input `generate_qr` is set to `true`

## Example Usage

```yaml
# Trigger workflow via GitHub UI with:
# - Build Type: release
# - Flutter Version: 3.38.7  
# - Generate QR: true

# Result:
# 1. APK built and uploaded as artifact
# 2. QR code generated linking to artifact
# 3. Build logs available for debugging
```

## Related Workflows

- **iOS Release to App Store Connect**: iOS deployment to TestFlight
- **Run Flutter Tests**: Testing workflow for unit/widget/integration tests