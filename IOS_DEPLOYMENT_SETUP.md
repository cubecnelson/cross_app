# iOS Deployment Setup Guide

This guide will help you set up automated iOS deployment to App Store Connect using GitHub Actions.

## Quick Start Checklist

- [ ] Create App Store Connect API Key
- [ ] Set up certificate repository
- [ ] Configure GitHub Secrets
- [ ] Run initial certificate generation
- [ ] Test the workflow

## Step 1: App Store Connect API Key

1. Log in to [App Store Connect](https://appstoreconnect.apple.com/)
2. Go to **Users and Access** → **Keys** (under Integrations)
3. Click **Generate API Key** or the **+** button
4. Name: `GitHub Actions CI`
5. Access: **Admin** (or App Manager)
6. **Download the `.p8` file** - you can only do this once!
7. Save these values:
   - **Key ID**: e.g., `ABC123XYZ`
   - **Issuer ID**: e.g., `12345678-1234-1234-1234-123456789012`
   - **Key file**: `AuthKey_ABC123XYZ.p8`

## Step 2: Certificate Repository Setup

Create a private repository to store your iOS certificates and provisioning profiles:

1. Create new **private** GitHub repository: `ios-certificates`
2. Keep it empty (no README, no .gitignore)
3. Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
4. Generate token with `repo` scope
5. Save the token securely

## Step 3: Configure GitHub Secrets

Go to your app repository → Settings → Secrets and variables → Actions → New repository secret

Add these secrets:

### App Store Connect
```
APP_STORE_CONNECT_API_KEY_ID
  Value: ABC123XYZ (from Step 1)

APP_STORE_CONNECT_API_ISSUER_ID
  Value: 12345678-1234-1234-1234-123456789012 (from Step 1)

APP_STORE_CONNECT_API_KEY_CONTENT
  Value: (copy entire content of .p8 file)
  -----BEGIN PRIVATE KEY-----
  MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHk...
  -----END PRIVATE KEY-----
```

### Apple Developer
```
APPLE_ID
  Value: your-apple-id@email.com

TEAM_ID
  Value: ABC123 (find in App Store Connect → Membership)

APP_IDENTIFIER
  Value: com.yourcompany.cross

ITC_TEAM_ID
  Value: ABC123 (usually same as TEAM_ID)
```

### Fastlane Match (Certificate Management)
```
MATCH_GIT_URL
  Value: https://github.com/yourusername/ios-certificates

MATCH_GIT_BASIC_AUTHORIZATION
  Value: base64-encoded-token (see below)

MATCH_PASSWORD
  Value: YourStrongPassword123! (choose a strong password)
```

### Generate MATCH_GIT_BASIC_AUTHORIZATION

In your terminal:

```bash
echo -n "your-github-username:ghp_yourGitHubPersonalAccessToken" | base64
```

Example:
```bash
echo -n "john:ghp_abc123xyz789" | base64
# Output: am9objpnaHBfYWJjMTIzeHl6Nzg5
```

## Step 4: Update App Bundle Identifier

Check your current bundle identifier:

```bash
# Open Xcode project
open ios/Runner.xcworkspace

# Or check manually in:
# ios/Runner.xcodeproj/project.pbxproj
```

Update the `APP_IDENTIFIER` secret to match your actual bundle ID (e.g., `com.yourcompany.cross`).

## Step 5: Initial Certificate Generation

Before running the GitHub Action, generate certificates locally:

```bash
cd ios

# Install Ruby dependencies
bundle install

# Set environment variables (use your actual values)
export MATCH_GIT_URL="https://github.com/yourusername/ios-certificates"
export MATCH_PASSWORD="YourStrongPassword123!"
export MATCH_GIT_BASIC_AUTHORIZATION="am9objpnaHBfYWJjMTIzeHl6Nzg5"
export APPLE_ID="your-apple-id@email.com"
export TEAM_ID="ABC123"
export APP_IDENTIFIER="com.yourcompany.cross"

# Generate and upload certificates
bundle exec fastlane certificates
```

This will:
- Create iOS Distribution Certificate
- Create App Store Provisioning Profile
- Encrypt and store them in your certificates repository

## Step 6: Test the Workflow

### Option A: Push to main
```bash
git add .
git commit -m "Add iOS deployment workflow"
git push origin main
```

### Option B: Manual trigger
1. Go to GitHub → Actions tab
2. Select "iOS Release to App Store Connect"
3. Click "Run workflow"
4. Click green "Run workflow" button

### Option C: Create a version tag
```bash
git tag v1.0.1
git push origin v1.0.1
```

## Step 7: Monitor the Build

1. Go to **Actions** tab in GitHub
2. Click on the running workflow
3. Watch each step complete
4. Build artifacts will be saved automatically

## Step 8: Check TestFlight

After successful upload (10-30 minutes processing):

1. Go to [App Store Connect](https://appstoreconnect.apple.com/)
2. Navigate to **My Apps** → **Your App** → **TestFlight**
3. Your build should appear under iOS builds
4. Add build to test groups
5. Start testing!

## Troubleshooting

### "Could not find provisioning profile"

```bash
# Regenerate certificates locally
cd ios
export MATCH_GIT_URL="..."
export MATCH_PASSWORD="..."
# ... other exports ...
bundle exec fastlane match nuke distribution  # CAUTION: Deletes certificates
bundle exec fastlane certificates
```

### "Invalid API Key"

- Verify the `.p8` file content is correct in `APP_STORE_CONNECT_API_KEY_CONTENT`
- Check Key ID and Issuer ID match App Store Connect
- Ensure API key has not been revoked

### "Authentication failed"

- Check `MATCH_GIT_BASIC_AUTHORIZATION` is correctly encoded
- Verify GitHub PAT has `repo` scope
- Ensure certificates repository is accessible

### "App ID not found"

- Create app in App Store Connect first
- Verify `APP_IDENTIFIER` matches bundle ID exactly
- Check Team ID is correct

## Advanced Configuration

### Distribute to External Testers

Edit `.github/workflows/ios-release.yml`:

```yaml
upload_to_testflight(
  skip_waiting_for_build_processing: false,  # Wait for processing
  skip_submission: false,                     # Submit for review
  distribute_external: true,                  # Enable external testing
  notify_external_testers: true,              # Send notifications
  groups: ["External Testers"]                # Test group names
)
```

### Submit Directly to App Store

Use the `release` lane:

```yaml
- name: Build and upload to App Store
  run: |
    cd ios
    bundle exec fastlane release
```

### Custom Build Numbers

Add to workflow before build step:

```yaml
- name: Set build number
  run: |
    cd ios
    bundle exec fastlane run increment_build_number \
      build_number:${{ github.run_number }}
```

## Security Notes

- ✅ Never commit `.p8` files or certificates
- ✅ Keep certificates repository private
- ✅ Rotate tokens every 6-12 months
- ✅ Use strong passwords for Match
- ✅ Audit access to secrets regularly

## Useful Commands

```bash
# Check Fastlane version
bundle exec fastlane --version

# List available lanes
cd ios && bundle exec fastlane lanes

# Test certificate access
cd ios && bundle exec fastlane match appstore --readonly

# View build number
cd ios && agvtool what-version

# Increment build number manually
cd ios && agvtool next-version -all
```

## Next Steps

Once deployment is working:

1. Set up beta testing groups in TestFlight
2. Configure automatic submission to App Store
3. Add release notes automation
4. Set up Slack/Discord notifications
5. Create staging and production workflows

## Resources

- [Fastlane Documentation](https://docs.fastlane.tools/)
- [Match Guide](https://docs.fastlane.tools/actions/match/)
- [App Store Connect API](https://developer.apple.com/documentation/appstoreconnectapi)
- [GitHub Actions iOS Guide](https://docs.github.com/en/actions/deployment/deploying-xcode-applications)

---

Need help? Check `.github/workflows/README.md` for more detailed information.
