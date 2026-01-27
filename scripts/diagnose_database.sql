-- ============================================================================
-- CROSS APP - DATABASE DIAGNOSTIC SCRIPT
-- ============================================================================
-- Run this in Supabase SQL Editor to check your database setup
-- ============================================================================

-- Check if all tables exist
SELECT 
    'Tables Check' as check_type,
    CASE 
        WHEN COUNT(*) = 5 THEN '✅ All 5 tables exist'
        ELSE '❌ Missing tables! Found: ' || COUNT(*)::text || '/5'
    END as status
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('users', 'exercises', 'workouts', 'sets', 'routines');

-- List all tables
SELECT 
    'Available Tables' as info,
    string_agg(table_name, ', ') as tables
FROM information_schema.tables 
WHERE table_schema = 'public';

-- Check exercises count
SELECT 
    'Predefined Exercises' as info,
    COUNT(*) as count,
    CASE 
        WHEN COUNT(*) >= 50 THEN '✅ Good'
        WHEN COUNT(*) > 0 THEN '⚠️  Low count'
        ELSE '❌ No exercises'
    END as status
FROM exercises 
WHERE is_predefined = TRUE;

-- Check if auth.users exist
SELECT 
    'Authenticated Users' as info,
    COUNT(*) as count
FROM auth.users;

-- Check if user profiles exist
SELECT 
    'User Profiles' as info,
    COUNT(*) as count,
    CASE 
        WHEN COUNT(*) > 0 THEN '✅ Profiles exist'
        ELSE '❌ No profiles - users table empty'
    END as status
FROM users;

-- Check RLS policies
SELECT 
    'RLS Policies' as info,
    tablename,
    COUNT(*) as policy_count
FROM pg_policies 
WHERE schemaname = 'public'
GROUP BY tablename
ORDER BY tablename;

-- Check foreign key constraints
SELECT
    'Foreign Keys' as info,
    conname as constraint_name,
    conrelid::regclass as table_name,
    confrelid::regclass as references_table
FROM pg_constraint
WHERE contype = 'f' 
AND connamespace = 'public'::regnamespace
ORDER BY conrelid::regclass::text;

-- Check if current user can insert into workouts
SELECT 
    'Current User Permissions' as info,
    auth.uid() as user_id,
    CASE 
        WHEN auth.uid() IS NOT NULL THEN '✅ Authenticated'
        ELSE '❌ Not authenticated'
    END as auth_status;

-- Check recent workouts (if any)
SELECT 
    'Recent Workouts' as info,
    COUNT(*) as total_workouts,
    MAX(created_at) as last_workout
FROM workouts;

-- Summary
SELECT 
    '===================' as separator,
    'DIAGNOSTIC COMPLETE' as status,
    '===================' as separator2;

