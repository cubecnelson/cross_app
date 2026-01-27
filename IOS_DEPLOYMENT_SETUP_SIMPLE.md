# iOS Deployment Setup Guide (Simplified - No Certificate Repo)

This guide uses a simpler approach where certificates are stored directly in GitHub Secrets instead of a separate repository.

## Prerequisites

- Apple Developer Account
- App created in App Store Connect
- Xcode installed on your Mac

## Step 1: App Store Connect API Key

1. Go to [App Store Connect](https://appstoreconnect.apple.com/)
2. **Users and Access** → **Keys** → **Generate API Key**
3. Name: `GitHub Actions`
4. Access: **Admin** or **App Manager**
5. Click **Generate** and download the `.p8` file
6. Save these values:
   - **Key ID** (e.g., `EBYTI4YYF06V`)
   - **Issuer ID** (UUID at top of page)
   - **Key Content** (entire contents of `.p8` file)

## Step 2: Export Certificates from Xcode

### A. Create/Download Distribution Certificate

1. Open Xcode
2. **Xcode** → **Settings** → **Accounts**
3. Select your Apple ID → Select your Team
4. Click **Manage Certificates**
5. Click **+** → **Apple Distribution** (if you don't have one)
6. Right-click the certificate → **Export**
7. Save as `distribution.p12`
8. Enter a password (you'll need this later)

### B. Download Provisioning Profile

1. Go to [Apple Developer Portal](https://developer.apple.com/account/)
2. **Certificates, Identifiers & Profiles** → **Profiles**
3. Find or create an **App Store** profile for your app
4. Download the `.mobileprovision` file

## Step 3: Convert to Base64

In Terminal, convert your certificate and provisioning profile to base64:

```bash
# Navigate to where your files are
cd ~/Downloads

# Convert certificate to base64
base64 -i distribution.p12 -o certificate.txt

# Convert provisioning profile to base64
base64 -i YourProfile.mobileprovision -o profile.txt

# View the contents (copy these for GitHub Secrets)
cat certificate.txt
cat profile.txt
```

## Step 4: Configure GitHub Secrets

Go to your repository → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

Add these 6 secrets:

### App Store Connect API

```
Name: APP_STORE_CONNECT_API_KEY_ID
Value: EBYTI4YYF06V
(Your Key ID from Step 1)

Name: APP_STORE_CONNECT_API_ISSUER_ID
Value: 12345678-abcd-1234-efgh-567890abcdef
(Your Issuer ID from Step 1)

Name: APP_STORE_CONNECT_API_KEY_CONTENT
Value: (Full contents of .p8 file including BEGIN/END lines)
-----BEGIN PRIVATE KEY-----
MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHk...
-----END PRIVATE KEY-----
```

### Certificates and Provisioning

```
Name: BUILD_CERTIFICATE_BASE64
Value: (Contents of certificate.txt from Step 3)
MIIKcQIBAzCCChoGCSqGSIb3DQEHAaCCCgsEggoH...

Name: P12_PASSWORD
Value: (The password you used when exporting the .p12)
YourP12ExportPassword

Name: BUILD_PROVISION_PROFILE_BASE64
Value: (Contents of profile.txt from Step 3)
MIINuQYJKoZIhvcNAQcCoIINqjCCDaYCAQExDzAN...
```

### Optional

```
Name: KEYCHAIN_PASSWORD
Value: temp_password_123
(Optional - used for temporary keychain on CI)
```

## Step 5: Update Xcode Project Settings

Open your project in Xcode:

```bash
cd ios
open Runner.xcworkspace
```

1. Select **Runner** project → **Runner** target
2. **Signing & Capabilities** tab
3. **Uncheck** "Automatically manage signing"
4. **Provisioning Profile**: Select the profile you downloaded
5. **Signing Certificate**: iOS Distribution

Note your:
- **Bundle Identifier** (e.g., `com.yourcompany.cross`)
- **Team ID** (e.g., `ABC123XYZ`)

## Step 6: Test the Workflow

### Option A: Push to main branch

```bash
git add .
git commit -m "Setup iOS deployment"
git push origin main
```

### Option B: Manual trigger

1. Go to **Actions** tab in GitHub
2. Select **iOS Release to App Store Connect**
3. Click **Run workflow**

### Option C: Create a version tag

```bash
git tag v1.0.0
git push origin v1.0.0
```

## Step 7: Monitor and Verify

1. Watch the workflow run in the **Actions** tab
2. After success (15-30 minutes), check TestFlight in App Store Connect
3. Your build should appear under **TestFlight** → **iOS**

## Troubleshooting

### "Code signing error"

- Verify certificate is valid (not expired)
- Check provisioning profile includes your app's Bundle ID
- Ensure P12_PASSWORD matches the password you used

### "Provisioning profile doesn't match"

Export a new provisioning profile from Apple Developer Portal that matches your Bundle ID exactly.

### "Certificate not found in keychain"

The certificate.p12 file must include:
- Your distribution certificate
- The private key

Re-export from Xcode making sure both are included.

### "Build succeeds but upload fails"

- Check API key has proper permissions in App Store Connect
- Verify Key ID and Issuer ID are correct
- Ensure API key hasn't been revoked

## Updating Certificates

When certificates expire (yearly):

1. Generate new certificate in Xcode
2. Download new provisioning profile
3. Convert both to base64 (Step 3)
4. Update GitHub Secrets with new values

## Required GitHub Secrets Summary

✅ **6 Required Secrets:**

1. `APP_STORE_CONNECT_API_KEY_ID`
2. `APP_STORE_CONNECT_API_ISSUER_ID`
3. `APP_STORE_CONNECT_API_KEY_CONTENT`
4. `BUILD_CERTIFICATE_BASE64`
5. `P12_PASSWORD`
6. `BUILD_PROVISION_PROFILE_BASE64`

❌ **NOT Required (removed):**

- ~~MATCH_GIT_URL~~
- ~~MATCH_GIT_BASIC_AUTHORIZATION~~
- ~~MATCH_PASSWORD~~
- ~~APPLE_ID~~
- ~~TEAM_ID~~
- ~~APP_IDENTIFIER~~

## Security Notes

- ✅ Never commit `.p12` or `.mobileprovision` files to your repository
- ✅ Never commit `.p8` API key files
- ✅ Keep certificate passwords strong and secure
- ✅ Rotate API keys annually
- ✅ Check `.gitignore` includes certificate file patterns

## Next Steps

Once deployment is working:

1. Add external testers in TestFlight
2. Configure beta testing groups
3. Set up automated release notes
4. Consider adding Android deployment workflow

## Quick Command Reference

```bash
# Check build number
cd ios
agvtool what-version

# Increment build number manually
agvtool next-version -all

# Test Fastlane locally
bundle exec fastlane beta

# Clean Xcode build
rm -rf ios/build/
```

---

**Simplified approach:** No certificate repository needed! Everything is stored securely in GitHub Secrets.
