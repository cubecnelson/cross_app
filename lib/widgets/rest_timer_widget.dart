import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cross/services/rest_timer_service.dart';

class RestTimerWidget extends ConsumerWidget {
  final Duration initialDuration;
  final Function()? onTimerComplete;
  final bool showControls;

  const RestTimerWidget({
    super.key,
    this.initialDuration = const Duration(minutes: 1, seconds: 30),
    this.onTimerComplete,
    this.showControls = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(restTimerStateProvider);
    final timerService = ref.watch(restTimerServiceProvider);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Rest Timer',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    timerService.resetTimer(null);
                  },
                  tooltip: 'Close timer',
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Timer circle
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: timerState.progress,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      timerState.isCompleted
                          ? Colors.green
                          : Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      timerState.formattedTime,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timerState.isCompleted
                          ? 'Complete!'
                          : timerState.isRunning
                              ? 'Resting...'
                              : 'Paused',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Quick duration buttons
            if (showControls) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _DurationButton(
                    duration: const Duration(seconds: 30),
                    label: '30s',
                    onPressed: () => timerService.resetTimer(const Duration(seconds: 30)),
                  ),
                  _DurationButton(
                    duration: const Duration(seconds: 60),
                    label: '1m',
                    onPressed: () => timerService.resetTimer(const Duration(seconds: 60)),
                  ),
                  _DurationButton(
                    duration: const Duration(seconds: 90),
                    label: '1m30s',
                    onPressed: () => timerService.resetTimer(const Duration(seconds: 90)),
                  ),
                  _DurationButton(
                    duration: const Duration(minutes: 2),
                    label: '2m',
                    onPressed: () => timerService.resetTimer(const Duration(minutes: 2)),
                  ),
                  _DurationButton(
                    duration: const Duration(minutes: 3),
                    label: '3m',
                    onPressed: () => timerService.resetTimer(const Duration(minutes: 3)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            // Control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (timerState.isRunning)
                  ElevatedButton.icon(
                    onPressed: timerService.pauseTimer,
                    icon: const Icon(Icons.pause),
                    label: const Text('Pause'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: timerState.isCompleted
                        ? null
                        : () => timerService.resumeTimer(),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start'),
                  ),
                ElevatedButton.icon(
                  onPressed: timerService.skipTimer,
                  icon: const Icon(Icons.skip_next),
                  label: const Text('Skip'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => timerService.resetTimer(initialDuration),
                  icon: const Icon(Icons.replay),
                  label: const Text('Reset'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Progress indicator
            LinearProgressIndicator(
              value: timerState.progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                timerState.isCompleted
                    ? Colors.green
                    : Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${(timerState.progress * 100).toStringAsFixed(0)}% complete',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _DurationButton extends StatelessWidget {
  final Duration duration;
  final String label;
  final VoidCallback onPressed;

  const _DurationButton({
    required this.duration,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(label),
    );
  }
}

// Hook widget for easy integration
class RestTimerContainer extends ConsumerWidget {
  final Duration? initialDuration;
  final Widget? child;
  final bool showTimer;

  const RestTimerContainer({
    super.key,
    this.initialDuration,
    this.child,
    this.showTimer = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(restTimerStateProvider);
    
    if (!showTimer || !timerState.isRunning && !timerState.isCompleted) {
      return child ?? const SizedBox.shrink();
    }

    return Stack(
      children: [
        if (child != null) child!,
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => DraggableScrollableSheet(
                  expand: false,
                  initialChildSize: 0.6,
                  minChildSize: 0.4,
                  maxChildSize: 0.8,
                  builder: (context, scrollController) => RestTimerWidget(
                    initialDuration: initialDuration ?? const Duration(minutes: 1, seconds: 30),
                  ),
                ),
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  timerState.isCompleted
                      ? Icons.check_circle
                      : Icons.timer,
                  size: 24,
                ),
                const SizedBox(height: 2),
                Text(
                  timerState.formattedTime.split(':')[1], // Just seconds
                  style: const TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}