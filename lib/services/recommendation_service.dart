import 'package:uuid/uuid.dart';
import '../models/exercise.dart';
import '../models/workout.dart';
import '../models/workout_set.dart';
import '../models/workout_recommendation.dart';
import '../models/user_profile.dart';

class RecommendationService {
  final _uuid = const Uuid();

  /// Generate personalized workout recommendations based on history and user profile
  List<WorkoutRecommendation> generateRecommendations({
    required List<Workout> workoutHistory,
    required List<Exercise> availableExercises,
    UserProfile? userProfile,
    String? userGoal,
    String? primarySport,
  }) {
    final recommendations = <WorkoutRecommendation>[];

    // 1. Analyze exercise performance
    final analytics = _analyzeExercisePerformance(workoutHistory);

    // 2. Generate progression recommendations
    recommendations.addAll(_generateProgressionRecommendations(
      analytics,
      availableExercises,
    ));

    // 3. Detect plateaus and suggest alternatives
    recommendations.addAll(_generatePlateauRecommendations(
      analytics,
      availableExercises,
    ));

    // 4. Sport-specific conditioning (if user has a sport preference)
    if (primarySport != null && primarySport.isNotEmpty) {
      recommendations.addAll(_generateSportConditioningRecommendations(
        primarySport,
        availableExercises,
        workoutHistory,
      ));
    }

    // 5. Variety recommendations (for exercises not done recently)
    recommendations.addAll(_generateVarietyRecommendations(
      analytics,
      availableExercises,
      workoutHistory,
    ));

    // 6. Deload recommendations (if showing fatigue signs)
    recommendations.addAll(_generateDeloadRecommendations(
      analytics,
      workoutHistory,
    ));

    // Sort by priority
    recommendations.sort((a, b) => b.priority.index.compareTo(a.priority.index));

    return recommendations;
  }

  /// Analyze historical performance for each exercise
  Map<String, ExerciseAnalytics> _analyzeExercisePerformance(
    List<Workout> workouts,
  ) {
    final exerciseData = <String, List<WorkoutSet>>{};

    // Group all sets by exercise
    for (var workout in workouts) {
      for (var set in workout.sets) {
        if (!exerciseData.containsKey(set.exerciseId)) {
          exerciseData[set.exerciseId] = [];
        }
        exerciseData[set.exerciseId]!.add(set);
      }
    }

    // Calculate analytics for each exercise
    final analytics = <String, ExerciseAnalytics>{};
    for (var entry in exerciseData.entries) {
      final exerciseId = entry.key;
      final sets = entry.value;

      if (sets.isEmpty) continue;

      // Get unique workout dates for this exercise
      final workoutDates = <DateTime>{};
      for (var set in sets) {
        final workout = workouts.firstWhere((w) => w.id == set.workoutId);
        workoutDates.add(workout.date);
      }

      // Calculate stats
      final weights = sets.where((s) => s.weight != null).map((s) => s.weight!).toList();
      final reps = sets.where((s) => s.reps != null).map((s) => s.reps!).toList();
      
      // Get recent weights (last 5 workouts)
      final recentSets = sets.take(15).where((s) => s.weight != null).toList();
      final recentWeights = recentSets.map((s) => s.weight!).toList();
      final recentReps = recentSets.where((s) => s.reps != null).map((s) => s.reps!).toList();

      // Detect plateau: max weight hasn't changed in last 5 workouts
      bool isPlateauing = false;
      if (recentWeights.length >= 5) {
        final maxRecentWeight = recentWeights.reduce((a, b) => a > b ? a : b);
        final lastFiveMax = recentWeights.take(5).reduce((a, b) => a > b ? a : b);
        isPlateauing = (maxRecentWeight - lastFiveMax).abs() < 0.5; // Within 0.5kg
      }

      analytics[exerciseId] = ExerciseAnalytics(
        exerciseId: exerciseId,
        exerciseName: sets.first.exerciseName,
        totalWorkouts: workoutDates.length,
        totalSets: sets.length,
        averageWeight: weights.isNotEmpty ? weights.reduce((a, b) => a + b) / weights.length : null,
        maxWeight: weights.isNotEmpty ? weights.reduce((a, b) => a > b ? a : b) : null,
        averageReps: reps.isNotEmpty ? reps.reduce((a, b) => a + b) / reps.length : null,
        totalVolume: sets.fold<double>(0.0, (sum, set) => sum + (set.volume ?? 0.0)),
        lastPerformed: workouts.isNotEmpty ? workouts.first.date : null,
        firstPerformed: workouts.isNotEmpty ? workouts.last.date : null,
        recentWeights: recentWeights,
        recentReps: recentReps.cast<int>(),
        isPlateauing: isPlateauing,
      );
    }

    return analytics;
  }

  /// Generate progression recommendations (increase weight/reps)
  List<WorkoutRecommendation> _generateProgressionRecommendations(
    Map<String, ExerciseAnalytics> analytics,
    List<Exercise> availableExercises,
  ) {
    final recommendations = <WorkoutRecommendation>[];

    for (var analytic in analytics.values) {
      // Skip if not strength exercise or insufficient data
      if (analytic.maxWeight == null || analytic.recentWeights.length < 3) {
        continue;
      }

      // Rule: If consistently hitting reps, suggest weight increase
      if (analytic.recentReps.isNotEmpty && analytic.recentReps.length >= 3) {
        final avgRecentReps = analytic.recentReps.take(3).reduce((a, b) => a + b) / 3;
        
        // If averaging 10+ reps, suggest increasing weight
        if (avgRecentReps >= 10) {
          final currentWeight = analytic.recentWeights.first;
          final suggestedWeight = _calculateProgressiveWeight(currentWeight);

          recommendations.add(WorkoutRecommendation(
            id: _uuid.v4(),
            exerciseId: analytic.exerciseId,
            type: RecommendationType.progression,
            priority: RecommendationPriority.medium,
            title: 'Increase weight for ${analytic.exerciseName}',
            description: 'You\'ve been consistently hitting $avgRecentReps reps. Try increasing the weight.',
            suggestedParameters: {
              'weight': suggestedWeight,
              'reps': 8,
            },
            reasoning: 'Averaging ${avgRecentReps.toStringAsFixed(1)} reps over last 3 workouts',
            createdAt: DateTime.now(),
          ));
        }
      }

      // Rule: If weight has been stable and reps are low, suggest increasing reps
      if (analytic.recentWeights.length >= 3 && 
          analytic.recentReps.isNotEmpty && 
          analytic.recentReps.length >= 3) {
        final recentWeightsStable = analytic.recentWeights
            .take(3)
            .every((w) => (w - analytic.recentWeights.first).abs() < 1.0);
        final avgRecentReps = analytic.recentReps.take(3).reduce((a, b) => a + b) / 3;

        if (recentWeightsStable && avgRecentReps >= 5 && avgRecentReps < 8) {
          recommendations.add(WorkoutRecommendation(
            id: _uuid.v4(),
            exerciseId: analytic.exerciseId,
            type: RecommendationType.progression,
            priority: RecommendationPriority.low,
            title: 'Increase reps for ${analytic.exerciseName}',
            description: 'Try adding 1-2 more reps before increasing weight.',
            suggestedParameters: {
              'weight': analytic.recentWeights.first,
              'reps': (avgRecentReps + 2).toInt(),
            },
            reasoning: 'Weight stable at ${analytic.recentWeights.first}kg, averaging ${avgRecentReps.toStringAsFixed(1)} reps',
            createdAt: DateTime.now(),
          ));
        }
      }
    }

    return recommendations;
  }

  /// Detect plateaus and recommend alternatives
  List<WorkoutRecommendation> _generatePlateauRecommendations(
    Map<String, ExerciseAnalytics> analytics,
    List<Exercise> availableExercises,
  ) {
    final recommendations = <WorkoutRecommendation>[];

    for (var analytic in analytics.values) {
      if (analytic.isPlateauing) {
        // Find similar exercises (same category/muscle group)
        final currentExercise = availableExercises.firstWhere(
          (e) => e.id == analytic.exerciseId,
          orElse: () => availableExercises.first,
        );

        final alternativeExercises = availableExercises.where((e) =>
          e.id != analytic.exerciseId &&
          e.category == currentExercise.category &&
          e.exerciseType == currentExercise.exerciseType
        ).toList();

        if (alternativeExercises.isNotEmpty) {
          final alternative = alternativeExercises.first;
          
          recommendations.add(WorkoutRecommendation(
            id: _uuid.v4(),
            exerciseId: alternative.id,
            exercise: alternative,
            type: RecommendationType.plateau,
            priority: RecommendationPriority.high,
            title: 'Break plateau: Try ${alternative.name}',
            description: 'Your ${analytic.exerciseName} progress has plateaued. Try this alternative to stimulate new growth.',
            suggestedParameters: {
              'weight': (analytic.maxWeight ?? 0) * 0.85, // Start 15% lighter
              'reps': 10,
            },
            reasoning: 'No weight increase in last 5 workouts',
            createdAt: DateTime.now(),
          ));
        }
      }
    }

    return recommendations;
  }

  /// Generate sport-specific conditioning recommendations
  List<WorkoutRecommendation> _generateSportConditioningRecommendations(
    String sport,
    List<Exercise> availableExercises,
    List<Workout> workoutHistory,
  ) {
    final recommendations = <WorkoutRecommendation>[];

    // Get conditioning exercises relevant to the sport
    final conditioningExercises = _getConditioningExercisesForSport(sport);

    // Check which conditioning exercises user hasn't done recently
    final recentExerciseIds = workoutHistory
        .take(5)
        .expand((w) => w.sets)
        .map((s) => s.exerciseId)
        .toSet();

    for (var conditioningInfo in conditioningExercises) {
      final exerciseName = conditioningInfo['name'] as String;
      
      // Check if this exercise exists in available exercises
      final matchingExercise = availableExercises.firstWhere(
        (e) => e.name.toLowerCase().contains(exerciseName.toLowerCase()),
        orElse: () => Exercise(
          id: _uuid.v4(),
          name: exerciseName,
          category: 'Conditioning',
          exerciseType: ExerciseType.cardio,
          createdAt: DateTime.now(),
          isPredefined: true,
        ),
      );

      // Only recommend if not done recently
      if (!recentExerciseIds.contains(matchingExercise.id)) {
        recommendations.add(WorkoutRecommendation(
          id: _uuid.v4(),
          exerciseId: matchingExercise.id,
          exercise: matchingExercise,
          type: RecommendationType.sportConditioning,
          priority: RecommendationPriority.medium,
          title: 'Sport conditioning: ${matchingExercise.name}',
          description: conditioningInfo['description'] as String,
          suggestedParameters: conditioningInfo['parameters'] as Map<String, dynamic>,
          reasoning: 'Recommended for $sport athletes',
          createdAt: DateTime.now(),
        ));
      }

      // Limit to 3 conditioning recommendations per session
      if (recommendations.length >= 3) break;
    }

    return recommendations;
  }

  /// Generate variety recommendations for undertrained exercises
  List<WorkoutRecommendation> _generateVarietyRecommendations(
    Map<String, ExerciseAnalytics> analytics,
    List<Exercise> availableExercises,
    List<Workout> workoutHistory,
  ) {
    final recommendations = <WorkoutRecommendation>[];

    // Find exercises not done in last 14 days
    final recentExerciseIds = workoutHistory
        .where((w) => DateTime.now().difference(w.date).inDays <= 14)
        .expand((w) => w.sets)
        .map((s) => s.exerciseId)
        .toSet();

    for (var exercise in availableExercises) {
      if (!recentExerciseIds.contains(exercise.id) && 
          analytics.containsKey(exercise.id)) {
        final analytic = analytics[exercise.id]!;
        
        recommendations.add(WorkoutRecommendation(
          id: _uuid.v4(),
          exerciseId: exercise.id,
          exercise: exercise,
          type: RecommendationType.variety,
          priority: RecommendationPriority.low,
          title: 'Add variety: ${exercise.name}',
          description: 'You haven\'t done this exercise in ${analytic.daysSinceLastPerformed} days.',
          suggestedParameters: {
            'weight': analytic.maxWeight ?? 20.0,
            'reps': 10,
          },
          reasoning: 'Last performed ${analytic.daysSinceLastPerformed} days ago',
          createdAt: DateTime.now(),
        ));

        if (recommendations.length >= 2) break;
      }
    }

    return recommendations;
  }

  /// Generate deload recommendations based on fatigue indicators
  List<WorkoutRecommendation> _generateDeloadRecommendations(
    Map<String, ExerciseAnalytics> analytics,
    List<Workout> workoutHistory,
  ) {
    final recommendations = <WorkoutRecommendation>[];

    // Check workout frequency (if 5+ workouts in last 7 days, suggest deload)
    final recentWorkouts = workoutHistory
        .where((w) => DateTime.now().difference(w.date).inDays <= 7)
        .length;

    if (recentWorkouts >= 5) {
      // Suggest deload for main compound lifts
      for (var analytic in analytics.values.take(3)) {
        if (analytic.maxWeight != null) {
          recommendations.add(WorkoutRecommendation(
            id: _uuid.v4(),
            exerciseId: analytic.exerciseId,
            type: RecommendationType.deload,
            priority: RecommendationPriority.high,
            title: 'Deload week: Reduce ${analytic.exerciseName} intensity',
            description: 'You\'ve trained hard recently. Consider reducing weight by 20% to recover.',
            suggestedParameters: {
              'weight': analytic.maxWeight! * 0.8,
              'reps': 8,
            },
            reasoning: '$recentWorkouts workouts in the past week',
            createdAt: DateTime.now(),
          ));
        }
      }
    }

    return recommendations;
  }

  /// Calculate progressive weight increase based on current weight
  double _calculateProgressiveWeight(double currentWeight) {
    // Smaller increments for lighter weights, larger for heavier
    if (currentWeight < 20) {
      return currentWeight + 1.25; // 1.25kg increment
    } else if (currentWeight < 60) {
      return currentWeight + 2.5; // 2.5kg increment
    } else {
      return currentWeight + 5.0; // 5kg increment
    }
  }

  /// Get sport-specific conditioning exercises
  List<Map<String, dynamic>> _getConditioningExercisesForSport(String sport) {
    final sportLower = sport.toLowerCase();

    // Basketball conditioning
    if (sportLower.contains('basketball') || sportLower.contains('volleyball')) {
      return [
        {
          'name': 'Box Jumps',
          'description': 'Explosive power for vertical leap. Jump onto a 20-24" box.',
          'parameters': {'sets': 3, 'reps': 8, 'rest': 120},
        },
        {
          'name': 'Lateral Bounds',
          'description': 'Lateral explosiveness for quick directional changes.',
          'parameters': {'sets': 3, 'reps': 10, 'rest': 90},
        },
        {
          'name': 'Medicine Ball Slams',
          'description': 'Full-body power development.',
          'parameters': {'sets': 4, 'reps': 12, 'rest': 60},
        },
      ];
    }

    // Soccer/Football conditioning
    if (sportLower.contains('soccer') || sportLower.contains('football')) {
      return [
        {
          'name': 'Shuttle Runs',
          'description': 'Agility and speed for quick directional changes.',
          'parameters': {'sets': 5, 'duration': 30, 'rest': 60},
        },
        {
          'name': 'Sled Push',
          'description': 'Build acceleration and leg power.',
          'parameters': {'sets': 4, 'distance': 20, 'rest': 120},
        },
        {
          'name': 'High-Knee Runs',
          'description': 'Improve running form and hip flexor strength.',
          'parameters': {'sets': 4, 'duration': 20, 'rest': 45},
        },
      ];
    }

    // Tennis/Racquet sports
    if (sportLower.contains('tennis') || sportLower.contains('badminton')) {
      return [
        {
          'name': 'Ladder Drills',
          'description': 'Foot speed and agility for court movement.',
          'parameters': {'sets': 4, 'duration': 30, 'rest': 60},
        },
        {
          'name': 'Medicine Ball Rotations',
          'description': 'Rotational power for serves and strokes.',
          'parameters': {'sets': 3, 'reps': 12, 'rest': 60},
        },
      ];
    }

    // Running/Endurance sports
    if (sportLower.contains('running') || sportLower.contains('cycling') || 
        sportLower.contains('triathlon')) {
      return [
        {
          'name': 'Assault Bike Intervals',
          'description': 'Build cardiovascular endurance without impact.',
          'parameters': {'sets': 5, 'duration': 60, 'rest': 90},
        },
        {
          'name': 'Burpees',
          'description': 'Full-body conditioning and mental toughness.',
          'parameters': {'sets': 4, 'reps': 15, 'rest': 60},
        },
      ];
    }

    // Default general athletic conditioning
    return [
      {
        'name': 'Burpees',
        'description': 'Full-body conditioning exercise.',
        'parameters': {'sets': 3, 'reps': 10, 'rest': 60},
      },
      {
        'name': 'Jump Squats',
        'description': 'Lower body power and explosiveness.',
        'parameters': {'sets': 3, 'reps': 12, 'rest': 90},
      },
    ];
  }
}
