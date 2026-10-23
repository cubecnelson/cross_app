import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../providers/workout_provider.dart';
import '../../../providers/training_load_provider.dart';
import '../../../widgets/loading_indicator.dart';

class TrainingLoadScreen extends ConsumerWidget {
  const TrainingLoadScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workouts = ref.watch(workoutNotifierProvider);
    final weeklyTotals = ref.watch(weeklyTotalsProvider);
    final acuteLoad = ref.watch(currentWeekAUProvider);
    final chronicLoad = ref.watch(chronicLoadProvider);
    final acwr = ref.watch(acwrProvider);
    final preferredTarget = ref.watch(preferredTargetProvider);
    final safeRange = ref.watch(safeRangeProvider);
    final trainingStatus = ref.watch(trainingStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Training Load Analysis'),
      ),
      body: workouts.when(
        data: (workoutsList) {
          if (workoutsList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.insights_outlined,
                    size: 80,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No training data yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complete workouts with sRPE ratings to see training load analysis',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // Check if any workouts have sRPE data
          final hasSRPEData = workoutsList.any((w) => w.sRPE != null);
          if (!hasSRPEData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sentiment_dissatisfied_outlined,
                    size: 80,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No sRPE data',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rate your workouts with Session RPE (0-10) to enable training load analysis',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to workouts list
                      Navigator.pop(context);
                    },
                    child: const Text('Go to Workouts'),
                  ),
                ],
              ),
            );
          }

          // Prepare chart data
          final weeklyData = weeklyTotals.entries.toList()
            ..sort((a, b) => a.key.compareTo(b.key));
          
          final chartSpots = weeklyData.asMap().entries.map((entry) {
            return FlSpot(
              entry.key.toDouble(),
              entry.value.value,
            );
          }).toList();

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(workoutNotifierProvider);
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current Status Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Training Status',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  context,
                                  'Acute Load (7-day)',
                                  '${acuteLoad.toStringAsFixed(0)} AU',
                                  Icons.trending_up,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  context,
                                  'Chronic Load (28-day)',
                                  '${chronicLoad.toStringAsFixed(0)} AU',
                                  Icons.timeline,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  context,
                                  'ACWR',
                                  acwr.toStringAsFixed(2),
                                  _getACWRIcon(acwr),
                                  color: _getACWRColor(acwr),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  context,
                                  'Training Status',
                                  trainingStatus,
                                  _getStatusIcon(trainingStatus),
                                  color: _getStatusColor(trainingStatus),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Recommended Targets Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recommended Targets',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          _buildTargetCard(
                            context,
                            'Preferred Weekly Target',
                            '${preferredTarget.toStringAsFixed(0)} AU',
                            'Based on 5% weekly progression',
                            Icons.flag,
                          ),
                          const SizedBox(height: 8),
                          _buildTargetCard(
                            context,
                            'Safe Range',
                            '${safeRange['lower']!.toStringAsFixed(0)} - ${safeRange['upper']!.toStringAsFixed(0)} AU',
                            'Sweet spot (0.8-1.3 ACWR)',
                            Icons.safety_check,
                          ),
                          const SizedBox(height: 8),
                          _buildTargetCard(
                            context,
                            '10% Rule Limit',
                            '${(acuteLoad * 1.1).toStringAsFixed(0)} AU',
                            'Max safe increase from last week',
                            Icons.warning_amber,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Weekly AU Trend Chart
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Weekly AU Trend (Last 4 Weeks)',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 200,
                            child: LineChart(
                              LineChartData(
                                gridData: FlGridData(show: false),
                                titlesData: FlTitlesData(show: false),
                                borderData: FlBorderData(show: false),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: chartSpots,
                                    isCurved: true,
                                    color: Theme.of(context).colorScheme.primary,
                                    barWidth: 4,
                                    belowBarData: BarAreaData(
                                      show: true,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.1),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ACWR Guide
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ACWR Guide',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          _buildGuideItem(
                            context,
                            '< 0.8',
                            'Under-training',
                            'Increased injury risk when deconditioned',
                            Colors.blue,
                          ),
                          const SizedBox(height: 8),
                          _buildGuideItem(
                            context,
                            '0.8 - 1.3',
                            'Sweet Spot ✅',
                            'Optimal for progress & injury prevention',
                            Colors.green,
                          ),
                          const SizedBox(height: 8),
                          _buildGuideItem(
                            context,
                            '1.3 - 1.5',
                            'Caution Zone',
                            'Moderate injury risk - consider reducing load',
                            Colors.orange,
                          ),
                          const SizedBox(height: 8),
                          _buildGuideItem(
                            context,
                            '> 1.5',
                            'Danger Zone',
                            'High injury risk - reduce load immediately',
                            Colors.red,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Hybrid Athlete Targets
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hybrid Athlete Weekly AU Ranges',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          _buildTargetRange(
                            context,
                            'Beginner',
                            '1,200 - 2,000 AU',
                            'Build consistency first',
                          ),
                          const SizedBox(height: 8),
                          _buildTargetRange(
                            context,
                            'Intermediate',
                            '2,000 - 3,500 AU',
                            'Balance running & strength',
                          ),
                          const SizedBox(height: 8),
                          _buildTargetRange(
                            context,
                            'Advanced',
                            '3,500 - 6,000+ AU',
                            'Elite concurrent training',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const LoadingIndicator(message: 'Loading training data...'),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading training data: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(workoutNotifierProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetCard(
    BuildContext context,
    String title,
    String value,
    String subtitle,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideItem(
    BuildContext context,
    String range,
    String label,
    String description,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      range,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetRange(
    BuildContext context,
    String level,
    String range,
    String description,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            level,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            range,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  IconData _getACWRIcon(double acwr) {
    if (acwr < 0.8) return Icons.arrow_downward;
    if (acwr > 1.3) return Icons.arrow_upward;
    return Icons.check_circle;
  }

  Color _getACWRColor(double acwr) {
    if (acwr < 0.8) return Colors.blue;
    if (acwr > 1.3) return Colors.red;
    return Colors.green;
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Under-training':
        return Icons.warning;
      case 'Spike! Risk':
        return Icons.dangerous;
      case 'Sweet Spot ✅':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Under-training':
        return Colors.blue;
      case 'Spike! Risk':
        return Colors.red;
      case 'Sweet Spot ✅':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}