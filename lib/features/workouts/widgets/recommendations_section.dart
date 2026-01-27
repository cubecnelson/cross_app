import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/workout_recommendation.dart';
import '../../../providers/recommendation_provider.dart';
import 'recommendation_card.dart';

class RecommendationsSection extends ConsumerWidget {
  final bool showOnlyPriority;
  final int maxRecommendations;
  final Function(WorkoutRecommendation)? onRecommendationTap;

  const RecommendationsSection({
    super.key,
    this.showOnlyPriority = false,
    this.maxRecommendations = 5,
    this.onRecommendationTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendationsAsync = ref.watch(workoutRecommendationsProvider);

    return recommendationsAsync.when(
      data: (recommendations) {
        if (recommendations.isEmpty) {
          return const SizedBox.shrink();
        }

        // Filter by priority if needed
        var displayRecommendations = showOnlyPriority
            ? recommendations.where((r) => r.priority == RecommendationPriority.high).toList()
            : recommendations;

        // Limit number of recommendations
        displayRecommendations = displayRecommendations.take(maxRecommendations).toList();

        if (displayRecommendations.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'AI Recommendations',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                if (!showOnlyPriority)
                  TextButton(
                    onPressed: () {
                      ref.read(recommendationNotifierProvider.notifier).refreshRecommendations();
                    },
                    child: const Text('Refresh'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Personalized suggestions based on your workout history',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            ...displayRecommendations.map((recommendation) {
              return RecommendationCard(
                recommendation: recommendation,
                onTap: () {
                  if (onRecommendationTap != null) {
                    onRecommendationTap!(recommendation);
                  }
                },
                onDismiss: () {
                  ref
                      .read(recommendationNotifierProvider.notifier)
                      .dismissRecommendation(recommendation.id);
                },
              );
            }),
          ],
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 32),
              const SizedBox(height: 8),
              Text(
                'Failed to load recommendations',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact recommendations widget for dashboard
class CompactRecommendations extends ConsumerWidget {
  const CompactRecommendations({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendationsAsync = ref.watch(workoutRecommendationsProvider);

    return recommendationsAsync.when(
      data: (recommendations) {
        if (recommendations.isEmpty) {
          return const SizedBox.shrink();
        }

        // Show only top 3 high priority recommendations
        final topRecommendations = recommendations
            .where((r) => r.priority == RecommendationPriority.high)
            .take(3)
            .toList();

        if (topRecommendations.isEmpty) {
          // Show top 2 medium priority if no high priority
          final mediumRecommendations = recommendations
              .where((r) => r.priority == RecommendationPriority.medium)
              .take(2)
              .toList();
          
          if (mediumRecommendations.isEmpty) {
            return const SizedBox.shrink();
          }

          return _buildCompactCard(context, mediumRecommendations);
        }

        return _buildCompactCard(context, topRecommendations);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildCompactCard(BuildContext context, List<WorkoutRecommendation> recommendations) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Workout Tips',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...recommendations.map((rec) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.arrow_right,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          rec.title,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
