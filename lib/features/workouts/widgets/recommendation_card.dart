import 'package:flutter/material.dart';
import '../../../models/workout_recommendation.dart';

class RecommendationCard extends StatelessWidget {
  final WorkoutRecommendation recommendation;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const RecommendationCard({
    super.key,
    required this.recommendation,
    this.onTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icon based on recommendation type
                  _buildTypeIcon(),
                  const SizedBox(width: 12),
                  // Title and priority badge
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                recommendation.title,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                            _buildPriorityBadge(context),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Dismiss button
                  if (onDismiss != null)
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: onDismiss,
                      tooltip: 'Dismiss',
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                recommendation.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (recommendation.suggestedParameters.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildSuggestedParameters(context),
              ],
              if (recommendation.reasoning != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        recommendation.reasoning!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeIcon() {
    IconData iconData;
    Color iconColor;

    switch (recommendation.type) {
      case RecommendationType.progression:
        iconData = Icons.trending_up;
        iconColor = Colors.green;
        break;
      case RecommendationType.deload:
        iconData = Icons.trending_down;
        iconColor = Colors.orange;
        break;
      case RecommendationType.variety:
        iconData = Icons.shuffle;
        iconColor = Colors.blue;
        break;
      case RecommendationType.sportConditioning:
        iconData = Icons.sports_soccer;
        iconColor = Colors.purple;
        break;
      case RecommendationType.plateau:
        iconData = Icons.warning_amber_rounded;
        iconColor = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(iconData, color: iconColor, size: 24),
    );
  }

  Widget _buildPriorityBadge(BuildContext context) {
    if (recommendation.priority == RecommendationPriority.low) {
      return const SizedBox.shrink();
    }

    String label;
    Color color;

    switch (recommendation.priority) {
      case RecommendationPriority.high:
        label = 'High Priority';
        color = Colors.red;
        break;
      case RecommendationPriority.medium:
        label = 'Recommended';
        color = Colors.orange;
        break;
      case RecommendationPriority.low:
        label = '';
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
      ),
    );
  }

  Widget _buildSuggestedParameters(BuildContext context) {
    final params = recommendation.suggestedParameters;
    final chips = <Widget>[];

    if (params.containsKey('weight')) {
      chips.add(_buildParameterChip(
        context,
        '${params['weight']}kg',
        Icons.fitness_center,
      ));
    }

    if (params.containsKey('reps')) {
      chips.add(_buildParameterChip(
        context,
        '${params['reps']} reps',
        Icons.repeat,
      ));
    }

    if (params.containsKey('sets')) {
      chips.add(_buildParameterChip(
        context,
        '${params['sets']} sets',
        Icons.format_list_numbered,
      ));
    }

    if (params.containsKey('duration')) {
      chips.add(_buildParameterChip(
        context,
        '${params['duration']}s',
        Icons.timer,
      ));
    }

    if (params.containsKey('rest')) {
      chips.add(_buildParameterChip(
        context,
        '${params['rest']}s rest',
        Icons.bedtime,
      ));
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chips,
    );
  }

  Widget _buildParameterChip(BuildContext context, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Theme.of(context).colorScheme.onSecondaryContainer),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
