-- ============================================================================
-- ADD ISOMETRIC EXERCISE SUPPORT
-- ============================================================================
-- This script adds support for isometric exercises (static holds)
-- Run this if you have an existing database and want to add isometric exercises

-- Step 1: Update exercise_type CHECK constraint to include isometric
ALTER TABLE exercises
DROP CONSTRAINT IF EXISTS exercises_exercise_type_check;

ALTER TABLE exercises
ADD CONSTRAINT exercises_exercise_type_check 
CHECK (exercise_type IN ('strength', 'cardio', 'isometric'));

-- Step 2: Update comment to reflect new exercise type
COMMENT ON COLUMN exercises.exercise_type IS 'Type of exercise: strength, cardio, or isometric';
COMMENT ON COLUMN sets.duration IS 'Duration in seconds (for cardio exercises) or hold time (for isometric exercises)';

-- Step 3: Add predefined isometric exercises
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
ON CONFLICT (name) DO UPDATE SET
    exercise_type = EXCLUDED.exercise_type,
    description = EXCLUDED.description,
    target_muscles = EXCLUDED.target_muscles;

-- Step 4: Verification queries
SELECT '=== Isometric Exercises Added ===' as section;
SELECT name, description, target_muscles
FROM exercises
WHERE exercise_type = 'isometric' AND is_predefined = TRUE
ORDER BY name;

SELECT '' as spacing;

SELECT '=== Exercise Type Summary ===' as section;
SELECT 
    exercise_type,
    COUNT(*) as count
FROM exercises
WHERE is_predefined = TRUE
GROUP BY exercise_type
ORDER BY exercise_type;

SELECT '' as spacing;

SELECT '✅ Isometric support successfully added!' as status;
SELECT 'Total predefined isometric exercises: ' || COUNT(*)::TEXT as summary
FROM exercises
WHERE exercise_type = 'isometric' AND is_predefined = TRUE;

