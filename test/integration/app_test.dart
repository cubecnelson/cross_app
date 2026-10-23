import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import 'package:cross/app.dart';
import 'package:cross/providers/auth_provider.dart';
import 'package:cross/providers/shorebird_provider.dart';
import 'package:cross/providers/theme_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Mock ThemeNotifier for testing
class MockThemeNotifier extends ThemeNotifier {
  MockThemeNotifier(ThemeMode initialMode) : super() {
    state = initialMode;
  }
}

void main() {
  testWidgets('CrossApp shows LoginScreen when no session', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) {
            return Stream.value(AuthState(AuthChangeEvent.signedOut, null));
          }),
          themeProvider.overrideWith((ref) => MockThemeNotifier(ThemeMode.light)),
          shorebirdCodePushProvider.overrideWithValue(ShorebirdUpdater()),
        ],
        child: CrossApp(shorebirdCodePush: ShorebirdUpdater()),
      ),
    );

    // Verify app title
    expect(find.text('Cross'), findsOneWidget);
    
    // LoginScreen should be shown since there's no session
    // We can verify by looking for login-related widgets
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('CrossApp shows loading state', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) {
            // Return a stream that never emits to simulate loading state
            return const Stream.empty();
          }),
          themeProvider.overrideWith((ref) => MockThemeNotifier(ThemeMode.light)),
          shorebirdCodePushProvider.overrideWithValue(ShorebirdUpdater()),
        ],
        child: CrossApp(shorebirdCodePush: ShorebirdUpdater()),
      ),
    );

    // Should show loading indicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('CrossApp shows error state then login', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) {
            return Stream.error('Test error');
          }),
          themeProvider.overrideWith((ref) => MockThemeNotifier(ThemeMode.light)),
          shorebirdCodePushProvider.overrideWithValue(ShorebirdUpdater()),
        ],
        child: CrossApp(shorebirdCodePush: ShorebirdUpdater()),
      ),
    );

    // Error state should fall back to LoginScreen
    // LoginScreen should be shown
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('CrossApp respects theme mode', (WidgetTester tester) async {
    // Test light theme
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) {
            return Stream.value(AuthState(AuthChangeEvent.signedOut, null));
          }),
          themeProvider.overrideWith((ref) => MockThemeNotifier(ThemeMode.light)),
          shorebirdCodePushProvider.overrideWithValue(ShorebirdUpdater()),
        ],
        child: CrossApp(shorebirdCodePush: ShorebirdUpdater()),
      ),
    );

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, ThemeMode.light);

    // Test dark theme
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) {
            return Stream.value(AuthState(AuthChangeEvent.signedOut, null));
          }),
          themeProvider.overrideWith((ref) => MockThemeNotifier(ThemeMode.dark)),
          shorebirdCodePushProvider.overrideWithValue(ShorebirdUpdater()),
        ],
        child: CrossApp(shorebirdCodePush: ShorebirdUpdater()),
      ),
    );

    final materialAppDark = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialAppDark.themeMode, ThemeMode.dark);

    // Test system theme
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) {
            return Stream.value(AuthState(AuthChangeEvent.signedOut, null));
          }),
          themeProvider.overrideWith((ref) => MockThemeNotifier(ThemeMode.system)),
          shorebirdCodePushProvider.overrideWithValue(ShorebirdUpdater()),
        ],
        child: CrossApp(shorebirdCodePush: ShorebirdUpdater()),
      ),
    );

    final materialAppSystem = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialAppSystem.themeMode, ThemeMode.system);
  });
}