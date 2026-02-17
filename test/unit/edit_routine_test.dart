import 'package:flutter_test/flutter_test.dart';
import 'package:cross/models/routine.dart';
import 'package:cross/core/utils/validators.dart';

void main() {
  group('EditRoutine - Routine Model', () {
    test('copyWith creates updated routine with new values', () {
      final originalRoutine = Routine(
        id: 'test-id-1',
        userId: 'user-1',
        name: 'Original Name',
        description: 'Original Description',
        exercises: [
          RoutineExercise(
            exerciseId: 'ex-1',
            exerciseName: 'Bench Press',
            sets: 3,
            reps: 10,
            order: 0,
          ),
        ],
        createdAt: DateTime(2023, 1, 1),
      );

      final updatedRoutine = originalRoutine.copyWith(
        name: 'Updated Name',
        description: 'Updated Description',
        updatedAt: DateTime(2023, 12, 25),
      );

      expect(updatedRoutine.name, 'Updated Name');
      expect(updatedRoutine.description, 'Updated Description');
      expect(updatedRoutine.id, originalRoutine.id);
      expect(updatedRoutine.userId, originalRoutine.userId);
      expect(updatedRoutine.exercises, originalRoutine.exercises);
      expect(updatedRoutine.updatedAt, DateTime(2023, 12, 25));
    });

    test('copyWith preserves original values when not specified', () {
      final originalRoutine = Routine(
        id: 'test-id-1',
        userId: 'user-1',
        name: 'Original Name',
        description: 'Original Description',
        exercises: [],
        createdAt: DateTime(2023, 1, 1),
      );

      final updatedRoutine = originalRoutine.copyWith(
        name: 'Updated Name',
      );

      expect(updatedRoutine.name, 'Updated Name');
      expect(updatedRoutine.description, 'Original Description');
      expect(updatedRoutine.id, originalRoutine.id);
    });

    test('copyWith can update exercises list', () {
      final originalRoutine = Routine(
        id: 'test-id-1',
        userId: 'user-1',
        name: 'Test Routine',
        exercises: [
          RoutineExercise(
            exerciseId: 'ex-1',
            exerciseName: 'Exercise 1',
            sets: 3,
            reps: 10,
            order: 0,
          ),
        ],
        createdAt: DateTime(2023, 1, 1),
      );

      final updatedExercises = [
        RoutineExercise(
          exerciseId: 'ex-1',
          exerciseName: 'Exercise 1',
          sets: 3,
          reps: 10,
          order: 0,
        ),
        RoutineExercise(
          exerciseId: 'ex-2',
          exerciseName: 'Exercise 2',
          sets: 4,
          reps: 12,
          order: 1,
        ),
      ];

      final updatedRoutine = originalRoutine.copyWith(
        exercises: updatedExercises,
      );

      expect(updatedRoutine.exercises.length, 2);
      expect(updatedRoutine.exercises[1].exerciseName, 'Exercise 2');
    });
  });

  group('EditRoutine - RoutineExercise Model', () {
    test('copyWith updates exercise properties correctly', () {
      final originalExercise = RoutineExercise(
        exerciseId: 'ex-1',
        exerciseName: 'Bench Press',
        sets: 3,
        reps: 10,
        weight: 100.0,
        restTime: 90,
        order: 0,
      );

      final updatedExercise = originalExercise.copyWith(
        sets: 4,
        reps: 12,
        weight: 110.0,
      );

      expect(updatedExercise.sets, 4);
      expect(updatedExercise.reps, 12);
      expect(updatedExercise.weight, 110.0);
      expect(updatedExercise.exerciseId, originalExercise.exerciseId);
      expect(updatedExercise.restTime, originalExercise.restTime);
    });

    test('copyWith preserves original values when not specified', () {
      final originalExercise = RoutineExercise(
        exerciseId: 'ex-1',
        exerciseName: 'Bench Press',
        sets: 3,
        reps: 10,
        order: 0,
      );

      final updatedExercise = originalExercise.copyWith(
        sets: 5,
      );

      expect(updatedExercise.sets, 5);
      expect(updatedExercise.reps, originalExercise.reps);
      expect(updatedExercise.exerciseId, originalExercise.exerciseId);
    });

    test('copyWith can update order for reordering', () {
      final exercise = RoutineExercise(
        exerciseId: 'ex-1',
        exerciseName: 'Bench Press',
        sets: 3,
        reps: 10,
        order: 0,
      );

      final reorderedExercise = exercise.copyWith(order: 2);

      expect(reorderedExercise.order, 2);
      expect(reorderedExercise.exerciseId, exercise.exerciseId);
    });
  });

  group('EditRoutine - Validation', () {
    test('validateRequired passes for non-empty routine name', () {
      final result = Validators.validateRequired('My Routine', 'Name');
      expect(result, isNull);
    });

    test('validateRequired fails for empty routine name', () {
      final result = Validators.validateRequired('', 'Name');
      expect(result, 'Name is required');
    });

    test('validateRequired fails for null routine name', () {
      final result = Validators.validateRequired(null, 'Name');
      expect(result, 'Name is required');
    });

    test('validateRequired handles whitespace-only strings', () {
      final result = Validators.validateRequired('   ', 'Name');
      expect(result, 'Name is required');
    });

    test('validateInteger passes for valid sets/reps', () {
      expect(Validators.validateInteger('3', 'Sets'), isNull);
      expect(Validators.validateInteger('10', 'Reps'), isNull);
      expect(Validators.validateInteger('1', 'Sets'), isNull);
    });

    test('validateInteger fails for non-integer sets/reps', () {
      expect(
        Validators.validateInteger('3.5', 'Sets'),
        'Please enter a valid whole number',
      );
      expect(
        Validators.validateInteger('abc', 'Reps'),
        'Please enter a valid whole number',
      );
    });

    test('validatePositiveNumber passes for valid weight', () {
      expect(Validators.validatePositiveNumber('50.5', 'Weight'), isNull);
      expect(Validators.validatePositiveNumber('100', 'Weight'), isNull);
      expect(Validators.validatePositiveNumber('0.1', 'Weight'), isNull);
    });

    test('validatePositiveNumber fails for zero or negative weight', () {
      expect(
        Validators.validatePositiveNumber('0', 'Weight'),
        'Weight must be greater than 0',
      );
      expect(
        Validators.validatePositiveNumber('-10', 'Weight'),
        'Weight must be greater than 0',
      );
    });
  });

  group('EditRoutine - Routine JSON Serialization', () {
    test('toJson includes updatedAt when present', () {
      final routine = Routine(
        id: 'test-id',
        userId: 'user-1',
        name: 'Test Routine',
        description: 'Test Description',
        exercises: [],
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 12, 25),
      );

      final json = routine.toJson();

      expect(json['updated_at'], isNotNull);
      expect(json['name'], 'Test Routine');
      expect(json['description'], 'Test Description');
    });

    test('toJson handles null description', () {
      final routine = Routine(
        id: 'test-id',
        userId: 'user-1',
        name: 'Test Routine',
        description: null,
        exercises: [],
        createdAt: DateTime(2023, 1, 1),
      );

      final json = routine.toJson();

      expect(json['description'], isNull);
      expect(json['name'], 'Test Routine');
    });

    test('fromJson correctly deserializes routine with updatedAt', () {
      final json = {
        'id': 'test-id',
        'user_id': 'user-1',
        'name': 'Test Routine',
        'description': 'Test Description',
        'exercises': [],
        'created_at': '2023-01-01T00:00:00.000Z',
        'updated_at': '2023-12-25T00:00:00.000Z',
      };

      final routine = Routine.fromJson(json);

      expect(routine.name, 'Test Routine');
      expect(routine.description, 'Test Description');
      expect(routine.updatedAt, isNotNull);
      expect(routine.updatedAt!.year, 2023);
      expect(routine.updatedAt!.month, 12);
      expect(routine.updatedAt!.day, 25);
    });

    test('fromJson handles null updatedAt', () {
      final json = {
        'id': 'test-id',
        'user_id': 'user-1',
        'name': 'Test Routine',
        'description': 'Test Description',
        'exercises': [],
        'created_at': '2023-01-01T00:00:00.000Z',
        'updated_at': null,
      };

      final routine = Routine.fromJson(json);

      expect(routine.updatedAt, isNull);
    });
  });

  group('EditRoutine - Exercise Reordering', () {
    test('updating order maintains other properties', () {
      final exercises = [
        RoutineExercise(
          exerciseId: 'ex-1',
          exerciseName: 'Exercise 1',
          sets: 3,
          reps: 10,
          order: 0,
        ),
        RoutineExercise(
          exerciseId: 'ex-2',
          exerciseName: 'Exercise 2',
          sets: 4,
          reps: 12,
          order: 1,
        ),
        RoutineExercise(
          exerciseId: 'ex-3',
          exerciseName: 'Exercise 3',
          sets: 3,
          reps: 8,
          order: 2,
        ),
      ];

      // Simulate reordering: move exercise at index 2 to index 0
      final reordered = <RoutineExercise>[];
      final item = exercises.removeAt(2);
      exercises.insert(0, item);

      // Update orders
      for (var i = 0; i < exercises.length; i++) {
        reordered.add(exercises[i].copyWith(order: i));
      }

      expect(reordered[0].exerciseName, 'Exercise 3');
      expect(reordered[0].order, 0);
      expect(reordered[1].exerciseName, 'Exercise 1');
      expect(reordered[1].order, 1);
      expect(reordered[2].exerciseName, 'Exercise 2');
      expect(reordered[2].order, 2);
    });
  });
}
