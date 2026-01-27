-- Cross Workout App - Supabase Database Setup
-- Run this SQL in your Supabase SQL editor

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table
CREATE TABLE users (
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
CREATE TABLE exercises (
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
CREATE TABLE workouts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    date TIMESTAMP WITH TIME ZONE NOT NULL,
    routine_id UUID,
    routine_name TEXT,
    notes TEXT,
    duration INTEGER, -- in seconds
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE
);

-- Sets table
CREATE TABLE sets (
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
CREATE TABLE routines (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    exercises JSONB NOT NULL DEFAULT '[]',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE
);

-- Create indexes for better performance
CREATE INDEX idx_exercises_user_id ON exercises(user_id);
CREATE INDEX idx_exercises_category ON exercises(category);
CREATE INDEX idx_workouts_user_id ON workouts(user_id);
CREATE INDEX idx_workouts_date ON workouts(date);
CREATE INDEX idx_sets_workout_id ON sets(workout_id);
CREATE INDEX idx_sets_exercise_id ON sets(exercise_id);
CREATE INDEX idx_routines_user_id ON routines(user_id);

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE workouts ENABLE ROW LEVEL SECURITY;
ALTER TABLE sets ENABLE ROW LEVEL SECURITY;
ALTER TABLE routines ENABLE ROW LEVEL SECURITY;

-- RLS Policies for users table
CREATE POLICY "Users can view own profile"
    ON users FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
    ON users FOR UPDATE
    USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
    ON users FOR INSERT
    WITH CHECK (auth.uid() = id);

-- RLS Policies for exercises table
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

-- RLS Policies for workouts table
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

-- RLS Policies for sets table
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

-- RLS Policies for routines table
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

-- Insert predefined exercises
INSERT INTO exercises (name, category, description, target_muscles, is_predefined) VALUES
    ('Bench Press', 'Chest', 'Barbell bench press', ARRAY['Chest', 'Triceps', 'Shoulders'], TRUE),
    ('Squat', 'Legs', 'Barbell back squat', ARRAY['Quadriceps', 'Glutes', 'Hamstrings'], TRUE),
    ('Deadlift', 'Back', 'Conventional deadlift', ARRAY['Back', 'Glutes', 'Hamstrings'], TRUE),
    ('Overhead Press', 'Shoulders', 'Barbell overhead press', ARRAY['Shoulders', 'Triceps'], TRUE),
    ('Barbell Row', 'Back', 'Bent over barbell row', ARRAY['Back', 'Biceps'], TRUE),
    ('Pull-up', 'Back', 'Pull-up exercise', ARRAY['Back', 'Biceps'], TRUE),
    ('Dip', 'Chest', 'Parallel bar dips', ARRAY['Chest', 'Triceps'], TRUE),
    ('Lat Pulldown', 'Back', 'Cable lat pulldown', ARRAY['Back', 'Biceps'], TRUE),
    ('Leg Press', 'Legs', 'Leg press machine', ARRAY['Quadriceps', 'Glutes'], TRUE),
    ('Leg Curl', 'Legs', 'Hamstring curl', ARRAY['Hamstrings'], TRUE),
    ('Leg Extension', 'Legs', 'Quad extension', ARRAY['Quadriceps'], TRUE),
    ('Bicep Curl', 'Arms', 'Barbell or dumbbell curl', ARRAY['Biceps'], TRUE),
    ('Tricep Extension', 'Arms', 'Overhead tricep extension', ARRAY['Triceps'], TRUE),
    ('Shoulder Lateral Raise', 'Shoulders', 'Dumbbell lateral raise', ARRAY['Shoulders'], TRUE),
    ('Face Pull', 'Shoulders', 'Cable face pull', ARRAY['Shoulders', 'Upper Back'], TRUE),
    ('Calf Raise', 'Legs', 'Standing calf raise', ARRAY['Calves'], TRUE),
    ('Plank', 'Core', 'Front plank hold', ARRAY['Core'], TRUE),
    ('Crunch', 'Core', 'Abdominal crunch', ARRAY['Abs'], TRUE),
    ('Russian Twist', 'Core', 'Seated twisting motion', ARRAY['Obliques'], TRUE),
    ('Treadmill', 'Cardio', 'Treadmill running/walking', ARRAY['Full Body'], TRUE),
    ('Cycling', 'Cardio', 'Stationary bike', ARRAY['Legs'], TRUE);

-- Function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for updated_at
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_workouts_updated_at
    BEFORE UPDATE ON workouts
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_routines_updated_at
    BEFORE UPDATE ON routines
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

