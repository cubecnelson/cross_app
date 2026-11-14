import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/ontherack_constants.dart';
import '../../../providers/catalog_provider.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/review_tile.dart';
import '../../../widgets/sample_badge.dart';
import '../../../widgets/stars.dart';
import '../../account/screens/local_login_screen.dart';
import '../../reviews/screens/write_review_screen.dart';

class EquipmentDetailScreen extends ConsumerWidget {
  const EquipmentDetailScreen({super.key, required this.equipmentId});

  final String equipmentId;

  Future<void> _requireLogin(BuildContext context, WidgetRef ref) async {
    if (ref.read(sessionProvider) != null) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LocalLoginScreen()),
    );
  }

  Future<void> _write(BuildContext context, WidgetRef ref) async {
    await _requireLogin(context, ref);
    if (!context.mounted || ref.read(sessionProvider) == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WriteReviewScreen(equipmentId: equipmentId),
      ),
    );
  }

  Future<void> _upvote(
    BuildContext context,
    WidgetRef ref,
    String reviewId,
  ) async {
    await _requireLogin(context, ref);
    final session = ref.read(sessionProvider);
    if (session == null) return;
    await ref.read(catalogServiceProvider).toggleUpvote(
          session: session,
          reviewId: reviewId,
        );
    bumpCatalog(ref);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = ref.watch(equipmentItemProvider(equipmentId));
    final reviews = ref.watch(equipmentReviewsProvider(equipmentId));
    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Equipment')),
        body: const Center(child: Text('This equipment could not be found.')),
      );
    }

    final gym = ref.watch(gymDetailProvider(item.gymId));
    final conditions = reviews.map((r) => r.review.condition);
    final avg = conditions.isEmpty
        ? null
        : conditions.reduce((a, b) => a + b) / conditions.length;

    return Scaffold(
      appBar: AppBar(title: Text(item.name)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _write(context, ref),
        icon: const Icon(Icons.rate_review_outlined),
        label: const Text('Write a review'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(item.name, style: Theme.of(context).textTheme.displaySmall),
              ),
              if (item.isSample) const SampleBadge(),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${categoryLabel(item.category)} · ${gym?.gym.name ?? 'Unknown gym'}'
            '${gym != null ? ' (${gym.gym.district})' : ''}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (item.notes != null) ...[
            const SizedBox(height: 8),
            Text(item.notes!, style: Theme.of(context).textTheme.bodyMedium),
          ],
          const SizedBox(height: 12),
          Stars(value: avg),
          const SizedBox(height: 4),
          Text(
            'Added by ${item.addedByUsername}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Divider(height: 32),
          Text(
            'Reviews',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          if (reviews.isEmpty)
            EmptyState(
              icon: Icons.rate_review_outlined,
              title: 'No reviews yet',
              message: 'Be the first to report condition and wait time for this equipment.',
              actionText: 'Write a review',
              onAction: () => _write(context, ref),
            )
          else
            ...reviews.map(
              (meta) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ReviewTile(
                  meta: meta,
                  onToggleUpvote: () => _upvote(context, ref, meta.review.id),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
