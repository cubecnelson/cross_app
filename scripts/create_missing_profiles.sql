-- ============================================================================
-- CREATE PROFILES FOR EXISTING USERS
-- ============================================================================
-- This script creates user profiles for any auth users who don't have them yet.
-- Run this if you have existing users who signed up before the trigger was added.

-- Step 1: Check how many auth users are missing profiles
SELECT 
  'Missing Profiles' as status,
  COUNT(*) as count
FROM auth.users au
LEFT JOIN public.users u ON au.id = u.id
WHERE u.id IS NULL;

-- Step 2: Show the users who are missing profiles
SELECT 
  au.id,
  au.email,
  au.created_at as auth_created_at
FROM auth.users au
LEFT JOIN public.users u ON au.id = u.id
WHERE u.id IS NULL
ORDER BY au.created_at DESC;

-- Step 3: Create profiles for all missing users
INSERT INTO public.users (id, email, created_at)
SELECT 
  au.id,
  au.email,
  au.created_at
FROM auth.users au
LEFT JOIN public.users u ON au.id = u.id
WHERE u.id IS NULL
ON CONFLICT (id) DO NOTHING;

-- Step 4: Verify all users now have profiles
SELECT 
  'All Users Status' as status,
  COUNT(DISTINCT au.id) as total_auth_users,
  COUNT(DISTINCT u.id) as total_profiles,
  COUNT(DISTINCT au.id) - COUNT(DISTINCT u.id) as missing_profiles
FROM auth.users au
LEFT JOIN public.users u ON au.id = u.id;

-- Step 5: Show all users with their profiles
SELECT 
  au.id,
  au.email,
  au.created_at as auth_created,
  u.id IS NOT NULL as has_profile,
  u.created_at as profile_created
FROM auth.users au
LEFT JOIN public.users u ON au.id = u.id
ORDER BY au.created_at DESC
LIMIT 20;

