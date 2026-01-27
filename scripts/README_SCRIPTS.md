# 📜 SQL Scripts Guide

This directory contains all SQL scripts for setting up and managing the Cross App database.

---

## 🚀 Quick Start (New Database)

### **For a brand new database, you only need ONE file:**

```sql
scripts/initialize_database.sql
```

This single script contains **everything** you need:
- ✅ All tables with cardio support built-in
- ✅ All indexes for performance
- ✅ Row Level Security policies
- ✅ Auto-update triggers
- ✅ Auto-profile creation trigger
- ✅ 70 predefined exercises (58 strength + 12 cardio)

### **How to use:**
1. Open **Supabase Dashboard** → **SQL Editor**
2. Copy the entire contents of `initialize_database.sql`
3. Paste and click **Run**
4. Done! ✓

---

## 📁 All Available Scripts

### 🆕 **`initialize_database.sql`** ⭐ (USE THIS FOR NEW DATABASES)
**Purpose:** Complete database initialization from scratch

**What it does:**
- Creates all 5 tables (users, exercises, workouts, sets, routines)
- Sets up both strength and cardio support
- Creates all indexes
- Enables Row Level Security
- Sets up all RLS policies
- Creates automatic update triggers
- Creates auto-profile creation trigger
- Seeds 58 strength exercises
- Seeds 12 cardio exercises
- Provides verification queries

**When to use:** Setting up a brand new database

**Safe to run multiple times:** ✅ Yes (uses IF NOT EXISTS and conflict handling)

---

### 📋 **`seed_exercises.sql`** (LEGACY - included in initialize_database.sql)
**Purpose:** Original setup script (strength exercises only)

**What it does:**
- Creates tables (strength-focused)
- Sets up indexes, RLS, triggers
- Seeds 58 strength exercises

**When to use:** 
- ⚠️ Don't use for new databases - use `initialize_database.sql` instead
- Only use if you need reference to the original schema

**Status:** Legacy - superseded by `initialize_database.sql`

---

### 🏃 **`add_cardio_support.sql`** (MIGRATION SCRIPT)
**Purpose:** Add cardio support to existing strength-only database

**What it does:**
- Adds `exercise_type` column to exercises table
- Makes `reps` and `weight` nullable in sets table
- Adds cardio columns to sets table (distance, duration, pace, heart rate, calories, elevation_gain)
- Creates index on exercise_type
- Seeds 12 cardio exercises

**When to use:** 
- ✅ If you already have a database with only strength exercises
- ✅ To migrate existing database to support cardio

**Prerequisites:** Existing database with tables already created

**Safe to run multiple times:** ✅ Yes (uses IF NOT EXISTS)

---

### 👤 **`fix_user_profile_trigger.sql`** (INCLUDED in initialize_database.sql)
**Purpose:** Auto-create user profiles when users sign up

**What it does:**
- Creates `handle_new_user()` function
- Creates trigger on `auth.users` table
- Grants necessary permissions
- Provides verification queries

**When to use:** 
- ⚠️ Not needed if using `initialize_database.sql` (already included)
- ✅ Can run separately if you only need to add/fix the trigger

**Safe to run multiple times:** ✅ Yes

---

### 🔧 **`create_missing_profiles.sql`** (UTILITY SCRIPT)
**Purpose:** Create profiles for existing auth users who don't have them

**What it does:**
- Identifies auth users without profiles
- Creates missing profiles in bulk
- Shows before/after statistics

**When to use:** 
- ✅ If you have existing users who signed up before the trigger was added
- ✅ To fix orphaned auth users

**Safe to run multiple times:** ✅ Yes (uses ON CONFLICT DO NOTHING)

---

### 🔍 **`diagnose_database.sql`** (DIAGNOSTIC TOOL)
**Purpose:** Check database health and configuration

**What it does:**
- Checks if tables exist
- Verifies RLS is enabled
- Counts records in each table
- Shows RLS policies
- Checks for recent workouts

**When to use:** 
- ✅ Troubleshooting database issues
- ✅ Verifying setup is correct
- ✅ Checking data integrity

**Safe to run multiple times:** ✅ Yes (read-only queries)

---

## 🎯 Which Script Should I Use?

### **Scenario 1: Brand New Database**
```
✅ Use: initialize_database.sql
```
This is all you need! One script, complete setup.

### **Scenario 2: Existing Database (strength only) → Add Cardio**
```
1. Run: add_cardio_support.sql
2. Optional: fix_user_profile_trigger.sql (if not already set up)
```

### **Scenario 3: Users Can't Log In (Profile Issues)**
```
1. Run: fix_user_profile_trigger.sql (for future signups)
2. Run: create_missing_profiles.sql (for existing users)
```

### **Scenario 4: Something's Wrong (Troubleshooting)**
```
1. Run: diagnose_database.sql
2. Review output to identify issues
3. Run appropriate fix script
```

---

## 📊 Script Comparison

| Script | New DB | Existing DB | Purpose | Includes Cardio | Includes Trigger |
|--------|--------|-------------|---------|-----------------|------------------|
| **initialize_database.sql** | ✅ YES | ⚠️ No | Complete setup | ✅ Yes | ✅ Yes |
| **seed_exercises.sql** | ⚠️ Legacy | ⚠️ No | Strength only | ❌ No | ❌ No |
| **add_cardio_support.sql** | ❌ No | ✅ YES | Add cardio | ✅ Yes | ❌ No |
| **fix_user_profile_trigger.sql** | ❌ No | ✅ YES | Fix profiles | N/A | ✅ Yes |
| **create_missing_profiles.sql** | ❌ No | ✅ YES | Bulk fix users | N/A | ❌ No |
| **diagnose_database.sql** | ❌ No | ✅ YES | Diagnostics | N/A | N/A |

---

## 🔄 Migration Path

### **From Nothing → Complete Database**
```
┌─────────────────────────┐
│  Empty Database         │
└────────────┬────────────┘
             │
             ▼
┌─────────────────────────┐
│ initialize_database.sql │ ← Run this ONE script
└────────────┬────────────┘
             │
             ▼
┌─────────────────────────┐
│  ✅ Complete Setup      │
│  • 5 Tables             │
│  • Strength + Cardio    │
│  • RLS + Triggers       │
│  • 70 Exercises         │
└─────────────────────────┘
```

### **From Strength-Only → With Cardio**
```
┌─────────────────────────┐
│  Existing DB            │
│  (strength only)        │
└────────────┬────────────┘
             │
             ▼
┌─────────────────────────┐
│ add_cardio_support.sql  │ ← Add cardio features
└────────────┬────────────┘
             │
             ▼
┌─────────────────────────┐
│  ✅ Updated Database    │
│  • Strength + Cardio    │
│  • 70 Exercises         │
└─────────────────────────┘
```

---

## 📝 Script Execution Order (If Running Separately)

If you need to run scripts individually instead of using `initialize_database.sql`:

```
1. seed_exercises.sql         (or just table creation part)
2. fix_user_profile_trigger.sql
3. add_cardio_support.sql     (if needed)
4. create_missing_profiles.sql (if needed)
5. diagnose_database.sql      (to verify)
```

**⚠️ Recommendation:** Just use `initialize_database.sql` - it's simpler!

---

## 🔐 Security Notes

All scripts include:
- ✅ **Row Level Security (RLS)** - Users can only access their own data
- ✅ **Secure triggers** - Use `SECURITY DEFINER` appropriately
- ✅ **Proper permissions** - Grant only necessary access
- ✅ **Data isolation** - Users cannot see each other's workouts

---

## 🧪 Testing Your Setup

After running any script, verify with:

```sql
-- Check table structure
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public';

-- Check RLS is enabled
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public';

-- Check exercise count
SELECT exercise_type, COUNT(*) 
FROM exercises 
WHERE is_predefined = TRUE 
GROUP BY exercise_type;

-- Check trigger exists
SELECT trigger_name, event_object_table
FROM information_schema.triggers
WHERE trigger_name = 'on_auth_user_created';
```

Or just run `diagnose_database.sql` which includes all these checks!

---

## 💡 Pro Tips

### **Tip 1: Always use the SQL Editor in Supabase**
- Navigate to: Dashboard → SQL Editor
- Paste script and click Run
- Review output for errors

### **Tip 2: Check the output**
All scripts include verification queries that show:
- ✅ What was created
- ✅ Record counts
- ✅ Configuration status

### **Tip 3: Safe to re-run**
Most scripts use:
- `IF NOT EXISTS` - Won't error if already exists
- `ON CONFLICT DO NOTHING` - Won't duplicate data
- `DROP ... IF EXISTS` - Clean before creating

### **Tip 4: Read the comments**
Each script has detailed comments explaining:
- What each section does
- Why it's needed
- Expected outcome

---

## 🆘 Troubleshooting

### **Problem: "relation already exists"**
**Solution:** This is usually fine. The script is trying to create something that already exists. Check the output to ensure it completed successfully.

### **Problem: "permission denied"**
**Solution:** Make sure you're running as database owner or have sufficient permissions. In Supabase, you should have full access by default.

### **Problem: "User profile not created on signup"**
**Solution:** 
1. Run `fix_user_profile_trigger.sql`
2. Verify trigger exists (check output)
3. Test with new signup

### **Problem: "Can't find exercises in app"**
**Solution:**
1. Run `diagnose_database.sql`
2. Check exercise count
3. If 0, run the seed section from `initialize_database.sql`

### **Problem: "Cardio exercises not working"**
**Solution:**
1. Check if `exercise_type` column exists
2. If not, run `add_cardio_support.sql`
3. Verify with `diagnose_database.sql`

---

## 📚 Additional Resources

- **Supabase Docs:** https://supabase.com/docs
- **PostgreSQL Docs:** https://www.postgresql.org/docs/
- **RLS Guide:** https://supabase.com/docs/guides/auth/row-level-security
- **Triggers Guide:** https://www.postgresql.org/docs/current/sql-createtrigger.html

---

## ✅ Quick Reference

| Need to... | Use this script |
|------------|----------------|
| 🆕 Set up new database | `initialize_database.sql` |
| 🏃 Add cardio to existing DB | `add_cardio_support.sql` |
| 👤 Fix profile creation | `fix_user_profile_trigger.sql` |
| 🔧 Fix existing users | `create_missing_profiles.sql` |
| 🔍 Check database health | `diagnose_database.sql` |

---

## 🎉 Summary

For **99% of cases**, you only need:

```sql
scripts/initialize_database.sql
```

This one file gives you a complete, production-ready database with:
- ✅ Full schema
- ✅ Strength + Cardio support
- ✅ Security (RLS)
- ✅ Auto-features (triggers)
- ✅ 70 exercises pre-loaded

**Just run it and you're done!** 🚀

