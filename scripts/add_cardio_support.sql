-- ============================================================================
-- ADD CARDIO EXERCISE SUPPORT
-- ============================================================================
-- This script adds support for cardio exercises with Strava-like attributes:
-- - Distance, Duration, Pace, Heart Rate, Calories, Elevation Gain

-- Step 1: Add exercise_type column to exercises table
ALTER TABLE exercises
ADD COLUMN IF NOT EXISTS exercise_type TEXT DEFAULT 'strength'
CHECK (exercise_type IN ('strength', 'cardio'));

-- Update existing exercises to be 'strength' type
UPDATE exercises
SET exercise_type = 'strength'
WHERE exercise_type IS NULL;

-- Step 2: Make strength-specific columns nullable in sets table
ALTER TABLE sets
ALTER COLUMN reps DROP NOT NULL,
ALTER COLUMN weight DROP NOT NULL;

-- Step 3: Add cardio-specific columns to sets table
ALTER TABLE sets
ADD COLUMN IF NOT EXISTS distance DOUBLE PRECISION,
ADD COLUMN IF NOT EXISTS duration INTEGER,
ADD COLUMN IF NOT EXISTS pace DOUBLE PRECISION,
ADD COLUMN IF NOT EXISTS heart_rate INTEGER,
ADD COLUMN IF NOT EXISTS calories INTEGER,
ADD COLUMN IF NOT EXISTS elevation_gain DOUBLE PRECISION;

-- Step 4: Add comments for documentation
COMMENT ON COLUMN exercises.exercise_type IS 'Type of exercise: strength or cardio';
COMMENT ON COLUMN sets.reps IS 'Number of repetitions (for strength exercises)';
COMMENT ON COLUMN sets.weight IS 'Weight in kg or lbs (for strength exercises)';
COMMENT ON COLUMN sets.distance IS 'Distance in km or miles (for cardio exercises)';
COMMENT ON COLUMN sets.duration IS 'Duration in seconds (for cardio exercises)';
COMMENT ON COLUMN sets.pace IS 'Pace in min/km or min/mile (for cardio exercises)';
COMMENT ON COLUMN sets.heart_rate IS 'Average heart rate in bpm (for cardio exercises)';
COMMENT ON COLUMN sets.calories IS 'Calories burned (for cardio exercises)';
COMMENT ON COLUMN sets.elevation_gain IS 'Elevation gain in meters or feet (for cardio exercises)';

-- Step 5: Create index on exercise_type for better query performance
CREATE INDEX IF NOT EXISTS idx_exercises_exercise_type ON exercises(exercise_type);

-- Step 6: Add some predefined cardio exercises
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
ON CONFLICT (name) DO UPDATE SET
  exercise_type = EXCLUDED.exercise_type,
  description = EXCLUDED.description;

-- Step 7: Verification queries
SELECT '=== Exercise Types ===' as section;
SELECT exercise_type, COUNT(*) as count
FROM exercises
WHERE is_predefined = TRUE
GROUP BY exercise_type
ORDER BY exercise_type;

SELECT '=== Sample Cardio Exercises ===' as section;
SELECT name, category, exercise_type, description
FROM exercises
WHERE exercise_type = 'cardio' AND is_predefined = TRUE
ORDER BY name
LIMIT 10;

SELECT '=== Sets Table Structure ===' as section;
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'sets' AND table_schema = 'public'
ORDER BY ordinal_position;

SELECT '✅ Cardio support successfully added!' as status;

