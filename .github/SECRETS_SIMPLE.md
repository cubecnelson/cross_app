# GitHub Secrets - Simple Setup (No Certificate Repo)

This is the simplified setup that stores certificates directly in GitHub Secrets instead of using a certificate repository.

## Quick Setup Checklist

- [ ] Get App Store Connect API Key
- [ ] Export Distribution Certificate (.p12)
- [ ] Download Provisioning Profile
- [ ] Convert both to base64
- [ ] Add 6 secrets to GitHub

---

## Required Secrets (6 Total)

### 1. APP_STORE_CONNECT_API_KEY_ID

**What**: Your API Key ID from App Store Connect

**How to get**:
1. [App Store Connect](https://appstoreconnect.apple.com/) → Users and Access → Keys
2. Generate API Key or use existing
3. Copy the **Key ID** (e.g., `EBYTI4YYF06V`)

**Example value**:
```
EBYTI4YYF06V
```

---

### 2. APP_STORE_CONNECT_API_ISSUER_ID

**What**: Your Issuer ID from App Store Connect

**How to get**:
1. Same page as above (Keys section)
2. Look at the top of the page for **Issuer ID**
3. It's a UUID format

**Example value**:
```
12345678-90ab-cdef-1234-567890abcdef
```

---

### 3. APP_STORE_CONNECT_API_KEY_CONTENT

**What**: Full content of your `.p8` API key file

**How to get**:
1. Download the `.p8` file from App Store Connect (one-time only!)
2. Open it in a text editor
3. Copy **entire contents** including BEGIN/END lines

**Example value**:
```
-----BEGIN PRIVATE KEY-----
MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQgYourPrivateKey
DataGoesHereAndIsQuiteLongWithMultipleLinesOfBase64EncodedContent
AndEndsWithTheClosingTag==
-----END PRIVATE KEY-----
```

---

### 4. BUILD_CERTIFICATE_BASE64

**What**: Your distribution certificate (.p12) encoded in base64

**How to get**:

**Step 1 - Export from Xcode:**
```
Xcode → Settings → Accounts → Manage Certificates
Right-click "Apple Distribution" → Export
Save as: distribution.p12
Password: (choose a strong password)
```

**Step 2 - Convert to base64:**
```bash
base64 -i distribution.p12 -o certificate.txt
cat certificate.txt
```

**Step 3 - Copy the output**

**Example value**:
```
MIIKcQIBAzCCChoGCSqGSIb3DQEHAaCCCgsEggoHMIIKAzCCBW8GCSqG
SIb3DQEHBqCCBWAwggVcAgEAMIIFVQYJKoZIhvcNAQcBMBwGCiqGSIb3
(... very long string ...)
```

---

### 5. P12_PASSWORD

**What**: Password you used when exporting the .p12 file

**How to get**:
- This is the password YOU chose in Step 1 of the previous section
- When you exported the certificate, you were asked to create a password
- Use that same password here

**Example value**:
```
MySecureP12Password123!
```

---

### 6. BUILD_PROVISION_PROFILE_BASE64

**What**: Your provisioning profile (.mobileprovision) encoded in base64

**How to get**:

**Step 1 - Download from Apple Developer:**
```
1. Go to https://developer.apple.com/account/
2. Certificates, Identifiers & Profiles → Profiles
3. Find your App Store profile (or create one)
4. Download the .mobileprovision file
```

**Step 2 - Convert to base64:**
```bash
base64 -i YourProfile.mobileprovision -o profile.txt
cat profile.txt
```

**Step 3 - Copy the output**

**Example value**:
```
MIINuQYJKoZIhvcNAQcCoIINqjCCDaYCAQExDzANBglghkgBZQMEAgEFADCC
AuIGCSqGSIb3DQEHAaCCAtkEggLVMYIC0TAMDApWZXJzaW9uAgEB...
(... very long string ...)
```

---

## Optional Secrets

### KEYCHAIN_PASSWORD

**What**: Password for temporary keychain on CI (optional)

**Default**: If not provided, uses `temp_keychain_password`

**Recommended value**:
```
any_secure_password_123
```

---

## Complete Setup Commands

Run these in Terminal:

```bash
# Navigate to where you saved your files
cd ~/Downloads

# Convert certificate
base64 -i distribution.p12 -o certificate.txt

# Convert provisioning profile  
base64 -i YourAppProfile.mobileprovision -o profile.txt

# View the base64 strings to copy
echo "=== CERTIFICATE BASE64 ==="
cat certificate.txt
echo ""
echo "=== PROFILE BASE64 ==="
cat profile.txt
```

---

## Adding Secrets to GitHub

For EACH secret:

1. Go to your repository on GitHub
2. **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Enter the **Name** and **Value**
5. Click **Add secret**

---

## Verification Checklist

Before running the workflow:

- [ ] All 6 secrets are added
- [ ] APP_STORE_CONNECT_API_KEY_CONTENT includes BEGIN/END lines
- [ ] BUILD_CERTIFICATE_BASE64 is one long string (no spaces/newlines)
- [ ] BUILD_PROVISION_PROFILE_BASE64 is one long string
- [ ] P12_PASSWORD matches what you used during export
- [ ] API Key hasn't been revoked in App Store Connect

---

## Troubleshooting

### "Invalid base64"
- Copy the entire output including all characters
- Don't add any spaces or line breaks manually
- Use `cat` command to view the file, not opening in a text editor

### "Certificate expired"
Certificates are valid for 1 year. Generate a new one:
```
Xcode → Settings → Accounts → Manage Certificates
Click + → Apple Distribution
Export and update BUILD_CERTIFICATE_BASE64 secret
```

### "Profile doesn't match bundle identifier"
Download a new provisioning profile that includes your app's exact Bundle ID from developer.apple.com

### "Wrong password"
The P12_PASSWORD must exactly match what you entered when exporting from Xcode. Try exporting again with a new password.

---

## What Changed from Original Guide?

**✅ Removed (no longer needed):**
- `MATCH_GIT_URL` - No certificate repository
- `MATCH_GIT_BASIC_AUTHORIZATION` - No GitHub token needed
- `MATCH_PASSWORD` - No Match encryption
- `APPLE_ID` - Not needed with this approach
- `TEAM_ID` - Not needed as secret
- `APP_IDENTIFIER` - Not needed as secret
- `ITC_TEAM_ID` - Not needed as secret

**✅ Added (new requirements):**
- `BUILD_CERTIFICATE_BASE64` - Certificate stored directly
- `P12_PASSWORD` - Certificate password
- `BUILD_PROVISION_PROFILE_BASE64` - Profile stored directly

**Result**: Simpler setup, fewer secrets (9 → 6), no external repository needed!

---

## Security Best Practices

- ✅ Never commit `.p12`, `.mobileprovision`, or `.p8` files
- ✅ Use strong passwords for P12_PASSWORD
- ✅ Rotate certificates and API keys annually
- ✅ Limit access to GitHub repository settings
- ✅ Keep provisioning profiles up to date

---

Need more help? See `IOS_DEPLOYMENT_SETUP_SIMPLE.md` for the complete guide.
