# Google Authentication Setup Checklist

Use this checklist to configure Google & Apple Sign-In for your app.

---

## ☑️ Pre-Setup

- [ ] Flutter dependencies installed (`flutter pub get`)
- [ ] iOS pods installed (`cd ios && pod install`)
- [ ] Supabase project created and configured
- [ ] Access to Google Cloud Console

---

## 🌐 Google Cloud Console Setup

### Create OAuth Client IDs

- [ ] **Web Client ID** (for Supabase)
  - [ ] Created in Google Cloud Console
  - [ ] Client ID saved: `___________________________`
  - [ ] Client Secret saved: `___________________________`
  - [ ] Redirect URI added: `https://<project>.supabase.co/auth/v1/callback`

- [ ] **Android Client ID**
  - [ ] SHA-1 fingerprint generated
    ```bash
    keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android | grep SHA1
    ```
  - [ ] SHA-1 added to Google Console: `___________________________`
  - [ ] Package name set: `com.yourcompany.cross` (or yours)
  - [ ] Android Client ID saved: `___________________________`

- [ ] **iOS Client ID**
  - [ ] Bundle ID set: `com.yourcompany.cross` (or yours)
  - [ ] iOS Client ID saved: `___________________________`
  - [ ] Reversed Client ID saved: `com.googleusercontent.apps.______`

---

## 🔧 Supabase Configuration

- [ ] Logged into Supabase Dashboard
- [ ] Navigation: Authentication → Providers → Google
- [ ] Google provider enabled
- [ ] Web Client ID pasted
- [ ] Web Client Secret pasted
- [ ] Changes saved

**Redirect URLs** (should include):
- [ ] `https://<your-project>.supabase.co/auth/v1/callback`
- [ ] `com.yourcompany.cross://login-callback`

---

## 🤖 Android Configuration

### File: `android/app/build.gradle`
- [ ] `minSdkVersion` is 23 or higher
- [ ] `applicationId` matches package name
- [ ] Package name: `___________________________`

### File: `android/app/src/main/res/values/strings.xml`
- [ ] File created (if didn't exist)
- [ ] Added `default_web_client_id` with Android Client ID
- [ ] File saved

```xml
<string name="default_web_client_id">YOUR_ANDROID_CLIENT_ID_HERE</string>
```

### File: `android/app/src/main/AndroidManifest.xml`
- [ ] Added `INTERNET` permission
- [ ] Added deep link `intent-filter` for login callback
- [ ] Scheme matches: `com.yourcompany.cross` (or yours)

---

## 🍎 iOS Configuration

### File: `ios/Runner/Info.plist`
- [ ] Added `CFBundleURLTypes` array
- [ ] Added reversed iOS Client ID: `com.googleusercontent.apps.______`
- [ ] Added custom URL scheme: `com.yourcompany.cross`
- [ ] Added `GIDClientID` key (optional)
- [ ] File saved

### File: `ios/Podfile`
- [ ] Platform version is 12.0 or higher
- [ ] Post-install script configured

### Run Pod Install
- [ ] Executed: `cd ios && pod install && cd ..`
- [ ] No errors reported

---

## 🎨 Assets (Optional)

- [ ] Downloaded Google logo (24x24 PNG)
- [ ] Saved to: `assets/icons/google.png`
- [ ] Asset referenced in `pubspec.yaml` (already done)

---

## 🧪 Testing

### Android Testing
- [ ] App builds successfully: `flutter run`
- [ ] Login screen shows "Continue with Google" button
- [ ] Tapping button opens Google Sign-In
- [ ] Can select Google account
- [ ] Successfully signs in
- [ ] Redirected to Home screen
- [ ] Profile created in Supabase `users` table

### iOS Testing
- [ ] App builds successfully: `flutter run`
- [ ] Login screen shows both Google and Apple buttons
- [ ] Google Sign-In works
- [ ] Apple Sign-In works (iOS only)
- [ ] Successfully redirects to Home
- [ ] Profile created in database

### Console Logs
- [ ] See: `🔐 Starting Google Sign-In...`
- [ ] See: `✅ Google user: email@example.com`
- [ ] See: `✅ Supabase auth successful: user-id`
- [ ] See: `✅ Profile found: user-id`
- [ ] No errors in console

---

## 🐛 Troubleshooting (If Needed)

### If Sign-In Fails
- [ ] Verified Client IDs are correct for each platform
- [ ] Checked SHA-1 fingerprint matches (Android)
- [ ] Confirmed Bundle ID matches (iOS)
- [ ] Reviewed Supabase Auth logs
- [ ] Checked Google Cloud Console settings

### If Redirect Fails
- [ ] Verified deep link configuration
- [ ] Tested deep link manually:
  ```bash
  # Android
  adb shell am start -W -a android.intent.action.VIEW -d "com.yourcompany.cross://login-callback"
  
  # iOS
  xcrun simctl openurl booted "com.yourcompany.cross://login-callback"
  ```

### If Profile Not Created
- [ ] Checked Supabase database permissions
- [ ] Verified `users` table exists with correct schema
- [ ] Reviewed console logs for errors

---

## ✅ Completion

### Final Checks
- [ ] Google Sign-In works on Android
- [ ] Google Sign-In works on iOS
- [ ] Apple Sign-In works on iOS
- [ ] User profiles created correctly
- [ ] Session persists after app restart
- [ ] No console errors
- [ ] Production client IDs created (for release)
- [ ] Release SHA-1 added to Google Console (for production)

### Documentation Read
- [ ] `README_GOOGLE_AUTH.md` - Overview
- [ ] `docs/QUICK_AUTH_SETUP.md` - Quick guide
- [ ] `docs/GOOGLE_AUTH_SETUP.md` - Detailed guide

---

## 📝 Notes

**Package Name/Bundle ID**: ___________________________

**Supabase Project**: ___________________________

**Web Client ID**: ___________________________

**Android Client ID**: ___________________________

**iOS Client ID**: ___________________________

**Additional Notes**:
```
(Add any custom configuration notes here)







```

---

## 🎉 Status

- [ ] **Setup Complete** - All OAuth authentication working!
- [ ] **Tested Successfully** - Both Google and Apple Sign-In work
- [ ] **Ready for Production** - Production credentials configured

---

**Setup Started**: ___/___/_______

**Setup Completed**: ___/___/_______

**Completed By**: ___________________________

---

## 📞 Support Links

- [Google Cloud Console](https://console.cloud.google.com/)
- [Supabase Dashboard](https://supabase.com/dashboard)
- [Quick Setup Guide](docs/QUICK_AUTH_SETUP.md)
- [Full Documentation](docs/GOOGLE_AUTH_SETUP.md)

---

**Save this file after completion for future reference!**
