import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/ontherack_constants.dart';
import '../../../providers/catalog_provider.dart';
import '../../../widgets/availability_pill.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/sample_badge.dart';
import '../../../widgets/stars.dart';
import '../../account/screens/local_login_screen.dart';
import '../../equipment/screens/add_equipment_screen.dart';
import '../../equipment/screens/equipment_detail_screen.dart';

class GymDetailScreen extends ConsumerWidget {
  const GymDetailScreen({super.key, required this.gymId});

  final String gymId;

  Future<void> _addEquipment(BuildContext context, WidgetRef ref) async {
    if (ref.read(sessionProvider) == null) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LocalLoginScreen()),
      );
      if (!context.mounted || ref.read(sessionProvider) == null) return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AddEquipmentScreen(gymId: gymId)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(gymDetailProvider(gymId));
    final equipment = ref.watch(gymEquipmentProvider(gymId));

    if (summary == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Gym')),
        body: const Center(child: Text('This gym could not be found.')),
      );
    }

    final gym = summary.gym;
    return Scaffold(
      appBar: AppBar(title: Text(gym.name)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addEquipment(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add equipment'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  gym.name,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ),
              if (gym.isSample) const SampleBadge(),
            ],
          ),
          const SizedBox(height: 8),
          Text(gym.district, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(gym.address, style: Theme.of(context).textTheme.bodyLarge),
          if (gym.chain != null) ...[
            const SizedBox(height: 8),
            Text(gym.chain!, style: Theme.of(context).textTheme.bodyMedium),
          ],
          if (gym.hours != null) ...[
            const SizedBox(height: 8),
            Text('Hours: ${gym.hours}', style: Theme.of(context).textTheme.bodyMedium),
          ],
          if (gym.website != null || gym.mapsUrl != null) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                if (gym.website != null)
                  TextButton.icon(
                    onPressed: () => launchUrl(Uri.parse(gym.website!)),
                    icon: const Icon(Icons.language),
                    label: const Text('Website'),
                  ),
                if (gym.mapsUrl != null)
                  TextButton.icon(
                    onPressed: () => launchUrl(Uri.parse(gym.mapsUrl!)),
                    icon: const Icon(Icons.map_outlined),
                    label: const Text('Maps'),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Stars(value: summary.avgCondition),
              const SizedBox(width: 12),
              Text(
                '${summary.equipmentCount} equipment · ${summary.reviewCount} reviews',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Added by ${gym.addedByUsername}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Divider(height: 32),
          Text('Equipment on the floor', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          if (equipment.isEmpty)
            EmptyState(
              icon: Icons.fitness_center_outlined,
              title: 'No equipment listed yet',
              message: 'Add a machine, rack, or free-weight setup you have seen here.',
              actionText: 'Add equipment',
              onAction: () => _addEquipment(context, ref),
            )
          else
            ...equipment.map((item) {
              return Card(
                child: ListTile(
                  title: Row(
                    children: [
                      Expanded(child: Text(item.item.name)),
                      if (item.item.isSample) const SampleBadge(),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(categoryLabel(item.item.category)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Stars(value: item.avgCondition, size: 14),
                          const SizedBox(width: 8),
                          Text(
                            '${item.reviewCount} ${item.reviewCount == 1 ? 'review' : 'reviews'}',
                          ),
                          if (item.latestAvailability != null) ...[
                            const SizedBox(width: 8),
                            AvailabilityPill(value: item.latestAvailability!),
                          ],
                        ],
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          EquipmentDetailScreen(equipmentId: item.item.id),
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
