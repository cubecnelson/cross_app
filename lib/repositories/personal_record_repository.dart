import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/personal_record.dart';
import '../core/config/supabase_config.dart';

class PersonalRecordRepository {
  final SupabaseClient _supabase = SupabaseConfig.supabaseClient;

  /// Get all personal records for a user
  Future<List<PersonalRecord>> getPersonalRecordsByUserId(String userId) async {
    try {
      final response = await _supabase
          .from('personal_records')
          .select('*')
          .eq('user_id', userId)
          .order('date', ascending: false);

      final records = (response as List)
          .map((json) => PersonalRecord.fromJson(json))
          .toList();

      return records;
    } catch (e) {
      print('Error fetching personal records: $e');
      rethrow;
    }
  }

  /// Get personal records for a specific exercise
  Future<List<PersonalRecord>> getPersonalRecordsByExercise(
    String userId,
    String exerciseId,
  ) async {
    try {
      final response = await _supabase
          .from('personal_records')
          .select('*')
          .eq('user_id', userId)
          .eq('exercise_id', exerciseId)
          .order('date', ascending: false);

      final records = (response as List)
          .map((json) => PersonalRecord.fromJson(json))
          .toList();

      return records;
    } catch (e) {
      print('Error fetching exercise PRs: $e');
      rethrow;
    }
  }

  /// Save a personal record
  Future<PersonalRecord> savePersonalRecord(PersonalRecord record) async {
    try {
      final recordJson = record.toJson();
      
      final response = await _supabase
          .from('personal_records')
          .insert(recordJson)
          .select()
          .single();

      return PersonalRecord.fromJson(response);
    } catch (e) {
      print('Error saving personal record: $e');
      rethrow;
    }
  }

  /// Save multiple personal records
  Future<List<PersonalRecord>> savePersonalRecords(List<PersonalRecord> records) async {
    try {
      if (records.isEmpty) return [];

      final recordsJson = records.map((r) => r.toJson()).toList();
      
      final response = await _supabase
          .from('personal_records')
          .insert(recordsJson)
          .select();

      final savedRecords = (response as List)
          .map((json) => PersonalRecord.fromJson(json))
          .toList();

      return savedRecords;
    } catch (e) {
      print('Error saving personal records: $e');
      rethrow;
    }
  }

  /// Update a personal record
  Future<PersonalRecord> updatePersonalRecord(PersonalRecord record) async {
    try {
      final recordJson = record.toJson();
      
      final response = await _supabase
          .from('personal_records')
          .update(recordJson)
          .eq('id', record.id)
          .select()
          .single();

      return PersonalRecord.fromJson(response);
    } catch (e) {
      print('Error updating personal record: $e');
      rethrow;
    }
  }

  /// Delete a personal record
  Future<void> deletePersonalRecord(String recordId) async {
    try {
      await _supabase
          .from('personal_records')
          .delete()
          .eq('id', recordId);
    } catch (e) {
      print('Error deleting personal record: $e');
      rethrow;
    }
  }

  /// Delete all personal records for a user (for testing/cleanup)
  Future<void> deleteAllPersonalRecords(String userId) async {
    try {
      await _supabase
          .from('personal_records')
          .delete()
          .eq('user_id', userId);
    } catch (e) {
      print('Error deleting all personal records: $e');
      rethrow;
    }
  }

  /// Check if a set is already recorded as a PR
  Future<bool> isSetAlreadyPR(String workoutSetId) async {
    try {
      final response = await _supabase
          .from('personal_records')
          .select('id')
          .eq('workout_set_id', workoutSetId)
          .limit(1);

      return (response as List).isNotEmpty;
    } catch (e) {
      print('Error checking if set is PR: $e');
      return false;
    }
  }

  /// Get PR statistics for a user
  Future<Map<String, dynamic>> getPRStatistics(String userId) async {
    try {
      // Get all PRs
      final prs = await getPersonalRecordsByUserId(userId);
      
      if (prs.isEmpty) {
        return {
          'totalPRs': 0,
          'total1RMs': 0,
          'best1RM': null,
          'best1RMExercise': null,
          'recentPRs': 0,
          'streak': 0,
        };
      }

      // Calculate statistics
      final last30Days = DateTime.now().subtract(const Duration(days: 30));
      final recentPRs = prs.where((pr) => pr.date.isAfter(last30Days)).length;

      final oneRMs = prs.where((pr) => pr.reps == 1).toList();
      final best1RM = oneRMs.isNotEmpty
          ? oneRMs.reduce((a, b) => a.weight > b.weight ? a : b)
          : null;

      // Calculate streak (consecutive days with PRs)
      final sortedByDate = List<PersonalRecord>.from(prs)
        ..sort((a, b) => b.date.compareTo(a.date));
      
      int streak = 1;
      for (int i = 1; i < sortedByDate.length; i++) {
        final previousDate = sortedByDate[i - 1].date;
        final currentDate = sortedByDate[i].date;
        final daysBetween = currentDate.difference(previousDate).inDays;
        
        if (daysBetween == 1) {
          streak++;
        } else {
          break;
        }
      }

      return {
        'totalPRs': prs.length,
        'total1RMs': oneRMs.length,
        'best1RM': best1RM?.weight,
        'best1RMExercise': best1RM?.exerciseName,
        'recentPRs': recentPRs,
        'streak': streak,
      };
    } catch (e) {
      print('Error getting PR statistics: $e');
      rethrow;
    }
  }

  /// Get best PR for each exercise
  Future<Map<String, PersonalRecord>> getBestPRsByExercise(String userId) async {
    try {
      final prs = await getPersonalRecordsByUserId(userId);
      
      final bestPRs = <String, PersonalRecord>{};
      
      for (final pr in prs) {
        final currentBest = bestPRs[pr.exerciseId];
        if (currentBest == null || pr.isBetterThan(currentBest)) {
          bestPRs[pr.exerciseId] = pr;
        }
      }

      return bestPRs;
    } catch (e) {
      print('Error getting best PRs by exercise: $e');
      rethrow;
    }
  }

  /// Get exercise progression over time
  Future<List<Map<String, dynamic>>> getExerciseProgression(
    String userId,
    String exerciseId,
  ) async {
    try {
      final exercisePRs = await getPersonalRecordsByExercise(userId, exerciseId);
      
      final sortedPRs = List<PersonalRecord>.from(exercisePRs)
        ..sort((a, b) => a.date.compareTo(b.date));

      return sortedPRs.map((pr) {
        return {
          'date': pr.date,
          'weight': pr.weight,
          'reps': pr.reps,
          'estimated1RM': pr.calculatedOneRepMax,
          'type': pr.type,
          'workoutId': pr.workoutId,
        };
      }).toList();
    } catch (e) {
      print('Error getting exercise progression: $e');
      rethrow;
    }
  }
}