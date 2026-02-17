import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/validators.dart';
import '../../../models/routine.dart';
import '../../../providers/routine_provider.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../../exercises/screens/exercise_picker_screen.dart';

class EditRoutineScreen extends ConsumerStatefulWidget {
  final Routine routine;

  const EditRoutineScreen({
    super.key,
    required this.routine,
  });

  @override
  ConsumerState<EditRoutineScreen> createState() => _EditRoutineScreenState();
}

class _EditRoutineScreenState extends ConsumerState<EditRoutineScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late List<RoutineExercise> _exercises;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Pre-populate the form with existing routine data
    _nameController = TextEditingController(text: widget.routine.name);
    _descriptionController = TextEditingController(
      text: widget.routine.description ?? '',
    );
    // Create a mutable copy of the exercises list
    _exercises = List.from(widget.routine.exercises);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _addExercise() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExercisePickerScreen(),
      ),
    );

    if (result != null && mounted) {
      showDialog(
        context: context,
        builder: (context) => _ExerciseConfigDialog(
          exerciseName: result.name,
          onSave: (sets, reps, weight, restTime) {
            setState(() {
              _exercises.add(
                RoutineExercise(
                  exerciseId: result.id,
                  exerciseName: result.name,
                  sets: sets,
                  reps: reps,
                  weight: weight,
                  restTime: restTime,
                  order: _exercises.length,
                ),
              );
            });
          },
        ),
      );
    }
  }

  void _editExercise(int index) {
    final exercise = _exercises[index];
    showDialog(
      context: context,
      builder: (context) => _ExerciseConfigDialog(
        exerciseName: exercise.exerciseName,
        initialSets: exercise.sets,
        initialReps: exercise.reps,
        initialWeight: exercise.weight,
        initialRestTime: exercise.restTime,
        onSave: (sets, reps, weight, restTime) {
          setState(() {
            _exercises[index] = exercise.copyWith(
              sets: sets,
              reps: reps,
              weight: weight,
              restTime: restTime,
            );
          });
        },
      ),
    );
  }

  void _removeExercise(int index) {
    setState(() {
      _exercises.removeAt(index);
      // Update order
      for (var i = 0; i < _exercises.length; i++) {
        _exercises[i] = _exercises[i].copyWith(order: i);
      }
    });
  }

  Future<void> _saveRoutine() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate routine name is not empty after trimming
    final trimmedName = _nameController.text.trim();
    if (trimmedName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Routine name cannot be empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one exercise'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Create updated routine with new data
      final updatedRoutine = widget.routine.copyWith(
        name: trimmedName,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        exercises: _exercises,
        updatedAt: DateTime.now(),
      );

      await ref.read(routineNotifierProvider.notifier).updateRoutine(updatedRoutine);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Routine updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update routine: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Routine'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _nameController,
                label: 'Routine Name',
                validator: (value) => Validators.validateRequired(value, 'Name'),
              ),

              const SizedBox(height: 16),

              CustomTextField(
                controller: _descriptionController,
                label: 'Description (optional)',
                maxLines: 3,
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Exercises',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton.icon(
                    onPressed: _addExercise,
                    icon: const Icon(Icons.add),
                    label: const Text('Add'),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              if (_exercises.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.fitness_center_outlined, size: 48),
                          const SizedBox(height: 12),
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
                )
              else
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _exercises.length,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) {
                        newIndex -= 1;
                      }
                      final item = _exercises.removeAt(oldIndex);
                      _exercises.insert(newIndex, item);
                      // Update order
                      for (var i = 0; i < _exercises.length; i++) {
                        _exercises[i] = _exercises[i].copyWith(order: i);
                      }
                    });
                  },
                  itemBuilder: (context, index) {
                    final exercise = _exercises[index];
                    return Card(
                      key: ValueKey(exercise.exerciseId + index.toString()),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.drag_handle),
                        title: Text(exercise.exerciseName),
                        subtitle: Text(
                          '${exercise.sets} sets × ${exercise.reps} reps'
                          '${exercise.weight != null ? " @ ${exercise.weight}kg" : ""}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => _editExercise(index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _removeExercise(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

              const SizedBox(height: 32),

              CustomButton(
                text: 'Update Routine',
                onPressed: _saveRoutine,
                isLoading: _isSaving,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExerciseConfigDialog extends StatefulWidget {
  final String exerciseName;
  final int? initialSets;
  final int? initialReps;
  final double? initialWeight;
  final int? initialRestTime;
  final Function(int sets, int reps, double? weight, int? restTime) onSave;

  const _ExerciseConfigDialog({
    required this.exerciseName,
    required this.onSave,
    this.initialSets,
    this.initialReps,
    this.initialWeight,
    this.initialRestTime,
  });

  @override
  State<_ExerciseConfigDialog> createState() => _ExerciseConfigDialogState();
}

class _ExerciseConfigDialogState extends State<_ExerciseConfigDialog> {
  late TextEditingController _setsController;
  late TextEditingController _repsController;
  late TextEditingController _weightController;
  late TextEditingController _restController;

  @override
  void initState() {
    super.initState();
    _setsController = TextEditingController(
      text: widget.initialSets?.toString() ?? '3',
    );
    _repsController = TextEditingController(
      text: widget.initialReps?.toString() ?? '10',
    );
    _weightController = TextEditingController(
      text: widget.initialWeight?.toString() ?? '',
    );
    _restController = TextEditingController(
      text: widget.initialRestTime?.toString() ?? '90',
    );
  }

  @override
  void dispose() {
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    _restController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Configure ${widget.exerciseName}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _setsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Sets',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _repsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Reps',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Weight (kg, optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _restController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Rest Time (seconds)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Validate inputs
            final sets = int.tryParse(_setsController.text);
            final reps = int.tryParse(_repsController.text);

            if (sets == null || sets <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter a valid number of sets'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            if (reps == null || reps <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter a valid number of reps'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            final weight = double.tryParse(_weightController.text);
            final restTime = int.tryParse(_restController.text);

            widget.onSave(sets, reps, weight, restTime);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
