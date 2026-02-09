import 'dart:async';
import 'package:flutter/foundation.dart';
import '../repositories/workout_repository.dart';
import '../repositories/exercise_repository.dart';
import '../repositories/routine_repository.dart';
import 'local_storage_service.dart';
import 'connectivity_service.dart';

class SyncService {
  final WorkoutRepository _workoutRepository;
  final ExerciseRepository _exerciseRepository;
  final RoutineRepository _routineRepository;

  SyncService({
    required WorkoutRepository workoutRepository,
    required ExerciseRepository exerciseRepository,
    required RoutineRepository routineRepository,
  })  : _workoutRepository = workoutRepository,
        _exerciseRepository = exerciseRepository,
        _routineRepository = routineRepository;

  // Sync workouts
  Future<void> syncWorkouts(String userId) async {
    try {
      if (await ConnectivityService.hasInternetConnection()) {
        // Fetch from server
        final workouts = await _workoutRepository.getWorkoutsByUserId(userId);
        
        // Cache the data
        final workoutsJson = workouts.map((w) => w.toJson()).toList();
        await LocalStorageService.cacheWorkouts(workoutsJson);
      }
    } catch (e) {
      // If sync fails, we'll use cached data
      debugPrint('Workout sync failed: $e');
    }
  }

  // Sync exercises
  Future<void> syncExercises(String userId) async {
    try {
      if (await ConnectivityService.hasInternetConnection()) {
        // Fetch from server
        final exercises = await _exerciseRepository.getAllExercises(userId: userId);
        
        // Cache the data
        final exercisesJson = exercises.map((e) => e.toJson()).toList();
        await LocalStorageService.cacheExercises(exercisesJson);
      }
    } catch (e) {
      debugPrint('Exercise sync failed: $e');
    }
  }

  // Sync routines
  Future<void> syncRoutines(String userId) async {
    try {
      if (await ConnectivityService.hasInternetConnection()) {
        // Fetch from server
        final routines = await _routineRepository.getRoutinesByUserId(userId);
        
        // Cache the data
        final routinesJson = routines.map((r) => r.toJson()).toList();
        await LocalStorageService.cacheRoutines(routinesJson);
      }
    } catch (e) {
      debugPrint('Routine sync failed: $e');
    }
  }

  // Sync all data
  Future<void> syncAllData(String userId) async {
    await Future.wait([
      syncWorkouts(userId),
      syncExercises(userId),
      syncRoutines(userId),
    ]);
  }

  // Auto-sync with periodic updates
  StreamSubscription<void>? startAutoSync(String userId, Duration interval) {
    return Stream.periodic(interval).listen((_) async {
      if (await ConnectivityService.hasInternetConnection()) {
        await syncAllData(userId);
      }
    });
  }
}

