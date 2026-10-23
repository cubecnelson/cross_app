import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import 'core/config/supabase_config.dart';
import 'services/local_storage_service.dart';
import 'app.dart';
import 'providers/shorebird_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Shorebird for over-the-air updates
  final shorebirdCodePush = ShorebirdUpdater();
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  await LocalStorageService.initialize();
  
  // Initialize Supabase
  await SupabaseConfig.initialize();
  
  runApp(
    ProviderScope(
      overrides: [
        shorebirdCodePushProvider.overrideWithValue(shorebirdCodePush),
      ],
      child: CrossApp(
        shorebirdCodePush: shorebirdCodePush,
      ),
    ),
  );
}

