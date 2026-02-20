import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/routine_provider.dart';
import '../../../widgets/loading_indicator.dart';
import '../../../widgets/empty_state.dart';
import '../../workouts/screens/active_workout_screen.dart';
import 'create_routine_screen.dart';

class RoutinesListScreen extends ConsumerStatefulWidget {
  const RoutinesListScreen({super.key});

  @override
  ConsumerState<RoutinesListScreen> createState() => _RoutinesListScreenState();
}

class _RoutinesListScreenState extends ConsumerState<RoutinesListScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      // Refresh when app comes back to foreground
      ref.invalidate(routineNotifierProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final routines = ref.watch(routineNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Routines'),
      ),
      body: routines.when(
        data: (routinesList) {
          if (routinesList.isEmpty) {
            return EmptyState(
              icon: Icons.list_alt_outlined,
              title: 'No routines yet',
              message: 'Create a routine to plan your workouts',
              actionText: 'Create Routine',
              onAction: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateRoutineScreen(),
                  ),
                );
              },
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(routineNotifierProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: routinesList.length,
              itemBuilder: (context, index) {
                final routine = routinesList[index];
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('${routine.exercises.length}'),
                    ),
                    title: Text(routine.name),
                    subtitle: routine.description != null
                        ? Text(routine.description!)
                        : Text('${routine.exercises.length} exercises'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.play_arrow),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ActiveWorkoutScreen(
                                  routine: routine,
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CreateRoutineScreen(
                                  routine: routine,
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            final result = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Routine'),
                                content: Text(
                                  'Are you sure you want to delete "${routine.name}"?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );

                            if (result == true) {
                              await ref
                                  .read(routineNotifierProvider.notifier)
                                  .deleteRoutine(routine.id);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const LoadingIndicator(message: 'Loading routines...'),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(routineNotifierProvider),
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
              builder: (_) => CreateRoutineScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Routine'),
      ),
    );
  }
}

