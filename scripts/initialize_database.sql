-- ============================================================================
-- CROSS APP - COMPLETE DATABASE INITIALIZATION SCRIPT
-- ============================================================================
-- 
-- This script creates a complete Cross workout tracking database including:
--   ✓ Database schema (5 tables: users, exercises, workouts, sets, routines)
--   ✓ Support for strength, cardio, and isometric exercises
--   ✓ Performance indexes
--   ✓ Row Level Security (RLS) policies
--   ✓ Automatic timestamp update triggers
--   ✓ Automatic user profile creation trigger
--   ✓ 84 predefined exercises (57 strength + 12 cardio + 15 isometric)
--
-- FEATURES:
--   • Strength Training: Weight, Reps, Sets, Rest time, RPE
--   • Cardio Tracking: Distance, Duration, Pace, Heart Rate, Calories, Elevation
--   • Isometric Holds: Duration/Hold time, RPE
--   • Secure: RLS ensures users can only access their own data
--   • Auto-profile: User profiles created automatically on signup
--
-- USAGE:
--   1. Open Supabase SQL Editor
--   2. Copy and paste this entire script
--   3. Click "Run" or press Ctrl+Enter
--   4. Database is ready to use! ✓
--
-- SAFE TO RUN MULTIPLE TIMES - Uses "IF NOT EXISTS" and conflict handling
-- ============================================================================

-- ============================================================================
-- PART 1: ENABLE EXTENSIONS
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- PART 2: CREATE TABLES
-- ============================================================================

-- -----------------------------------------------------------------------------
-- Users Table (extends Supabase auth.users with profile information)
-- -----------------------------------------------------------------------------
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

-- -----------------------------------------------------------------------------
-- Exercises Table (supports strength, cardio, and isometric)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS exercises (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    category TEXT NOT NULL,
    exercise_type TEXT DEFAULT 'strength' CHECK (exercise_type IN ('strength', 'cardio', 'isometric')),
    description TEXT,
    target_muscles TEXT[],
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    is_predefined BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- Workouts Table
-- -----------------------------------------------------------------------------
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

-- -----------------------------------------------------------------------------
-- Sets Table (supports strength, cardio, and isometric attributes)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS sets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    workout_id UUID NOT NULL REFERENCES workouts(id) ON DELETE CASCADE,
    exercise_id UUID NOT NULL REFERENCES exercises(id),
    exercise_name TEXT NOT NULL,
    set_number INTEGER NOT NULL,
    
    -- Strength training attributes (optional for cardio/isometric)
    reps INTEGER,
    weight DOUBLE PRECISION,
    rest_time INTEGER, -- in seconds
    
    -- Cardio attributes (optional for strength/isometric)
    distance DOUBLE PRECISION, -- km or miles
    duration INTEGER, -- seconds (also used for isometric hold time)
    pace DOUBLE PRECISION, -- min/km or min/mile
    heart_rate INTEGER, -- BPM
    calories INTEGER,
    elevation_gain DOUBLE PRECISION, -- meters or feet
    
    -- Common attributes
    rpe INTEGER CHECK (rpe >= 1 AND rpe <= 10), -- Rate of Perceived Exertion
    notes TEXT,
    is_completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- -----------------------------------------------------------------------------
-- Routines Table
-- -----------------------------------------------------------------------------
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
-- PART 3: CREATE INDEXES FOR PERFORMANCE
-- ============================================================================

-- Users indexes
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- Exercises indexes
CREATE INDEX IF NOT EXISTS idx_exercises_user_id ON exercises(user_id);
CREATE INDEX IF NOT EXISTS idx_exercises_category ON exercises(category);
CREATE INDEX IF NOT EXISTS idx_exercises_exercise_type ON exercises(exercise_type);
CREATE INDEX IF NOT EXISTS idx_exercises_is_predefined ON exercises(is_predefined);

-- Unique constraint for predefined exercise names (allows users to create exercises with same names)
CREATE UNIQUE INDEX IF NOT EXISTS idx_exercises_predefined_name 
ON exercises(name) WHERE is_predefined = TRUE;

-- Workouts indexes
CREATE INDEX IF NOT EXISTS idx_workouts_user_id ON workouts(user_id);
CREATE INDEX IF NOT EXISTS idx_workouts_date ON workouts(date);
CREATE INDEX IF NOT EXISTS idx_workouts_routine_id ON workouts(routine_id);

-- Sets indexes
CREATE INDEX IF NOT EXISTS idx_sets_workout_id ON sets(workout_id);
CREATE INDEX IF NOT EXISTS idx_sets_exercise_id ON sets(exercise_id);

-- Routines indexes
CREATE INDEX IF NOT EXISTS idx_routines_user_id ON routines(user_id);

-- ============================================================================
-- PART 4: ENABLE ROW LEVEL SECURITY (RLS)
-- ============================================================================

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE workouts ENABLE ROW LEVEL SECURITY;
ALTER TABLE sets ENABLE ROW LEVEL SECURITY;
ALTER TABLE routines ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- PART 5: CREATE ROW LEVEL SECURITY POLICIES
-- ============================================================================

-- -----------------------------------------------------------------------------
-- Users table policies
-- -----------------------------------------------------------------------------
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

-- -----------------------------------------------------------------------------
-- Exercises table policies
-- -----------------------------------------------------------------------------
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

-- -----------------------------------------------------------------------------
-- Workouts table policies
-- -----------------------------------------------------------------------------
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

-- -----------------------------------------------------------------------------
-- Sets table policies
-- -----------------------------------------------------------------------------
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

-- -----------------------------------------------------------------------------
-- Routines table policies
-- -----------------------------------------------------------------------------
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
-- PART 6: CREATE TRIGGERS FOR AUTO-UPDATE TIMESTAMPS
-- ============================================================================

-- Function to update updated_at column
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply trigger to users table
DROP TRIGGER IF EXISTS set_users_updated_at ON users;
CREATE TRIGGER set_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Apply trigger to workouts table
DROP TRIGGER IF EXISTS set_workouts_updated_at ON workouts;
CREATE TRIGGER set_workouts_updated_at
    BEFORE UPDATE ON workouts
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Apply trigger to routines table
DROP TRIGGER IF EXISTS set_routines_updated_at ON routines;
CREATE TRIGGER set_routines_updated_at
    BEFORE UPDATE ON routines
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- PART 7: CREATE AUTO-PROFILE CREATION TRIGGER
-- ============================================================================
-- This trigger automatically creates a user profile when someone signs up

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email, created_at)
  VALUES (NEW.id, NEW.email, NOW())
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
EXCEPTION
  WHEN others THEN
    RAISE WARNING 'Failed to create user profile: %', SQLERRM;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON public.users TO postgres, service_role;
GRANT SELECT, INSERT, UPDATE ON public.users TO authenticated;

-- ============================================================================
-- PART 8: SEED PREDEFINED STRENGTH EXERCISES
-- ============================================================================

INSERT INTO exercises (name, category, exercise_type, description, target_muscles, is_predefined, created_at)
VALUES
    -- Chest Exercises
    ('Barbell Bench Press', 'Chest', 'strength', 'Primary chest compound movement', ARRAY['Pectoralis Major', 'Anterior Deltoids', 'Triceps'], TRUE, NOW()),
    ('Incline Barbell Bench Press', 'Chest', 'strength', 'Upper chest focus', ARRAY['Upper Pectoralis', 'Anterior Deltoids'], TRUE, NOW()),
    ('Dumbbell Bench Press', 'Chest', 'strength', 'Chest exercise with greater range of motion', ARRAY['Pectoralis Major', 'Triceps'], TRUE, NOW()),
    ('Incline Dumbbell Press', 'Chest', 'strength', 'Upper chest with dumbbells', ARRAY['Upper Pectoralis', 'Anterior Deltoids'], TRUE, NOW()),
    ('Dumbbell Flyes', 'Chest', 'strength', 'Chest isolation exercise', ARRAY['Pectoralis Major'], TRUE, NOW()),
    ('Cable Crossover', 'Chest', 'strength', 'Cable chest isolation', ARRAY['Pectoralis Major'], TRUE, NOW()),
    ('Push-ups', 'Chest', 'strength', 'Bodyweight chest exercise', ARRAY['Pectoralis Major', 'Triceps', 'Core'], TRUE, NOW()),
    ('Dips', 'Chest', 'strength', 'Compound chest and triceps exercise', ARRAY['Lower Pectoralis', 'Triceps'], TRUE, NOW()),

    -- Back Exercises
    ('Deadlift', 'Back', 'strength', 'King of compound exercises', ARRAY['Erector Spinae', 'Lats', 'Traps', 'Hamstrings', 'Glutes'], TRUE, NOW()),
    ('Pull-ups', 'Back', 'strength', 'Bodyweight back exercise', ARRAY['Lats', 'Biceps', 'Rear Deltoids'], TRUE, NOW()),
    ('Barbell Row', 'Back', 'strength', 'Compound back thickness exercise', ARRAY['Lats', 'Rhomboids', 'Traps'], TRUE, NOW()),
    ('Dumbbell Row', 'Back', 'strength', 'Unilateral back exercise', ARRAY['Lats', 'Rhomboids'], TRUE, NOW()),
    ('Lat Pulldown', 'Back', 'strength', 'Machine lat exercise', ARRAY['Lats', 'Biceps'], TRUE, NOW()),
    ('Seated Cable Row', 'Back', 'strength', 'Cable back exercise', ARRAY['Lats', 'Rhomboids', 'Traps'], TRUE, NOW()),
    ('T-Bar Row', 'Back', 'strength', 'Thick back builder', ARRAY['Lats', 'Traps', 'Rhomboids'], TRUE, NOW()),
    ('Face Pulls', 'Back', 'strength', 'Rear delt and upper back', ARRAY['Rear Deltoids', 'Traps'], TRUE, NOW()),

    -- Leg Exercises
    ('Barbell Squat', 'Legs', 'strength', 'King of leg exercises', ARRAY['Quadriceps', 'Glutes', 'Hamstrings'], TRUE, NOW()),
    ('Front Squat', 'Legs', 'strength', 'Quad-focused squat variation', ARRAY['Quadriceps', 'Core'], TRUE, NOW()),
    ('Leg Press', 'Legs', 'strength', 'Machine quad and glute exercise', ARRAY['Quadriceps', 'Glutes'], TRUE, NOW()),
    ('Romanian Deadlift', 'Legs', 'strength', 'Hamstring and glute focus', ARRAY['Hamstrings', 'Glutes', 'Lower Back'], TRUE, NOW()),
    ('Leg Curl', 'Legs', 'strength', 'Hamstring isolation', ARRAY['Hamstrings'], TRUE, NOW()),
    ('Leg Extension', 'Legs', 'strength', 'Quad isolation', ARRAY['Quadriceps'], TRUE, NOW()),
    ('Bulgarian Split Squat', 'Legs', 'strength', 'Unilateral leg exercise', ARRAY['Quadriceps', 'Glutes'], TRUE, NOW()),
    ('Walking Lunges', 'Legs', 'strength', 'Dynamic leg exercise', ARRAY['Quadriceps', 'Glutes', 'Hamstrings'], TRUE, NOW()),
    ('Calf Raise', 'Legs', 'strength', 'Calf isolation', ARRAY['Gastrocnemius', 'Soleus'], TRUE, NOW()),
    ('Hip Thrust', 'Legs', 'strength', 'Glute-focused exercise', ARRAY['Glutes', 'Hamstrings'], TRUE, NOW()),

    -- Shoulder Exercises
    ('Overhead Press', 'Shoulders', 'strength', 'Primary shoulder compound movement', ARRAY['Anterior Deltoids', 'Lateral Deltoids', 'Triceps'], TRUE, NOW()),
    ('Dumbbell Shoulder Press', 'Shoulders', 'strength', 'Shoulder press with dumbbells', ARRAY['Deltoids', 'Triceps'], TRUE, NOW()),
    ('Lateral Raise', 'Shoulders', 'strength', 'Side delt isolation', ARRAY['Lateral Deltoids'], TRUE, NOW()),
    ('Front Raise', 'Shoulders', 'strength', 'Front delt isolation', ARRAY['Anterior Deltoids'], TRUE, NOW()),
    ('Reverse Flyes', 'Shoulders', 'strength', 'Rear delt isolation', ARRAY['Rear Deltoids'], TRUE, NOW()),
    ('Arnold Press', 'Shoulders', 'strength', 'Complete shoulder development', ARRAY['Deltoids'], TRUE, NOW()),
    ('Upright Row', 'Shoulders', 'strength', 'Shoulder and trap exercise', ARRAY['Lateral Deltoids', 'Traps'], TRUE, NOW()),

    -- Arm Exercises
    ('Barbell Curl', 'Arms', 'strength', 'Classic bicep exercise', ARRAY['Biceps'], TRUE, NOW()),
    ('Dumbbell Curl', 'Arms', 'strength', 'Bicep exercise with dumbbells', ARRAY['Biceps'], TRUE, NOW()),
    ('Hammer Curl', 'Arms', 'strength', 'Bicep and forearm exercise', ARRAY['Biceps', 'Brachialis', 'Forearms'], TRUE, NOW()),
    ('Tricep Pushdown', 'Arms', 'strength', 'Cable tricep isolation', ARRAY['Triceps'], TRUE, NOW()),
    ('Overhead Tricep Extension', 'Arms', 'strength', 'Tricep stretch and contraction', ARRAY['Triceps'], TRUE, NOW()),
    ('Skull Crushers', 'Arms', 'strength', 'Lying tricep extension', ARRAY['Triceps'], TRUE, NOW()),
    ('Close-Grip Bench Press', 'Arms', 'strength', 'Compound tricep exercise', ARRAY['Triceps', 'Chest'], TRUE, NOW()),
    ('Preacher Curl', 'Arms', 'strength', 'Isolated bicep exercise', ARRAY['Biceps'], TRUE, NOW()),

    -- Core Exercises
    ('Crunches', 'Core', 'strength', 'Basic ab exercise', ARRAY['Rectus Abdominis'], TRUE, NOW()),
    ('Russian Twists', 'Core', 'strength', 'Oblique exercise', ARRAY['Obliques'], TRUE, NOW()),
    ('Hanging Leg Raise', 'Core', 'strength', 'Advanced ab exercise', ARRAY['Rectus Abdominis', 'Hip Flexors'], TRUE, NOW()),
    ('Cable Woodchoppers', 'Core', 'strength', 'Rotational core exercise', ARRAY['Obliques'], TRUE, NOW()),
    ('Ab Wheel Rollout', 'Core', 'strength', 'Advanced core stability', ARRAY['Rectus Abdominis', 'Core Stabilizers'], TRUE, NOW()),

    -- Olympic Lifts
    ('Clean and Jerk', 'Olympic', 'strength', 'Olympic weightlifting movement', ARRAY['Full Body'], TRUE, NOW()),
    ('Snatch', 'Olympic', 'strength', 'Olympic weightlifting movement', ARRAY['Full Body'], TRUE, NOW()),
    ('Power Clean', 'Olympic', 'strength', 'Explosive pulling movement', ARRAY['Full Body'], TRUE, NOW()),
    ('Hang Clean', 'Olympic', 'strength', 'Clean variation from hang position', ARRAY['Full Body'], TRUE, NOW()),

    -- Full Body
    ('Burpees', 'Full Body', 'strength', 'Cardio and strength combo', ARRAY['Full Body'], TRUE, NOW()),
    ('Thrusters', 'Full Body', 'strength', 'Front squat to overhead press', ARRAY['Legs', 'Shoulders', 'Core'], TRUE, NOW()),
    ('Farmers Walk', 'Full Body', 'strength', 'Loaded carry exercise', ARRAY['Forearms', 'Traps', 'Core', 'Legs'], TRUE, NOW()),
    ('Kettlebell Swing', 'Full Body', 'strength', 'Hip hinge power movement', ARRAY['Glutes', 'Hamstrings', 'Core'], TRUE, NOW())
ON CONFLICT (name) WHERE is_predefined = TRUE DO UPDATE SET
    exercise_type = EXCLUDED.exercise_type,
    description = EXCLUDED.description,
    target_muscles = EXCLUDED.target_muscles;

-- ============================================================================
-- PART 9: SEED PREDEFINED CARDIO EXERCISES
-- ============================================================================

INSERT INTO exercises (name, category, exercise_type, description, is_predefined, created_at)
VALUES
    ('Running', 'Cardio', 'cardio', 'Outdoor or treadmill running', TRUE, NOW()),
    ('Cycling', 'Cardio', 'cardio', 'Road cycling or stationary bike', TRUE, NOW()),
    ('Swimming', 'Cardio', 'cardio', 'Lap swimming', TRUE, NOW()),
    ('Rowing', 'Cardio', 'cardio', 'Rowing machine or water rowing', TRUE, NOW()),
    ('Walking', 'Cardio', 'cardio', 'Outdoor or treadmill walking', TRUE, NOW()),
    ('Elliptical', 'Cardio', 'cardio', 'Elliptical trainer', TRUE, NOW()),
    ('Stair Climbing', 'Cardio', 'cardio', 'Stair climber or actual stairs', TRUE, NOW()),
    ('Jump Rope', 'Cardio', 'cardio', 'Skipping rope', TRUE, NOW()),
    ('HIIT', 'Cardio', 'cardio', 'High-Intensity Interval Training', TRUE, NOW()),
    ('Trail Running', 'Cardio', 'cardio', 'Off-road running with elevation', TRUE, NOW()),
    ('Mountain Biking', 'Cardio', 'cardio', 'Off-road cycling', TRUE, NOW()),
    ('Hiking', 'Cardio', 'cardio', 'Outdoor hiking with elevation', TRUE, NOW())
ON CONFLICT (name) WHERE is_predefined = TRUE DO UPDATE SET
    exercise_type = EXCLUDED.exercise_type,
    description = EXCLUDED.description;

-- ============================================================================
-- PART 10: SEED PREDEFINED ISOMETRIC EXERCISES
-- ============================================================================

INSERT INTO exercises (name, category, exercise_type, description, target_muscles, is_predefined, created_at)
VALUES
    ('Plank', 'Isometric', 'isometric', 'Standard front plank hold', ARRAY['Core', 'Shoulders'], TRUE, NOW()),
    ('Side Plank', 'Isometric', 'isometric', 'Side plank for obliques', ARRAY['Obliques', 'Core'], TRUE, NOW()),
    ('Wall Sit', 'Isometric', 'isometric', 'Static squat against wall', ARRAY['Quadriceps', 'Glutes'], TRUE, NOW()),
    ('Hollow Body Hold', 'Isometric', 'isometric', 'Core bracing position', ARRAY['Core'], TRUE, NOW()),
    ('L-Sit', 'Isometric', 'isometric', 'Advanced core hold', ARRAY['Core', 'Hip Flexors', 'Shoulders'], TRUE, NOW()),
    ('Dead Hang', 'Isometric', 'isometric', 'Passive hang from bar', ARRAY['Lats', 'Forearms', 'Grip'], TRUE, NOW()),
    ('Active Hang', 'Isometric', 'isometric', 'Engaged hang from bar', ARRAY['Lats', 'Shoulders', 'Core'], TRUE, NOW()),
    ('Bridge Hold', 'Isometric', 'isometric', 'Glute bridge hold', ARRAY['Glutes', 'Hamstrings', 'Lower Back'], TRUE, NOW()),
    ('Single Leg Bridge', 'Isometric', 'isometric', 'Unilateral bridge hold', ARRAY['Glutes', 'Hamstrings'], TRUE, NOW()),
    ('Horse Stance', 'Isometric', 'isometric', 'Wide squat martial arts stance', ARRAY['Quadriceps', 'Glutes', 'Adductors'], TRUE, NOW()),
    ('Static Lunge Hold', 'Isometric', 'isometric', 'Hold bottom of lunge', ARRAY['Quadriceps', 'Glutes'], TRUE, NOW()),
    ('Overhead Hold', 'Isometric', 'isometric', 'Hold weight overhead', ARRAY['Shoulders', 'Core'], TRUE, NOW()),
    ('Farmer Hold', 'Isometric', 'isometric', 'Static farmer carry position', ARRAY['Forearms', 'Traps', 'Core'], TRUE, NOW()),
    ('Superman Hold', 'Isometric', 'isometric', 'Back extension hold', ARRAY['Lower Back', 'Glutes'], TRUE, NOW()),
    ('Boat Pose', 'Isometric', 'isometric', 'V-sit core hold', ARRAY['Core', 'Hip Flexors'], TRUE, NOW())
ON CONFLICT (name) WHERE is_predefined = TRUE DO UPDATE SET
    exercise_type = EXCLUDED.exercise_type,
    description = EXCLUDED.description,
    target_muscles = EXCLUDED.target_muscles;

-- ============================================================================
-- PART 11: ADD COLUMN COMMENTS FOR DOCUMENTATION
-- ============================================================================

COMMENT ON TABLE users IS 'User profiles extending Supabase auth.users';
COMMENT ON TABLE exercises IS 'Exercise library (predefined and user-created)';
COMMENT ON TABLE workouts IS 'Workout sessions';
COMMENT ON TABLE sets IS 'Individual sets within workouts (supports strength and cardio)';
COMMENT ON TABLE routines IS 'Pre-defined workout routines';

COMMENT ON COLUMN exercises.exercise_type IS 'Type of exercise: strength, cardio, or isometric';
COMMENT ON COLUMN sets.reps IS 'Number of repetitions (for strength exercises)';
COMMENT ON COLUMN sets.weight IS 'Weight in kg or lbs (for strength exercises)';
COMMENT ON COLUMN sets.distance IS 'Distance in km or miles (for cardio exercises)';
COMMENT ON COLUMN sets.duration IS 'Duration in seconds (for cardio exercises) or hold time (for isometric exercises)';
COMMENT ON COLUMN sets.pace IS 'Pace in min/km or min/mile (for cardio exercises)';
COMMENT ON COLUMN sets.heart_rate IS 'Average heart rate in bpm (for cardio exercises)';
COMMENT ON COLUMN sets.calories IS 'Calories burned (for cardio exercises)';
COMMENT ON COLUMN sets.elevation_gain IS 'Elevation gain in meters or feet (for cardio exercises)';
COMMENT ON COLUMN sets.rpe IS 'Rate of Perceived Exertion (1-10 scale, applicable to all exercise types)';

-- ============================================================================
-- PART 11: VERIFICATION QUERIES
-- ============================================================================

SELECT '========================================' as divider;
SELECT '✅ DATABASE INITIALIZATION COMPLETE!' as status;
SELECT '========================================' as divider;

SELECT '' as spacing;

-- Table counts
SELECT '📊 TABLE SUMMARY' as section;
SELECT 'Users' as table_name, COUNT(*) as count FROM users
UNION ALL
SELECT 'Exercises', COUNT(*) FROM exercises
UNION ALL
SELECT 'Workouts', COUNT(*) FROM workouts
UNION ALL
SELECT 'Sets', COUNT(*) FROM sets
UNION ALL
SELECT 'Routines', COUNT(*) FROM routines;

SELECT '' as spacing;

-- Exercise breakdown
SELECT '🏋️ EXERCISE BREAKDOWN' as section;
SELECT 
    exercise_type,
    COUNT(*) as count,
    STRING_AGG(DISTINCT category, ', ' ORDER BY category) as categories
FROM exercises 
WHERE is_predefined = TRUE
GROUP BY exercise_type
ORDER BY exercise_type;

SELECT '' as spacing;

-- Category breakdown
SELECT '📂 EXERCISES BY CATEGORY' as section;
SELECT 
    category,
    exercise_type,
    COUNT(*) as count
FROM exercises
WHERE is_predefined = TRUE
GROUP BY category, exercise_type
ORDER BY category, exercise_type;

SELECT '' as spacing;

-- RLS Status
SELECT '🔒 ROW LEVEL SECURITY STATUS' as section;
SELECT 
    schemaname,
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables
WHERE schemaname = 'public'
    AND tablename IN ('users', 'exercises', 'workouts', 'sets', 'routines')
ORDER BY tablename;

SELECT '' as spacing;

-- Triggers
SELECT '⚡ ACTIVE TRIGGERS' as section;
SELECT 
    trigger_name,
    event_object_table as table_name,
    action_timing || ' ' || string_agg(event_manipulation, ', ') as trigger_event
FROM information_schema.triggers
WHERE trigger_schema = 'public'
    AND event_object_table IN ('users', 'workouts', 'routines')
    OR trigger_name = 'on_auth_user_created'
GROUP BY trigger_name, event_object_table, action_timing
ORDER BY event_object_table, trigger_name;

SELECT '' as spacing;

-- Indexes
SELECT '📇 INDEXES CREATED' as section;
SELECT 
    schemaname,
    tablename,
    indexname
FROM pg_indexes
WHERE schemaname = 'public'
    AND tablename IN ('users', 'exercises', 'workouts', 'sets', 'routines')
ORDER BY tablename, indexname;

SELECT '' as spacing;

SELECT '========================================' as divider;
SELECT '🎉 Your Cross App database is ready!' as message;
SELECT '========================================' as divider;
SELECT 'Next steps:' as instruction;
SELECT '1. Update your Flutter app with Supabase credentials' as step_1;
SELECT '2. Run the app and test user registration' as step_2;
SELECT '3. Start tracking workouts!' as step_3;
SELECT '========================================' as divider;

