> **Note (November 2026):** This repository is now **OnTheRack**, a crowdsourced gym-equipment review app. The running Flutter app is no longer the Cross workout tracker. See the root [README.md](README.md) for current setup and product details. The notes below are historical Cross documentation and may be outdated.

# iOS Deployment - Quick Start

Your GitHub Action is ready! Follow these steps to complete setup.

## ⚠️ SECURITY WARNING

**Delete the API key file from your project root immediately:**

```bash
rm ApiKey_EBYTI4YYF06V.p8
```

This file should NEVER be committed to your repository. It's already in `.gitignore`, but delete it now for security.

---

## Setup Steps (Simplified - No Certificate Repo Needed!)

### 1. You Already Have ✅

- ✅ App Store Connect API Key file (should be named `AuthKey_EBYTI4YYF06V.p8`)
- Your Key ID is: `EBYTI4YYF06V`

**Note**: Apple's standard naming is `AuthKey_<KEY_ID>.p8`, not `ApiKey_`

### 2. Get Issuer ID

1. Go to [App Store Connect](https://appstoreconnect.apple.com/)
2. Users and Access → Keys
3. Copy the **Issuer ID** from the top of the page (UUID format)

### 3. Export Certificate from Xcode

```bash
# Open Xcode
open ios/Runner.xcworkspace

# Then:
# Xcode → Settings → Accounts → Manage Certificates
# Right-click "Apple Distribution" → Export
# Save as: distribution.p12
# Choose a password (remember it!)
```

### 4. Download Provisioning Profile

1. Go to [Apple Developer](https://developer.apple.com/account/)
2. Certificates, Identifiers & Profiles → Profiles
3. Download your App Store provisioning profile

### 5. Convert to Base64

```bash
# Navigate to where you saved the files
cd ~/Downloads

# Convert certificate
base64 -i distribution.p12 -o certificate.txt

# Convert provisioning profile
base64 -i YourProfile.mobileprovision -o profile.txt

# View to copy
cat certificate.txt
cat profile.txt
```

### 6. Add GitHub Secrets

Go to your repo → Settings → Secrets and variables → Actions

Add these **6 secrets**:

| Secret Name | Value |
|------------|-------|
| `APP_STORE_CONNECT_API_KEY_ID` | `EBYTI4YYF06V` |
| `APP_STORE_CONNECT_API_ISSUER_ID` | (UUID from Step 2) |
| `APP_STORE_CONNECT_API_KEY_CONTENT` | (Contents of `ApiKey_EBYTI4YYF06V.p8`) |
| `BUILD_CERTIFICATE_BASE64` | (Contents of `certificate.txt`) |
| `P12_PASSWORD` | (Password from Step 3) |
| `BUILD_PROVISION_PROFILE_BASE64` | (Contents of `profile.txt`) |

### 7. Run the Workflow

```bash
# Push to trigger
git add .
git commit -m "Setup iOS deployment"
git push origin main

# Or create a tag
git tag v1.0.0
git push origin v1.0.0
```

---

## 📚 Documentation

- **`.github/SECRETS_SIMPLE.md`** - Detailed guide for each secret
- **`IOS_DEPLOYMENT_SETUP_SIMPLE.md`** - Complete setup instructions
- **`.github/workflows/ios-release.yml`** - The workflow file

---

## 🎯 What This Workflow Does

1. ✅ Builds your Flutter iOS app
2. ✅ Signs it with your certificates
3. ✅ Uploads to TestFlight automatically
4. ✅ Saves build artifacts for 30 days

**Triggers:**
- Push to `main` or `release/*` branches
- Version tags (e.g., `v1.0.0`)
- Manual trigger in GitHub Actions

---

## 🔒 Security

**Delete these files from your computer after setup:**
```bash
rm ~/Downloads/distribution.p12
rm ~/Downloads/YourProfile.mobileprovision
rm ~/Downloads/certificate.txt
rm ~/Downloads/profile.txt
rm ApiKey_EBYTI4YYF06V.p8  # Delete from project root!
rm AuthKey_EBYTI4YYF06V.p8  # If you renamed it
```

The values are safely stored in GitHub Secrets.

---

## ✅ Simplified Approach

**What we removed:**
- ❌ No certificate repository needed
- ❌ No GitHub Personal Access Token
- ❌ No Fastlane Match setup
- ❌ No MATCH_GIT_URL, MATCH_PASSWORD, etc.

**Result:**
- ✅ Only 6 secrets needed (down from 9+)
- ✅ Simpler setup process
- ✅ Everything in GitHub Secrets

---

## 🚀 Next Steps After First Successful Build

1. Check TestFlight in App Store Connect
2. Add beta testers
3. Configure test groups
4. Submit for App Store review when ready

---

**Need help?** Check the detailed guides in `.github/` and the root directory.
