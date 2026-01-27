# 🔧 User Profile Creation Fix Guide

## Problem
When users sign up, the app can't insert their profile into the `users` table due to RLS (Row Level Security) timing issues.

## ✅ Solution: Use Database Trigger (Recommended)

The best solution is to automatically create user profiles using a **database trigger** when users sign up. This is the official Supabase recommended approach.

---

## 📋 Steps to Fix

### Step 1: Run the Trigger SQL Script

1. Go to your **Supabase Dashboard**
2. Navigate to **SQL Editor**
3. Open the file: `scripts/fix_user_profile_trigger.sql`
4. Copy and paste the entire SQL script
5. Click **Run** or press `Ctrl+Enter`

This will create a trigger that automatically creates a profile in the `users` table whenever a new user signs up via Supabase Auth.

### Step 2: Verify the Trigger Works

After running the script, you should see output showing:
- ✅ Trigger created successfully
- ✅ Function created successfully
- 📊 List of any existing auth users without profiles

### Step 3: Test User Signup

1. **Hot reload** your Flutter app (press `r` in terminal)
2. Try to **register a new user**
3. Watch the terminal logs for:
   ```
   🔐 Starting sign up for: test@example.com
   ✅ Auth user created: <user-id>
   🔄 Attempting to fetch existing profile...
   ✅ User profile retrieved: <user-id>
   ```

---

## 🔍 How It Works

### Before (Manual Insert - Problematic):
```
User Signs Up → Auth Created → App Tries to Insert Profile → RLS Blocks It ❌
```

### After (Database Trigger - Reliable):
```
User Signs Up → Auth Created → Trigger Auto-Creates Profile → App Fetches Profile ✅
```

---

## 🛠️ What the Code Does Now

The updated `auth_repository.dart` now:

1. ✅ **Creates auth user** via Supabase Auth
2. ✅ **Waits for trigger** to create profile (with fallback)
3. ✅ **Fetches profile** from database
4. ✅ **Falls back** to manual creation if trigger fails
5. ✅ **Detailed logging** for debugging

### Code Flow:
```dart
signUp() {
  1. Create auth user ✓
  2. Wait 500ms for trigger ⏱️
  3. Try to fetch profile (created by trigger) 🔄
  4. If not found, create manually 📝
  5. If that fails, retry fetch 🔁
  6. Return profile or error ✅
}
```

---

## 🐛 Debugging

### Check if Trigger Exists
Run this in Supabase SQL Editor:
```sql
SELECT trigger_name, event_object_table
FROM information_schema.triggers
WHERE trigger_name = 'on_auth_user_created';
```

**Expected output:**
| trigger_name | event_object_table |
|--------------|-------------------|
| on_auth_user_created | users |

### Check for Orphaned Auth Users
Find auth users without profiles:
```sql
SELECT 
  au.id,
  au.email,
  u.id as profile_id
FROM auth.users au
LEFT JOIN public.users u ON au.id = u.id
WHERE u.id IS NULL;
```

If you find any, manually create their profiles:
```sql
INSERT INTO public.users (id, email, created_at)
SELECT id, email, created_at
FROM auth.users
WHERE id NOT IN (SELECT id FROM public.users);
```

### Check RLS Policies
Verify the users table has the correct policies:
```sql
SELECT polname, polcmd, qual, with_check
FROM pg_policy
WHERE polrelid = 'public.users'::regclass;
```

**Expected policies:**
- ✅ `Users can view own profile` (SELECT)
- ✅ `Users can update own profile` (UPDATE)
- ✅ `Users can insert own profile` (INSERT)

---

## 📱 App Terminal Logs

### Successful Signup (with trigger):
```
🔐 Starting sign up for: john@example.com
✅ Auth user created: 550e8400-e29b-41d4-a716-446655440000
🔄 Fetching user profile...
✅ User profile retrieved: 550e8400-e29b-41d4-a716-446655440000
```

### Successful Signup (manual fallback):
```
🔐 Starting sign up for: jane@example.com
✅ Auth user created: 550e8400-e29b-41d4-a716-446655440001
🔄 Fetching user profile...
⚠️ Profile not found via trigger, creating manually...
📝 Manual profile creation: {id: ..., email: ...}
✅ Profile created manually: {id: ..., email: ...}
```

### Failed Signup:
```
🔐 Starting sign up for: test@example.com
✅ Auth user created: 550e8400-e29b-41d4-a716-446655440002
🔄 Fetching user profile...
⚠️ Profile not found via trigger, creating manually...
❌ Manual profile creation failed: <error details>
❌ All profile creation attempts failed
```

---

## 🎯 Quick Fix Checklist

- [ ] Run `fix_user_profile_trigger.sql` in Supabase SQL Editor
- [ ] Verify trigger was created (check above)
- [ ] Hot reload Flutter app
- [ ] Test registration with new email
- [ ] Check terminal logs for success messages
- [ ] Try logging in with the new account
- [ ] Verify profile data appears in Profile screen

---

## 🚨 Common Issues

### Issue 1: "permission denied for table users"
**Solution:** The trigger function uses `SECURITY DEFINER` to bypass RLS. Make sure you ran the full SQL script as the database owner.

### Issue 2: "null value in column 'id' violates not-null constraint"
**Solution:** The `auth.users` trigger passes `NEW.id`. Verify the trigger is on the `auth.users` table, not `public.users`.

### Issue 3: Profile still not created
**Solution:** 
1. Check Supabase logs: Dashboard → Logs → Database
2. Look for trigger execution errors
3. Verify the `handle_new_user()` function exists:
   ```sql
   SELECT proname FROM pg_proc WHERE proname = 'handle_new_user';
   ```

### Issue 4: "relation 'auth.users' does not exist"
**Solution:** Make sure you're running the SQL in the correct database. The `auth` schema should exist in your Supabase project by default.

---

## 🔐 Security Notes

- ✅ The trigger uses `SECURITY DEFINER` to bypass RLS when creating profiles
- ✅ This is safe because it only runs on new auth user creation
- ✅ The trigger only inserts basic profile data (id, email, timestamp)
- ✅ Users still can't insert/update other users' profiles due to RLS

---

## 📚 Additional Resources

- [Supabase: Managing User Data](https://supabase.com/docs/guides/auth/managing-user-data)
- [PostgreSQL Triggers](https://www.postgresql.org/docs/current/sql-createtrigger.html)
- [Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)

---

## ✅ Success Criteria

You know it's working when:
1. ✅ New users can register without errors
2. ✅ Profile data appears immediately after signup
3. ✅ Home screen shows user information
4. ✅ No "User is not authenticated" errors
5. ✅ Terminal logs show successful profile creation

