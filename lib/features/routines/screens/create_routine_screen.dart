import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/utils/validators.dart';
import '../../../models/routine.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/routine_provider.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../../exercises/screens/exercise_picker_screen.dart';

class CreateRoutineScreen extends ConsumerStatefulWidget {
  final Routine? routine;

  const CreateRoutineScreen({super.key, this.routine});

  @override
  ConsumerState<CreateRoutineScreen> createState() =>
      _CreateRoutineScreenState();
}

class _CreateRoutineScreenState extends ConsumerState<CreateRoutineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<RoutineExercise> _exercises = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // If editing an existing routine, populate the form
    if (widget.routine != null) {
      _nameController.text = widget.routine!.name;
      if (widget.routine!.description != null) {
        _descriptionController.text = widget.routine!.description!;
      }
      _exercises.addAll(widget.routine!.exercises);
    }
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
    
    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one exercise'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _isSaving = true);

    try {
      if (widget.routine != null) {
        // Update existing routine
        final updatedRoutine = widget.routine!.copyWith(
          name: _nameController.text.trim(),
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
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
      } else {
        // Create new routine
        final routine = Routine(
          id: const Uuid().v4(),
          userId: user.id,
          name: _nameController.text.trim(),
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          exercises: _exercises,
          createdAt: DateTime.now(),
        );

        await ref.read(routineNotifierProvider.notifier).createRoutine(routine);

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Routine created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save routine: $e'),
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
        title: Text(widget.routine != null ? 'Edit Routine' : 'Create Routine'),
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
                      key: ValueKey(exercise.exerciseId),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.drag_handle),
                        title: Text(exercise.exerciseName),
                        subtitle: Text(
                          '${exercise.sets} sets × ${exercise.reps} reps',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _removeExercise(index),
                        ),
                      ),
                    );
                  },
                ),
              
              const SizedBox(height: 32),
              
              CustomButton(
                text: 'Save Routine',
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
  final Function(int sets, int reps, double? weight, int? restTime) onSave;

  const _ExerciseConfigDialog({
    required this.exerciseName,
    required this.onSave,
  });

  @override
  State<_ExerciseConfigDialog> createState() => _ExerciseConfigDialogState();
}

class _ExerciseConfigDialogState extends State<_ExerciseConfigDialog> {
  final _setsController = TextEditingController(text: '3');
  final _repsController = TextEditingController(text: '10');
  final _weightController = TextEditingController();
  final _restController = TextEditingController(text: '90');

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
            final sets = int.tryParse(_setsController.text) ?? 3;
            final reps = int.tryParse(_repsController.text) ?? 10;
            final weight = double.tryParse(_weightController.text);
            final restTime = int.tryParse(_restController.text);
            
            widget.onSave(sets, reps, weight, restTime);
            Navigator.pop(context);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

