import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/ontherack_constants.dart';
import '../../../providers/catalog_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../widgets/disclaimer_banner.dart';
import 'local_login_screen.dart';
import 'local_register_screen.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            OnTheRackConstants.appName,
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 4),
          Text(
            OnTheRackConstants.tagline,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          if (session == null) ...[
            const Text(
              'You are browsing as a guest. Log in to contribute a gym, add equipment, or write a review.',
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LocalLoginScreen()),
              ),
              child: const Text('Log in'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LocalRegisterScreen()),
              ),
              child: const Text('Create an account'),
            ),
          ] else ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(session.username),
              subtitle: const Text('Signed in on this device'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => ref.read(sessionProvider.notifier).signOut(),
              child: const Text('Log out'),
            ),
          ],
          const Divider(height: 32),
          Text('Appearance', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.system, label: Text('System')),
              ButtonSegment(value: ThemeMode.light, label: Text('Light')),
              ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
            ],
            selected: {themeMode},
            onSelectionChanged: (value) {
              ref.read(themeProvider.notifier).setThemeMode(value.first);
            },
          ),
          const Divider(height: 32),
          Text('About', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          const DisclaimerBanner(),
          const SizedBox(height: 16),
          Text(
            'v1 stores gyms, equipment, and reviews locally with Hive so the app runs without a new cloud schema. '
            'Supabase auth from the previous Cross app can still be configured with --dart-define, but catalog data is not written to Cross workout tables. '
            'The Dart package name remains "cross" and the GitHub repo remains cubecnelson/cross_app. '
            'iOS bundle id (com.cross.app) and Android applicationId were left unchanged in this pass.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
