import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'core/config/supabase_config.dart';
import 'providers/catalog_provider.dart';
import 'services/catalog_service.dart';
import 'services/local_auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  final catalog = CatalogService.hive();
  await catalog.initialize();

  final auth = LocalAuthService(catalog);
  await auth.initialize();

  // Optional: keep Cross-era Supabase config via dart-define, but do not
  // block startup or write catalog data to Cross workout tables.
  try {
    await SupabaseConfig.initializeIfConfigured();
  } catch (e) {
    if (kDebugMode) {
      debugPrint('Supabase init skipped: $e');
    }
  }

  runApp(
    ProviderScope(
      overrides: [
        catalogServiceProvider.overrideWithValue(catalog),
        localAuthServiceProvider.overrideWithValue(auth),
      ],
      child: const OnTheRackApp(),
    ),
  );
}
