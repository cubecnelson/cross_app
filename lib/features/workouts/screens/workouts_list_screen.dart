import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/date_utils.dart';
import '../../../providers/workout_provider.dart';
import '../../../widgets/loading_indicator.dart';
import '../../../widgets/empty_state.dart';
import 'active_workout_screen.dart';
import 'workout_detail_screen.dart';
import '../widgets/recommendations_section.dart';

class WorkoutsListScreen extends ConsumerWidget {
  const WorkoutsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workouts = ref.watch(workoutsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workouts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              // TODO: Show calendar view
            },
          ),
        ],
      ),
      body: workouts.when(
        data: (workoutsList) {
          if (workoutsList.isEmpty) {
            return EmptyState(
              icon: Icons.fitness_center_outlined,
              title: 'No workouts yet',
              message: 'Start your first workout to track your progress',
              actionText: 'Start Workout',
              onAction: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ActiveWorkoutScreen(),
                  ),
                );
              },
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(workoutsProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: workoutsList.length + 1, // +1 for recommendations section
              itemBuilder: (context, index) {
                // Show recommendations at the top
                if (index == 0) {
                  return Column(
                    children: [
                      const CompactRecommendations(),
                      const SizedBox(height: 16),
                    ],
                  );
                }
                
                final workout = workoutsList[index - 1]; // Adjust index for recommendations
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WorkoutDetailScreen(workout: workout),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  workout.routineName ?? 'Custom Workout',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ),
                              Text(
                                AppDateUtils.formatWorkoutDate(workout.date),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildStat(
                                context,
                                Icons.timer_outlined,
                                workout.duration != null
                                    ? AppDateUtils.formatDuration(workout.duration!)
                                    : 'N/A',
                              ),
                              const SizedBox(width: 16),
                              _buildStat(
                                context,
                                Icons.fitness_center,
                                '${workout.totalSets} sets',
                              ),
                              const SizedBox(width: 16),
                              _buildStat(
                                context,
                                Icons.trending_up,
                                '${workout.totalVolume.toStringAsFixed(0)} kg',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const LoadingIndicator(message: 'Loading workouts...'),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading workouts: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(workoutsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ActiveWorkoutScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Workout'),
      ),
    );
  }

  Widget _buildStat(BuildContext context, IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).textTheme.bodyMedium?.color),
        const SizedBox(width: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

