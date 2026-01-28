# Automatic Signing Setup Guide

## ✨ Overview

**Automatic signing** is much simpler than manual signing! Xcode automatically downloads and manages certificates and provisioning profiles using your App Store Connect API key.

## 🎯 Benefits

- ✅ **No manual certificates** - Xcode downloads them automatically
- ✅ **No provisioning profiles to manage** - Created automatically
- ✅ **Works locally and in CI** - Same setup everywhere
- ✅ **Always up-to-date** - No expired certificates to worry about

## 📋 Required Secrets (Only 3!)

You only need these 3 GitHub Secrets:

| Secret Name | Description | How to Get |
|-------------|-------------|------------|
| `APP_STORE_CONNECT_API_KEY_ID` | API Key ID (10 characters) | From App Store Connect → Keys |
| `APP_STORE_CONNECT_API_ISSUER_ID` | Issuer ID (UUID format) | From App Store Connect → Keys |
| `APP_STORE_CONNECT_API_KEY_CONTENT` | Private key content (.p8 file) | Downloaded when creating API key |

## 🔑 Getting Your API Key

### Step 1: Create API Key

1. Go to [App Store Connect → Users and Access → Keys](https://appstoreconnect.apple.com/access/api)
2. Click **"+"** to generate a new key
3. Enter a name (e.g., "GitHub Actions CI")
4. Select **Access**: `App Manager` or `Admin`
5. Click **Generate**

### Step 2: Download and Save

1. **Download the .p8 file** (you can only download once!)
2. Note the **Key ID** (e.g., `TP6BNJR7G5`)
3. Note the **Issuer ID** (UUID at the top of the page)

### Step 3: Prepare for GitHub

```bash
# Read the .p8 file content
cat AuthKey_TP6BNJR7G5.p8

# Output looks like:
-----BEGIN PRIVATE KEY-----
MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQg...
-----END PRIVATE KEY-----
```

Copy the **entire content** including the BEGIN/END lines.

## ⚙️ Configure GitHub Secrets

1. Go to: `https://github.com/YOUR_USERNAME/cross_app/settings/secrets/actions`
2. Click **"New repository secret"**
3. Add these 3 secrets:

### 1. APP_STORE_CONNECT_API_KEY_ID
```
TP6BNJR7G5
```
(Your key ID from Step 2)

### 2. APP_STORE_CONNECT_API_ISSUER_ID
```
95e0b86f-29ee-4ba4-9f95-e851c52934af
```
(Your issuer ID from Step 2)

### 3. APP_STORE_CONNECT_API_KEY_CONTENT
```
-----BEGIN PRIVATE KEY-----
MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQg...
-----END PRIVATE KEY-----
```
(Full content from the .p8 file)

## 🚀 How It Works

### In GitHub Actions

1. Workflow creates the API key file: `~/private_keys/AuthKey_TP6BNJR7G5.p8`
2. Fastlane sets environment variables for the API key
3. Xcode uses `-allowProvisioningUpdates` flag
4. Xcode authenticates with App Store Connect API
5. Xcode automatically:
   - Downloads the correct distribution certificate
   - Creates/downloads provisioning profile
   - Signs the app
6. Fastlane uploads to TestFlight

### Locally

Same process! Just make sure your API key is in:
```
~/private_keys/AuthKey_YOUR_KEY_ID.p8
```

Or set environment variables:
```bash
export APP_STORE_CONNECT_API_KEY_KEY_ID=TP6BNJR7G5
export APP_STORE_CONNECT_API_KEY_ISSUER_ID=95e0b86f-29ee-4ba4-9f95-e851c52934af
export APP_STORE_CONNECT_API_KEY_KEY="$(cat AuthKey_TP6BNJR7G5.p8)"

# Then run Fastlane
cd ios
bundle exec fastlane beta
```

## 🔧 What Changed in the Workflow

### Before (Manual Signing) ❌
```yaml
- Import certificate (.p12)
- Install provisioning profile
- Set up keychain
- Configure manual signing
- Build with explicit certificate
```

### After (Automatic Signing) ✅
```yaml
- Setup API key file
- Build with -allowProvisioningUpdates
- Xcode handles everything automatically!
```

## 📱 Xcode Project Configuration

Make sure your Xcode project (`ios/Runner.xcodeproj`) has:

1. **Signing & Capabilities** tab:
   - **Automatically manage signing**: ✅ Checked (for local development)
   - **Team**: Select your team
   - **Bundle Identifier**: `com.cross.app`

2. **Build Settings**:
   - **Code Signing Style**: `Automatic`
   - **Development Team**: `YWQH3Z3Z85`

The CI workflow will use automatic signing with the API key, while local development also uses automatic signing with your logged-in Apple ID.

## 🎉 Test the Setup

Push to trigger the workflow:

```bash
git add .
git commit -m "Switch to automatic signing with App Store Connect API"
git push origin main
```

Watch the GitHub Actions run. You should see:
```
✅ API Key installed
Xcode will automatically download certificates and provisioning profiles
```

Then Xcode will handle all the signing automatically! 🎯

## 🔒 Security Notes

- **Never commit** the `.p8` file to Git
- The API key has limited permissions (only what you granted)
- Keys can be revoked at any time in App Store Connect
- Keys expire after they're revoked or deleted

## 📚 References

- [App Store Connect API](https://developer.apple.com/documentation/appstoreconnectapi)
- [Creating API Keys](https://developer.apple.com/documentation/appstoreconnectapi/creating_api_keys_for_app_store_connect_api)
- [Fastlane App Store Connect API](https://docs.fastlane.tools/app-store-connect-api/)
