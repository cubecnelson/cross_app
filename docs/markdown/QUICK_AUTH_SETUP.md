# Quick Setup: Google & Apple Authentication

## ✅ What's Already Done

The code implementation is complete! Here's what's been added:

### Code Changes
- ✅ Added `google_sign_in`, `sign_in_with_apple`, and `crypto` packages
- ✅ Implemented `signInWithGoogle()` in `AuthRepository`
- ✅ Implemented `signInWithApple()` in `AuthRepository`
- ✅ Added OAuth methods to `AuthNotifier` provider
- ✅ Updated login screen with Google and Apple sign-in buttons
- ✅ Automatic user profile creation for OAuth users

### UI Changes
- ✅ "Continue with Google" button with icon
- ✅ "Continue with Apple" button (iOS only)
- ✅ Clean divider: "OR" separator
- ✅ Loading states for all auth methods

---

## 🚀 Quick Start (5-10 Minutes)

### 1. Install Dependencies
```bash
flutter pub get

# For iOS
cd ios && pod install && cd ..
```

### 2. Get Your Client IDs

You need **3 OAuth Client IDs** from Google Cloud Console:

| Type | Platform | Used For |
|------|----------|----------|
| **Web** | Supabase | Backend authentication |
| **Android** | Android app | Android Google Sign-In |
| **iOS** | iOS app | iOS Google Sign-In |

**Quick Link**: [Create OAuth Client IDs](https://console.cloud.google.com/apis/credentials)

#### Steps:
1. Go to Google Cloud Console → APIs & Services → Credentials
2. Create 3 OAuth Client IDs (one for each type above)
3. For Android: Need SHA-1 fingerprint (run below)
4. For iOS: Need Bundle ID

**Get SHA-1 fingerprint (Android)**:
```bash
# Debug key
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android | grep SHA1
```

---

### 3. Configure Supabase (2 minutes)

1. Go to [Supabase Dashboard](https://supabase.com/dashboard) → Your Project
2. **Authentication** → **Providers** → **Google**
3. Toggle **Enable**
4. Paste **Web Client ID** and **Web Client Secret**
5. Click **Save**

**Redirect URL** (already configured):
```
https://<your-ref>.supabase.co/auth/v1/callback
```

---

### 4. Configure Android (3 minutes)

#### File: `android/app/src/main/res/values/strings.xml`
Create this file if it doesn't exist:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">Cross</string>
    <string name="default_web_client_id">YOUR_ANDROID_CLIENT_ID_HERE</string>
</resources>
```

Replace `YOUR_ANDROID_CLIENT_ID_HERE` with your **Android Client ID** from Google Console.

#### File: `android/app/src/main/AndroidManifest.xml`
Add deep link support (add inside `<activity>` tag):

```xml
<!-- Add this inside MainActivity -->
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data
        android:scheme="com.yourcompany.cross"
        android:host="login-callback" />
</intent-filter>
```

**Update package name** to match yours (currently using `com.yourcompany.cross`).

---

### 5. Configure iOS (3 minutes)

#### File: `ios/Runner/Info.plist`
Add URL schemes (insert before closing `</dict>`):

```xml
<!-- Google & Apple Sign-In -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <!-- Replace with YOUR iOS Client ID (reversed) -->
            <string>com.googleusercontent.apps.YOUR_IOS_CLIENT_ID</string>
            <!-- Your app's URL scheme -->
            <string>com.yourcompany.cross</string>
        </array>
    </dict>
</array>

<!-- Optional: Direct Google Sign-In config -->
<key>GIDClientID</key>
<string>YOUR_IOS_CLIENT_ID.apps.googleusercontent.com</string>
```

Replace:
- `YOUR_IOS_CLIENT_ID` with your iOS Client ID (numbers only)
- `com.yourcompany.cross` with your actual Bundle ID

---

### 6. Add Google Icon (Optional but Nice)

Download the Google "G" logo and save as:
```
assets/icons/google.png
```

Or it will fall back to a Material icon.

---

### 7. Test It! 🎉

```bash
flutter run
```

**On Login Screen:**
1. Tap **"Continue with Google"**
2. Select your Google account
3. Grant permissions
4. Should log you in and navigate to home!

**On iOS:**
- Also see **"Continue with Apple"** button

---

## ⚡ Super Quick Test (Skip Configuration)

Want to test without full setup? Use email/password login that's already working!

Google/Apple auth will be available once you complete the configuration above.

---

## 🔧 Minimal Configuration

If you just want to test Google Sign-In:

1. **Supabase Only**: Configure Google provider in Supabase (Step 3)
2. **Run on Web/Desktop**: No mobile config needed
3. Web authentication will work out of the box

For mobile apps, you must complete Steps 4-5.

---

## 📱 Platform Support

| Platform | Google Sign-In | Apple Sign-In |
|----------|----------------|---------------|
| Android | ✅ Yes | ❌ No |
| iOS | ✅ Yes | ✅ Yes |
| Web | ✅ Yes | ✅ Yes (limited) |
| macOS | ✅ Yes | ✅ Yes |
| Windows | ✅ Yes | ❌ No |
| Linux | ✅ Yes | ❌ No |

---

## 🐛 Quick Troubleshooting

### "Sign-In Failed"
- ✅ Check Client IDs are correct
- ✅ Verify SHA-1 fingerprint (Android)
- ✅ Check Bundle ID matches (iOS)

### "No Client ID Found"
- ✅ Make sure `strings.xml` exists (Android)
- ✅ Check `Info.plist` has URL schemes (iOS)

### "Redirect URI Mismatch"
- ✅ Add callback URL to Google Console
- ✅ Configure deep link in AndroidManifest

### Still Not Working?
Check full docs: `docs/GOOGLE_AUTH_SETUP.md`

---

## 🎯 What Happens After Sign-In

1. User authenticates with Google/Apple
2. Supabase creates auth session
3. App automatically creates user profile in `users` table
4. User is redirected to Home Screen
5. Session persists across app restarts

---

## 🔒 Security Notes

- ✅ Client secrets stay on server (Supabase)
- ✅ Tokens are securely stored by Supabase
- ✅ OAuth flow uses PKCE for mobile
- ✅ Deep links are verified (Android)

---

## 📦 Packages Added

```yaml
google_sign_in: ^6.2.1      # Google Sign-In
sign_in_with_apple: ^6.1.0  # Apple Sign-In
crypto: ^3.0.3               # For Apple nonce generation
```

---

## 🚀 Ready to Ship

Once configured:
- ✅ Production-ready OAuth implementation
- ✅ Secure token handling
- ✅ Cross-platform support
- ✅ Beautiful UI with brand logos
- ✅ Automatic user profile creation

---

## Need Help?

1. **Quick Issues**: Check error messages in console
2. **Config Problems**: See `GOOGLE_AUTH_SETUP.md`
3. **Deep Dive**: Check Supabase Auth logs

**Console Debug Output**:
```
🔐 Starting Google Sign-In...
✅ Google user: user@example.com
🔑 Got Google tokens, signing in to Supabase...
✅ Supabase auth successful: abc-123
✅ Profile found: abc-123
```

---

## Next Steps

After Google/Apple auth works:
- [ ] Add Facebook Login
- [ ] Implement Magic Link (passwordless email)
- [ ] Add 2FA/MFA
- [ ] Set up biometric authentication
- [ ] Add session management

Happy authenticating! 🎉
