# iOS App Store Connect Deployment

This directory contains GitHub Actions workflows for automated iOS app deployment to App Store Connect.

## Workflow: `ios-release.yml`

Automatically builds and uploads your Flutter iOS app to TestFlight whenever you push to main/release branches or create a version tag.

### Prerequisites

Before the workflow can run successfully, you need to set up the following:

#### 1. App Store Connect API Key

Create an API key in App Store Connect:

1. Go to [App Store Connect](https://appstoreconnect.apple.com/)
2. Navigate to **Users and Access** → **Keys** (under Integrations)
3. Click **Generate API Key** or **+**
4. Give it a name (e.g., "GitHub Actions")
5. Select **Admin** access level (or appropriate role)
6. Download the `.p8` file (you can only download it once!)
7. Note the **Key ID** and **Issuer ID**

#### 2. Certificate Management with Fastlane Match

Fastlane Match stores your certificates and provisioning profiles in a Git repository. Set up a private repository:

1. Create a new **private** GitHub repository (e.g., `ios-certificates`)
2. Generate a Personal Access Token (PAT) with `repo` scope:
   - Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
   - Generate new token with `repo` permissions
   - Save the token securely

#### 3. GitHub Secrets

Add the following secrets to your GitHub repository (Settings → Secrets and variables → Actions):

| Secret Name | Description | Example/Notes |
|------------|-------------|---------------|
| `APP_STORE_CONNECT_API_KEY_ID` | API Key ID from App Store Connect | `ABC123XYZ` |
| `APP_STORE_CONNECT_API_ISSUER_ID` | Issuer ID from App Store Connect | `12345678-1234-1234-1234-123456789012` |
| `APP_STORE_CONNECT_API_KEY_CONTENT` | Content of the `.p8` file | Copy entire file content including header/footer |
| `MATCH_GIT_URL` | URL of your certificates repository | `https://github.com/yourusername/ios-certificates` |
| `MATCH_GIT_BASIC_AUTHORIZATION` | Base64 encoded GitHub PAT | `base64encode("username:PAT")` |
| `MATCH_PASSWORD` | Password to encrypt certificates | Choose a strong password |
| `APPLE_ID` | Your Apple ID email | `developer@example.com` |
| `TEAM_ID` | Apple Developer Team ID | Found in App Store Connect |
| `APP_IDENTIFIER` | App Bundle Identifier | `com.yourcompany.cross` |
| `ITC_TEAM_ID` | iTunes Connect Team ID | Usually same as TEAM_ID |

**To generate `MATCH_GIT_BASIC_AUTHORIZATION`:**

```bash
echo -n "your-github-username:your-github-pat" | base64
```

#### 4. Initial Certificate Setup

Before running the workflow, you need to generate and store certificates using Fastlane Match locally:

```bash
cd ios

# Install dependencies
bundle install

# Set environment variables
export MATCH_GIT_URL="https://github.com/yourusername/ios-certificates"
export MATCH_PASSWORD="your-match-password"
export MATCH_GIT_BASIC_AUTHORIZATION="your-base64-encoded-token"
export APPLE_ID="developer@example.com"
export TEAM_ID="YOUR_TEAM_ID"
export APP_IDENTIFIER="com.yourcompany.cross"

# Generate certificates and profiles
bundle exec fastlane certificates
```

This will:
- Create signing certificates
- Create provisioning profiles
- Store them encrypted in your certificates repository

### Running the Workflow

The workflow runs automatically on:
- Push to `main` branch
- Push to any `release/*` branch
- Creation of tags starting with `v` (e.g., `v1.0.0`)
- Manual trigger via GitHub Actions UI

#### Manual Trigger

1. Go to **Actions** tab in GitHub
2. Select **iOS Release to App Store Connect**
3. Click **Run workflow**
4. Optionally add release notes
5. Click **Run workflow** button

### Workflow Steps

1. **Checkout code** - Gets your repository code
2. **Set up Flutter** - Installs Flutter SDK
3. **Get dependencies** - Runs `flutter pub get`
4. **Run tests** - Executes Flutter tests
5. **Set up Ruby** - Installs Ruby and Bundler
6. **Install Fastlane** - Installs Fastlane and plugins
7. **Setup signing** - Configures API key for App Store Connect
8. **Build and upload** - Builds IPA and uploads to TestFlight
9. **Upload artifacts** - Saves build artifacts for 30 days

### Troubleshooting

#### Common Issues

**"No such file or directory - AuthKey_*.p8"**
- Make sure `APP_STORE_CONNECT_API_KEY_CONTENT` secret contains the full content of your `.p8` file

**"Could not find a valid code signing identity"**
- Run `fastlane certificates` locally first to generate certificates
- Verify `MATCH_GIT_URL` and `MATCH_GIT_BASIC_AUTHORIZATION` are correct

**"Invalid username and password"**
- Check `MATCH_GIT_BASIC_AUTHORIZATION` is correctly base64 encoded
- Verify GitHub PAT has `repo` permissions and hasn't expired

**"Could not find App with identifier"**
- Ensure your app exists in App Store Connect
- Verify `APP_IDENTIFIER` matches your app's bundle identifier

**Build succeeds but upload fails**
- Check App Store Connect API key has proper permissions
- Verify `APP_STORE_CONNECT_API_ISSUER_ID` and `APP_STORE_CONNECT_API_KEY_ID` are correct

### Build Artifacts

After each run, build artifacts are saved for 30 days:
- `Runner.xcarchive` - Xcode archive
- `*.ipa` - iOS app package

Access them from the workflow run summary page.

### Next Steps

After the workflow successfully uploads to TestFlight:

1. Wait for Apple to process the build (10-30 minutes)
2. Go to [App Store Connect](https://appstoreconnect.apple.com/)
3. Navigate to **TestFlight**
4. Add build to test groups
5. Submit for external testing (if desired)
6. When ready, submit for App Store review

### Security Best Practices

- ✅ Never commit `.p8` files or certificates to your repository
- ✅ Use GitHub Secrets for all sensitive data
- ✅ Keep your certificates repository private
- ✅ Rotate API keys and PATs periodically
- ✅ Use strong passwords for `MATCH_PASSWORD`
- ✅ Limit API key permissions to minimum required

### Additional Resources

- [Fastlane Documentation](https://docs.fastlane.tools/)
- [Fastlane Match](https://docs.fastlane.tools/actions/match/)
- [App Store Connect API](https://developer.apple.com/app-store-connect/api/)
- [GitHub Actions](https://docs.github.com/en/actions)
