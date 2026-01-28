# Apple Distribution Certificate Setup Guide

## Step 1: Create Certificate in Apple Developer Portal

1. Go to [Apple Developer Certificates](https://developer.apple.com/account/resources/certificates/list)
2. Click **"+"** to create a new certificate
3. Select **"Apple Distribution"** (for App Store and TestFlight)
4. Click **Continue**

## Step 2: Generate Certificate Signing Request (CSR)

On your Mac:

1. Open **Keychain Access** (Applications → Utilities → Keychain Access)
2. Menu: **Keychain Access** → **Certificate Assistant** → **Request a Certificate From a Certificate Authority**
3. Fill in:
   - **User Email Address**: Your email
   - **Common Name**: Your name or company name
   - **CA Email Address**: Leave empty
   - Select: **"Saved to disk"**
4. Click **Continue** and save the file (e.g., `CertificateSigningRequest.certSigningRequest`)

## Step 3: Upload CSR and Download Certificate

1. Back in Apple Developer portal, upload the CSR file
2. Click **Continue**
3. Download the certificate file (e.g., `distribution.cer`)

## Step 4: Install Certificate

1. Double-click the downloaded `distribution.cer` file
2. This installs it in your **Keychain Access** → **login** keychain
3. You should see:
   - **Apple Distribution: Your Name (YWQH3Z3Z85)**
   - With a private key underneath it (▶ arrow to expand)

## Step 5: Export as .p12

1. In **Keychain Access**, select **login** keychain
2. Find **"Apple Distribution: Your Name (YWQH3Z3Z85)"**
3. **Expand it** (click ▶) to see the private key
4. **Right-click** on the certificate (not the key) → **Export "Apple Distribution..."**
5. Save as:
   - **File format**: Personal Information Exchange (.p12)
   - **Name**: `distribution.p12`
6. Set a **password** (remember this for GitHub Secrets as `P12_PASSWORD`)
7. Enter your Mac login password when prompted

## Step 6: Convert to Base64 for GitHub Secrets

```bash
# Convert certificate to base64
base64 -i distribution.p12 | pbcopy
# Now base64 string is in clipboard - paste as BUILD_CERTIFICATE_BASE64

# Convert provisioning profile to base64
base64 -i your_profile.mobileprovision | pbcopy
# Paste as BUILD_PROVISION_PROFILE_BASE64
```

## Step 7: Create Provisioning Profile

1. Go to [Provisioning Profiles](https://developer.apple.com/account/resources/profiles/list)
2. Click **"+"** to create new
3. Select **"App Store Connect"** (for TestFlight and App Store)
4. Select your **App ID**: `com.cross.app`
5. Select the **Apple Distribution certificate** you just created
6. **Don't select any devices** (App Store profiles don't need devices)
7. Name it (e.g., "Cross App App Store")
8. Download the `.mobileprovision` file

## Step 8: Update GitHub Secrets

Set these 6 secrets in GitHub:

| Secret Name | Value |
|-------------|-------|
| `BUILD_CERTIFICATE_BASE64` | Base64 of `distribution.p12` |
| `P12_PASSWORD` | Password you set when exporting .p12 |
| `BUILD_PROVISION_PROFILE_BASE64` | Base64 of `.mobileprovision` |
| `APP_STORE_CONNECT_API_KEY_ID` | `TP6BNJR7G5` or your key ID |
| `APP_STORE_CONNECT_API_ISSUER_ID` | Your issuer ID (UUID) |
| `APP_STORE_CONNECT_API_KEY_CONTENT` | Full `.p8` file content with BEGIN/END lines |

## Verification

Run this to verify your certificate:

```bash
# Check certificate details
openssl pkcs12 -in distribution.p12 -passin pass:YOUR_PASSWORD -nokeys -clcerts | openssl x509 -noout -subject -dates

# Should show:
# subject=CN = Apple Distribution: Your Name (YWQH3Z3Z85)
# notBefore=...
# notAfter=...
```

## Common Issues

### ❌ "No private key found"
- You didn't export the certificate that has a private key
- Make sure the certificate shows an expandable arrow (▶) with a private key underneath

### ❌ "iPhone Distribution" instead of "Apple Distribution"
- You created the old certificate type
- Delete it and create a new "Apple Distribution" certificate

### ❌ Certificate expired
- Check `notAfter` date
- Certificates expire after 1 year - create a new one

## Notes

- **Apple Distribution** certificates are for:
  - App Store submission
  - TestFlight beta testing
  - Ad Hoc distribution
  
- **Apple Development** certificates are for:
  - Local development
  - Debugging on physical devices

For CI/CD, you **MUST** use **Apple Distribution** certificate.
