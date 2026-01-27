-- ============================================================================
-- CROSS APP - COMPLETE DATABASE SETUP SCRIPT
-- ============================================================================
-- 
-- This script creates the complete Cross workout app database including:
--   ✓ 5 Tables (users, exercises, workouts, sets, routines)
--   ✓ All indexes for optimal performance
--   ✓ Row Level Security policies for data protection
--   ✓ Triggers for automatic timestamp updates
--   ✓ 58 Predefined exercises across 7 categories
--
-- USAGE:
--   1. Open Supabase SQL Editor
--   2. Copy and paste this entire script
--   3. Click "Run"
--   4. Database ready! ✓
--
-- SAFE TO RUN MULTIPLE TIMES - Uses "IF NOT EXISTS" checks
-- ============================================================================

-- Enable UUID extension (required for id generation)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- CREATE TABLES
-- ============================================================================

-- Users table (extends Supabase auth.users with profile information)
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    name TEXT,
    age INTEGER,
    weight DOUBLE PRECISION,
    height DOUBLE PRECISION,
    units TEXT DEFAULT 'metric' CHECK (units IN ('metric', 'imperial')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE
);

-- Exercises table
CREATE TABLE IF NOT EXISTS exercises (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    category TEXT NOT NULL,
    description TEXT,
    target_muscles TEXT[],
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    is_predefined BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Workouts table
CREATE TABLE IF NOT EXISTS workouts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    date TIMESTAMP WITH TIME ZONE NOT NULL,
    routine_id UUID,
    routine_name TEXT,
    notes TEXT,
    duration INTEGER, -- in seconds
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE
);

-- Sets table
CREATE TABLE IF NOT EXISTS sets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    workout_id UUID NOT NULL REFERENCES workouts(id) ON DELETE CASCADE,
    exercise_id UUID NOT NULL REFERENCES exercises(id),
    exercise_name TEXT NOT NULL,
    set_number INTEGER NOT NULL,
    reps INTEGER NOT NULL,
    weight DOUBLE PRECISION NOT NULL,
    rest_time INTEGER, -- in seconds
    rpe INTEGER CHECK (rpe >= 1 AND rpe <= 10),
    notes TEXT,
    is_completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Routines table
CREATE TABLE IF NOT EXISTS routines (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    exercises JSONB NOT NULL DEFAULT '[]',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE
);

-- ============================================================================
-- CREATE INDEXES
-- ============================================================================

-- Users indexes
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- Exercises indexes
CREATE INDEX IF NOT EXISTS idx_exercises_user_id ON exercises(user_id);
CREATE INDEX IF NOT EXISTS idx_exercises_category ON exercises(category);
CREATE INDEX IF NOT EXISTS idx_exercises_is_predefined ON exercises(is_predefined);

-- Workouts indexes
CREATE INDEX IF NOT EXISTS idx_workouts_user_id ON workouts(user_id);
CREATE INDEX IF NOT EXISTS idx_workouts_date ON workouts(date);

-- Sets indexes
CREATE INDEX IF NOT EXISTS idx_sets_workout_id ON sets(workout_id);
CREATE INDEX IF NOT EXISTS idx_sets_exercise_id ON sets(exercise_id);

-- Routines indexes
CREATE INDEX IF NOT EXISTS idx_routines_user_id ON routines(user_id);

-- ============================================================================
-- ENABLE ROW LEVEL SECURITY
-- ============================================================================

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE workouts ENABLE ROW LEVEL SECURITY;
ALTER TABLE sets ENABLE ROW LEVEL SECURITY;
ALTER TABLE routines ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- RLS POLICIES
-- ============================================================================

-- Users table policies
DO $$ 
BEGIN
    DROP POLICY IF EXISTS "Users can view own profile" ON users;
    DROP POLICY IF EXISTS "Users can update own profile" ON users;
    DROP POLICY IF EXISTS "Users can insert own profile" ON users;

    CREATE POLICY "Users can view own profile"
        ON users FOR SELECT
        USING (auth.uid() = id);

    CREATE POLICY "Users can update own profile"
        ON users FOR UPDATE
        USING (auth.uid() = id);

    CREATE POLICY "Users can insert own profile"
        ON users FOR INSERT
        WITH CHECK (auth.uid() = id);
END $$;

-- Exercises table policies
DO $$ 
BEGIN
    DROP POLICY IF EXISTS "Users can view predefined and own exercises" ON exercises;
    DROP POLICY IF EXISTS "Users can insert own exercises" ON exercises;
    DROP POLICY IF EXISTS "Users can update own exercises" ON exercises;
    DROP POLICY IF EXISTS "Users can delete own exercises" ON exercises;

    CREATE POLICY "Users can view predefined and own exercises"
        ON exercises FOR SELECT
        USING (is_predefined = TRUE OR user_id = auth.uid());

    CREATE POLICY "Users can insert own exercises"
        ON exercises FOR INSERT
        WITH CHECK (user_id = auth.uid());

    CREATE POLICY "Users can update own exercises"
        ON exercises FOR UPDATE
        USING (user_id = auth.uid());

    CREATE POLICY "Users can delete own exercises"
        ON exercises FOR DELETE
        USING (user_id = auth.uid());
END $$;

-- Workouts table policies
DO $$ 
BEGIN
    DROP POLICY IF EXISTS "Users can view own workouts" ON workouts;
    DROP POLICY IF EXISTS "Users can insert own workouts" ON workouts;
    DROP POLICY IF EXISTS "Users can update own workouts" ON workouts;
    DROP POLICY IF EXISTS "Users can delete own workouts" ON workouts;

    CREATE POLICY "Users can view own workouts"
        ON workouts FOR SELECT
        USING (user_id = auth.uid());

    CREATE POLICY "Users can insert own workouts"
        ON workouts FOR INSERT
        WITH CHECK (user_id = auth.uid());

    CREATE POLICY "Users can update own workouts"
        ON workouts FOR UPDATE
        USING (user_id = auth.uid());

    CREATE POLICY "Users can delete own workouts"
        ON workouts FOR DELETE
        USING (user_id = auth.uid());
END $$;

-- Sets table policies
DO $$ 
BEGIN
    DROP POLICY IF EXISTS "Users can view own sets" ON sets;
    DROP POLICY IF EXISTS "Users can insert own sets" ON sets;
    DROP POLICY IF EXISTS "Users can update own sets" ON sets;
    DROP POLICY IF EXISTS "Users can delete own sets" ON sets;

    CREATE POLICY "Users can view own sets"
        ON sets FOR SELECT
        USING (
            workout_id IN (
                SELECT id FROM workouts WHERE user_id = auth.uid()
            )
        );

    CREATE POLICY "Users can insert own sets"
        ON sets FOR INSERT
        WITH CHECK (
            workout_id IN (
                SELECT id FROM workouts WHERE user_id = auth.uid()
            )
        );

    CREATE POLICY "Users can update own sets"
        ON sets FOR UPDATE
        USING (
            workout_id IN (
                SELECT id FROM workouts WHERE user_id = auth.uid()
            )
        );

    CREATE POLICY "Users can delete own sets"
        ON sets FOR DELETE
        USING (
            workout_id IN (
                SELECT id FROM workouts WHERE user_id = auth.uid()
            )
        );
END $$;

-- Routines table policies
DO $$ 
BEGIN
    DROP POLICY IF EXISTS "Users can view own routines" ON routines;
    DROP POLICY IF EXISTS "Users can insert own routines" ON routines;
    DROP POLICY IF EXISTS "Users can update own routines" ON routines;
    DROP POLICY IF EXISTS "Users can delete own routines" ON routines;

    CREATE POLICY "Users can view own routines"
        ON routines FOR SELECT
        USING (user_id = auth.uid());

    CREATE POLICY "Users can insert own routines"
        ON routines FOR INSERT
        WITH CHECK (user_id = auth.uid());

    CREATE POLICY "Users can update own routines"
        ON routines FOR UPDATE
        USING (user_id = auth.uid());

    CREATE POLICY "Users can delete own routines"
        ON routines FOR DELETE
        USING (user_id = auth.uid());
END $$;

-- ============================================================================
-- TRIGGERS FOR UPDATED_AT
-- ============================================================================

-- Function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply triggers
DROP TRIGGER IF EXISTS update_users_updated_at ON users;
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_workouts_updated_at ON workouts;
CREATE TRIGGER update_workouts_updated_at
    BEFORE UPDATE ON workouts
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_routines_updated_at ON routines;
CREATE TRIGGER update_routines_updated_at
    BEFORE UPDATE ON routines
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- SEED PREDEFINED EXERCISES
-- ============================================================================

-- Clear existing predefined exercises (optional - comment out if you want to keep existing)
-- DELETE FROM exercises WHERE is_predefined = TRUE;

-- CHEST EXERCISES
INSERT INTO exercises (name, category, description, target_muscles, is_predefined) VALUES
('Barbell Bench Press', 'Chest', 'Classic compound exercise for chest development', ARRAY['Chest', 'Triceps', 'Shoulders'], TRUE),
('Incline Barbell Bench Press', 'Chest', 'Targets upper chest with inclined bench angle', ARRAY['Upper Chest', 'Shoulders', 'Triceps'], TRUE),
('Decline Barbell Bench Press', 'Chest', 'Emphasizes lower chest development', ARRAY['Lower Chest', 'Triceps'], TRUE),
('Dumbbell Bench Press', 'Chest', 'Allows for greater range of motion than barbell', ARRAY['Chest', 'Triceps', 'Shoulders'], TRUE),
('Incline Dumbbell Press', 'Chest', 'Upper chest focus with dumbbells', ARRAY['Upper Chest', 'Shoulders'], TRUE),
('Dumbbell Flyes', 'Chest', 'Isolation exercise for chest stretch', ARRAY['Chest'], TRUE),
('Cable Crossover', 'Chest', 'Cable exercise for chest isolation', ARRAY['Chest'], TRUE),
('Push-up', 'Chest', 'Bodyweight chest exercise', ARRAY['Chest', 'Triceps', 'Core'], TRUE),
('Dips (Chest Focused)', 'Chest', 'Lean forward for chest emphasis', ARRAY['Lower Chest', 'Triceps'], TRUE);

-- BACK EXERCISES
INSERT INTO exercises (name, category, description, target_muscles, is_predefined) VALUES
('Deadlift', 'Back', 'King of compound exercises for posterior chain', ARRAY['Lower Back', 'Glutes', 'Hamstrings', 'Traps'], TRUE),
('Barbell Row', 'Back', 'Bent over barbell row for back thickness', ARRAY['Lats', 'Rhomboids', 'Traps'], TRUE),
('Pull-up', 'Back', 'Bodyweight back exercise for width', ARRAY['Lats', 'Biceps'], TRUE),
('Chin-up', 'Back', 'Underhand grip variation emphasizing biceps', ARRAY['Lats', 'Biceps'], TRUE),
('Lat Pulldown', 'Back', 'Cable exercise for lat development', ARRAY['Lats', 'Biceps'], TRUE),
('Seated Cable Row', 'Back', 'Cable rowing for mid-back', ARRAY['Lats', 'Rhomboids', 'Traps'], TRUE),
('T-Bar Row', 'Back', 'Compound rowing movement', ARRAY['Lats', 'Rhomboids'], TRUE),
('Dumbbell Row', 'Back', 'Single-arm rowing exercise', ARRAY['Lats', 'Rhomboids'], TRUE),
('Face Pull', 'Back', 'Cable exercise for rear delts and upper back', ARRAY['Rear Delts', 'Traps', 'Rhomboids'], TRUE);

-- SHOULDER EXERCISES
INSERT INTO exercises (name, category, description, target_muscles, is_predefined) VALUES
('Overhead Press', 'Shoulders', 'Barbell shoulder press standing or seated', ARRAY['Shoulders', 'Triceps'], TRUE),
('Dumbbell Shoulder Press', 'Shoulders', 'Seated or standing shoulder press with dumbbells', ARRAY['Shoulders', 'Triceps'], TRUE),
('Lateral Raise', 'Shoulders', 'Isolation for side delts', ARRAY['Side Delts'], TRUE),
('Front Raise', 'Shoulders', 'Isolation for front delts', ARRAY['Front Delts'], TRUE),
('Rear Delt Fly', 'Shoulders', 'Targets rear deltoids', ARRAY['Rear Delts'], TRUE),
('Arnold Press', 'Shoulders', 'Rotating dumbbell press for all delt heads', ARRAY['Shoulders'], TRUE),
('Upright Row', 'Shoulders', 'Compound movement for shoulders and traps', ARRAY['Shoulders', 'Traps'], TRUE);

-- LEG EXERCISES
INSERT INTO exercises (name, category, description, target_muscles, is_predefined) VALUES
('Barbell Squat', 'Legs', 'King of leg exercises', ARRAY['Quadriceps', 'Glutes', 'Hamstrings'], TRUE),
('Front Squat', 'Legs', 'Quad-focused squat variation', ARRAY['Quadriceps', 'Core'], TRUE),
('Leg Press', 'Legs', 'Machine exercise for overall leg development', ARRAY['Quadriceps', 'Glutes', 'Hamstrings'], TRUE),
('Romanian Deadlift', 'Legs', 'Hamstring and glute focus', ARRAY['Hamstrings', 'Glutes'], TRUE),
('Leg Curl', 'Legs', 'Isolation for hamstrings', ARRAY['Hamstrings'], TRUE),
('Leg Extension', 'Legs', 'Isolation for quadriceps', ARRAY['Quadriceps'], TRUE),
('Bulgarian Split Squat', 'Legs', 'Single-leg exercise for quads and glutes', ARRAY['Quadriceps', 'Glutes'], TRUE),
('Lunges', 'Legs', 'Walking or stationary lunges', ARRAY['Quadriceps', 'Glutes'], TRUE),
('Calf Raise', 'Legs', 'Standing or seated calf raises', ARRAY['Calves'], TRUE),
('Hip Thrust', 'Legs', 'Glute-focused exercise', ARRAY['Glutes'], TRUE);

-- ARM EXERCISES
INSERT INTO exercises (name, category, description, target_muscles, is_predefined) VALUES
('Barbell Curl', 'Arms', 'Classic bicep exercise', ARRAY['Biceps'], TRUE),
('Dumbbell Curl', 'Arms', 'Alternating or simultaneous bicep curls', ARRAY['Biceps'], TRUE),
('Hammer Curl', 'Arms', 'Neutral grip for biceps and brachialis', ARRAY['Biceps', 'Brachialis'], TRUE),
('Preacher Curl', 'Arms', 'Isolated bicep curl on preacher bench', ARRAY['Biceps'], TRUE),
('Close-Grip Bench Press', 'Arms', 'Compound tricep exercise', ARRAY['Triceps', 'Chest'], TRUE),
('Tricep Pushdown', 'Arms', 'Cable exercise for triceps', ARRAY['Triceps'], TRUE),
('Overhead Tricep Extension', 'Arms', 'Stretches triceps for growth', ARRAY['Triceps'], TRUE),
('Skull Crusher', 'Arms', 'Lying tricep extension', ARRAY['Triceps'], TRUE),
('Dips (Tricep Focused)', 'Arms', 'Bodyweight exercise for triceps', ARRAY['Triceps'], TRUE);

-- CORE EXERCISES
INSERT INTO exercises (name, category, description, target_muscles, is_predefined) VALUES
('Plank', 'Core', 'Isometric core exercise', ARRAY['Core', 'Abs'], TRUE),
('Crunch', 'Core', 'Basic abdominal exercise', ARRAY['Abs'], TRUE),
('Bicycle Crunch', 'Core', 'Dynamic ab exercise', ARRAY['Abs', 'Obliques'], TRUE),
('Russian Twist', 'Core', 'Rotational core exercise', ARRAY['Obliques', 'Abs'], TRUE),
('Leg Raise', 'Core', 'Lower ab focus', ARRAY['Lower Abs'], TRUE),
('Mountain Climber', 'Core', 'Dynamic core and cardio', ARRAY['Core', 'Hip Flexors'], TRUE),
('Ab Wheel Rollout', 'Core', 'Advanced core exercise', ARRAY['Core', 'Abs'], TRUE),
('Dead Bug', 'Core', 'Anti-extension core exercise', ARRAY['Core', 'Abs'], TRUE);

-- CARDIO EXERCISES
INSERT INTO exercises (name, category, description, target_muscles, is_predefined) VALUES
('Treadmill Running', 'Cardio', 'Indoor running exercise', ARRAY['Legs', 'Cardiovascular'], TRUE),
('Stationary Bike', 'Cardio', 'Low-impact cardio', ARRAY['Legs', 'Cardiovascular'], TRUE),
('Rowing Machine', 'Cardio', 'Full-body cardio workout', ARRAY['Full Body', 'Cardiovascular'], TRUE),
('Elliptical', 'Cardio', 'Low-impact cardio machine', ARRAY['Legs', 'Cardiovascular'], TRUE),
('Jump Rope', 'Cardio', 'High-intensity cardio', ARRAY['Calves', 'Cardiovascular'], TRUE),
('Burpees', 'Cardio', 'Full-body cardio exercise', ARRAY['Full Body', 'Cardiovascular'], TRUE);

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Verify the count
SELECT category, COUNT(*) as exercise_count 
FROM exercises 
WHERE is_predefined = TRUE 
GROUP BY category 
ORDER BY category;

-- Show total count
SELECT COUNT(*) as total_predefined_exercises 
FROM exercises 
WHERE is_predefined = TRUE;

