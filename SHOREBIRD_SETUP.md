# Shorebird Setup for Over-the-Air Updates

Shorebird provides over-the-air (OTA) updates for Flutter apps, allowing you to push bug fixes and minor updates without going through app store review processes.

## Prerequisites

1. **Shorebird Account**: Sign up at [shorebird.dev](https://shorebird.dev)
2. **Shorebird CLI**: Install the Shorebird CLI
3. **App Signing**: Your app must be signed with release credentials

## Installation

### 1. Install Shorebird CLI

```bash
# Install Shorebird CLI
curl --proto '=https' --tlsv1.2 https://raw.githubusercontent.com/shorebirdtech/install/main/install.sh -sSf | bash

# Restart your terminal or source your shell config
source ~/.bashrc  # or ~/.zshrc, etc.

# Verify installation
shorebird --version
```

### 2. Login to Shorebird

```bash
shorebird login
```

Follow the prompts to authenticate with your Shorebird account.

### 3. Initialize Shorebird in Your Project

```bash
cd cross_app
shorebird init
```

This will:
- Create a `shorebird.yaml` configuration file
- Set up your project with Shorebird
- Generate necessary credentials

## Configuration

### iOS Setup

1. **Add Shorebird to iOS Podfile**:

The `shorebird init` command should have updated your `ios/Podfile`. Verify it includes:

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
    end
  end
end
```

2. **Update iOS Deployment Target**:
Ensure your iOS deployment target is at least 11.0 in `ios/Podfile` and `ios/Runner.xcodeproj`.

### Android Setup

1. **Update Android Gradle**:
Shorebird requires minSdkVersion 21 or higher. Check `android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        minSdkVersion 21
    }
}
```

2. **Enable Multidex** (if needed):
```gradle
android {
    defaultConfig {
        multiDexEnabled true
    }
}

dependencies {
    implementation 'androidx.multidex:multidex:2.0.1'
}
```

## Building with Shorebird

### 1. Create a Release

```bash
# Create a release (do this for each new version)
shorebird release android --artifact=apk  # or --artifact=aab
shorebird release ios
```

### 2. Create Patches

When you need to push an update:

```bash
# 1. Make your code changes
# 2. Create a patch
shorebird patch android
shorebird patch ios

# 3. The patch will be automatically distributed to users
```

## Testing Updates

### 1. Test Locally

```bash
# Create a test release
shorebird release android --artifact=apk --flavor development

# Create a test patch
shorebird patch android --flavor development

# Install the release on a device
# Then apply the patch to see updates
```

### 2. Staged Rollouts

```bash
# Release to 10% of users
shorebird patch android --percentage=10

# Gradually increase rollout
shorebird patch android --percentage=50
shorebird patch android --percentage=100
```

## Integration in Code

The Cross app already has Shorebird integrated with:

### 1. Automatic Update Checks
- Checks for updates on app start (with 2-second delay)
- Shows update dialog when available
- Downloads updates in background

### 2. Manual Update Control
- Settings → Updates section
- Manual check for updates
- Download and install controls

### 3. Update UI
- Update available dialog
- Download progress indicator
- Success/error notifications

## Usage Guidelines

### When to Use Shorebird
- **Bug fixes**: Critical bugs that need immediate fixing
- **Minor updates**: Small feature additions
- **Text/UI changes**: Copy updates, styling tweaks
- **Configuration changes**: API endpoint updates, feature flags

### When NOT to Use Shorebird
- **Major features**: Significant new functionality
- **Native code changes**: Changes to iOS/Android native code
- **Permission changes**: New permissions require store updates
- **Binary size increases**: Large asset additions

### Best Practices
1. **Test thoroughly**: Always test patches before release
2. **Use staged rollouts**: Start with 10% of users
3. **Monitor crash rates**: Watch for issues after patch deployment
4. **Keep patches small**: < 10MB recommended
5. **Document changes**: Keep track of what each patch contains

## Troubleshooting

### Common Issues

**"Shorebird not initialized"**
```bash
# Re-run shorebird init
shorebird init --force
```

**"Patch not applying"**
- Ensure app was built with Shorebird release
- Check device has internet connection
- Verify patch was created correctly

**"iOS build failures"**
```bash
# Clean and rebuild
cd ios
pod deintegrate
pod install
cd ..
shorebird release ios --clean
```

**"Android build failures"**
```bash
# Clean build
./gradlew clean
shorebird release android --clean
```

### Debugging

Enable debug logs:
```dart
// In main.dart, before Shorebird initialization
final shorebirdCodePush = ShorebirdCodePush();
shorebirdCodePush.setDebugLogging(true);
```

Check current patch:
```dart
final currentPatch = await shorebirdCodePush.currentPatchNumber();
print('Current patch: $currentPatch');
```

## Monitoring

### Shorebird Dashboard
Monitor your releases and patches at [console.shorebird.dev](https://console.shorebird.dev)

### Key Metrics
- **Patch adoption rate**: % of users who have applied the patch
- **Rollback rate**: % of patches rolled back due to issues
- **Error rates**: Crash and error rates per patch

## Security Considerations

1. **Code signing**: Shorebird patches are cryptographically signed
2. **Rollback capability**: Bad patches can be automatically rolled back
3. **Enterprise security**: Supports enterprise deployment requirements
4. **Compliance**: Meets standard mobile security requirements

## Cost

Shorebird offers a free tier with limitations:
- Free: Up to 10,000 monthly active users
- Paid: Custom pricing for larger deployments

Check [shorebird.dev/pricing](https://shorebird.dev/pricing) for current pricing.

## Support

- **Documentation**: [docs.shorebird.dev](https://docs.shorebird.dev)
- **Discord**: [shorebird.dev/discord](https://shorebird.dev/discord)
- **GitHub**: [github.com/shorebirdtech](https://github.com/shorebirdtech)
- **Email**: support@shorebird.dev

## Next Steps

1. **Create Shorebird account** and login
2. **Run `shorebird init`** in your project
3. **Create first release** for both Android and iOS
4. **Test OTA updates** with a test patch
5. **Deploy to production** using staged rollouts