# Google Authentication Setup Guide

## Overview
This guide will walk you through setting up Google Sign-In for your Cross workout tracking app using Supabase OAuth.

## Prerequisites
- Supabase project created
- Flutter app set up with Supabase
- Google Cloud Console access

---

## Step 1: Configure Google Cloud Console

### 1.1 Create OAuth Client IDs

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select or create a project
3. Navigate to **APIs & Services** > **Credentials**
4. Click **Create Credentials** > **OAuth client ID**

### 1.2 Create Web Client ID (for Supabase)

1. Select **Application type**: Web application
2. Name: `Cross App - Supabase`
3. **Authorized redirect URIs**: Add your Supabase callback URL:
   ```
   https://<your-project-ref>.supabase.co/auth/v1/callback
   ```
   Replace `<your-project-ref>` with your actual Supabase project reference

4. Click **Create**
5. **Save the Client ID and Client Secret** - you'll need these for Supabase

### 1.3 Create Android Client ID

1. Click **Create Credentials** > **OAuth client ID** again
2. Select **Application type**: Android
3. Name: `Cross App - Android`
4. **Package name**: `com.yourcompany.cross` (match your app's package)
5. **SHA-1 certificate fingerprint**: Get this by running:
   ```bash
   # For debug key
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   
   # For release key (when you create one)
   keytool -list -v -keystore /path/to/your/keystore.jks -alias your-alias
   ```
6. Copy the SHA-1 fingerprint and paste it
7. Click **Create**
8. **Save the Client ID**

### 1.4 Create iOS Client ID

1. Click **Create Credentials** > **OAuth client ID** again
2. Select **Application type**: iOS
3. Name: `Cross App - iOS`
4. **Bundle ID**: `com.yourcompany.cross` (match your iOS bundle identifier)
5. Click **Create**
6. **Save the Client ID**

---

## Step 2: Configure Supabase

### 2.1 Enable Google Provider

1. Go to your [Supabase Dashboard](https://supabase.com/dashboard)
2. Select your project
3. Navigate to **Authentication** > **Providers**
4. Find **Google** and click to configure
5. Enable **Google enabled**
6. Paste your **Web Client ID** (from Step 1.2)
7. Paste your **Web Client Secret** (from Step 1.2)
8. Click **Save**

### 2.2 Configure Redirect URLs

1. In Supabase, go to **Authentication** > **URL Configuration**
2. Add your app's custom URL scheme to **Redirect URLs**:
   ```
   com.yourcompany.cross://login-callback
   ```
3. For development, also add:
   ```
   http://localhost:54321/auth/v1/callback
   ```

---

## Step 3: Configure Android

### 3.1 Update `android/app/build.gradle`

```gradle
android {
    ...
    defaultConfig {
        applicationId "com.yourcompany.cross"  // Your package name
        minSdkVersion 23  // Google Sign-In requires min SDK 23
        targetSdkVersion 33
        ...
    }
}
```

### 3.2 Create `android/app/src/main/res/values/strings.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">Cross</string>
    <!-- Add your Android Client ID from Step 1.3 -->
    <string name="default_web_client_id">YOUR_ANDROID_CLIENT_ID.apps.googleusercontent.com</string>
</resources>
```

### 3.3 Update `android/app/src/main/AndroidManifest.xml`

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Add internet permission -->
    <uses-permission android:name="android.permission.INTERNET"/>
    
    <application
        android:label="Cross"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        
        <!-- Add deep link intent filter -->
        <activity
            android:name=".MainActivity"
            ...>
            
            <!-- Existing intent filters -->
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
            
            <!-- Add this for Supabase deep linking -->
            <intent-filter android:autoVerify="true">
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data
                    android:scheme="com.yourcompany.cross"
                    android:host="login-callback" />
            </intent-filter>
        </activity>
    </application>
</manifest>
```

---

## Step 4: Configure iOS

### 4.1 Update `ios/Runner/Info.plist`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    ...
    
    <!-- Add Google Sign-In URL scheme -->
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <!-- Add your reversed iOS Client ID from Step 1.4 -->
                <string>com.googleusercontent.apps.YOUR_IOS_CLIENT_ID</string>
                <!-- Add custom scheme for Supabase -->
                <string>com.yourcompany.cross</string>
            </array>
        </dict>
    </array>
    
    <!-- Optional: Enable Google Sign-In -->
    <key>GIDClientID</key>
    <string>YOUR_IOS_CLIENT_ID.apps.googleusercontent.com</string>
    
    ...
</dict>
</plist>
```

### 4.2 Update `ios/Podfile`

```ruby
platform :ios, '12.0'

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    
    # Add this for Google Sign-In
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
end
```

---

## Step 5: Add Google Icon (Optional but Recommended)

### 5.1 Download Google Logo

1. Download the official Google logo from [Google Brand Resources](https://about.google/brand-resources/)
2. Use the "G" logo (24x24 recommended)

### 5.2 Add to Assets

1. Create file: `assets/icons/google.png`
2. Update `pubspec.yaml` (already done in your project):
   ```yaml
   flutter:
     assets:
       - assets/icons/
   ```

---

## Step 6: Install Dependencies

Run this command to install the new packages:

```bash
flutter pub get
```

For iOS, also run:

```bash
cd ios
pod install
cd ..
```

---

## Step 7: Environment Variables (Optional)

For more security, you can use environment variables for client IDs.

### Create `.env` file (don't commit this!)

```env
GOOGLE_WEB_CLIENT_ID=your-web-client-id.apps.googleusercontent.com
GOOGLE_ANDROID_CLIENT_ID=your-android-client-id.apps.googleusercontent.com
GOOGLE_IOS_CLIENT_ID=your-ios-client-id.apps.googleusercontent.com
```

### Run with environment variables:

```bash
flutter run --dart-define=GOOGLE_SERVER_CLIENT_ID=your-client-id
```

---

## Step 8: Testing

### Test on Android

1. Build and run:
   ```bash
   flutter run
   ```

2. On login screen, tap **Continue with Google**
3. Select your Google account
4. Grant permissions
5. You should be redirected back to the app and logged in

### Test on iOS

1. Build and run:
   ```bash
   flutter run
   ```

2. On login screen, tap **Continue with Google** or **Continue with Apple**
3. Follow the OAuth flow
4. Should redirect back to app

### Common Issues

**"Sign-In Failed: No Client ID"**
- Check that `strings.xml` (Android) or `Info.plist` (iOS) has correct Client IDs
- Verify package name/bundle ID matches Google Console

**"Redirect URI Mismatch"**
- Ensure Supabase callback URL is added to Google Console
- Check that custom URL scheme is configured correctly

**"Invalid Client"**
- Verify you're using the correct client IDs for each platform
- Web client ID → Supabase
- Android client ID → Android app
- iOS client ID → iOS app

---

## Step 9: User Profile Setup

The code automatically creates user profiles in your Supabase `users` table with these fields:
- `id` - Supabase user ID
- `email` - From Google account
- `name` - From Google account (if available)
- `created_at` - Timestamp

Make sure your `users` table schema supports these fields:

```sql
CREATE TABLE users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    name TEXT,
    age INTEGER,
    weight NUMERIC,
    height NUMERIC,
    units TEXT DEFAULT 'metric',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ
);
```

---

## Security Best Practices

1. **Never commit client secrets** to version control
2. **Use environment variables** for sensitive data
3. **Restrict OAuth scopes** to only what you need
4. **Enable App Check** in Firebase (optional but recommended)
5. **Set up authorized domains** in Google Console
6. **Use production keys** for release builds

---

## Troubleshooting

### Check Logs

```dart
// Enable debug logging in your app
print('🔐 Starting Google Sign-In...');
```

Check console for detailed error messages.

### Verify Configuration

1. **Google Console**: All three client IDs created (Web, Android, iOS)
2. **Supabase**: Google provider enabled with Web credentials
3. **Android**: Package name matches, SHA-1 fingerprint correct
4. **iOS**: Bundle ID matches, URL schemes configured
5. **Deep Links**: Custom URL scheme working

### Test Deep Links

Android:
```bash
adb shell am start -W -a android.intent.action.VIEW -d "com.yourcompany.cross://login-callback"
```

iOS:
```bash
xcrun simctl openurl booted "com.yourcompany.cross://login-callback"
```

---

## Next Steps

1. **Add Sign-In with Apple** (iOS) - Already implemented!
2. **Add Facebook Login** - Similar process
3. **Add Email OTP** - For passwordless login
4. **Implement Token Refresh** - Handle session expiration
5. **Add Biometric Auth** - For returning users

---

## References

- [Supabase Auth Documentation](https://supabase.com/docs/guides/auth/social-login/auth-google)
- [Google Sign-In Flutter Package](https://pub.dev/packages/google_sign_in)
- [Sign In with Apple Package](https://pub.dev/packages/sign_in_with_apple)
- [Google Cloud Console](https://console.cloud.google.com/)
- [OAuth 2.0 Best Practices](https://datatracker.ietf.org/doc/html/draft-ietf-oauth-security-topics)

---

## Support

If you encounter issues:
1. Check the console logs for error details
2. Verify all configuration steps
3. Test with different Google accounts
4. Check Supabase Auth logs in dashboard
5. Review Google Cloud Console settings

Happy coding! 🚀
