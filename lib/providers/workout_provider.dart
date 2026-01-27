import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/workout.dart';
import '../models/workout_set.dart';
import '../repositories/workout_repository.dart';
import 'auth_provider.dart';

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  return WorkoutRepository();
});

final workoutsProvider = FutureProvider<List<Workout>>((ref) async {
  final repository = ref.watch(workoutRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  
  if (user == null) return [];
  
  return await repository.getWorkoutsByUserId(user.id);
});

final workoutByIdProvider =
    FutureProvider.family<Workout?, String>((ref, workoutId) async {
  final repository = ref.watch(workoutRepositoryProvider);
  return await repository.getWorkoutById(workoutId);
});

class WorkoutNotifier extends StateNotifier<AsyncValue<List<Workout>>> {
  final WorkoutRepository _repository;
  final String? _userId;

  WorkoutNotifier(this._repository, this._userId)
      : super(const AsyncValue.loading()) {
    if (_userId != null) {
      loadWorkouts();
    }
  }

  Future<void> loadWorkouts() async {
    if (_userId == null) return;
    
    state = const AsyncValue.loading();
    try {
      final workouts = await _repository.getWorkoutsByUserId(_userId!);
      state = AsyncValue.data(workouts);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<Workout?> createWorkout(Workout workout) async {
    try {
      final newWorkout = await _repository.createWorkout(workout);
      state.whenData((workouts) {
        state = AsyncValue.data([newWorkout, ...workouts]);
      });
      return newWorkout;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return null;
    }
  }

  Future<void> updateWorkout(Workout workout) async {
    try {
      final updatedWorkout = await _repository.updateWorkout(workout);
      state.whenData((workouts) {
        final index = workouts.indexWhere((w) => w.id == workout.id);
        if (index != -1) {
          final updatedList = [...workouts];
          updatedList[index] = updatedWorkout;
          state = AsyncValue.data(updatedList);
        }
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteWorkout(String workoutId) async {
    try {
      await _repository.deleteWorkout(workoutId);
      state.whenData((workouts) {
        state = AsyncValue.data(
          workouts.where((w) => w.id != workoutId).toList(),
        );
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<WorkoutSet?> addSet(WorkoutSet set) async {
    try {
      return await _repository.createSet(set);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return null;
    }
  }

  Future<void> updateSet(WorkoutSet set) async {
    try {
      await _repository.updateSet(set);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteSet(String setId) async {
    try {
      await _repository.deleteSet(setId);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final workoutNotifierProvider =
    StateNotifierProvider<WorkoutNotifier, AsyncValue<List<Workout>>>((ref) {
  final repository = ref.watch(workoutRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  return WorkoutNotifier(repository, user?.id);
});

