# iOS Build Troubleshooting

## Recent Changes

✅ **API Authentication** - Now working! Build number incremented successfully.  
🔄 **Build Error** - Need to debug code signing

## What I Fixed

1. **Code signing configuration**:
   - Set `signingStyle: "manual"` 
   - Added `-allowProvisioningUpdates`
   - Added debugging output for certificates and profiles

2. **Build output**:
   - Configured proper output directory
   - Updated artifact paths

## Next: Finding the Actual Error

The build is failing, but we need to see the actual error. When you run the workflow again, look for:

### In the GitHub Actions log, search for:

#### 1. Code Signing Errors
Look for these keywords:
```
"No signing certificate"
"Provisioning profile"
"Code signing is required"
"No profile for team"
```

#### 2. Compilation Errors
```
"error:"
"fatal error:"
"Compilation failed"
```

#### 3. Missing Dependencies
```
"CocoaPods"
"pod install"
"Flutter"
```

## Common Issues & Solutions

### Issue: "No signing certificate"

**Solution**: The certificate might not be imported correctly.

Check the workflow log for:
```
Installed certificates:
```

Should show something like:
```
1) ABC123... "Apple Distribution: Your Name (TEAMID)"
```

If empty, the `BUILD_CERTIFICATE_BASE64` secret is wrong.

### Issue: "Provisioning profile doesn't include signing certificate"

**Solution**: The profile and certificate don't match.

Both need to be:
- From the same team
- For the same Bundle ID
- Downloaded recently (not expired)

### Issue: "Could not find or use auto-linked library"

**Solution**: Missing dependencies. Need to run pod install.

We can add this to the workflow before building.

### Issue: Bundle ID mismatch

**Solution**: The provisioning profile Bundle ID must exactly match the app's Bundle ID.

Check Xcode:
```bash
open ios/Runner.xcworkspace
# Check Runner → General → Bundle Identifier
```

## How to Debug Locally

Before pushing again, test locally:

```bash
# 1. Clean everything
flutter clean
cd ios
rm -rf build/
pod deintegrate
pod install
cd ..

# 2. Try building
flutter build ios --release

# 3. If that works, the issue is in CI setup
# If it fails, fix the local issue first
```

## If You Need the Full Build Log

The complete log is at:
```
/Users/runner/Library/Logs/gym/Runner-Runner.log
```

To see it in GitHub Actions:
1. Add this step before the build:
```yaml
- name: Enable detailed logging
  run: |
    export FASTLANE_VERBOSE=true
```

2. Or add to Fastfile:
```ruby
build_app(
  ...
  verbose: true,
  buildlog_path: "./build/logs"
)
```

## Quick Checks

Before trying again, verify these secrets are correct:

```bash
# 1. Check certificate is valid
echo "$BUILD_CERTIFICATE_BASE64" | base64 --decode > test.p12
# Should be ~4-10KB

# 2. Check provisioning profile is valid  
echo "$BUILD_PROVISION_PROFILE_BASE64" | base64 --decode > test.mobileprovision
# Should be ~10-30KB

# 3. Check API key is valid
echo "$APP_STORE_CONNECT_API_KEY_CONTENT"
# Should start with -----BEGIN PRIVATE KEY-----
```

## Next Steps

1. **Push the changes** and run the workflow again
2. **Look for the specific error** in the build log
3. **Search for** the error keywords above
4. **Share the specific error message** and I can help fix it

The workflow will now show:
- ✅ Which certificates are installed
- ✅ Which provisioning profiles are available
- ✅ More detailed build information

This will help identify the exact issue!
