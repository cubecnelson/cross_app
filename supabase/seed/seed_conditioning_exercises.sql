-- Seed Script: Sports Conditioning Exercises
-- Description: Populate exercises table with conditioning exercises for AI recommendations
-- Run after: 003_add_recommendation_fields.sql

-- Basketball/Volleyball Conditioning
INSERT INTO exercises (id, name, category, exercise_type, description, target_muscles, sport_tags, sub_type, intensity, equipment_required, is_predefined, created_at)
VALUES
  (gen_random_uuid(), 'Box Jumps', 'Plyometric', 'cardio', 'Explosive lower body exercise. Jump onto a 20-24 inch box with both feet.', ARRAY['quadriceps', 'glutes', 'calves'], ARRAY['basketball', 'volleyball', 'track', 'general'], 'plyometric', 8, 'box', true, NOW()),
  (gen_random_uuid(), 'Lateral Bounds', 'Agility', 'cardio', 'Lateral explosiveness drill. Bound side to side, landing on single leg.', ARRAY['glutes', 'hip abductors', 'quadriceps'], ARRAY['basketball', 'tennis', 'soccer', 'football'], 'agility', 7, 'bodyweight', true, NOW()),
  (gen_random_uuid(), 'Medicine Ball Slams', 'Power', 'cardio', 'Full-body explosive movement. Slam medicine ball to ground from overhead.', ARRAY['core', 'shoulders', 'lats'], ARRAY['basketball', 'volleyball', 'football', 'general'], 'power', 7, 'medicine_ball', true, NOW()),
  (gen_random_uuid(), 'Tuck Jumps', 'Plyometric', 'cardio', 'Jump vertically bringing knees to chest in mid-air.', ARRAY['quadriceps', 'hip flexors', 'calves'], ARRAY['basketball', 'volleyball', 'general'], 'plyometric', 8, 'bodyweight', true, NOW()),
  (gen_random_uuid(), 'Depth Jumps', 'Plyometric', 'cardio', 'Step off box, land, immediately jump vertically as high as possible.', ARRAY['quadriceps', 'glutes', 'calves'], ARRAY['basketball', 'volleyball', 'track'], 'plyometric', 9, 'box', true, NOW());

-- Soccer/Football Conditioning
INSERT INTO exercises (id, name, category, exercise_type, description, target_muscles, sport_tags, sub_type, intensity, equipment_required, is_predefined, created_at)
VALUES
  (gen_random_uuid(), 'Shuttle Runs', 'Agility', 'cardio', 'Quick directional change drill. Sprint between two points 10-20m apart.', ARRAY['quadriceps', 'hamstrings', 'glutes'], ARRAY['soccer', 'football', 'basketball', 'tennis'], 'agility', 9, 'cones', true, NOW()),
  (gen_random_uuid(), 'Sled Push', 'Power', 'cardio', 'Drive through legs to push weighted sled 20-40 meters.', ARRAY['quadriceps', 'glutes', 'calves', 'core'], ARRAY['soccer', 'football', 'track', 'general'], 'power', 9, 'sled', true, NOW()),
  (gen_random_uuid(), 'High-Knee Runs', 'Speed', 'cardio', 'Drive knees high while running in place or forward. Focus on quick turnover.', ARRAY['hip flexors', 'quadriceps', 'calves'], ARRAY['soccer', 'football', 'track', 'general'], 'speed', 6, 'bodyweight', true, NOW()),
  (gen_random_uuid(), 'Cone Drills (5-10-5)', 'Agility', 'cardio', 'Sprint pattern: 5 yards right, 10 yards left, 5 yards right (20 yards total).', ARRAY['quadriceps', 'glutes', 'coordination'], ARRAY['football', 'basketball', 'soccer'], 'agility', 8, 'cones', true, NOW()),
  (gen_random_uuid(), 'Agility T-Drill', 'Agility', 'cardio', 'Sprint forward, shuffle right, shuffle left, shuffle back to center, backpedal.', ARRAY['quadriceps', 'glutes', 'coordination'], ARRAY['soccer', 'basketball', 'football', 'tennis'], 'agility', 7, 'cones', true, NOW()),
  (gen_random_uuid(), 'Prowler Push', 'Power', 'cardio', 'Push weighted prowler sled forward with low body position.', ARRAY['quadriceps', 'glutes', 'calves', 'shoulders'], ARRAY['football', 'rugby', 'general'], 'power', 9, 'prowler_sled', true, NOW()),
  (gen_random_uuid(), 'Sled Drag', 'Power', 'cardio', 'Pull weighted sled backwards or walk forward while dragging.', ARRAY['hamstrings', 'glutes', 'calves', 'back'], ARRAY['football', 'general', 'strongman'], 'power', 8, 'sled', true, NOW());

-- Tennis/Racquet Sports Conditioning
INSERT INTO exercises (id, name, category, exercise_type, description, target_muscles, sport_tags, sub_type, intensity, equipment_required, is_predefined, created_at)
VALUES
  (gen_random_uuid(), 'Ladder Drills', 'Agility', 'cardio', 'Various footwork patterns through agility ladder for quick feet.', ARRAY['calves', 'hip flexors', 'coordination'], ARRAY['tennis', 'badminton', 'soccer', 'basketball'], 'agility', 6, 'agility_ladder', true, NOW()),
  (gen_random_uuid(), 'Medicine Ball Rotations', 'Power', 'cardio', 'Rotational power exercise. Throw medicine ball against wall with rotation.', ARRAY['obliques', 'core', 'shoulders'], ARRAY['tennis', 'badminton', 'baseball', 'golf'], 'power', 6, 'medicine_ball', true, NOW());

-- Endurance Sports Conditioning
INSERT INTO exercises (id, name, category, exercise_type, description, target_muscles, sport_tags, sub_type, intensity, equipment_required, is_predefined, created_at)
VALUES
  (gen_random_uuid(), 'Assault Bike Intervals', 'Endurance', 'cardio', 'High-intensity cardio on assault bike. Sprint intervals with rest.', ARRAY['quadriceps', 'cardiovascular system'], ARRAY['running', 'cycling', 'triathlon', 'general'], 'endurance', 9, 'assault_bike', true, NOW()),
  (gen_random_uuid(), 'Rowing Machine Intervals', 'Endurance', 'cardio', 'High-intensity intervals on rowing machine for cardiovascular conditioning.', ARRAY['back', 'legs', 'core', 'cardiovascular system'], ARRAY['rowing', 'general', 'crossfit'], 'endurance', 8, 'rowing_machine', true, NOW()),
  (gen_random_uuid(), 'Sprint Intervals', 'Speed', 'cardio', 'Maximum effort sprints (30-60m) with full recovery between reps.', ARRAY['hamstrings', 'quadriceps', 'glutes'], ARRAY['track', 'soccer', 'football', 'general'], 'speed', 10, 'bodyweight', true, NOW());

-- General Athletic Conditioning
INSERT INTO exercises (id, name, category, exercise_type, description, target_muscles, sport_tags, sub_type, intensity, equipment_required, is_predefined, created_at)
VALUES
  (gen_random_uuid(), 'Burpees', 'Conditioning', 'cardio', 'Full-body conditioning. From standing, drop to pushup, jump back up.', ARRAY['full_body', 'cardiovascular system'], ARRAY['running', 'general', 'mma', 'crossfit'], 'endurance', 8, 'bodyweight', true, NOW()),
  (gen_random_uuid(), 'Jump Squats', 'Plyometric', 'cardio', 'Explosive squat variation. Jump as high as possible from squat position.', ARRAY['quadriceps', 'glutes', 'calves'], ARRAY['general', 'basketball', 'volleyball', 'track'], 'plyometric', 7, 'bodyweight', true, NOW()),
  (gen_random_uuid(), 'Battle Ropes', 'Conditioning', 'cardio', 'Wave heavy ropes with alternating or simultaneous arm movements.', ARRAY['shoulders', 'core', 'grip', 'cardiovascular system'], ARRAY['general', 'mma', 'crossfit'], 'endurance', 8, 'battle_ropes', true, NOW()),
  (gen_random_uuid(), 'Broad Jumps', 'Plyometric', 'cardio', 'Jump forward for maximum distance from standing position.', ARRAY['quadriceps', 'glutes', 'hamstrings'], ARRAY['track', 'football', 'general'], 'power', 7, 'bodyweight', true, NOW()),
  (gen_random_uuid(), 'Kettlebell Swings', 'Power', 'cardio', 'Hip-hinge explosive movement swinging kettlebell to shoulder height.', ARRAY['glutes', 'hamstrings', 'core', 'shoulders'], ARRAY['general', 'crossfit', 'mma'], 'power', 7, 'kettlebell', true, NOW()),
  (gen_random_uuid(), 'Mountain Climbers', 'Conditioning', 'cardio', 'From plank position, drive knees to chest alternating quickly.', ARRAY['core', 'hip flexors', 'shoulders', 'cardiovascular system'], ARRAY['general', 'mma', 'crossfit'], 'endurance', 6, 'bodyweight', true, NOW()),
  (gen_random_uuid(), 'Farmer''s Walk', 'Conditioning', 'cardio', 'Walk with heavy weights in each hand maintaining posture.', ARRAY['grip', 'traps', 'core', 'forearms'], ARRAY['general', 'strongman', 'crossfit'], 'endurance', 7, 'dumbbells', true, NOW()),
  (gen_random_uuid(), 'Wall Balls', 'Conditioning', 'cardio', 'Squat with medicine ball, explode up, throw ball to wall target, catch and repeat.', ARRAY['quadriceps', 'shoulders', 'core'], ARRAY['crossfit', 'general'], 'endurance', 7, 'medicine_ball', true, NOW());

-- Create a view for easy querying of sport-specific exercises
CREATE OR REPLACE VIEW sport_conditioning_exercises AS
SELECT 
  e.id,
  e.name,
  e.category,
  e.exercise_type,
  e.description,
  e.target_muscles,
  e.sport_tags,
  e.sub_type,
  e.intensity,
  e.equipment_required
FROM exercises e
WHERE e.is_predefined = true
  AND e.exercise_type = 'cardio'
  AND e.sport_tags IS NOT NULL
  AND array_length(e.sport_tags, 1) > 0
ORDER BY e.intensity DESC, e.name;

-- Create function to get exercises by sport
CREATE OR REPLACE FUNCTION get_exercises_by_sport(sport_name text)
RETURNS TABLE (
  id uuid,
  name text,
  category text,
  description text,
  sub_type text,
  intensity integer,
  equipment_required text
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    e.id,
    e.name,
    e.category,
    e.description,
    e.sub_type,
    e.intensity,
    e.equipment_required
  FROM exercises e
  WHERE sport_name = ANY(e.sport_tags)
    AND e.is_predefined = true
  ORDER BY e.intensity DESC, e.name;
END;
$$ LANGUAGE plpgsql;

-- Create function to get exercises by intensity range
CREATE OR REPLACE FUNCTION get_exercises_by_intensity(min_intensity integer, max_intensity integer)
RETURNS TABLE (
  id uuid,
  name text,
  category text,
  sport_tags text[],
  intensity integer
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    e.id,
    e.name,
    e.category,
    e.sport_tags,
    e.intensity
  FROM exercises e
  WHERE e.intensity >= min_intensity
    AND e.intensity <= max_intensity
    AND e.is_predefined = true
  ORDER BY e.intensity DESC, e.name;
END;
$$ LANGUAGE plpgsql;

-- Add comments
COMMENT ON VIEW sport_conditioning_exercises IS 'View of all predefined conditioning exercises with sport tags';
COMMENT ON FUNCTION get_exercises_by_sport IS 'Returns exercises filtered by sport name';
COMMENT ON FUNCTION get_exercises_by_intensity IS 'Returns exercises within specified intensity range';
