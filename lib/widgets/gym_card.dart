import 'package:flutter/material.dart';
import '../models/gym.dart';
import 'sample_badge.dart';
import 'stars.dart';

class GymCard extends StatelessWidget {
  const GymCard({super.key, required this.summary, required this.onTap});

  final GymSummary summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final gym = summary.gym;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      gym.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  if (gym.isSample) const SampleBadge(),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${gym.district} · ${gym.address}',
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (gym.chain != null) ...[
                const SizedBox(height: 4),
                Text(
                  gym.chain!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Stars(value: summary.avgCondition),
                  const Spacer(),
                  Text(
                    '${summary.equipmentCount} equipment · ${summary.reviewCount} reviews',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
