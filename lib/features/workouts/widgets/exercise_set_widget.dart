import 'package:flutter/material.dart';
import '../screens/active_workout_screen.dart';

class ExerciseSetWidget extends StatelessWidget {
  final WorkoutExercise exercise;
  final VoidCallback onAddSet;
  final Function(int) onRemoveSet;
  final VoidCallback onRemoveExercise;
  final Function(int, SetData) onSetChanged;

  const ExerciseSetWidget({
    super.key,
    required this.exercise,
    required this.onAddSet,
    required this.onRemoveSet,
    required this.onRemoveExercise,
    required this.onSetChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.exerciseName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      _buildExerciseTypeBadge(context),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: onRemoveExercise,
                  color: Colors.red,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Headers based on exercise type
            _buildSetHeaders(context),

            const Divider(height: 16),

            // Sets
            ...exercise.sets.asMap().entries.map((entry) {
              final index = entry.key;
              final set = entry.value;
              return _SetRow(
                exerciseType: exercise.exerciseType,
                setData: set,
                onChanged: (updatedSet) => onSetChanged(index, updatedSet),
                onRemove: () => onRemoveSet(index),
              );
            }),

            const SizedBox(height: 8),

            // Add Set Button
            TextButton.icon(
              onPressed: onAddSet,
              icon: const Icon(Icons.add),
              label: const Text('Add Set'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseTypeBadge(BuildContext context) {
    final color = exercise.exerciseType == 'strength'
        ? Colors.blue
        : exercise.exerciseType == 'cardio'
            ? Colors.orange
            : Colors.purple;

    final icon = exercise.exerciseType == 'strength'
        ? Icons.fitness_center
        : exercise.exerciseType == 'cardio'
            ? Icons.directions_run
            : Icons.timer;

    final label = exercise.exerciseType == 'strength'
        ? 'Strength'
        : exercise.exerciseType == 'cardio'
            ? 'Cardio'
            : 'Isometric';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(opacity: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetHeaders(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodySmall;

    if (exercise.exerciseType == 'strength') {
      return Row(
        children: [
          const SizedBox(width: 48),
          Expanded(
            child: Text('Reps', style: textStyle, textAlign: TextAlign.center),
          ),
          Expanded(
            child: Text('Weight (kg)',
                style: textStyle, textAlign: TextAlign.center),
          ),
          const SizedBox(width: 48),
        ],
      );
    } else if (exercise.exerciseType == 'cardio') {
      return Row(
        children: [
          const SizedBox(width: 48),
          Expanded(
            child: Text('Distance\n(km)',
                style: textStyle, textAlign: TextAlign.center),
          ),
          Expanded(
            child: Text('Duration\n(min:sec)',
                style: textStyle, textAlign: TextAlign.center),
          ),
          Expanded(
            child: Text('HR\n(bpm)',
                style: textStyle, textAlign: TextAlign.center),
          ),
          const SizedBox(width: 48),
        ],
      );
    } else {
      // isometric
      return Row(
        children: [
          const SizedBox(width: 48),
          Expanded(
            child: Text('Hold Time\n(seconds)',
                style: textStyle, textAlign: TextAlign.center),
          ),
          Expanded(
            child: Text('RPE\n(1-10)',
                style: textStyle, textAlign: TextAlign.center),
          ),
          const SizedBox(width: 48),
        ],
      );
    }
  }
}

class _SetRow extends StatefulWidget {
  final String exerciseType;
  final SetData setData;
  final Function(SetData) onChanged;
  final VoidCallback onRemove;

  const _SetRow({
    required this.exerciseType,
    required this.setData,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  State<_SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<_SetRow> {
  // Strength controllers
  late TextEditingController _repsController;
  late TextEditingController _weightController;

  // Cardio controllers
  late TextEditingController _distanceController;
  late TextEditingController _durationController;
  late TextEditingController _heartRateController;

  // Isometric controllers
  late TextEditingController _holdTimeController;
  late TextEditingController _rpeController;

  @override
  void initState() {
    super.initState();

    // Initialize strength controllers
    _repsController = TextEditingController(
      text: widget.setData.reps > 0 ? widget.setData.reps.toString() : '',
    );
    _weightController = TextEditingController(
      text: widget.setData.weight > 0 ? widget.setData.weight.toString() : '',
    );

    // Initialize cardio controllers
    _distanceController = TextEditingController(
      text: widget.setData.distance != null && widget.setData.distance! > 0
          ? widget.setData.distance.toString()
          : '',
    );
    _durationController = TextEditingController(
      text: widget.setData.duration != null && widget.setData.duration! > 0
          ? _formatDuration(widget.setData.duration!)
          : '',
    );
    _heartRateController = TextEditingController(
      text: widget.setData.heartRate != null && widget.setData.heartRate! > 0
          ? widget.setData.heartRate.toString()
          : '',
    );

    // Initialize isometric controllers
    _holdTimeController = TextEditingController(
      text: widget.setData.duration != null && widget.setData.duration! > 0
          ? widget.setData.duration.toString()
          : '',
    );
    _rpeController = TextEditingController(
      text: widget.setData.rpe != null && widget.setData.rpe! > 0
          ? widget.setData.rpe.toString()
          : '',
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  int _parseDuration(String text) {
    final parts = text.split(':');
    if (parts.length == 2) {
      final minutes = int.tryParse(parts[0]) ?? 0;
      final seconds = int.tryParse(parts[1]) ?? 0;
      return minutes * 60 + seconds;
    } else {
      return int.tryParse(text) ?? 0;
    }
  }

  @override
  void dispose() {
    _repsController.dispose();
    _weightController.dispose();
    _distanceController.dispose();
    _durationController.dispose();
    _heartRateController.dispose();
    _holdTimeController.dispose();
    _rpeController.dispose();
    super.dispose();
  }

  void _updateStrengthSet() {
    final reps = int.tryParse(_repsController.text) ?? 0;
    final weight = double.tryParse(_weightController.text) ?? 0;

    widget.onChanged(
      SetData(
        setNumber: widget.setData.setNumber,
        reps: reps,
        weight: weight,
        restTime: widget.setData.restTime,
        rpe: widget.setData.rpe,
        notes: widget.setData.notes,
        isCompleted: reps > 0 && weight >= 0,
      ),
    );
  }

  void _updateCardioSet() {
    final distance = double.tryParse(_distanceController.text) ?? 0;
    final duration = _parseDuration(_durationController.text);
    final heartRate = int.tryParse(_heartRateController.text);

    widget.onChanged(
      SetData(
        setNumber: widget.setData.setNumber,
        distance: distance > 0 ? distance : null,
        duration: duration > 0 ? duration : null,
        heartRate: heartRate,
        rpe: widget.setData.rpe,
        notes: widget.setData.notes,
        isCompleted: distance > 0 || duration > 0,
      ),
    );
  }

  void _updateIsometricSet() {
    final holdTime = int.tryParse(_holdTimeController.text) ?? 0;
    final rpe = int.tryParse(_rpeController.text);

    widget.onChanged(
      SetData(
        setNumber: widget.setData.setNumber,
        duration: holdTime > 0 ? holdTime : null,
        rpe: rpe,
        notes: widget.setData.notes,
        isCompleted: holdTime > 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.exerciseType == 'strength') {
      return _buildStrengthRow();
    } else if (widget.exerciseType == 'cardio') {
      return _buildCardioRow();
    } else {
      return _buildIsometricRow();
    }
  }

  Widget _buildStrengthRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Set Number
          SizedBox(
            width: 40,
            child: Text(
              '${widget.setData.setNumber}',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(width: 8),

          // Reps Input
          Expanded(
            child: TextField(
              controller: _repsController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              onChanged: (_) => _updateStrengthSet(),
            ),
          ),

          const SizedBox(width: 8),

          // Weight Input
          Expanded(
            child: TextField(
              controller: _weightController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              onChanged: (_) => _updateStrengthSet(),
            ),
          ),

          const SizedBox(width: 8),

          // Checkmark
          IconButton(
            icon: Icon(
              widget.setData.isCompleted
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: widget.setData.isCompleted ? Colors.green : null,
            ),
            onPressed: () {
              widget.onChanged(
                SetData(
                  setNumber: widget.setData.setNumber,
                  reps: widget.setData.reps,
                  weight: widget.setData.weight,
                  isCompleted: !widget.setData.isCompleted,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCardioRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Set Number
          SizedBox(
            width: 40,
            child: Text(
              '${widget.setData.setNumber}',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(width: 8),

          // Distance Input
          Expanded(
            child: TextField(
              controller: _distanceController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                hintText: '5.0',
              ),
              onChanged: (_) => _updateCardioSet(),
            ),
          ),

          const SizedBox(width: 8),

          // Duration Input (MM:SS)
          Expanded(
            child: TextField(
              controller: _durationController,
              keyboardType: TextInputType.text,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                hintText: '25:30',
              ),
              onChanged: (_) => _updateCardioSet(),
            ),
          ),

          const SizedBox(width: 8),

          // Heart Rate Input
          Expanded(
            child: TextField(
              controller: _heartRateController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                hintText: '145',
              ),
              onChanged: (_) => _updateCardioSet(),
            ),
          ),

          const SizedBox(width: 8),

          // Checkmark
          IconButton(
            icon: Icon(
              widget.setData.isCompleted
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: widget.setData.isCompleted ? Colors.green : null,
            ),
            onPressed: () {
              widget.onChanged(
                SetData(
                  setNumber: widget.setData.setNumber,
                  distance: widget.setData.distance,
                  duration: widget.setData.duration,
                  heartRate: widget.setData.heartRate,
                  isCompleted: !widget.setData.isCompleted,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIsometricRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Set Number
          SizedBox(
            width: 40,
            child: Text(
              '${widget.setData.setNumber}',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(width: 8),

          // Hold Time Input
          Expanded(
            child: TextField(
              controller: _holdTimeController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                hintText: '60',
              ),
              onChanged: (_) => _updateIsometricSet(),
            ),
          ),

          const SizedBox(width: 8),

          // RPE Input
          Expanded(
            child: TextField(
              controller: _rpeController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                hintText: '7',
              ),
              onChanged: (_) => _updateIsometricSet(),
            ),
          ),

          const SizedBox(width: 8),

          // Checkmark
          IconButton(
            icon: Icon(
              widget.setData.isCompleted
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: widget.setData.isCompleted ? Colors.green : null,
            ),
            onPressed: () {
              widget.onChanged(
                SetData(
                  setNumber: widget.setData.setNumber,
                  duration: widget.setData.duration,
                  rpe: widget.setData.rpe,
                  isCompleted: !widget.setData.isCompleted,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
