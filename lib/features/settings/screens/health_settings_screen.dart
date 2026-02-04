import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/health_provider.dart';
import '../../../services/health_service.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/loading_indicator.dart';

class HealthSettingsScreen extends ConsumerWidget {
  const HealthSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthAvailability = ref.watch(healthAvailabilityProvider);
    final healthSummary = ref.watch(healthSummaryProvider);
    final healthPermissions = ref.watch(healthPermissionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Integration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            const Text(
              'Health & Fitness Integration',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Connect Cross with Apple Health or Google Fit to sync your workout data and view health metrics.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),

            // Platform Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Platform Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    healthAvailability.when(
                      data: (isAvailable) {
                        if (isAvailable) {
                          return _buildConnectedState(healthPermissions);
                        } else {
                          return _buildNotConnectedState(healthPermissions);
                        }
                      },
                      loading: () => const LoadingIndicator(
                        message: 'Checking health platform...',
                      ),
                      error: (error, stack) => _buildErrorState(error),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Today's Health Data
            if (healthPermissions.isInitialized) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Today's Health Summary",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      healthSummary.when(
                        data: (summary) {
                          if (summary == null) {
                            return const Center(
                              child: Text(
                                'No health data available for today',
                                style: TextStyle(color: Colors.grey),
                              ),
                            );
                          }

                          return _buildHealthSummary(summary);
                        },
                        loading: () => const LoadingIndicator(
                          message: 'Loading health data...',
                        ),
                        error: (error, stack) => _buildErrorState(error),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Sync Settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sync Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSyncSettings(ref),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Information
            const Text(
              'How It Works',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Workouts logged in Cross will be synced to your health platform\n'
              '• Daily steps, calories, and heart rate will be displayed in Cross\n'
              '• No personal data is stored on Cross servers\n'
              '• You can disconnect at any time',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectedState(HealthPermissions healthPermissions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Connected to ${healthPermissions.platformName}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Your workouts are automatically synced, and health data is available in the app.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        CustomButton(
          text: 'Disconnect',
          isOutlined: true,
          onPressed: () => _showDisconnectDialog(),
        ),
      ],
    );
  }

  Widget _buildNotConnectedState(HealthPermissions healthPermissions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.health_and_safety_outlined,
              color: Colors.orange,
              size: 24,
            ),
            SizedBox(width: 8),
            Text(
              'Health Integration Available',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Connect with ${healthPermissions.platformName} to sync your workout data and view health metrics.',
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        CustomButton(
          text: 'Connect to ${healthPermissions.platformName}',
          onPressed: () async {
            await healthPermissions.requestPermissions();
          },
        ),
      ],
    );
  }

  Widget _buildErrorState(Object error) {
    return Column(
      children: [
        const Icon(
          Icons.error_outline,
          color: Colors.red,
          size: 48,
        ),
        const SizedBox(height: 16),
        const Text(
          'Error Connecting to Health Platform',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          error.toString(),
          style: const TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        CustomButton(
          text: 'Retry Connection',
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildHealthSummary(HealthData summary) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildMetricTile('Steps', '${summary.steps?.toInt() ?? '--'}', Icons.directions_walk),
            _buildMetricTile('Calories', '${summary.calories?.toInt() ?? '--'}', Icons.local_fire_department),
            _buildMetricTile('Distance', _formatDistance(summary.distance), Icons.directions_run),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildMetricTile('Heart Rate', '${summary.heartRate?.toInt() ?? '--'} BPM', Icons.favorite),
            _buildMetricTile('Active', '${summary.activeMinutes?.inMinutes ?? '--'} min', Icons.timer),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.blue),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildSyncSettings(WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSyncToggle(
          title: 'Sync Workouts',
          subtitle: 'Automatically send workouts to health platform',
          value: true,
          onChanged: (value) {},
        ),
        const SizedBox(height: 16),
        _buildSyncToggle(
          title: 'Read Health Data',
          subtitle: 'Display steps, calories, and heart rate in app',
          value: true,
          onChanged: (value) {},
        ),
        const SizedBox(height: 16),
        _buildSyncToggle(
          title: 'Background Sync',
          subtitle: 'Keep data synced when app is not in use',
          value: false,
          onChanged: (value) {},
        ),
      ],
    );
  }

  Widget _buildSyncToggle({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }

  String _formatDistance(double? meters) {
    if (meters == null) return '--';
    if (meters < 1000) {
      return '${meters.toInt()}m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)}km';
    }
  }

  Future<void> _showDisconnectDialog() async {
    // TODO: Implement disconnect dialog
  }
}