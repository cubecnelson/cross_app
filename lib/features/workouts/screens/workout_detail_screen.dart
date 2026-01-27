import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/date_utils.dart';
import '../../../models/workout.dart';
import '../../../models/workout_set.dart';
import '../../../providers/workout_provider.dart';

class WorkoutDetailScreen extends ConsumerWidget {
  final Workout workout;

  const WorkoutDetailScreen({super.key, required this.workout});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Debug: Log workout sets info
    print('📊 Workout Detail - ID: ${workout.id}');
    print('📊 Total sets loaded: ${workout.sets.length}');
    
    // Group sets by exercise
    final exerciseGroups = <String, List<WorkoutSet>>{};
    for (var set in workout.sets) {
      if (!exerciseGroups.containsKey(set.exerciseId)) {
        exerciseGroups[set.exerciseId] = [];
      }
      exerciseGroups[set.exerciseId]!.add(set);
    }
    
    print('📊 Exercise groups: ${exerciseGroups.length}');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final result = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Workout'),
                  content: const Text(
                    'Are you sure you want to delete this workout?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );

              if (result == true && context.mounted) {
                await ref
                    .read(workoutNotifierProvider.notifier)
                    .deleteWorkout(workout.id);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout.routineName ?? 'Custom Workout',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppDateUtils.formatDateTime(workout.date),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatColumn(
                          context,
                          'Duration',
                          workout.duration != null
                              ? AppDateUtils.formatDuration(workout.duration!)
                              : 'N/A',
                        ),
                        _buildStatColumn(
                          context,
                          'Total Sets',
                          '${workout.totalSets}',
                        ),
                        _buildStatColumn(
                          context,
                          'Volume',
                          '${workout.totalVolume.toStringAsFixed(0)} kg',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            if (workout.notes != null) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notes',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(workout.notes!),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),
            Text(
              'Exercises',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),

            // Show empty state if no exercises
            if (exerciseGroups.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.fitness_center_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No exercises recorded',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Exercise Details
            ...exerciseGroups.entries.map((entry) {
              final sets = entry.value;
              final exerciseName = sets.first.exerciseName;
              final firstSet = sets.first;

              // Determine exercise type
              final bool isStrength = firstSet.isStrength;
              final bool isCardio = firstSet.isCardio;
              final bool isIsometric = firstSet.isIsometric;

              // Calculate summary stats based on type
              Widget summaryWidget;
              IconData typeIcon;
              Color typeColor;

              if (isStrength) {
                final totalVolume = sets.fold<double>(
                  0,
                  (sum, set) => sum + ((set.weight ?? 0) * (set.reps ?? 0)),
                );
                summaryWidget = Text(
                  '${totalVolume.toStringAsFixed(0)} kg',
                  style: Theme.of(context).textTheme.bodyMedium,
                );
                typeIcon = Icons.fitness_center;
                typeColor = Colors.blue;
              } else if (isCardio) {
                final totalDistance = sets.fold<double>(
                  0,
                  (sum, set) => sum + (set.distance ?? 0),
                );
                final totalDuration = sets.fold<int>(
                  0,
                  (sum, set) => sum + (set.duration ?? 0),
                );
                summaryWidget = Text(
                  '${totalDistance.toStringAsFixed(2)} km • ${AppDateUtils.formatDuration(Duration(seconds: totalDuration))}',
                  style: Theme.of(context).textTheme.bodyMedium,
                );
                typeIcon = Icons.directions_run;
                typeColor = Colors.orange;
              } else if (isIsometric) {
                final totalHoldTime = sets.fold<int>(
                  0,
                  (sum, set) => sum + (set.duration ?? 0),
                );
                summaryWidget = Text(
                  '${totalHoldTime}s total',
                  style: Theme.of(context).textTheme.bodyMedium,
                );
                typeIcon = Icons.timer;
                typeColor = Colors.purple;
              } else {
                summaryWidget = const SizedBox();
                typeIcon = Icons.help_outline;
                typeColor = Colors.grey;
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
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
                            child: Row(
                              children: [
                                Icon(typeIcon, color: typeColor, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    exerciseName,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          summaryWidget,
                        ],
                      ),
                      const Divider(height: 16),

                      // Dynamic headers based on exercise type
                      if (isStrength) _buildStrengthHeaders(context),
                      if (isCardio) _buildCardioHeaders(context),
                      if (isIsometric) _buildIsometricHeaders(context),

                      const SizedBox(height: 8),

                      // Sets with dynamic columns
                      ...sets.map((set) {
                        if (isStrength) {
                          return _buildStrengthSetRow(context, set);
                        } else if (isCardio) {
                          return _buildCardioSetRow(context, set);
                        } else if (isIsometric) {
                          return _buildIsometricSetRow(context, set);
                        }
                        return const SizedBox();
                      }),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  // Strength Exercise Headers
  Widget _buildStrengthHeaders(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 40),
        Expanded(
          child: Text(
            'Reps',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Text(
            'Weight',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Text(
            'Volume',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildStrengthSetRow(BuildContext context, WorkoutSet set) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              '${set.setNumber}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              '${set.reps ?? 0}',
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              '${set.weight?.toStringAsFixed(1) ?? 0} kg',
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              '${(set.volume ?? 0).toStringAsFixed(0)} kg',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // Cardio Exercise Headers
  Widget _buildCardioHeaders(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 40),
        Expanded(
          child: Text(
            'Distance',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Text(
            'Duration',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Text(
            'Pace',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Text(
            'HR',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildCardioSetRow(BuildContext context, WorkoutSet set) {
    final duration = set.duration;
    final durationStr = duration != null
        ? AppDateUtils.formatDuration(Duration(seconds: duration))
        : '-';

    final pace = set.averagePace;
    final paceStr = pace != null ? '${pace.toStringAsFixed(2)} min/km' : '-';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 40,
                child: Text(
                  '${set.setNumber}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Expanded(
                child: Text(
                  set.distance != null
                      ? '${set.distance!.toStringAsFixed(2)} km'
                      : '-',
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  durationStr,
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  paceStr,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Expanded(
                child: Text(
                  set.heartRate != null ? '${set.heartRate} bpm' : '-',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          // Additional cardio metrics if available
          if (set.calories != null || set.elevationGain != null)
            Padding(
              padding: const EdgeInsets.only(left: 40, top: 4),
              child: Row(
                children: [
                  if (set.calories != null) ...[
                    const Icon(Icons.local_fire_department,
                        size: 14, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      '${set.calories} cal',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (set.elevationGain != null) ...[
                    const Icon(Icons.terrain, size: 14, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      '${set.elevationGain!.toStringAsFixed(0)} m',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Isometric Exercise Headers
  Widget _buildIsometricHeaders(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 40),
        Expanded(
          flex: 2,
          child: Text(
            'Hold Time',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Text(
            'RPE',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildIsometricSetRow(BuildContext context, WorkoutSet set) {
    final duration = set.holdTime;
    final durationStr = duration != null ? '${duration}s' : '-';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 40,
                child: Text(
                  '${set.setNumber}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  durationStr,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Expanded(
                child: Text(
                  set.rpe != null ? '${set.rpe}/10' : '-',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          // Show notes if available
          if (set.notes != null && set.notes!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 40, top: 4),
              child: Text(
                set.notes!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                    ),
              ),
            ),
        ],
      ),
    );
  }
}
