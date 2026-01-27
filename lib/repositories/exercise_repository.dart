import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';
import '../models/exercise.dart';

class ExerciseRepository {
  final SupabaseClient _client = SupabaseConfig.client;

  Future<List<Exercise>> getAllExercises({String? userId}) async {
    try {
      final query = _client.from('exercises').select();

      // Get both predefined and user's custom exercises
      if (userId != null) {
        query.or('is_predefined.eq.true,user_id.eq.$userId');
      } else {
        query.eq('is_predefined', true);
      }

      final response = await query.order('name');

      return (response as List).map((json) => Exercise.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get exercises: ${e.toString()}');
    }
  }

  Future<List<Exercise>> getExercisesByCategory(
    String category, {
    String? userId,
  }) async {
    try {
      final query = _client.from('exercises').select().eq('category', category);

      if (userId != null) {
        query.or('is_predefined.eq.true,user_id.eq.$userId');
      } else {
        query.eq('is_predefined', true);
      }

      final response = await query.order('name');

      return (response as List).map((json) => Exercise.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get exercises by category: ${e.toString()}');
    }
  }

  Future<List<Exercise>> searchExercises(
    String searchTerm, {
    String? userId,
  }) async {
    try {
      final query = _client
          .from('exercises')
          .select()
          .ilike('name', '%$searchTerm%');

      if (userId != null) {
        query.or('is_predefined.eq.true,user_id.eq.$userId');
      } else {
        query.eq('is_predefined', true);
      }

      final response = await query.order('name');

      return (response as List).map((json) => Exercise.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search exercises: ${e.toString()}');
    }
  }

  Future<Exercise> createExercise(Exercise exercise) async {
    try {
      final response = await _client
          .from('exercises')
          .insert(exercise.toJson())
          .select()
          .single();

      return Exercise.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create exercise: ${e.toString()}');
    }
  }

  Future<Exercise> updateExercise(Exercise exercise) async {
    try {
      final response = await _client
          .from('exercises')
          .update(exercise.toJson())
          .eq('id', exercise.id)
          .select()
          .single();

      return Exercise.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update exercise: ${e.toString()}');
    }
  }

  Future<void> deleteExercise(String exerciseId) async {
    try {
      await _client.from('exercises').delete().eq('id', exerciseId);
    } catch (e) {
      throw Exception('Failed to delete exercise: ${e.toString()}');
    }
  }

  Future<Exercise?> getExerciseById(String exerciseId) async {
    try {
      final response = await _client
          .from('exercises')
          .select()
          .eq('id', exerciseId)
          .single();

      return Exercise.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get exercise: ${e.toString()}');
    }
  }
}
