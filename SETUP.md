# Cross App - Setup Guide

## Prerequisites

- Flutter SDK 3.0.0 or higher
- Dart SDK
- A Supabase account (free tier available at https://supabase.com)
- iOS Simulator (for iOS development) or Android Emulator

## Step 1: Install Flutter Dependencies

```bash
flutter pub get
```

## Step 2: Set Up Supabase

### 2.1 Create a Supabase Project

1. Go to https://supabase.com and sign up/sign in
2. Click "New Project"
3. Fill in the project details:
   - Name: `cross-workout-app` (or any name you prefer)
   - Database Password: Choose a strong password
   - Region: Select the closest region to you
4. Wait for the project to be created (takes about 2 minutes)

### 2.2 Set Up the Database

1. In your Supabase dashboard, go to the SQL Editor
2. Open the `supabase_setup.sql` file in this project
3. Copy all the SQL content
4. Paste it into the Supabase SQL Editor
5. Click "Run" to execute the SQL script

This will:
- Create all necessary tables (users, exercises, workouts, sets, routines)
- Set up Row Level Security (RLS) policies
- Insert predefined exercises
- Create indexes for better performance

### 2.3 Configure Environment Variables

1. In your Supabase dashboard, go to Settings > API
2. Copy the following values:
   - **Project URL** (e.g., `https://abcdefghijklmnop.supabase.co`)
   - **anon/public key** (a long JWT token)

3. Create a `.env` file in the project root:
   ```bash
   cp .env.example .env
   ```

4. Edit the `.env` file and add your values:
   ```
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your_anon_key_here
   ```

### 2.4 Enable Email Authentication

1. In Supabase dashboard, go to Authentication > Providers
2. Make sure Email provider is enabled
3. Configure email templates if desired (optional)

## Step 3: Run the App

### For Development

Run with environment variables:

```bash
flutter run --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_ANON_KEY=your_key
```

Or create a launch configuration in your IDE.

### VS Code Launch Configuration

Create `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Cross (Development)",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "args": [
        "--dart-define=SUPABASE_URL=your_supabase_url",
        "--dart-define=SUPABASE_ANON_KEY=your_supabase_anon_key"
      ]
    }
  ]
}
```

### Android Studio / IntelliJ

1. Go to Run > Edit Configurations
2. Add the following to "Additional run args":
   ```
   --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_ANON_KEY=your_key
   ```

## Step 4: Test the App

1. Run the app on your preferred device/emulator
2. Register a new account using email/password
3. Verify the account is created in Supabase dashboard (Authentication > Users)
4. Log in and start using the app!

## Features to Test

- ✅ User registration and login
- ✅ Profile management
- ✅ Exercise library (predefined and custom exercises)
- ✅ Workout logging with timer
- ✅ Creating and managing routines
- ✅ Progress tracking with charts
- ✅ Dark mode toggle
- ✅ Units preference (metric/imperial)

## Troubleshooting

### "Failed to connect to Supabase"

- Check that your `.env` file has the correct credentials
- Verify you're passing the credentials via `--dart-define` flags
- Make sure your Supabase project is active

### "Authentication failed"

- Check that Email provider is enabled in Supabase
- Verify the email/password meets requirements
- Check Supabase dashboard for error logs (Settings > Logs)

### "Cannot read data"

- Verify the SQL script was executed successfully
- Check that RLS policies are set up correctly
- Go to Supabase dashboard > Table Editor to verify tables exist

### Build errors

```bash
# Clean the build
flutter clean
flutter pub get

# Try running again
flutter run
```

## Optional: Set Up OAuth Providers

### Google Sign-In (Optional)

1. Set up Google OAuth in Supabase (Authentication > Providers > Google)
2. Add iOS/Android configuration files
3. Update the app to use Google sign-in

### Apple Sign-In (Optional)

1. Set up Apple OAuth in Supabase (Authentication > Providers > Apple)
2. Configure Apple Developer account
3. Update the app to use Apple sign-in

## Production Deployment

### Android

```bash
flutter build apk --release --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_ANON_KEY=your_key
```

### iOS

```bash
flutter build ios --release --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_ANON_KEY=your_key
```

## Support

For issues or questions, please check:
- [Flutter Documentation](https://flutter.dev/docs)
- [Supabase Documentation](https://supabase.com/docs)
- Project GitHub Issues (if applicable)

