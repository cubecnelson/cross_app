import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/shorebird_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/home/screens/home_screen.dart';

class CrossApp extends ConsumerWidget {
  const CrossApp({super.key, required this.shorebirdCodePush});

  final ShorebirdUpdater shorebirdCodePush;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'Cross',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: themeMode,
      home: _ShorebirdUpdateChecker(
        child: authState.when(
          data: (state) {
            if (state.session != null) {
              return const HomeScreen();
            }
            return LoginScreen();
          },
          loading: () => const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
          error: (_, __) => LoginScreen(),
        ),
      ),
    );
  }
}

class _ShorebirdUpdateChecker extends ConsumerStatefulWidget {
  const _ShorebirdUpdateChecker({required this.child});

  final Widget child;

  @override
  ConsumerState<_ShorebirdUpdateChecker> createState() =>
      _ShorebirdUpdateCheckerState();
}

class _ShorebirdUpdateCheckerState
    extends ConsumerState<_ShorebirdUpdateChecker> {
  @override
  void initState() {
    super.initState();
    _checkForUpdates();
  }

  Future<void> _checkForUpdates() async {
    // Wait a bit for the app to initialize
    await Future.delayed(const Duration(seconds: 2));
    
    final notifier = ref.read(shorebirdNotifierProvider.notifier);
    await notifier.checkForUpdates();
  }

  @override
  Widget build(BuildContext context) {
    final shorebirdState = ref.watch(shorebirdNotifierProvider);
    
    // Show update available dialog
    if (shorebirdState.updateAvailable &&
        !shorebirdState.downloadingUpdate &&
        !shorebirdState.updateDownloaded) {
      _showUpdateDialog(context, shorebirdState);
    }
    
    // Show download progress
    if (shorebirdState.downloadingUpdate) {
      _showDownloadProgress(context);
    }
    
    return widget.child;
  }

  void _showUpdateDialog(BuildContext context, ShorebirdState state) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Update Available'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('A new version of Cross is available.'),
              if (state.currentPatchNumber != null &&
                  state.nextPatchNumber != null)
                Text(
                  'Update from patch ${state.currentPatchNumber} to ${state.nextPatchNumber}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              const SizedBox(height: 16),
              const Text(
                'Would you like to download and install it now?',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Later'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final notifier =
                    ref.read(shorebirdNotifierProvider.notifier);
                final success = await notifier.downloadUpdate();
                if (success && context.mounted) {
                  _showRestartDialog(context);
                }
              },
              child: const Text('Download'),
            ),
          ],
        ),
      );
    });
  }

  void _showDownloadProgress(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Downloading Update'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Downloading the latest update...'),
              const SizedBox(height: 8),
              Text(
                'This will only take a moment.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showRestartDialog(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Update Ready'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 48),
              SizedBox(height: 16),
              Text('Update downloaded successfully!'),
              SizedBox(height: 8),
              Text(
                'The update will be applied when you restart the app.',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Continue'),
            ),
            ElevatedButton(
              onPressed: () {
                final notifier = ref.read(shorebirdNotifierProvider.notifier);
                notifier.restartApp();
                Navigator.pop(context);
              },
              child: const Text('Restart Now'),
            ),
          ],
        ),
      );
    });
  }
}

