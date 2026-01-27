-- Migration: Add fields for AI-powered workout recommendations
-- Date: 2026-01-26
-- Description: Extends exercises and user_profiles tables to support recommendations

-- Add fields to exercises table for sport-specific conditioning
ALTER TABLE exercises
ADD COLUMN IF NOT EXISTS sport_tags text[] DEFAULT '{}',
ADD COLUMN IF NOT EXISTS sub_type text,
ADD COLUMN IF NOT EXISTS intensity integer CHECK (intensity >= 1 AND intensity <= 10),
ADD COLUMN IF NOT EXISTS equipment_required text;

-- Add index for sport tag queries
CREATE INDEX IF NOT EXISTS idx_exercises_sport_tags ON exercises USING GIN (sport_tags);

-- Add index for sub_type queries
CREATE INDEX IF NOT EXISTS idx_exercises_sub_type ON exercises (sub_type);

-- Add fields to user_profiles table for personalized recommendations
ALTER TABLE user_profiles
ADD COLUMN IF NOT EXISTS primary_goal text,
ADD COLUMN IF NOT EXISTS primary_sport text,
ADD COLUMN IF NOT EXISTS secondary_sports text[] DEFAULT '{}',
ADD COLUMN IF NOT EXISTS experience_level integer CHECK (experience_level >= 1 AND experience_level <= 5);

-- Add index for goal-based queries
CREATE INDEX IF NOT EXISTS idx_user_profiles_primary_goal ON user_profiles (primary_goal);

-- Add index for sport-based queries
CREATE INDEX IF NOT EXISTS idx_user_profiles_primary_sport ON user_profiles (primary_sport);

-- Add comments for documentation
COMMENT ON COLUMN exercises.sport_tags IS 'Array of sports this exercise is relevant for (e.g., basketball, soccer)';
COMMENT ON COLUMN exercises.sub_type IS 'Exercise sub-category: plyometric, agility, power, endurance, speed';
COMMENT ON COLUMN exercises.intensity IS 'Intensity rating from 1-10 for recommendation algorithms';
COMMENT ON COLUMN exercises.equipment_required IS 'Equipment needed: bodyweight, box, sled, medicine_ball, etc.';

COMMENT ON COLUMN user_profiles.primary_goal IS 'User''s primary fitness goal: hypertrophy, strength, powerlifting, sports_conditioning';
COMMENT ON COLUMN user_profiles.primary_sport IS 'User''s primary sport for conditioning recommendations';
COMMENT ON COLUMN user_profiles.secondary_sports IS 'Array of additional sports for cross-training recommendations';
COMMENT ON COLUMN user_profiles.experience_level IS 'Training experience: 1=Beginner, 2=Novice, 3=Intermediate, 4=Advanced, 5=Elite';
