# Quick Start Guide - Cross Workout App

## 🚀 Get Running in 5 Minutes

### Step 1: Install Flutter Dependencies (1 minute)

```bash
cd /Users/nelson.cheung/cross_app
flutter pub get
```

### Step 2: Set Up Supabase (2 minutes)

1. Go to https://supabase.com and create a free account
2. Click "New Project" and fill in:
   - **Name**: `cross-workout-app`
   - **Database Password**: (choose a strong password)
   - **Region**: (select closest to you)
3. Wait ~2 minutes for project creation

### Step 3: Initialize Database (1 minute)

1. In Supabase dashboard, go to **SQL Editor**
2. Open `supabase_setup.sql` from this project
3. Copy all the SQL content
4. Paste in Supabase SQL Editor
5. Click **Run** → This creates all tables, security policies, and sample exercises

### Step 4: Get Your Credentials (30 seconds)

1. In Supabase dashboard, go to **Settings** > **API**
2. Copy two values:
   - **Project URL** (e.g., `https://abcdefg.supabase.co`)
   - **anon/public key** (long JWT token)

### Step 5: Run the App (30 seconds)

```bash
flutter run \
  --dart-define=SUPABASE_URL=YOUR_PROJECT_URL \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

**Replace** `YOUR_PROJECT_URL` and `YOUR_ANON_KEY` with your actual values.

### 🎉 Done! You should now see the login screen.

---

## 📱 First Time Usage

### 1. Create an Account
- Tap "Sign Up"
- Enter email and password (min 8 chars, must include uppercase, lowercase, and number)
- Tap "Create Account"

### 2. Set Up Your Profile
- Go to Profile tab (bottom right)
- Tap "Edit Profile"
- Add your name, age, weight, height
- Choose units (metric or imperial)
- Save changes

### 3. Start Your First Workout
- Go to Home tab
- Tap "Start Empty Workout"
- Tap "Add Exercise"
- Select an exercise (e.g., "Bench Press")
- Enter sets, reps, and weight
- Tap checkmark when set is complete
- Add more exercises as needed
- Tap "Finish" when done

### 4. Create a Routine
- From Home, tap "See All" under Routines
- Tap "New Routine" (+ button)
- Enter routine name (e.g., "Push Day")
- Tap "Add Exercise"
- Configure each exercise with sets/reps
- Save routine
- Next time, start workout directly from routine!

---

## ⚙️ For Easier Development

### Option 1: VS Code Launch Configuration

Create `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Cross Dev",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "args": [
        "--dart-define=SUPABASE_URL=YOUR_URL",
        "--dart-define=SUPABASE_ANON_KEY=YOUR_KEY"
      ]
    }
  ]
}
```

Then just press F5 to run!

### Option 2: Create a Run Script

Create `run.sh`:

```bash
#!/bin/bash
flutter run \
  --dart-define=SUPABASE_URL=your_url \
  --dart-define=SUPABASE_ANON_KEY=your_key
```

Make executable and run:
```bash
chmod +x run.sh
./run.sh
```

---

## 🧪 Test the Features

### ✅ Test Checklist
- [ ] Register new account
- [ ] Log in
- [ ] Edit profile
- [ ] Toggle dark mode
- [ ] Create custom exercise
- [ ] Start and complete a workout
- [ ] View workout in history
- [ ] Create a routine
- [ ] Start workout from routine
- [ ] View progress charts

---

## 🆘 Troubleshooting

### "Failed to connect to Supabase"
- Verify URL and key are correct
- Check you're passing `--dart-define` flags
- Ensure Supabase project is active (check dashboard)

### "Authentication failed"
- Password must be 8+ characters
- Must include uppercase, lowercase, and number
- Check email is valid format

### "Cannot see exercises"
- Verify SQL script ran successfully
- Check Supabase Table Editor > `exercises` table exists
- Confirm predefined exercises were inserted

### Build errors
```bash
flutter clean
flutter pub get
flutter run --dart-define=...
```

---

## 📚 Next Steps

- Read `SETUP.md` for detailed documentation
- See `PROJECT_SUMMARY.md` for architecture overview
- Explore the codebase in `lib/` directory
- Check Supabase dashboard for data

---

## 💡 Pro Tips

1. **Use the routine feature** - Save time by creating routines for your regular workouts
2. **Check progress tab** - See your volume trends over time
3. **Dark mode** - Toggle in Profile > Theme
4. **Quick start** - Use dashboard quick actions to jump into workouts
5. **Offline mode** - App caches data, works even without internet!

---

**Enjoy tracking your workouts! 💪**

