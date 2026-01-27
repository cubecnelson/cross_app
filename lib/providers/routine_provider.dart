import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/routine.dart';
import '../repositories/routine_repository.dart';
import 'auth_provider.dart';

final routineRepositoryProvider = Provider<RoutineRepository>((ref) {
  return RoutineRepository();
});

final routinesProvider = FutureProvider<List<Routine>>((ref) async {
  final repository = ref.watch(routineRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  
  if (user == null) return [];
  
  return await repository.getRoutinesByUserId(user.id);
});

final routineByIdProvider =
    FutureProvider.family<Routine?, String>((ref, routineId) async {
  final repository = ref.watch(routineRepositoryProvider);
  return await repository.getRoutineById(routineId);
});

class RoutineNotifier extends StateNotifier<AsyncValue<List<Routine>>> {
  final RoutineRepository _repository;
  final String? _userId;

  RoutineNotifier(this._repository, this._userId)
      : super(const AsyncValue.loading()) {
    if (_userId != null) {
      loadRoutines();
    }
  }

  Future<void> loadRoutines() async {
    if (_userId == null) return;
    
    state = const AsyncValue.loading();
    try {
      final routines = await _repository.getRoutinesByUserId(_userId!);
      state = AsyncValue.data(routines);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<Routine?> createRoutine(Routine routine) async {
    try {
      final newRoutine = await _repository.createRoutine(routine);
      state.whenData((routines) {
        state = AsyncValue.data([newRoutine, ...routines]);
      });
      return newRoutine;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return null;
    }
  }

  Future<void> updateRoutine(Routine routine) async {
    try {
      final updatedRoutine = await _repository.updateRoutine(routine);
      state.whenData((routines) {
        final index = routines.indexWhere((r) => r.id == routine.id);
        if (index != -1) {
          final updatedList = [...routines];
          updatedList[index] = updatedRoutine;
          state = AsyncValue.data(updatedList);
        }
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteRoutine(String routineId) async {
    try {
      await _repository.deleteRoutine(routineId);
      state.whenData((routines) {
        state = AsyncValue.data(
          routines.where((r) => r.id != routineId).toList(),
        );
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final routineNotifierProvider =
    StateNotifierProvider<RoutineNotifier, AsyncValue<List<Routine>>>((ref) {
  final repository = ref.watch(routineRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  return RoutineNotifier(repository, user?.id);
});

