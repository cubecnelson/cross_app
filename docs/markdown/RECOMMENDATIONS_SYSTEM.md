# AI-Powered Workout Recommendations System

## Overview
The workout recommendations system provides personalized exercise suggestions based on user workout history, performance analytics, and sport-specific goals. It uses rules-based logic that can evolve into machine learning models.

## Architecture

### Core Components

1. **Models** (`lib/models/workout_recommendation.dart`)
   - `WorkoutRecommendation`: Represents a single recommendation with type, priority, and suggested parameters
   - `ExerciseAnalytics`: Tracks performance metrics for each exercise
   - `RecommendationType`: Progression, Deload, Variety, SportConditioning, Plateau

2. **Service** (`lib/services/recommendation_service.dart`)
   - Analyzes workout history
   - Generates recommendations based on rules
   - Calculates exercise analytics
   - Provides sport-specific conditioning suggestions

3. **Providers** (`lib/providers/recommendation_provider.dart`)
   - `workoutRecommendationsProvider`: Main provider for all recommendations
   - `recommendationsByTypeProvider`: Filter by recommendation type
   - `priorityRecommendationsProvider`: High-priority recommendations only

4. **UI Components** (`lib/features/workouts/widgets/`)
   - `RecommendationCard`: Display individual recommendations
   - `RecommendationsSection`: Full recommendations list with refresh
   - `CompactRecommendations`: Dashboard widget for top suggestions

## Recommendation Types

### 1. Progression Recommendations
**Logic**: Analyzes recent workout performance to suggest increases in weight or reps.

**Rules**:
- If averaging 10+ reps over last 3 workouts → Suggest weight increase
- If weight stable and reps 5-8 → Suggest adding 1-2 reps
- Progressive weight calculation:
  - <20kg: +1.25kg increment
  - 20-60kg: +2.5kg increment
  - >60kg: +5kg increment

**Example**:
```
Title: "Increase weight for Bench Press"
Description: "You've been consistently hitting 12 reps. Try increasing the weight."
Suggested: 50kg × 8 reps
Reasoning: "Averaging 12.3 reps over last 3 workouts"
```

### 2. Plateau Detection
**Logic**: Identifies when progress has stalled and recommends alternative exercises.

**Rules**:
- Max weight unchanged in last 5 workouts → Plateau detected
- Suggest exercises from same category/muscle group
- Start at 85% of plateaued weight

**Example**:
```
Title: "Break plateau: Try Dumbbell Bench Press"
Description: "Your Barbell Bench Press progress has plateaued. Try this alternative to stimulate new growth."
Suggested: 42.5kg × 10 reps (85% of 50kg max)
Reasoning: "No weight increase in last 5 workouts"
```

### 3. Sport-Specific Conditioning
**Logic**: Recommends conditioning exercises based on user's primary sport.

**Sport Mappings**:

#### Basketball / Volleyball
- Box Jumps: Explosive power for vertical leap
- Lateral Bounds: Lateral explosiveness for quick directional changes
- Medicine Ball Slams: Full-body power development

#### Soccer / Football
- Shuttle Runs: Agility and speed for directional changes
- Sled Push: Acceleration and leg power
- High-Knee Runs: Running form and hip flexor strength

#### Tennis / Racquet Sports
- Ladder Drills: Foot speed and agility
- Medicine Ball Rotations: Rotational power for serves

#### Running / Endurance Sports
- Assault Bike Intervals: Cardiovascular endurance
- Burpees: Full-body conditioning

**Example**:
```
Title: "Sport conditioning: Box Jumps"
Description: "Explosive power for vertical leap. Jump onto a 20-24" box."
Suggested: 3 sets × 8 reps, 120s rest
Reasoning: "Recommended for basketball athletes"
```

### 4. Variety Recommendations
**Logic**: Suggests exercises not performed in 14+ days.

**Rules**:
- Compare recent workouts against exercise library
- Prioritize exercises user has done before
- Suggest last used weight/reps

**Example**:
```
Title: "Add variety: Romanian Deadlifts"
Description: "You haven't done this exercise in 18 days."
Suggested: 60kg × 10 reps (your last max)
Reasoning: "Last performed 18 days ago"
```

### 5. Deload Recommendations
**Logic**: Detects overtraining indicators and suggests recovery.

**Rules**:
- 5+ workouts in last 7 days → Suggest deload
- Reduce main lifts by 20%
- High priority to prevent injury

**Example**:
```
Title: "Deload week: Reduce Squat intensity"
Description: "You've trained hard recently. Consider reducing weight by 20% to recover."
Suggested: 80kg × 8 reps (20% reduction from 100kg max)
Reasoning: "6 workouts in the past week"
```

## Integration Guide

### 1. Display Recommendations in Active Workout
```dart
// In active_workout_screen.dart
RecommendationsSection(
  maxRecommendations: 5,
  onRecommendationTap: (recommendation) {
    // Auto-add exercise with suggested parameters
    _handleRecommendationTap(recommendation);
  },
)
```

### 2. Show Compact Recommendations in Dashboard
```dart
// In dashboard_screen.dart
const CompactRecommendations()
```

### 3. Access Specific Recommendation Types
```dart
final progressionRecs = ref.watch(
  recommendationsByTypeProvider(RecommendationType.progression)
);
```

## Future Enhancements

### Phase 2: Enhanced Analytics (1-2 weeks)
- Volume load tracking (total weight × reps over time)
- Intensity distribution analysis
- Recovery metrics (workout frequency vs performance)
- Exercise variety scoring

### Phase 3: Machine Learning (Future)
- Train models on anonymized user data
- Predict optimal progression rates
- Personalized deload timing
- Exercise substitution recommendations

**Potential ML Models**:
1. **Progression Predictor**: Linear regression on weight/rep trends
2. **Plateau Detector**: Time-series analysis with LSTM
3. **Exercise Recommender**: Collaborative filtering based on similar users

**Implementation Options**:
- TensorFlow Lite for on-device inference
- Supabase Edge Functions for server-side ML
- Pre-trained models with fine-tuning

## Database Schema Extensions

### Required Fields for Enhanced Recommendations

#### `exercises` table
```sql
ALTER TABLE exercises
ADD COLUMN sport_tags text[],
ADD COLUMN sub_type text,  -- 'plyometric', 'agility', 'power', 'endurance'
ADD COLUMN intensity integer CHECK (intensity >= 1 AND intensity <= 10),
ADD COLUMN equipment_required text;
```

#### `user_profiles` table
```sql
ALTER TABLE user_profiles
ADD COLUMN primary_goal text,  -- 'hypertrophy', 'strength', 'powerlifting', 'sports_conditioning'
ADD COLUMN primary_sport text,  -- 'basketball', 'soccer', 'tennis', etc.
ADD COLUMN secondary_sports text[],
ADD COLUMN experience_level integer CHECK (experience_level >= 1 AND experience_level <= 5);
```

## Performance Considerations

### Optimization Strategies
1. **Caching**: Cache analytics for 5 minutes to reduce computation
2. **Lazy Loading**: Only generate recommendations when screen is visible
3. **Background Processing**: Calculate analytics in isolates for large datasets
4. **Pagination**: Limit history analysis to last 50 workouts

### Testing Recommendations
```dart
// Unit test example
void testProgressionRecommendation() {
  final service = RecommendationService();
  final mockWorkouts = [/* create mock data */];
  
  final recommendations = service.generateRecommendations(
    workoutHistory: mockWorkouts,
    availableExercises: mockExercises,
  );
  
  expect(recommendations.any((r) => r.type == RecommendationType.progression), true);
}
```

## API Documentation

### RecommendationService.generateRecommendations()
```dart
List<WorkoutRecommendation> generateRecommendations({
  required List<Workout> workoutHistory,
  required List<Exercise> availableExercises,
  UserProfile? userProfile,
  String? userGoal,
  String? primarySport,
})
```

**Parameters**:
- `workoutHistory`: User's past workouts (sorted newest first)
- `availableExercises`: All exercises user can perform
- `userProfile`: Optional user profile with demographics
- `userGoal`: Optional goal ('hypertrophy', 'strength', etc.)
- `primarySport`: Optional sport for conditioning recommendations

**Returns**: List of personalized recommendations sorted by priority

## Troubleshooting

### No Recommendations Showing
1. Check if user has sufficient workout history (needs 3+ workouts)
2. Verify `workoutsProvider` is loading correctly
3. Check console for errors in recommendation generation

### Incorrect Recommendations
1. Review workout history data quality
2. Verify exercise analytics calculations
3. Adjust recommendation thresholds in service

### Performance Issues
1. Limit workout history to last 50 workouts
2. Enable caching for analytics
3. Consider background computation for large datasets

## Contributing

### Adding New Recommendation Types
1. Add type to `RecommendationType` enum
2. Implement generation logic in `RecommendationService`
3. Add UI icon mapping in `RecommendationCard`
4. Update documentation

### Customizing Rules
Edit thresholds in `recommendation_service.dart`:
```dart
// Example: Change progression threshold
if (avgRecentReps >= 10) { // Change this value
  // Suggest weight increase
}
```
