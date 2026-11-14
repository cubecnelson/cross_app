import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/ontherack_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/home/screens/home_screen.dart';
import 'providers/theme_provider.dart';

/// Root widget for OnTheRack. Browsing does not require an account.
class OnTheRackApp extends ConsumerWidget {
  const OnTheRackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: OnTheRackConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: themeMode,
      home: const HomeScreen(),
    );
  }
}
