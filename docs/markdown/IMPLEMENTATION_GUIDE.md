# Implementation Guide: AI-Powered Workout Recommendations

## Quick Start

### Step 1: Run Database Migrations
```bash
# Apply schema changes
cd supabase
supabase db push

# Or manually run:
psql -h your-db-host -U postgres -d your-db -f migrations/003_add_recommendation_fields.sql
```

### Step 2: Seed Conditioning Exercises
```bash
# Load conditioning exercises into database
psql -h your-db-host -U postgres -d your-db -f seed/seed_conditioning_exercises.sql
```

### Step 3: Test the System
```dart
// In your test file or debug screen
final recommendations = ref.watch(workoutRecommendationsProvider);

recommendations.when(
  data: (recs) => print('Generated ${recs.length} recommendations'),
  loading: () => print('Loading recommendations...'),
  error: (e, _) => print('Error: $e'),
);
```

## Integration Checklist

### ✅ Phase 1: Core Setup (Completed)
- [x] Create `workout_recommendation.dart` model
- [x] Create `recommendation_service.dart` with rules logic
- [x] Create `recommendation_provider.dart` for state management
- [x] Create UI widgets (`RecommendationCard`, `RecommendationsSection`)
- [x] Integrate into `ActiveWorkoutScreen`
- [x] Integrate into `WorkoutsListScreen`
- [x] Create database migration script
- [x] Create seed data for conditioning exercises

### 📋 Phase 2: User Profile Enhancement (Next Steps)

#### 2.1 Update User Profile Model
```dart
// Add to lib/models/user_profile.dart
final String? primaryGoal; // 'hypertrophy', 'strength', 'powerlifting', 'sports_conditioning'
final String? primarySport; // 'basketball', 'soccer', 'tennis', etc.
final List<String> secondarySports;
final int? experienceLevel; // 1-5
```

#### 2.2 Create Profile Settings Screen
```dart
// lib/features/profile/screens/fitness_goals_screen.dart
class FitnessGoalsScreen extends StatelessWidget {
  // Dropdown for primary goal
  // Dropdown for primary sport
  // Multi-select for secondary sports
  // Slider for experience level
}
```

#### 2.3 Update Recommendation Provider
```dart
// Modify recommendation_provider.dart to use user profile
final userProfile = ref.watch(userProfileProvider);

return service.generateRecommendations(
  workoutHistory: workouts,
  availableExercises: exercises,
  userProfile: userProfile,
  userGoal: userProfile?.primaryGoal,
  primarySport: userProfile?.primarySport,
);
```

### 📋 Phase 3: Enhanced Analytics (Future)

#### 3.1 Add Analytics Screen
```dart
// lib/features/progress/screens/analytics_screen.dart
class AnalyticsScreen extends StatelessWidget {
  // Show exercise performance over time
  // Display volume trends
  // Show plateau warnings
  // Recovery metrics
}
```

#### 3.2 Implement Caching
```dart
// lib/services/analytics_cache_service.dart
class AnalyticsCacheService {
  final Map<String, ExerciseAnalytics> _cache = {};
  final Duration _cacheTimeout = Duration(minutes: 5);
  
  ExerciseAnalytics? getCachedAnalytics(String exerciseId) {
    // Return cached analytics if fresh
  }
}
```

## Testing Strategy

### Unit Tests

#### Test Recommendation Generation
```dart
// test/services/recommendation_service_test.dart
void main() {
  group('RecommendationService', () {
    late RecommendationService service;
    
    setUp(() {
      service = RecommendationService();
    });
    
    test('generates progression recommendations for consistent performance', () {
      final mockWorkouts = [
        // Create workouts with increasing reps
      ];
      
      final recommendations = service.generateRecommendations(
        workoutHistory: mockWorkouts,
        availableExercises: mockExercises,
      );
      
      expect(
        recommendations.any((r) => r.type == RecommendationType.progression),
        true,
      );
    });
    
    test('detects plateaus after 5 workouts with same weight', () {
      final mockWorkouts = [
        // Create 5 workouts with same weight
      ];
      
      final recommendations = service.generateRecommendations(
        workoutHistory: mockWorkouts,
        availableExercises: mockExercises,
      );
      
      expect(
        recommendations.any((r) => r.type == RecommendationType.plateau),
        true,
      );
    });
    
    test('recommends sport-specific conditioning', () {
      final recommendations = service.generateRecommendations(
        workoutHistory: mockWorkouts,
        availableExercises: mockExercises,
        primarySport: 'basketball',
      );
      
      final sportRecs = recommendations.where(
        (r) => r.type == RecommendationType.sportConditioning,
      );
      
      expect(sportRecs.isNotEmpty, true);
      expect(
        sportRecs.any((r) => r.exercise?.name.contains('Box Jump')),
        true,
      );
    });
  });
}
```

#### Test Exercise Analytics
```dart
test('calculates exercise analytics correctly', () {
  final service = RecommendationService();
  final analytics = service._analyzeExercisePerformance(mockWorkouts);
  
  expect(analytics['exercise-1']?.totalWorkouts, 5);
  expect(analytics['exercise-1']?.maxWeight, 100.0);
  expect(analytics['exercise-1']?.averageReps, greaterThan(8.0));
});
```

### Integration Tests

```dart
// integration_test/recommendations_flow_test.dart
void main() {
  testWidgets('recommendations appear on active workout screen', (tester) async {
    await tester.pumpWidget(ProviderScope(child: MyApp()));
    
    // Navigate to active workout
    await tester.tap(find.text('New Workout'));
    await tester.pumpAndSettle();
    
    // Check recommendations section appears
    expect(find.text('AI Recommendations'), findsOneWidget);
    expect(find.byType(RecommendationCard), findsWidgets);
  });
  
  testWidgets('can tap recommendation to add exercise', (tester) async {
    // Setup and tap a recommendation
    await tester.tap(find.byType(RecommendationCard).first);
    await tester.pumpAndSettle();
    
    // Verify exercise was added
    expect(find.byType(ExerciseSetWidget), findsOneWidget);
  });
}
```

### Manual Testing Checklist

- [ ] Open Active Workout Screen → Verify recommendations appear
- [ ] Verify recommendations update when dismissing
- [ ] Tap recommendation → Verify exercise is added with correct parameters
- [ ] Complete 5 workouts with same exercise/weight → Verify plateau recommendation
- [ ] Complete workouts with increasing reps → Verify progression recommendation
- [ ] Set primary sport to 'basketball' → Verify sport conditioning appears
- [ ] Complete 5 workouts in one week → Verify deload recommendation

## Performance Optimization

### 1. Limit History Analysis
```dart
// Only analyze last 50 workouts
final recentWorkouts = workoutHistory.take(50).toList();
final analytics = _analyzeExercisePerformance(recentWorkouts);
```

### 2. Implement Caching
```dart
// Cache recommendations for 5 minutes
final cachedRecommendations = Cache.get('recommendations_$userId');
if (cachedRecommendations != null && 
    cachedRecommendations.timestamp.difference(DateTime.now()).inMinutes < 5) {
  return cachedRecommendations.data;
}
```

### 3. Background Computation
```dart
// For large datasets, use isolates
final analytics = await compute(_analyzeExercisePerformance, workoutHistory);
```

## Troubleshooting

### Issue: No Recommendations Appearing

**Possible Causes:**
1. Insufficient workout history (needs 3+ workouts)
2. Provider not initialized
3. User not authenticated

**Debug Steps:**
```dart
// Add debug logging
print('Workouts count: ${workoutHistory.length}');
print('Exercises count: ${availableExercises.length}');
print('User: ${user?.email}');

final recommendations = service.generateRecommendations(
  workoutHistory: workoutHistory,
  availableExercises: availableExercises,
);
print('Generated ${recommendations.length} recommendations');
```

### Issue: Wrong Recommendations

**Check:**
1. Verify workout data accuracy (weights, reps)
2. Check analytics calculations
3. Review recommendation thresholds

**Adjust Thresholds:**
```dart
// In recommendation_service.dart
if (avgRecentReps >= 10) { // Change from 10 to 12 if too aggressive
  // Suggest weight increase
}
```

### Issue: App Performance Degraded

**Solutions:**
1. Limit workout history analysis
2. Enable caching
3. Reduce recommendation refresh frequency
4. Use background isolates for computation

## Deployment Checklist

### Before Production
- [ ] Run database migrations on production
- [ ] Seed conditioning exercises
- [ ] Test with real user data (anonymized)
- [ ] Add error tracking (Sentry integration)
- [ ] Set up analytics (track recommendation acceptance rate)
- [ ] Create user documentation/tutorial
- [ ] A/B test recommendation UI placement

### Monitoring
```dart
// Track recommendation acceptance
void trackRecommendationAccepted(WorkoutRecommendation rec) {
  Analytics.logEvent('recommendation_accepted', parameters: {
    'type': rec.type.toString(),
    'priority': rec.priority.toString(),
    'exercise_id': rec.exerciseId,
  });
}

// Track dismissals
void trackRecommendationDismissed(WorkoutRecommendation rec) {
  Analytics.logEvent('recommendation_dismissed', parameters: {
    'type': rec.type.toString(),
  });
}
```

## Future Roadmap

### Phase 4: Machine Learning (3-6 months)
1. Collect anonymized workout data
2. Train progression prediction model
3. Implement collaborative filtering
4. Deploy ML models via Supabase Edge Functions
5. A/B test ML vs rules-based recommendations

### Phase 5: Advanced Features (6-12 months)
1. Periodization planning (mesocycles)
2. Injury risk prediction
3. Recovery optimization
4. Social recommendations (what similar users do)
5. Video exercise demonstrations
6. Wearable integration (sleep, HRV)

## Support & Resources

- **Documentation**: `/docs/RECOMMENDATIONS_SYSTEM.md`
- **API Reference**: See inline code documentation
- **Sample Data**: `/docs/CONDITIONING_EXERCISES_SEED.json`
- **Migration Scripts**: `/supabase/migrations/`

## Contributing

To add new recommendation types:
1. Add to `RecommendationType` enum
2. Implement generation logic in `RecommendationService`
3. Update UI in `RecommendationCard`
4. Add unit tests
5. Update documentation

To customize sport recommendations:
1. Edit `_getConditioningExercisesForSport()` in `recommendation_service.dart`
2. Add exercises to seed script
3. Test with sport-specific workouts
