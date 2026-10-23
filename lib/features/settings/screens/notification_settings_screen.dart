import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/training_alert_provider.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final acwrAlertsAsync = ref.watch(acwrAlertsEnabledProvider);
    final weeklySummaryAsync = ref.watch(weeklySummaryEnabledProvider);
    final achievementAlertsAsync = ref.watch(achievementAlertsEnabledProvider);
    final underTrainingAlertsAsync = ref.watch(underTrainingAlertsEnabledProvider);
    final overTrainingAlertsAsync = ref.watch(overTrainingAlertsEnabledProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 16),
          
          // Notification Permissions Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notification Permissions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cross needs permission to send training alerts and achievement notifications.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await ref
                          .read(notificationNotifierProvider.notifier)
                          .requestPermissions();
                      
                      if (result) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Notification permissions granted!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enable notifications in your device settings'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    },
                    child: const Text('Request Permissions'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Training Load Alerts
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Training Load Alerts',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Get alerts when your training load is too high or too low based on ACWR science.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildSwitchTile(
                    context,
                    title: 'ACWR Alerts',
                    subtitle: 'Get notified when your ACWR is outside the safe range',
                    valueAsync: acwrAlertsAsync,
                    onChanged: (value) async {
                      await ref
                          .read(notificationNotifierProvider.notifier)
                          .updateAcwrAlertsEnabled(value);
                      ref.invalidate(acwrAlertsEnabledProvider);
                    },
                  ),
                  
                  _buildSwitchTile(
                    context,
                    title: 'Overtraining Alerts',
                    subtitle: 'Alert when ACWR > 1.3 (moderate to high injury risk)',
                    valueAsync: overTrainingAlertsAsync,
                    onChanged: (value) async {
                      await ref
                          .read(notificationNotifierProvider.notifier)
                          .updateOverTrainingAlertsEnabled(value);
                      ref.invalidate(overTrainingAlertsEnabledProvider);
                    },
                  ),
                  
                  _buildSwitchTile(
                    context,
                    title: 'Undertraining Alerts',
                    subtitle: 'Alert when ACWR < 0.8 (risk of deconditioning)',
                    valueAsync: underTrainingAlertsAsync,
                    onChanged: (value) async {
                      await ref
                          .read(notificationNotifierProvider.notifier)
                          .updateUnderTrainingAlertsEnabled(value);
                      ref.invalidate(underTrainingAlertsEnabledProvider);
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Weekly Summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weekly Reports',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Receive a summary of your training week every Sunday.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildSwitchTile(
                    context,
                    title: 'Weekly Summary',
                    subtitle: 'Sunday report with weekly stats and progress',
                    valueAsync: weeklySummaryAsync,
                    onChanged: (value) async {
                      await ref
                          .read(notificationNotifierProvider.notifier)
                          .updateWeeklySummaryEnabled(value);
                      ref.invalidate(weeklySummaryEnabledProvider);
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Achievements
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Achievements & Milestones',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Celebrate your progress with achievement notifications.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildSwitchTile(
                    context,
                    title: 'Achievement Alerts',
                    subtitle: 'Get notified when you unlock achievements',
                    valueAsync: achievementAlertsAsync,
                    onChanged: (value) async {
                      await ref
                          .read(notificationNotifierProvider.notifier)
                          .updateAchievementAlertsEnabled(value);
                      ref.invalidate(achievementAlertsEnabledProvider);
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Clear Notifications
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Manage Notifications',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      await ref
                          .read(notificationNotifierProvider.notifier)
                          .clearAllNotifications();
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('All notifications cleared'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.errorContainer,
                      foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    child: const Text('Clear All Notifications'),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This clears all pending notifications from your device.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Information
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'About Training Load Alerts',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'ACWR (Acute:Chronic Workload Ratio) is a scientifically validated method '
                  'for monitoring training load and preventing injury. '
                  'The sweet spot is 0.8-1.3, where you get optimal progress with minimal injury risk.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '• < 0.8: Undertraining risk\n'
                  '• 0.8-1.3: Sweet spot ✅\n'
                  '• 1.3-1.5: Caution zone\n'
                  '• > 1.5: High injury risk',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required AsyncValue<bool> valueAsync,
    required Function(bool) onChanged,
  }) {
    return valueAsync.when(
      data: (value) => SwitchListTile(
        title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        value: value,
        onChanged: onChanged,
        secondary: _getIconForSetting(title),
      ),
      loading: () => ListTile(
        title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        trailing: const CircularProgressIndicator(),
      ),
      error: (error, stack) => ListTile(
        title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
        subtitle: const Text('Error loading setting'),
        trailing: Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
      ),
    );
  }

  Icon _getIconForSetting(String title) {
    if (title.contains('ACWR') || title.contains('Training')) {
      return const Icon(Icons.trending_up);
    } else if (title.contains('Weekly')) {
      return const Icon(Icons.summarize);
    } else if (title.contains('Achievement')) {
      return const Icon(Icons.emoji_events);
    } else if (title.contains('Overtraining')) {
      return const Icon(Icons.warning);
    } else if (title.contains('Undertraining')) {
      return const Icon(Icons.trending_down);
    }
    return const Icon(Icons.notifications);
  }
}