import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';
import '../models/routine.dart';

class RoutineRepository {
  final SupabaseClient _client = SupabaseConfig.client;

  Future<List<Routine>> getRoutinesByUserId(String userId) async {
    try {
      final response = await _client
          .from('routines')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((json) => Routine.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get routines: ${e.toString()}');
    }
  }

  Future<Routine?> getRoutineById(String routineId) async {
    try {
      final response = await _client
          .from('routines')
          .select()
          .eq('id', routineId)
          .single();
      
      return Routine.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get routine: ${e.toString()}');
    }
  }

  Future<Routine> createRoutine(Routine routine) async {
    try {
      final response = await _client
          .from('routines')
          .insert(routine.toJson())
          .select()
          .single();
      
      return Routine.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create routine: ${e.toString()}');
    }
  }

  Future<Routine> updateRoutine(Routine routine) async {
    try {
      final response = await _client
          .from('routines')
          .update(routine.toJson())
          .eq('id', routine.id)
          .select()
          .single();
      
      return Routine.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update routine: ${e.toString()}');
    }
  }

  Future<void> deleteRoutine(String routineId) async {
    try {
      await _client.from('routines').delete().eq('id', routineId);
    } catch (e) {
      throw Exception('Failed to delete routine: ${e.toString()}');
    }
  }

  Future<List<Routine>> searchRoutines(String userId, String searchTerm) async {
    try {
      final response = await _client
          .from('routines')
          .select()
          .eq('user_id', userId)
          .ilike('name', '%$searchTerm%')
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((json) => Routine.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to search routines: ${e.toString()}');
    }
  }
}

