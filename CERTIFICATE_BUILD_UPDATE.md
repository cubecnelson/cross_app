# iOS Build Process Update: Certificate-Based Signing

## What Changed

### 1. **New Certificate-Based Workflow**
- Created `ios-release.yml` (certificate-based signing)
- Renamed old workflow to `ios-release-automatic.yml` (API key automatic signing)

### 2. **Updated Fastfile**
- Replaced automatic signing with manual signing
- Uses certificates and provisioning profiles from GitHub Secrets
- Updated both `beta` and `release` lanes

### 3. **New Required GitHub Secrets**
The workflow now requires these additional secrets:

```
BUILD_CERTIFICATE_BASE64    # .p12 distribution certificate in base64
P12_PASSWORD                # Password for the .p12 certificate  
BUILD_PROVISION_PROFILE_BASE64 # .mobileprovision file in base64
```

### 4. **Setup Process in Workflow**
The workflow now:
1. Decodes certificates and profiles from base64
2. Creates temporary keychain
3. Imports certificate with password
4. Installs provisioning profile
5. Uses manual signing with certificates

## How to Switch to Certificate-Based Approach

### Option A: Keep Automatic Signing (Current)
- Use `ios-release-automatic.yml` workflow
- Only needs API key secrets
- Simpler but less control

### Option B: Use Certificate-Based Signing (Recommended)
1. **Add new secrets** following `SECRETS_SIMPLE.md` instructions:
   - `BUILD_CERTIFICATE_BASE64`
   - `P12_PASSWORD` 
   - `BUILD_PROVISION_PROFILE_BASE64`

2. **Run the workflow** `ios-release.yml`

## File Changes

### Updated Files:
- `.github/workflows/ios-release.yml` → **Certificate-based signing**
- `.github/workflows/ios-release-automatic.yml` → **Automatic signing (backup)**
- `ios/fastlane/Fastfile` → **Manual signing configuration**
- `ios/fastlane/Fastfile.automatic` → **Original automatic signing (backup)**

### New Files:
- `ios/fastlane/Fastfile-certificate` → Template for certificate-based signing

## Benefits of Certificate-Based Approach

1. **More Control**: Manual signing gives you complete control
2. **No External Dependencies**: No need for certificate repositories
3. **Self-Contained**: Everything in GitHub Secrets
4. **Debugging**: Easier to troubleshoot signing issues

## Setup Instructions

Follow `SECRETS_SIMPLE.md` to:
1. Export .p12 certificate from Xcode
2. Download .mobileprovision from Apple Developer
3. Convert both to base64
4. Add as GitHub Secrets
5. Keep existing API key secrets

## Rollback

If you need to switch back to automatic signing:
1. Use `ios-release-automatic.yml` workflow
2. Restore original Fastfile: `cp ios/fastlane/Fastfile.automatic ios/fastlane/Fastfile`

## Verification Checklist

Before running certificate-based workflow:

- [ ] `BUILD_CERTIFICATE_BASE64` added to GitHub Secrets
- [ ] `P12_PASSWORD` added to GitHub Secrets  
- [ ] `BUILD_PROVISION_PROFILE_BASE64` added to GitHub Secrets
- [ ] All existing API key secrets still present
- [ ] Certificate password matches export password
- [ ] Provisioning profile matches app bundle ID (`com.cross.app`)