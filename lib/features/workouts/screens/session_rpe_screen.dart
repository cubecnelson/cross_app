import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/date_utils.dart';
import '../../../models/workout.dart';
import '../../../providers/workout_provider.dart';

/// Screen for selecting or editing Session RPE (Rate of Perceived Exertion) after a workout.
/// Shown after finishing a workout or when editing an existing workout.
class SessionRpeScreen extends ConsumerStatefulWidget {
  final Workout workout;

  /// When true, shows a "Skip for now" option (post-workout flow).
  /// When false, back button discards changes (edit flow).
  final bool isPostWorkout;

  const SessionRpeScreen({
    super.key,
    required this.workout,
    this.isPostWorkout = false,
  });

  @override
  ConsumerState<SessionRpeScreen> createState() => _SessionRpeScreenState();
}

class _SessionRpeScreenState extends ConsumerState<SessionRpeScreen> {
  double? _selectedRpe;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedRpe = widget.workout.sRPE;
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);

    try {
      final updatedWorkout = widget.workout.copyWith(
        sRPE: _selectedRpe,
        clearSRPE: _selectedRpe == null,
        updatedAt: DateTime.now(),
      );
      await ref.read(workoutNotifierProvider.notifier).updateWorkout(updatedWorkout);

      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _selectedRpe != null
                ? 'Session RPE saved: $_selectedRpe'
                : 'Session RPE cleared',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
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

  void _skip() {
    Navigator.pop(context, false);
    if (widget.isPostWorkout && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can add Session RPE later from workout details'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate Your Session'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            if (_selectedRpe != widget.workout.sRPE) {
              final discard = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Discard changes?'),
                  content: const Text(
                    'You have unsaved changes. Do you want to discard them?',
                  ),
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
              if (discard == true && mounted) {
                Navigator.pop(context, false);
              }
            } else if (widget.isPostWorkout) {
              _skip();
            } else {
              Navigator.pop(context, false);
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Workout summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.workout.routineName ?? 'Custom Workout',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppDateUtils.formatDateTime(widget.workout.date),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    if (widget.workout.duration != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 16,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppDateUtils.formatDuration(widget.workout.duration!),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'How hard was this session overall?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Session RPE (0–10): 0 = rest, 10 = max effort',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(11, (index) {
                final value = index.toDouble();
                final isSelected = _selectedRpe?.toInt() == index;
                return ChoiceChip(
                  label: Text(
                    index.toString(),
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedRpe = selected ? value : null;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _isSaving ? null : _save,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Save'),
            ),
            if (widget.isPostWorkout) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: _isSaving ? null : _skip,
                child: const Text('Skip for now'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
