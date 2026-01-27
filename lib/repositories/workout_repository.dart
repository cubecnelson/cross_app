import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';
import '../models/workout.dart';
import '../models/workout_set.dart';

class WorkoutRepository {
  final SupabaseClient _client = SupabaseConfig.client;

  Future<List<Workout>> getWorkoutsByUserId(String userId) async {
    try {
      final response = await _client
          .from('workouts')
          .select()
          .eq('user_id', userId)
          .order('date', ascending: false);
      
      final workouts = (response as List)
          .map((json) => Workout.fromJson(json))
          .toList();

      // Fetch sets for each workout
      for (var i = 0; i < workouts.length; i++) {
        workouts[i] = await _loadWorkoutSets(workouts[i]);
      }

      return workouts;
    } catch (e) {
      throw Exception('Failed to get workouts: ${e.toString()}');
    }
  }

  Future<List<Workout>> getWorkoutsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response = await _client
          .from('workouts')
          .select()
          .eq('user_id', userId)
          .gte('date', startDate.toIso8601String())
          .lte('date', endDate.toIso8601String())
          .order('date', ascending: false);
      
      final workouts = (response as List)
          .map((json) => Workout.fromJson(json))
          .toList();

      // Fetch sets for each workout
      for (var i = 0; i < workouts.length; i++) {
        workouts[i] = await _loadWorkoutSets(workouts[i]);
      }

      return workouts;
    } catch (e) {
      throw Exception('Failed to get workouts by date range: ${e.toString()}');
    }
  }

  Future<Workout?> getWorkoutById(String workoutId) async {
    try {
      final response = await _client
          .from('workouts')
          .select()
          .eq('id', workoutId)
          .single();
      
      final workout = Workout.fromJson(response);
      return await _loadWorkoutSets(workout);
    } catch (e) {
      throw Exception('Failed to get workout: ${e.toString()}');
    }
  }

  Future<Workout> createWorkout(Workout workout) async {
    try {
      final response = await _client
          .from('workouts')
          .insert(workout.toJson())
          .select()
          .single();
      
      return Workout.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create workout: ${e.toString()}');
    }
  }

  Future<Workout> updateWorkout(Workout workout) async {
    try {
      final response = await _client
          .from('workouts')
          .update(workout.toJson())
          .eq('id', workout.id)
          .select()
          .single();
      
      return Workout.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update workout: ${e.toString()}');
    }
  }

  Future<void> deleteWorkout(String workoutId) async {
    try {
      // Delete sets first (cascade should handle this, but being explicit)
      await _client.from('sets').delete().eq('workout_id', workoutId);
      
      // Delete workout
      await _client.from('workouts').delete().eq('id', workoutId);
    } catch (e) {
      throw Exception('Failed to delete workout: ${e.toString()}');
    }
  }

  Future<WorkoutSet> createSet(WorkoutSet set) async {
    try {
      final response = await _client
          .from('sets')
          .insert(set.toJson())
          .select()
          .single();
      
      return WorkoutSet.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create set: ${e.toString()}');
    }
  }

  Future<WorkoutSet> updateSet(WorkoutSet set) async {
    try {
      final response = await _client
          .from('sets')
          .update(set.toJson())
          .eq('id', set.id)
          .select()
          .single();
      
      return WorkoutSet.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update set: ${e.toString()}');
    }
  }

  Future<void> deleteSet(String setId) async {
    try {
      await _client.from('sets').delete().eq('id', setId);
    } catch (e) {
      throw Exception('Failed to delete set: ${e.toString()}');
    }
  }

  Future<List<WorkoutSet>> getSetsByWorkoutId(String workoutId) async {
    try {
      final response = await _client
          .from('sets')
          .select()
          .eq('workout_id', workoutId)
          .order('set_number');
      
      return (response as List)
          .map((json) => WorkoutSet.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get sets: ${e.toString()}');
    }
  }

  Future<Workout> _loadWorkoutSets(Workout workout) async {
    final sets = await getSetsByWorkoutId(workout.id);
    print('💪 Loaded ${sets.length} sets for workout ${workout.id}');
    return workout.copyWith(sets: sets);
  }
}

