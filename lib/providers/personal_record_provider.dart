import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/personal_record.dart';
import '../models/workout.dart';
import '../repositories/personal_record_repository.dart';
import 'auth_provider.dart';
import '../services/pr_service.dart';

final personalRecordRepositoryProvider = Provider<PersonalRecordRepository>((ref) {
  return PersonalRecordRepository();
});

final personalRecordsProvider = FutureProvider<List<PersonalRecord>>((ref) async {
  final repository = ref.watch(personalRecordRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  
  if (user == null) return [];
  
  return await repository.getPersonalRecordsByUserId(user.id);
});

final personalRecordsByExerciseProvider = FutureProvider.family<List<PersonalRecord>, String>(
  (ref, exerciseId) async {
    final repository = ref.watch(personalRecordRepositoryProvider);
    final user = ref.watch(currentUserProvider);
    
    if (user == null) return [];
    
    return await repository.getPersonalRecordsByExercise(user.id, exerciseId);
  },
);

final prStatisticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(personalRecordRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  
  if (user == null) return {
    'totalPRs': 0,
    'total1RMs': 0,
    'best1RM': null,
    'best1RMExercise': null,
    'recentPRs': 0,
    'streak': 0,
  };
  
  return await repository.getPRStatistics(user.id);
});

final bestPRsByExerciseProvider = FutureProvider<Map<String, PersonalRecord>>((ref) async {
  final repository = ref.watch(personalRecordRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  
  if (user == null) return {};
  
  return await repository.getBestPRsByExercise(user.id);
});

final exerciseProgressionProvider = FutureProvider.family<List<Map<String, dynamic>>, String>(
  (ref, exerciseId) async {
    final repository = ref.watch(personalRecordRepositoryProvider);
    final user = ref.watch(currentUserProvider);
    
    if (user == null) return [];
    
    return await repository.getExerciseProgression(user.id, exerciseId);
  },
);

class PersonalRecordNotifier extends StateNotifier<AsyncValue<List<PersonalRecord>>> {
  final PersonalRecordRepository _repository;
  final String? _userId;

  PersonalRecordNotifier(this._repository, this._userId)
      : super(const AsyncValue.loading()) {
    if (_userId != null) {
      loadPersonalRecords();
    }
  }

  Future<void> loadPersonalRecords() async {
    if (_userId == null) return;
    
    state = const AsyncValue.loading();
    try {
      final records = await _repository.getPersonalRecordsByUserId(_userId!);
      state = AsyncValue.data(records);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> savePersonalRecord(PersonalRecord record) async {
    try {
      final savedRecord = await _repository.savePersonalRecord(record);
      state.whenData((records) {
        state = AsyncValue.data([savedRecord, ...records]);
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> savePersonalRecords(List<PersonalRecord> records) async {
    try {
      final savedRecords = await _repository.savePersonalRecords(records);
      state.whenData((existingRecords) {
        state = AsyncValue.data([...savedRecords, ...existingRecords]);
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> updatePersonalRecord(PersonalRecord record) async {
    try {
      final updatedRecord = await _repository.updatePersonalRecord(record);
      state.whenData((records) {
        final index = records.indexWhere((r) => r.id == record.id);
        if (index != -1) {
          final updatedList = [...records];
          updatedList[index] = updatedRecord;
          state = AsyncValue.data(updatedList);
        }
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> deletePersonalRecord(String recordId) async {
    try {
      await _repository.deletePersonalRecord(recordId);
      state.whenData((records) {
        state = AsyncValue.data(
          records.where((r) => r.id != recordId).toList(),
        );
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Auto-detect PRs from workouts and save them
  Future<List<PersonalRecord>> detectAndSavePRsFromWorkouts(
    List<Workout> workouts,
    List<PersonalRecord> existingPRs,
  ) async {
    if (_userId == null) return [];

    try {
      final newPRs = PrService.detectPRs(
        existingPRs: existingPRs,
        recentWorkouts: workouts,
        userId: _userId!,
      );

      if (newPRs.isNotEmpty) {
        await savePersonalRecords(newPRs);
      }

      return newPRs;
    } catch (e) {
      print('Error detecting PRs: $e');
      rethrow;
    }
  }

  /// Get milestones/achievements based on PRs
  Future<List<Map<String, dynamic>>> getMilestones() async {
    state.whenData((records) {
      return PrService.getMilestones(records);
    });
    
    // If no data yet, return empty list
    return [];
  }

  /// Check if a set is already recorded as a PR
  Future<bool> isSetAlreadyPR(String workoutSetId) async {
    try {
      return await _repository.isSetAlreadyPR(workoutSetId);
    } catch (e) {
      print('Error checking if set is PR: $e');
      return false;
    }
  }
}

final personalRecordNotifierProvider =
    StateNotifierProvider<PersonalRecordNotifier, AsyncValue<List<PersonalRecord>>>((ref) {
  final repository = ref.watch(personalRecordRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  return PersonalRecordNotifier(repository, user?.id);
});