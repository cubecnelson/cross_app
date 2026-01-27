import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/exercise.dart';
import '../repositories/exercise_repository.dart';
import 'auth_provider.dart';

final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  return ExerciseRepository();
});

final exercisesProvider = FutureProvider<List<Exercise>>((ref) async {
  final repository = ref.watch(exerciseRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  return await repository.getAllExercises(userId: user?.id);
});

final exercisesByCategoryProvider =
    FutureProvider.family<List<Exercise>, String>((ref, category) async {
      final repository = ref.watch(exerciseRepositoryProvider);
      final user = ref.watch(currentUserProvider);
      return await repository.getExercisesByCategory(
        category,
        userId: user?.id,
      );
    });

final searchExercisesProvider = FutureProvider.family<List<Exercise>, String>((
  ref,
  searchTerm,
) async {
  final repository = ref.watch(exerciseRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  return await repository.searchExercises(searchTerm, userId: user?.id);
});

class ExerciseNotifier extends StateNotifier<AsyncValue<List<Exercise>>> {
  final ExerciseRepository _repository;
  final String? _userId;

  ExerciseNotifier(this._repository, this._userId)
    : super(const AsyncValue.loading()) {
    loadExercises();
  }

  Future<void> loadExercises() async {
    state = const AsyncValue.loading();
    try {
      final exercises = await _repository.getAllExercises(userId: _userId);
      state = AsyncValue.data(exercises);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createExercise(Exercise exercise) async {
    try {
      final newExercise = await _repository.createExercise(exercise);
      state.whenData((exercises) {
        state = AsyncValue.data([...exercises, newExercise]);
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateExercise(Exercise exercise) async {
    try {
      final updatedExercise = await _repository.updateExercise(exercise);
      state.whenData((exercises) {
        final index = exercises.indexWhere((e) => e.id == exercise.id);
        if (index != -1) {
          final updatedList = [...exercises];
          updatedList[index] = updatedExercise;
          state = AsyncValue.data(updatedList);
        }
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteExercise(String exerciseId) async {
    try {
      await _repository.deleteExercise(exerciseId);
      state.whenData((exercises) {
        state = AsyncValue.data(
          exercises.where((e) => e.id != exerciseId).toList(),
        );
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final exerciseNotifierProvider =
    StateNotifierProvider<ExerciseNotifier, AsyncValue<List<Exercise>>>((ref) {
      final repository = ref.watch(exerciseRepositoryProvider);
      final user = ref.watch(currentUserProvider);
      return ExerciseNotifier(repository, user?.id);
    });
