import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/catalog_provider.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/review_tile.dart';
import '../../account/screens/local_login_screen.dart';
import '../../equipment/screens/equipment_detail_screen.dart';

class RecentReviewsScreen extends ConsumerWidget {
  const RecentReviewsScreen({super.key});

  Future<void> _upvote(
    BuildContext context,
    WidgetRef ref,
    String reviewId,
  ) async {
    if (ref.read(sessionProvider) == null) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LocalLoginScreen()),
      );
    }
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
    final reviews = ref.watch(recentReviewsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Recent reviews')),
      body: reviews.isEmpty
          ? const EmptyState(
              icon: Icons.rate_review_outlined,
              title: 'No reviews yet',
              message: 'Reviews of gym equipment will show up here.',
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final meta = reviews[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ReviewTile(
                    meta: meta,
                    showGymLink: true,
                    onOpenEquipment: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => EquipmentDetailScreen(
                          equipmentId: meta.equipmentId,
                        ),
                      ),
                    ),
                    onToggleUpvote: () => _upvote(context, ref, meta.review.id),
                  ),
                );
              },
            ),
    );
  }
}
