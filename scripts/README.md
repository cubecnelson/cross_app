# Database Setup Scripts

This folder contains scripts to set up the complete Cross app database with all tables and seed data.

## 📁 Files

1. **`seed_exercises.sql`** ⭐ **COMPLETE DATABASE SETUP** - Creates all tables + seeds 58 exercises
2. **`seed_exercises.dart`** - Dart script for programmatic seeding (exercises only)

## 🚀 Usage

### Option 1: SQL Script (Recommended - Complete Setup)

This script is **fully standalone** - it creates ALL tables and seeds exercises!

1. Go to your Supabase dashboard: https://supabase.com/dashboard
2. Navigate to **SQL Editor**
3. Open `seed_exercises.sql`
4. Copy the entire content
5. Paste into Supabase SQL Editor
6. Click **Run**
7. ✅ Done! Complete database ready!

**Note:** This script includes:
- ✅ **5 Tables**: users, exercises, workouts, sets, routines
- ✅ **Indexes** for all tables (performance optimization)
- ✅ **Row Level Security** policies (data protection)
- ✅ **Triggers** for updated_at timestamps
- ✅ **58 Predefined exercises** across 7 categories
- ✅ **All foreign keys** and constraints

### Option 2: Dart Script

1. Update your Supabase credentials in `seed_exercises.dart`:
   ```dart
   url: 'https://zwolfdcwatqazhjxmymg.supabase.co',
   anonKey: 'YOUR_COMPLETE_ANON_KEY_HERE',
   ```

2. Run the script:
   ```bash
   cd scripts
   dart run seed_exercises.dart
   ```

3. ✅ Done! Exercises seeded programmatically

## 🗄️ Database Schema Created

The SQL script creates a **complete database** with:

### Tables Created
1. **users** - User profiles (extends auth.users)
2. **exercises** - Exercise library (predefined + custom)
3. **workouts** - Workout sessions
4. **sets** - Individual sets within workouts
5. **routines** - Saved workout routines

### Security Features
- ✅ Row Level Security (RLS) on all tables
- ✅ Users can only access their own data
- ✅ Predefined exercises accessible to all
- ✅ Secure foreign key constraints

### Performance Optimizations
- ✅ Indexes on all frequently queried columns
- ✅ Automatic updated_at triggers
- ✅ Efficient query patterns

## 📊 Exercises Added

The script seeds **58 exercises** across 7 categories:

| Category  | Count | Examples                                    |
|-----------|-------|---------------------------------------------|
| Chest     | 9     | Bench Press, Dumbbell Flyes, Push-ups      |
| Back      | 9     | Deadlift, Pull-ups, Barbell Row            |
| Shoulders | 7     | Overhead Press, Lateral Raise, Face Pull   |
| Legs      | 10    | Squat, Leg Press, Lunges, Calf Raise       |
| Arms      | 9     | Barbell Curl, Tricep Pushdown, Dips        |
| Core      | 8     | Plank, Crunches, Russian Twist             |
| Cardio    | 6     | Treadmill, Bike, Rowing, Jump Rope         |

**Total: 58 exercises**

## 🔍 Verify Installation

Run this query in Supabase SQL Editor:

```sql
SELECT category, COUNT(*) as count 
FROM exercises 
WHERE is_predefined = TRUE 
GROUP BY category 
ORDER BY category;
```

Expected output:
```
Arms      | 9
Back      | 9
Cardio    | 6
Chest     | 9
Core      | 8
Legs      | 10
Shoulders | 7
```

## 🔄 Re-running Scripts

### To Clear and Re-seed

**SQL:**
```sql
-- Clear existing predefined exercises
DELETE FROM exercises WHERE is_predefined = TRUE;

-- Then run the seed_exercises.sql script again
```

**Dart:**
The Dart script will warn you if exercises already exist.

## ✨ Features

Each exercise includes:
- ✅ Name
- ✅ Category
- ✅ Description
- ✅ Target muscles (array)
- ✅ Predefined flag

## 🎯 Next Steps

After seeding:
1. Open the Cross app
2. Go to workout screen
3. Tap "Add Exercise"
4. See all 58 exercises available!
5. Start creating workouts and routines

## 📝 Adding More Exercises

### Via App (User-specific)
Users can create custom exercises through the app's "Add Custom Exercise" feature.

### Via SQL (Predefined)
Add more exercises to `seed_exercises.sql`:

```sql
INSERT INTO exercises (name, category, description, target_muscles, is_predefined) VALUES
('Your Exercise', 'Category', 'Description', ARRAY['Muscle1', 'Muscle2'], TRUE);
```

## ⚠️ Important Notes

1. **Predefined exercises** (`is_predefined = TRUE`) are accessible to all users
2. **Custom exercises** (`is_predefined = FALSE`) are user-specific
3. Users cannot delete predefined exercises (enforced by RLS)
4. This script is **standalone** - you can run it without `supabase_setup.sql` if you only need the exercises table
5. If running the full app setup, you can run either script first (both are safe)

## 🐛 Troubleshooting

### "Table 'exercises' doesn't exist"
This shouldn't happen! The script now creates the table automatically. If you see this error:
- Make sure you ran the entire script (not just part of it)
- Check that `uuid-ossp` extension is enabled: `CREATE EXTENSION IF NOT EXISTS "uuid-ossp";`

### "Duplicate key value" error
Exercises may already exist. Clear them first:
```sql
DELETE FROM exercises WHERE is_predefined = TRUE;
```

### Dart script connection error
- Verify your Supabase URL and anon key are correct
- Check you have internet connection
- Ensure your Supabase project is active

---

**Ready to populate your exercise database! 💪**

