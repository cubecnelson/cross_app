# GitHub Secrets Configuration Template

Copy this template and fill in your values. Then add them to:
**GitHub Repository → Settings → Secrets and variables → Actions → New repository secret**

## Required Secrets

### App Store Connect API

```
Secret Name: APP_STORE_CONNECT_API_KEY_ID
Value: [Your Key ID from App Store Connect]
Example: ABC123XYZ

Secret Name: APP_STORE_CONNECT_API_ISSUER_ID
Value: [Your Issuer ID from App Store Connect]
Example: 12345678-1234-1234-1234-123456789012

Secret Name: APP_STORE_CONNECT_API_KEY_CONTENT
Value: [Complete content of your .p8 file]
Example:
-----BEGIN PRIVATE KEY-----
MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQg...
-----END PRIVATE KEY-----
```

### Apple Developer Account

```
Secret Name: APPLE_ID
Value: [Your Apple ID email]
Example: developer@yourcompany.com

Secret Name: TEAM_ID
Value: [Your Apple Developer Team ID]
Example: ABCD123456
Where to find: App Store Connect → Membership → Team ID

Secret Name: APP_IDENTIFIER
Value: [Your app's bundle identifier]
Example: com.yourcompany.cross
Where to find: Xcode → Runner → General → Bundle Identifier

Secret Name: ITC_TEAM_ID
Value: [iTunes Connect Team ID - usually same as TEAM_ID]
Example: ABCD123456
```

### Fastlane Match (Certificate Management)

```
Secret Name: MATCH_GIT_URL
Value: [URL of your private certificates repository]
Example: https://github.com/yourcompany/ios-certificates
Note: Must be a PRIVATE repository

Secret Name: MATCH_GIT_BASIC_AUTHORIZATION
Value: [Base64 encoded GitHub credentials]
How to generate:
  echo -n "github-username:github-pat-token" | base64
Example: dXNlcm5hbWU6Z2hwX3lPdXJQZXJzb25hbEFjY2Vzc1Rva2Vu

Secret Name: MATCH_PASSWORD
Value: [Password to encrypt certificates]
Example: YourStrongPassword123!
Note: Choose a strong, unique password
```

### Optional Secrets

```
Secret Name: TEMP_KEYCHAIN_USER
Value: ci
Note: Used for temporary keychain on CI

Secret Name: TEMP_KEYCHAIN_PASSWORD
Value: ci_password
Note: Used for temporary keychain on CI
```

## How to Generate MATCH_GIT_BASIC_AUTHORIZATION

1. **Create a GitHub Personal Access Token (PAT):**
   - Go to GitHub → Settings → Developer settings
   - Personal access tokens → Tokens (classic)
   - Generate new token
   - Select scope: `repo` (Full control of private repositories)
   - Generate token and copy it

2. **Encode the credentials:**
   ```bash
   echo -n "your-github-username:ghp_yourPersonalAccessToken" | base64
   ```

3. **Example:**
   ```bash
   # If your username is "john" and PAT is "ghp_abc123xyz"
   echo -n "john:ghp_abc123xyz" | base64
   # Output: am9objpnaHBfYWJjMTIzeHl6
   ```

4. **Use the output as the secret value**

## Where to Find Each Value

### App Store Connect API Key
1. [App Store Connect](https://appstoreconnect.apple.com/)
2. Users and Access → Keys → Generate API Key
3. Download the `.p8` file (one-time only!)
4. Note the Key ID and Issuer ID

### Team ID
1. [App Store Connect](https://appstoreconnect.apple.com/)
2. Membership tab
3. Look for "Team ID"

### Bundle Identifier
```bash
# Open Xcode workspace
open ios/Runner.xcworkspace

# Or check in Xcode:
# Runner target → General → Identity → Bundle Identifier
```

## Verification Checklist

Before running the workflow, verify:

- [ ] All 9 required secrets are added to GitHub
- [ ] APP_STORE_CONNECT_API_KEY_CONTENT includes BEGIN/END lines
- [ ] MATCH_GIT_URL points to a PRIVATE repository
- [ ] MATCH_GIT_BASIC_AUTHORIZATION is base64 encoded correctly
- [ ] APP_IDENTIFIER matches your Xcode bundle identifier exactly
- [ ] GitHub PAT has `repo` scope
- [ ] API Key in App Store Connect has not been revoked
- [ ] You have Admin or App Manager role for the API key

## Testing Secret Configuration

After adding secrets, test locally first:

```bash
cd ios
bundle install

# Export all secrets as environment variables
export APP_STORE_CONNECT_API_KEY_ID="..."
export APP_STORE_CONNECT_API_ISSUER_ID="..."
export APPLE_ID="..."
export TEAM_ID="..."
export APP_IDENTIFIER="..."
export MATCH_GIT_URL="..."
export MATCH_GIT_BASIC_AUTHORIZATION="..."
export MATCH_PASSWORD="..."

# Test certificate access
bundle exec fastlane match appstore --readonly

# If successful, you'll see:
# "All required keys, certificates and provisioning profiles are installed"
```

## Security Best Practices

1. **Never commit secrets to repository**
   - Check .gitignore includes `.p8`, `.cer`, `.p12`, etc.

2. **Use strong passwords**
   - MATCH_PASSWORD should be 16+ characters with mixed case, numbers, symbols

3. **Limit API key permissions**
   - Only grant necessary access level in App Store Connect

4. **Rotate credentials regularly**
   - Replace tokens and keys every 6-12 months

5. **Keep certificates repository private**
   - MATCH_GIT_URL must point to a private repository
   - Limit access to essential team members only

6. **Monitor access**
   - Regularly audit who has access to secrets
   - Review GitHub Actions logs for suspicious activity

## Troubleshooting

### "Invalid base64 encoding"
- Make sure there are no spaces or newlines in MATCH_GIT_BASIC_AUTHORIZATION
- Re-generate using the exact command provided above

### "Authentication failed" 
- Verify GitHub PAT hasn't expired
- Check PAT has `repo` scope
- Ensure username is correct (case-sensitive)

### "Certificate not found"
- Run `fastlane certificates` locally first
- Check MATCH_GIT_URL is accessible
- Verify MATCH_PASSWORD is correct

### "API key not found"
- Confirm .p8 file content is complete
- Check API key hasn't been revoked in App Store Connect
- Verify Key ID and Issuer ID are correct

---

For more help, see:
- `IOS_DEPLOYMENT_SETUP.md` - Full setup guide
- `.github/workflows/README.md` - Workflow documentation
