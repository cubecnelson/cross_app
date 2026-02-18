import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/shorebird_provider.dart';
import '../../auth/screens/login_screen.dart';
import 'health_settings_screen.dart';
import 'data_export_screen.dart';
import 'notification_settings_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const _SectionHeader(title: 'App'),
          ListTile(
            leading: const Icon(Icons.info_outline, size: 24, color: null),
            title: const Text('About'),
            subtitle: const Text('Version ${AppConstants.appVersion}'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: AppConstants.appName,
                applicationVersion: AppConstants.appVersion,
                applicationLegalese: '© 2026 Cross. All rights reserved.',
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'A robust workout tracking app for strength training.',
                  ),
                ],
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined, size: 24, color: null),
            title: const Text('Notifications'),
            subtitle: const Text('Training alerts and achievements'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationSettingsScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined, size: 24, color: null),
            title: const Text('Privacy Policy'),
            onTap: () {
              // TODO: Show privacy policy
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Privacy policy coming soon')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined, size: 24, color: null),
            title: const Text('Terms of Service'),
            onTap: () {
              // TODO: Show terms of service
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Terms of service coming soon')),
              );
            },
          ),
          const Divider(),
          const _SectionHeader(title: 'Data'),
          ListTile(
            leading: const Icon(Icons.health_and_safety_outlined, size: 24, color: null),
            title: const Text('Health Integration'),
            subtitle: const Text('Connect with Apple Health or Google Fit'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HealthSettingsScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.download_outlined, size: 24, color: null),
            title: const Text('Export Data'),
            subtitle: const Text('Download your workout data as CSV or PDF'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DataExportScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, size: 24, color: null),
            title: const Text('Delete Account'),
            subtitle: const Text('Permanently delete your account and data'),
            textColor: Colors.red,
            iconColor: Colors.red,
            onTap: () async {
              final result = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Account'),
                  content: const Text(
                    'Are you sure you want to delete your account? '
                    'This action cannot be undone and all your data will be permanently deleted.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );

              if (result == true && context.mounted) {
                // TODO: Implement account deletion
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Account deletion coming soon'),
                  ),
                );
              }
            },
          ),
          const Divider(),
          const _SectionHeader(title: 'Updates'),
          Consumer(
            builder: (context, ref, child) {
              final shorebirdState = ref.watch(shorebirdNotifierProvider);
              final currentPatchAsync = ref.watch(shorebirdCurrentPatchNumberProvider);
              final nextPatchAsync = ref.watch(shorebirdNextPatchNumberProvider);
              
              return Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.system_update, size: 24, color: null),
                    title: const Text('Check for Updates'),
                    subtitle: currentPatchAsync.when(
                      data: (patchNumber) => Text(
                        patchNumber != null
                            ? 'Current patch: $patchNumber'
                            : 'Check for over-the-air updates',
                      ),
                      loading: () => const Text('Checking...'),
                      error: (_, __) => const Text('Update check failed'),
                    ),
                    trailing: shorebirdState.checkingForUpdates
                        ? const CircularProgressIndicator()
                        : null,
                    onTap: () async {
                      final notifier = ref.read(shorebirdNotifierProvider.notifier);
                      await notifier.checkForUpdates();
                    },
                  ),
                  if (shorebirdState.updateAvailable)
                    ListTile(
                      leading: const Icon(Icons.download, size: 24, color: Colors.green),
                      title: const Text('Update Available'),
                      subtitle: nextPatchAsync.when(
                        data: (nextPatch) => Text(
                          nextPatch != null
                              ? 'Patch $nextPatch ready to download'
                              : 'New version available',
                        ),
                        loading: () => const Text('Checking...'),
                        error: (_, __) => const Text('Error'),
                      ),
                      trailing: shorebirdState.downloadingUpdate
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: () async {
                                final notifier = ref.read(shorebirdNotifierProvider.notifier);
                                final success = await notifier.downloadUpdate();
                                if (success && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Update downloaded successfully!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              },
                              child: const Text('Download'),
                            ),
                    ),
                  if (shorebirdState.error != null)
                    ListTile(
                      leading: const Icon(Icons.error_outline, size: 24, color: Colors.red),
                      title: const Text('Update Error'),
                      subtitle: Text(shorebirdState.error!),
                      onTap: () {
                        final notifier = ref.read(shorebirdNotifierProvider.notifier);
                        notifier.clearError();
                      },
                    ),
                ],
              );
            },
          ),
          const Divider(),
          const _SectionHeader(title: 'Account'),
          ListTile(
            leading: const Icon(Icons.logout, size: 24, color: null),
            title: const Text('Sign Out'),
            subtitle: const Text('Log out of your account'),
            onTap: () async {
              final result = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Sign Out'),
                  content: const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('Sign Out'),
                    ),
                  ],
                ),
              );

              if (result == true && context.mounted) {
                debugPrint('🚪 Signing out from settings...');

                // Show loading indicator
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Signing out...'),
                    duration: Duration(seconds: 1),
                  ),
                );

                try {
                  await ref.read(authNotifierProvider.notifier).signOut();
                  debugPrint('✅ Sign out successful from settings');

                  if (context.mounted) {
                    // Navigate to login screen and clear navigation stack
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => LoginScreen(),
                      ),
                      (route) => false,
                    );

                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Signed out successfully! 👋'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  debugPrint('❌ Sign out failed: $e');

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to sign out: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
          ),
          const Divider(),
          const _SectionHeader(title: 'Support'),
          ListTile(
            leading: const Icon(Icons.help_outline, size: 24, color: null),
            title: const Text('Help & Support'),
            onTap: () {
              // TODO: Show help
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Help center coming soon')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.bug_report_outlined, size: 24, color: null),
            title: const Text('Report a Bug'),
            onTap: () {
              // TODO: Show bug report form
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bug reporting coming soon')),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
      ),
    );
  }
}
