import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-project.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-anon-key-here',
  );

  static Future<void> initialize() async {
    // Check if using default values (development)
    if (supabaseUrl == 'https://your-project.supabase.co' || 
        supabaseAnonKey == 'your-anon-key-here') {
      if (kDebugMode) {
        print('⚠️  WARNING: Using default Supabase configuration');
        print('   Set SUPABASE_URL and SUPABASE_ANON_KEY environment variables');
        print('   For production: Use --dart-define flags when building');
        print('   For development: Create a .env file or set in IDE');
      }
    }

    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
      );
      
      if (kDebugMode) {
        print('✅ Supabase initialized successfully');
        print('   URL: ${supabaseUrl.substring(0, 30)}...');
        print('   Environment: ${supabaseUrl.contains('localhost') || supabaseUrl.contains('127.0.0.1') ? 'Local' : 'Production'}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to initialize Supabase: $e');
        print('   Check your SUPABASE_URL and SUPABASE_ANON_KEY values');
        print('   URL format: https://[project-ref].supabase.co');
        print('   Get credentials from: Supabase Dashboard → Settings → API');
      }
      rethrow;
    }
  }

  static SupabaseClient get client {
    try {
      return Supabase.instance.client;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Supabase client not initialized: $e');
        print('   Call SupabaseConfig.initialize() first');
      }
      rethrow;
    }
  }
}
