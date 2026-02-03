import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/utils/date_utils.dart';
import '../../../models/routine.dart';
import '../../../models/workout.dart';
import '../../../models/workout_set.dart';
import '../../../models/workout_recommendation.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/workout_provider.dart';
import '../../../providers/recommendation_provider.dart';
import '../../exercises/screens/exercise_picker_screen.dart';
import '../widgets/exercise_set_widget.dart';
import '../widgets/recommendations_section.dart';

class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  final Routine? routine;

  const ActiveWorkoutScreen({super.key, this.routine});

  @override
  ConsumerState<ActiveWorkoutScreen> createState() =>
      _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  late DateTime _startTime;
  Timer? _timer;
  Duration _duration = Duration.zero;

  final List<WorkoutExercise> _exercises = [];
  final _notesController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _startTimer();

    // Initialize from routine if provided
    if (widget.routine != null) {
      for (var routineExercise in widget.routine!.exercises) {
        _exercises.add(
          WorkoutExercise(
            exerciseId: routineExercise.exerciseId,
            exerciseName: routineExercise.exerciseName,
            sets: List.generate(
              routineExercise.sets,
              (index) => SetData(
                setNumber: index + 1,
                reps: routineExercise.reps,
                weight: routineExercise.weight ?? 0,
              ),
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _notesController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _duration = DateTime.now().difference(_startTime);
      });
    });
  }

  Future<void> _addExercise() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ExercisePickerScreen(),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _exercises.add(
          WorkoutExercise(
            exerciseId: result.id,
            exerciseName: result.name,
            exerciseType:
                result.exerciseType.name, // Now works with custom getter
            sets: [
              SetData(setNumber: 1, reps: 0, weight: 0),
            ],
          ),
        );
      });
    }
  }

  void _addSet(int exerciseIndex) {
    setState(() {
      final exercise = _exercises[exerciseIndex];
      final lastSet = exercise.sets.isNotEmpty ? exercise.sets.last : null;

      exercise.sets.add(
        SetData(
          setNumber: exercise.sets.length + 1,
          reps: lastSet?.reps ?? 0,
          weight: lastSet?.weight ?? 0,
        ),
      );
    });
  }

  void _removeSet(int exerciseIndex, int setIndex) {
    setState(() {
      _exercises[exerciseIndex].sets.removeAt(setIndex);
      // Renumber sets
      for (var i = 0; i < _exercises[exerciseIndex].sets.length; i++) {
        _exercises[exerciseIndex].sets[i].setNumber = i + 1;
      }
    });
  }

  void _removeExercise(int exerciseIndex) {
    setState(() {
      _exercises.removeAt(exerciseIndex);
    });
  }

  void _handleRecommendationTap(WorkoutRecommendation recommendation) {
    // If recommendation has an exercise, add it to the workout with suggested parameters
    if (recommendation.exercise != null) {
      final exercise = recommendation.exercise!;
      final params = recommendation.suggestedParameters;

      setState(() {
        _exercises.add(
          WorkoutExercise(
            exerciseId: exercise.id,
            exerciseName: exercise.name,
            exerciseType: exercise.exerciseType.name,
            sets: [
              SetData(
                setNumber: 1,
                reps: params['reps'] as int? ?? 10,
                weight: (params['weight'] as num?)?.toDouble() ?? 0.0,
                duration: params['duration'] as int?,
                distance: (params['distance'] as num?)?.toDouble(),
              ),
            ],
          ),
        );
      });

      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${exercise.name} to workout'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _saveWorkout() async {
    // Validate user is logged in
    final user = ref.read(currentUserProvider);

    print('🔐 Checking authentication...');
    print('User: ${user?.email ?? "NULL"}');
    print('User ID: ${user?.id ?? "NULL"}');

    if (user == null) {
      print('❌ User is null - not authenticated!');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Error: User not authenticated. Please log in again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
      return;
    }

    print('✅ User authenticated: ${user.email}');

    // Validate there are exercises
    if (_exercises.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add at least one exercise to save workout'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // Check if any sets are completed
    final hasCompletedSets = _exercises.any(
      (exercise) => exercise.sets.any((set) => set.isCompleted),
    );

    if (!hasCompletedSets) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please complete at least one set before saving'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() => _isSaving = true);

    try {
      print('🏋️ Creating workout for user: ${user.id}');

      // Create workout
      final workout = Workout(
        id: const Uuid().v4(),
        userId: user.id,
        date: _startTime,
        routineId: widget.routine?.id,
        routineName: widget.routine?.name,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        duration: _duration,
        createdAt: DateTime.now(),
      );

      print('📝 Workout data: ${workout.toJson()}');

      final createdWorkout = await ref
          .read(workoutNotifierProvider.notifier)
          .createWorkout(workout);

      if (createdWorkout == null) {
        throw Exception('Failed to create workout - returned null');
      }

      print('✅ Workout created with ID: ${createdWorkout.id}');

      // Create sets
      int setsCreated = 0;
      for (var exercise in _exercises) {
        for (var set in exercise.sets) {
          if (set.isCompleted) {
            print(
                '💪 Creating set ${set.setNumber} for ${exercise.exerciseName}');

            await ref.read(workoutNotifierProvider.notifier).addSet(
                  WorkoutSet(
                    id: const Uuid().v4(),
                    workoutId: createdWorkout.id,
                    exerciseId: exercise.exerciseId,
                    exerciseName: exercise.exerciseName,
                    setNumber: set.setNumber,
                    // Strength attributes
                    reps: set.reps > 0 ? set.reps : null,
                    weight: set.weight > 0 ? set.weight : null,
                    restTime: set.restTime,
                    // Cardio attributes
                    distance: set.distance,
                    duration: set.duration,
                    pace: set.pace,
                    heartRate: set.heartRate,
                    calories: set.calories,
                    elevationGain: set.elevationGain,
                    // Common
                    rpe: set.rpe,
                    notes: set.notes,
                    isCompleted: true,
                    createdAt: DateTime.now(),
                  ),
                );
            setsCreated++;
          }
        }
      }

      print('✅ Created $setsCreated sets');

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Workout saved! $setsCreated sets completed 🎉'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e, stackTrace) {
      print('❌ Error saving workout: $e');
      print('Stack trace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save workout: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (_exercises.isEmpty) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Workout?'),
        content: const Text('Are you sure you want to discard this workout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.routine?.name ?? 'New Workout'),
              Text(
                AppDateUtils.formatDuration(_duration),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: _isSaving ? null : _saveWorkout,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Finish'),
            ),
          ],
        ),
        body: _exercises.isEmpty
            ? Consumer(
                builder: (context, ref, child) {
                  final recommendationsAsync = ref.watch(workoutRecommendationsProvider);
                  
                  return recommendationsAsync.when(
                    data: (recommendations) {
                      return Column(
                        children: [
                          if (recommendations.isNotEmpty)
                            RecommendationsSection(
                              maxRecommendations: 5,
                              onRecommendationTap: (recommendation) {
                                _handleRecommendationTap(recommendation);
                              },
                            ),
                          if (recommendations.isNotEmpty) const SizedBox(height: 32),
                          Expanded(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.fitness_center_outlined, size: 64),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'No exercises added yet',
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    ElevatedButton(
                                      onPressed: _addExercise,
                                      child: const Text('Add Exercise'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (error, stack) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.fitness_center_outlined, size: 64),
                            const SizedBox(height: 16),
                            const Text(
                              'No exercises added yet',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _addExercise,
                              child: const Text('Add Exercise'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _exercises.length + 1,
                itemBuilder: (context, index) {
                  if (index == _exercises.length) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: OutlinedButton.icon(
                        onPressed: _addExercise,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Exercise'),
                      ),
                    );
                  }

                  final exercise = _exercises[index];
                  return ExerciseSetWidget(
                    exercise: exercise,
                    onAddSet: () => _addSet(index),
                    onRemoveSet: (setIndex) => _removeSet(index, setIndex),
                    onRemoveExercise: () => _removeExercise(index),
                    onSetChanged: (setIndex, updatedSet) {
                      setState(() {
                        exercise.sets[setIndex] = updatedSet;
                      });
                    },
                  );
                },
              ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: TextField(
            controller: _notesController,
            decoration: const InputDecoration(
              hintText: 'Add workout notes...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.note_outlined),
            ),
            maxLines: 2,
          ),
        ),
      ),
    );
  }
}

class WorkoutExercise {
  final String exerciseId;
  final String exerciseName;
  final String exerciseType; // 'strength', 'cardio', 'isometric'
  final List<SetData> sets;

  WorkoutExercise({
    required this.exerciseId,
    required this.exerciseName,
    this.exerciseType = 'strength',
    required this.sets,
  });
}

class SetData {
  int setNumber;

  // Strength attributes
  int reps;
  double weight;
  int? restTime;

  // Cardio attributes
  double? distance; // km or miles
  int? duration; // seconds (also used for isometric hold time)
  double? pace; // min/km or min/mile
  int? heartRate; // BPM
  int? calories;
  double? elevationGain; // meters or feet

  // Common attributes
  int? rpe;
  String? notes;
  bool isCompleted;

  SetData({
    required this.setNumber,
    this.reps = 0,
    this.weight = 0.0,
    this.restTime,
    // Cardio
    this.distance,
    this.duration,
    this.pace,
    this.heartRate,
    this.calories,
    this.elevationGain,
    // Common
    this.rpe,
    this.notes,
    this.isCompleted = false,
  });
}
