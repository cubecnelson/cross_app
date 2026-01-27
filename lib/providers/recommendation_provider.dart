import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/workout_recommendation.dart';
import '../services/recommendation_service.dart';
import 'auth_provider.dart';
import 'workout_provider.dart';
import 'exercise_provider.dart';

final recommendationServiceProvider = Provider<RecommendationService>((ref) {
  return RecommendationService();
});

/// Provider for workout recommendations
final workoutRecommendationsProvider = FutureProvider<List<WorkoutRecommendation>>((ref) async {
  final service = ref.watch(recommendationServiceProvider);
  final user = ref.watch(currentUserProvider);
  
  if (user == null) return [];

  // Get workout history
  final workoutsAsync = ref.watch(workoutsProvider);
  final exercisesAsync = ref.watch(exercisesProvider);

  return workoutsAsync.when(
    data: (workouts) {
      return exercisesAsync.when(
        data: (exercises) {
          // TODO: Get user profile with goals/sport preferences
          // For now, use default values
          return service.generateRecommendations(
            workoutHistory: workouts,
            availableExercises: exercises,
            userProfile: null,
            userGoal: null,
            primarySport: null,
          );
        },
        loading: () => [],
        error: (_, __) => [],
      );
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider for recommendations filtered by type
final recommendationsByTypeProvider = Provider.family<List<WorkoutRecommendation>, RecommendationType>(
  (ref, type) {
    final recommendationsAsync = ref.watch(workoutRecommendationsProvider);
    
    return recommendationsAsync.when(
      data: (recommendations) => recommendations.where((r) => r.type == type).toList(),
      loading: () => [],
      error: (_, __) => [],
    );
  },
);

/// Provider for high-priority recommendations only
final priorityRecommendationsProvider = Provider<List<WorkoutRecommendation>>((ref) {
  final recommendationsAsync = ref.watch(workoutRecommendationsProvider);
  
  return recommendationsAsync.when(
    data: (recommendations) => recommendations
        .where((r) => r.priority == RecommendationPriority.high)
        .toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Notifier for managing recommendation state
class RecommendationNotifier extends StateNotifier<AsyncValue<List<WorkoutRecommendation>>> {
  final RecommendationService _service;
  final Ref _ref;

  RecommendationNotifier(this._service, this._ref) : super(const AsyncValue.loading());

  Future<void> refreshRecommendations() async {
    state = const AsyncValue.loading();
    
    try {
      final workoutsAsync = _ref.read(workoutsProvider);
      final exercisesAsync = _ref.read(exercisesProvider);

      await workoutsAsync.when(
        data: (workouts) async {
          await exercisesAsync.when(
            data: (exercises) async {
              final recommendations = _service.generateRecommendations(
                workoutHistory: workouts,
                availableExercises: exercises,
              );
              state = AsyncValue.data(recommendations);
            },
            loading: () async {
              state = const AsyncValue.data([]);
            },
            error: (error, stack) async {
              state = AsyncValue.error(error, stack);
            },
          );
        },
        loading: () async {
          state = const AsyncValue.data([]);
        },
        error: (error, stack) async {
          state = AsyncValue.error(error, stack);
        },
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Dismiss a recommendation (could store dismissed IDs in local storage)
  void dismissRecommendation(String recommendationId) {
    state.whenData((recommendations) {
      state = AsyncValue.data(
        recommendations.where((r) => r.id != recommendationId).toList(),
      );
    });
  }
}

final recommendationNotifierProvider = StateNotifierProvider<RecommendationNotifier, AsyncValue<List<WorkoutRecommendation>>>((ref) {
  final service = ref.watch(recommendationServiceProvider);
  return RecommendationNotifier(service, ref);
});
