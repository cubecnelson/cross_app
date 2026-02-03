-- Migration: Add video and tutorial URLs to exercises
-- Date: 2026-02-03
-- Description: Adds video_url and tutorial_url fields to exercises table for P2-004 feature

-- Add video_url and tutorial_url columns to exercises table
ALTER TABLE exercises
ADD COLUMN IF NOT EXISTS video_url text,
ADD COLUMN IF NOT EXISTS tutorial_url text;

-- Add index for faster queries on video_url (for filtering exercises with videos)
CREATE INDEX IF NOT EXISTS idx_exercises_video_url ON exercises (video_url) WHERE video_url IS NOT NULL;

-- Add index for faster queries on tutorial_url (for filtering exercises with tutorials)
CREATE INDEX IF NOT EXISTS idx_exercises_tutorial_url ON exercises (tutorial_url) WHERE tutorial_url IS NOT NULL;

-- Add comments for documentation
COMMENT ON COLUMN exercises.video_url IS 'URL to demonstration video for this exercise (YouTube, Vimeo, etc.)';
COMMENT ON COLUMN exercises.tutorial_url IS 'URL to detailed tutorial/article for this exercise';

-- Update existing predefined exercises with placeholder video URLs
-- Note: These are example YouTube video IDs for demonstration purposes
-- In production, these would be replaced with actual exercise tutorial videos

-- Chest exercises
UPDATE exercises 
SET video_url = 'https://www.youtube.com/watch?v=rT7DgCr-3pg',
    tutorial_url = 'https://www.artofmanliness.com/health-fitness/fitness/how-to-bench-press/'
WHERE name = 'Barbell Bench Press' AND is_predefined = TRUE;

UPDATE exercises 
SET video_url = 'https://www.youtube.com/watch?v=0bWRPC49-KI',
    tutorial_url = 'https://www.muscleandstrength.com/exercises/incline-bench-press.html'
WHERE name = 'Incline Barbell Bench Press' AND is_predefined = TRUE;

UPDATE exercises 
SET video_url = 'https://www.youtube.com/watch?v=Sm1qzuQp09w',
    tutorial_url = 'https://www.muscleandstrength.com/exercises/flat-dumbbell-press.html'
WHERE name = 'Dumbbell Bench Press' AND is_predefined = TRUE;

-- Back exercises
UPDATE exercises 
SET video_url = 'https://www.youtube.com/watch?v=1ZXobu7JvvE',
    tutorial_url = 'https://stronglifts.com/deadlift/'
WHERE name = 'Deadlift' AND is_predefined = TRUE;

UPDATE exercises 
SET video_url = 'https://www.youtube.com/watch?v=eGo4IYlbE5g',
    tutorial_url = 'https://www.nerdfitness.com/blog/how-to-do-a-pull-up/'
WHERE name = 'Pull-ups' AND is_predefined = TRUE;

-- Leg exercises
UPDATE exercises 
SET video_url = 'https://www.youtube.com/watch?v=SW_C1A-rejs',
    tutorial_url = 'https://stronglifts.com/squat/'
WHERE name = 'Barbell Squat' AND is_predefined = TRUE;

-- Shoulder exercises
UPDATE exercises 
SET video_url = 'https://www.youtube.com/watch?v=2yjwXTZQDDI',
    tutorial_url = 'https://www.muscleandstrength.com/exercises/overhead-press.html'
WHERE name = 'Overhead Press' AND is_predefined = TRUE;

-- Arm exercises
UPDATE exercises 
SET video_url = 'https://www.youtube.com/watch?v=kwG2ipFRgfo',
    tutorial_url = 'https://www.muscleandstrength.com/exercises/barbell-curl.html'
WHERE name = 'Barbell Curl' AND is_predefined = TRUE;

-- Cardio exercises
UPDATE exercises 
SET video_url = 'https://www.youtube.com/watch?v=8iC_bQeYw-Y',
    tutorial_url = 'https://www.runnersworld.com/training/a20855426/how-to-start-running/'
WHERE name = 'Running' AND is_predefined = TRUE;

UPDATE exercises 
SET video_url = 'https://www.youtube.com/watch?v=UuV6XuKQ_-U',
    tutorial_url = 'https://www.bicycling.com/training/a20047780/beginners-guide-to-cycling/'
WHERE name = 'Cycling' AND is_predefined = TRUE;

-- Isometric exercises
UPDATE exercises 
SET video_url = 'https://www.youtube.com/watch?v=pSHjTRCQxIw',
    tutorial_url = 'https://www.healthline.com/health/fitness-exercise/how-to-plank'
WHERE name = 'Plank' AND is_predefined = TRUE;

-- Verify the updates
SELECT '📊 VIDEO FIELD UPDATE SUMMARY' as section;
SELECT 
    COUNT(*) as total_exercises,
    COUNT(video_url) as exercises_with_videos,
    COUNT(tutorial_url) as exercises_with_tutorials
FROM exercises 
WHERE is_predefined = TRUE;

SELECT '' as spacing;

SELECT '🎯 SAMPLE EXERCISES WITH VIDEOS' as section;
SELECT 
    name,
    category,
    video_url,
    tutorial_url
FROM exercises 
WHERE is_predefined = TRUE AND video_url IS NOT NULL
LIMIT 5;