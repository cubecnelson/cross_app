-- Create personal_records table for tracking PRs (Personal Records)
CREATE TABLE IF NOT EXISTS personal_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  exercise_id TEXT NOT NULL,
  exercise_name TEXT NOT NULL,
  weight DOUBLE PRECISION NOT NULL CHECK (weight > 0),
  reps INTEGER NOT NULL CHECK (reps > 0),
  estimated_one_rep_max DOUBLE PRECISION,
  velocity DOUBLE PRECISION, -- For future VBT integration
  video_path TEXT, -- For future VBT integration
  date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  workout_id UUID NOT NULL REFERENCES workouts(id) ON DELETE CASCADE,
  workout_set_id UUID NOT NULL REFERENCES workout_sets(id) ON DELETE CASCADE,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Ensure we don't have duplicate PRs for the same set
  UNIQUE(workout_set_id)
);

-- Add indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_personal_records_user_id ON personal_records(user_id);
CREATE INDEX IF NOT EXISTS idx_personal_records_exercise_id ON personal_records(exercise_id);
CREATE INDEX IF NOT EXISTS idx_personal_records_date ON personal_records(date);
CREATE INDEX IF NOT EXISTS idx_personal_records_weight_reps ON personal_records(weight DESC, reps DESC);

-- Add comments
COMMENT ON TABLE personal_records IS 'Stores personal records (PRs) for strength training exercises';
COMMENT ON COLUMN personal_records.weight IS 'Weight lifted in kg';
COMMENT ON COLUMN personal_records.reps IS 'Number of repetitions';
COMMENT ON COLUMN personal_records.estimated_one_rep_max IS 'Calculated 1RM using Epley/Brzycki formulas';
COMMENT ON COLUMN personal_records.velocity IS 'Mean velocity from VBT (Velocity-Based Training)';
COMMENT ON COLUMN personal_records.video_path IS 'Path to recorded video for form analysis';
COMMENT ON COLUMN personal_records.workout_set_id IS 'The workout set that created this PR';

-- Enable Row Level Security
ALTER TABLE personal_records ENABLE ROW LEVEL SECURITY;

-- Create policies for RLS
CREATE POLICY "Users can view their own personal records"
  ON personal_records FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own personal records"
  ON personal_records FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own personal records"
  ON personal_records FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own personal records"
  ON personal_records FOR DELETE
  USING (auth.uid() = user_id);

-- Function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_personal_records_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to automatically update updated_at
CREATE TRIGGER update_personal_records_updated_at
  BEFORE UPDATE ON personal_records
  FOR EACH ROW
  EXECUTE FUNCTION update_personal_records_updated_at();

-- Function to check if a new PR is actually a record (optional business logic)
CREATE OR REPLACE FUNCTION check_new_pr_is_record()
RETURNS TRIGGER AS $$
BEGIN
  -- Check if there's an existing PR for this exercise with same or better weight/reps
  IF EXISTS (
    SELECT 1 FROM personal_records pr
    WHERE pr.user_id = NEW.user_id
      AND pr.exercise_id = NEW.exercise_id
      AND pr.reps = NEW.reps
      AND pr.weight >= NEW.weight
      AND pr.id != NEW.id
  ) THEN
    RAISE EXCEPTION 'New PR must be better than existing record for same rep range';
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to validate new PRs (optional, can be commented out if you want to allow "equal" PRs)
-- CREATE TRIGGER validate_new_pr
--   BEFORE INSERT ON personal_records
--   FOR EACH ROW
--   EXECUTE FUNCTION check_new_pr_is_record();