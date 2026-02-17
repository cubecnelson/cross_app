-- Add sRPE (Session Rate of Perceived Exertion) column to workouts table
-- This enables training load analysis via Acute:Chronic Workload Ratio (ACWR)

ALTER TABLE workouts 
ADD COLUMN IF NOT EXISTS s_rpe DOUBLE PRECISION CHECK (s_rpe >= 0 AND s_rpe <= 10);

-- Add comment explaining the column
COMMENT ON COLUMN workouts.s_rpe IS 'Session Rate of Perceived Exertion (0-10 scale) used for training load calculation (AU = sRPE × duration in minutes)';

-- Update existing rows to have NULL s_rpe (optional)
-- UPDATE workouts SET s_rpe = NULL WHERE s_rpe IS NOT NULL; -- Not needed for new column