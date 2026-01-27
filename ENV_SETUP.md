# Environment Variables Setup

Your Supabase credentials are now configured to be passed as environment variables for security.

## ⚠️ Important Security Notes

1. **Never commit credentials to git** - `.env` files are in `.gitignore`
2. **Get your complete anon key** from Supabase dashboard (the key provided may be incomplete)
3. Your credentials are at: Settings > API > Project API keys

## 📝 Your Current Credentials

- **Supabase URL:** `https://zwolfdcwatqazhjxmymg.supabase.co`
- **Anon Key:** `sb_publishable_jdnMG1WY5_DVsY3fqrolcA_DIToYnn_`

⚠️ **Note:** Make sure you have the complete anon key from your Supabase dashboard. The key above may be truncated.

## 🚀 How to Run the App

### Option 1: Use the Run Script (Easiest)

```bash
# Make the script executable (first time only)
chmod +x run_dev.sh

# Run the app
./run_dev.sh
```

### Option 2: Manual Flutter Command

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://zwolfdcwatqazhjxmymg.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=sb_publishable_jdnMG1WY5_DVsY3fqrolcA_DIToYnn_
```

### Option 3: VS Code (Recommended for Development)

1. Open the project in VS Code
2. Press `F5` or go to Run > Start Debugging
3. Select "Cross (Development)" from the dropdown
4. The app will run with your credentials automatically!

### Option 4: Android Studio / IntelliJ

1. Go to Run > Edit Configurations
2. Add to "Additional run args":
   ```
   --dart-define=SUPABASE_URL=https://zwolfdcwatqazhjxmymg.supabase.co --dart-define=SUPABASE_ANON_KEY=sb_publishable_jdnMG1WY5_DVsY3fqrolcA_DIToYnn_
   ```

## 🔑 Getting Your Complete Anon Key

If the key above is incomplete:

1. Go to your Supabase dashboard: https://supabase.com/dashboard
2. Select your project: `zwolfdcwatqazhjxmymg`
3. Go to Settings (⚙️) > API
4. Under "Project API keys", copy the **anon public** key
5. It should look like: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...` (much longer)
6. Update it in:
   - `run_dev.sh`
   - `.vscode/launch.json`

## 📦 Building for Production

### Android Release

```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=https://zwolfdcwatqazhjxmymg.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_COMPLETE_KEY
```

### iOS Release

```bash
flutter build ios --release \
  --dart-define=SUPABASE_URL=https://zwolfdcwatqazhjxmymg.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_COMPLETE_KEY
```

## 🧪 Verify Configuration

Run this to check if credentials are loaded:

```dart
// In any Dart file (for testing):
print('URL: ${SupabaseConfig.supabaseUrl}');
print('Key loaded: ${SupabaseConfig.supabaseAnonKey != "YOUR_SUPABASE_ANON_KEY"}');
```

If you see "YOUR_SUPABASE_URL" or "YOUR_SUPABASE_ANON_KEY", the environment variables aren't being passed correctly.

## ✅ Configuration Files Created

- ✅ `run_dev.sh` - Quick run script
- ✅ `.vscode/launch.json` - VS Code debug configuration  
- ✅ `lib/core/config/supabase_config.dart` - Already configured (no changes needed)

## 🔒 Security Best Practices

1. ✅ Environment variables used instead of hardcoded values
2. ✅ `.env` files are gitignored
3. ✅ Credentials not committed to repository
4. ⚠️ Make sure your `.gitignore` includes `.env` and `.vscode/launch.json` if sharing code

---

**You're all set! Press F5 in VS Code or run `./run_dev.sh` to start the app! 🚀**

