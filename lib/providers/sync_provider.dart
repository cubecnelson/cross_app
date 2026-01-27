import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/workout_repository.dart';
import '../repositories/exercise_repository.dart';
import '../repositories/routine_repository.dart';
import '../services/sync_service.dart';
import 'auth_provider.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    workoutRepository: WorkoutRepository(),
    exerciseRepository: ExerciseRepository(),
    routineRepository: RoutineRepository(),
  );
});

final syncStatusProvider = StateProvider<SyncStatus>((ref) {
  return SyncStatus.idle;
});

enum SyncStatus {
  idle,
  syncing,
  synced,
  error,
}

class SyncNotifier extends StateNotifier<SyncStatus> {
  final SyncService _syncService;
  final String? _userId;

  SyncNotifier(this._syncService, this._userId) : super(SyncStatus.idle);

  Future<void> syncAll() async {
    if (_userId == null) return;
    
    state = SyncStatus.syncing;
    
    try {
      await _syncService.syncAllData(_userId!);
      state = SyncStatus.synced;
      
      // Reset to idle after 2 seconds
      await Future.delayed(const Duration(seconds: 2));
      state = SyncStatus.idle;
    } catch (e) {
      state = SyncStatus.error;
      
      // Reset to idle after 2 seconds
      await Future.delayed(const Duration(seconds: 2));
      state = SyncStatus.idle;
    }
  }

  Future<void> syncWorkouts() async {
    if (_userId == null) return;
    await _syncService.syncWorkouts(_userId!);
  }

  Future<void> syncExercises() async {
    if (_userId == null) return;
    await _syncService.syncExercises(_userId!);
  }

  Future<void> syncRoutines() async {
    if (_userId == null) return;
    await _syncService.syncRoutines(_userId!);
  }
}

final syncNotifierProvider =
    StateNotifierProvider<SyncNotifier, SyncStatus>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  final user = ref.watch(currentUserProvider);
  return SyncNotifier(syncService, user?.id);
});

