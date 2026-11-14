import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/equipment_review.dart';
import 'availability_pill.dart';
import 'sample_badge.dart';
import 'stars.dart';

class ReviewTile extends StatelessWidget {
  const ReviewTile({
    super.key,
    required this.meta,
    this.showGymLink = false,
    this.onOpenEquipment,
    this.onToggleUpvote,
  });

  final ReviewWithMeta meta;
  final bool showGymLink;
  final VoidCallback? onOpenEquipment;
  final VoidCallback? onToggleUpvote;

  @override
  Widget build(BuildContext context) {
    final review = meta.review;
    final date = DateFormat.yMMMd().format(review.createdAt);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    review.authorUsername,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontSize: 16),
                  ),
                ),
                if (review.isSample) const SampleBadge(),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              date,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (showGymLink) ...[
              const SizedBox(height: 4),
              InkWell(
                onTap: onOpenEquipment,
                child: Text(
                  '${meta.equipmentName} · ${meta.gymName} (${meta.gymDistrict})',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Stars(value: review.condition.toDouble()),
                const SizedBox(width: 8),
                AvailabilityPill(value: review.availability),
              ],
            ),
            if (review.comment != null && review.comment!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                review.comment!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
            if (review.lastSeenWorking != null) ...[
              const SizedBox(height: 8),
              Text(
                'Last seen working: ${DateFormat.yMMMd().format(review.lastSeenWorking!)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onToggleUpvote,
                icon: Icon(
                  meta.votedByMe ? Icons.thumb_up : Icons.thumb_up_outlined,
                  size: 18,
                ),
                label: Text(
                  meta.upvoteCount == 0
                      ? 'Upvote'
                      : 'Upvote (${meta.upvoteCount})',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
