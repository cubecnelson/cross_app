import 'exercise.dart';

enum RecommendationType {
  progression, // Increase weight/reps based on performance
  deload, // Reduce intensity due to fatigue indicators
  variety, // Suggest new exercises for muscle groups
  sportConditioning, // Sport-specific conditioning exercises
  plateau, // Alternative exercises to break plateaus
}

enum RecommendationPriority {
  high, // Critical recommendations (e.g., plateau detected)
  medium, // Beneficial improvements
  low, // Nice-to-have suggestions
}

class WorkoutRecommendation {
  final String id;
  final String exerciseId;
  final Exercise? exercise;
  final RecommendationType type;
  final RecommendationPriority priority;
  final String title;
  final String description;
  final Map<String, dynamic> suggestedParameters; // e.g., {'weight': 50.0, 'reps': 8}
  final String? reasoning; // Why this recommendation was made
  final DateTime createdAt;

  WorkoutRecommendation({
    required this.id,
    required this.exerciseId,
    this.exercise,
    required this.type,
    required this.priority,
    required this.title,
    required this.description,
    this.suggestedParameters = const {},
    this.reasoning,
    required this.createdAt,
  });

  WorkoutRecommendation copyWith({
    String? id,
    String? exerciseId,
    Exercise? exercise,
    RecommendationType? type,
    RecommendationPriority? priority,
    String? title,
    String? description,
    Map<String, dynamic>? suggestedParameters,
    String? reasoning,
    DateTime? createdAt,
  }) {
    return WorkoutRecommendation(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      exercise: exercise ?? this.exercise,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      title: title ?? this.title,
      description: description ?? this.description,
      suggestedParameters: suggestedParameters ?? this.suggestedParameters,
      reasoning: reasoning ?? this.reasoning,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Analytics for exercise performance over time
class ExerciseAnalytics {
  final String exerciseId;
  final String exerciseName;
  final int totalWorkouts;
  final int totalSets;
  final double? averageWeight;
  final double? maxWeight;
  final double? averageReps;
  final double? totalVolume;
  final DateTime? lastPerformed;
  final DateTime? firstPerformed;
  final List<double> recentWeights; // Last 5-10 workouts
  final List<int> recentReps; // Last 5-10 workouts
  final bool isPlateauing; // Weight hasn't increased in X workouts

  ExerciseAnalytics({
    required this.exerciseId,
    required this.exerciseName,
    required this.totalWorkouts,
    required this.totalSets,
    this.averageWeight,
    this.maxWeight,
    this.averageReps,
    this.totalVolume,
    this.lastPerformed,
    this.firstPerformed,
    this.recentWeights = const [],
    this.recentReps = const [],
    this.isPlateauing = false,
  });

  /// Calculate days since last performed
  int? get daysSinceLastPerformed {
    if (lastPerformed == null) return null;
    return DateTime.now().difference(lastPerformed!).inDays;
  }

  /// Check if exercise needs variety (same weight for 4+ workouts)
  bool get needsVariety {
    if (recentWeights.length < 4) return false;
    final lastFour = recentWeights.take(4).toList();
    return lastFour.every((w) => w == lastFour.first);
  }
}
