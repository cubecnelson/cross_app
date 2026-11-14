import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/ontherack_constants.dart';
import '../../../providers/catalog_provider.dart';
import '../../../widgets/disclaimer_banner.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/gym_card.dart';
import '../../account/screens/local_login_screen.dart';
import 'add_gym_screen.dart';
import 'gym_detail_screen.dart';

class GymsListScreen extends ConsumerStatefulWidget {
  const GymsListScreen({super.key});

  @override
  ConsumerState<GymsListScreen> createState() => _GymsListScreenState();
}

class _GymsListScreenState extends ConsumerState<GymsListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _addGym() async {
    final session = ref.read(sessionProvider);
    if (session == null) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LocalLoginScreen()),
      );
      if (!mounted || ref.read(sessionProvider) == null) return;
    }
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddGymScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gyms = ref.watch(gymListProvider);
    final districts = ref.watch(districtListProvider);
    final filter = ref.watch(gymFilterProvider);
    final counts = ref.watch(catalogCountsProvider);
    final selected = filter.district;

    return Scaffold(
      appBar: AppBar(
        title: const Text(OnTheRackConstants.appName),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addGym,
        icon: const Icon(Icons.add),
        label: const Text('Add a gym'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          Text(
            'Crowdsourced equipment reviews',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            OnTheRackConstants.tagline,
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 8),
          Text(
            'A social inventory of machines, racks, cardio, and free weights — reviewed per gym. Hong Kong first, not Hong Kong only.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 12),
          Text(
            '${counts.gyms} gyms · ${counts.equipment} equipment items · ${counts.reviews} reviews',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          const DisclaimerBanner(compact: true),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Search gyms',
              hintText: 'Name, district, address, or chain',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) =>
                ref.read(gymFilterProvider.notifier).setQuery(value),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String?>(
            value: selected,
            decoration: const InputDecoration(
              labelText: 'Hong Kong district',
            ),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('All districts'),
              ),
              ...districts.map(
                (d) => DropdownMenuItem<String?>(value: d, child: Text(d)),
              ),
            ],
            onChanged: (value) =>
                ref.read(gymFilterProvider.notifier).setDistrict(value),
          ),
          const SizedBox(height: 16),
          Text(
            '${gyms.length} ${gyms.length == 1 ? 'gym' : 'gyms'}'
            '${filter.query.isNotEmpty || (filter.district ?? '').isNotEmpty ? ' matching your search' : ''}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          if (gyms.isEmpty)
            EmptyState(
              icon: Icons.storefront_outlined,
              title: filter.query.isNotEmpty || (filter.district ?? '').isNotEmpty
                  ? 'No gyms match that search'
                  : 'No gyms yet',
              message: filter.query.isNotEmpty || (filter.district ?? '').isNotEmpty
                  ? 'Try a different name or district.'
                  : 'Be the first to add a gym and the equipment on its floor.',
              actionText: 'Add a gym',
              onAction: _addGym,
            )
          else
            ...gyms.map(
              (summary) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GymCard(
                  summary: summary,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => GymDetailScreen(gymId: summary.gym.id),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
