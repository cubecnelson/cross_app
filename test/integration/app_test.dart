import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cross/app.dart';
import 'package:cross/providers/catalog_provider.dart';
import 'package:cross/services/catalog_service.dart';
import 'package:cross/services/local_auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('OnTheRackApp opens on the gym list for guests', (tester) async {
    final catalog = CatalogService.memory();
    await catalog.initialize();
    final auth = LocalAuthService(catalog);
    await auth.initialize();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          catalogServiceProvider.overrideWithValue(catalog),
          localAuthServiceProvider.overrideWithValue(auth),
        ],
        child: const OnTheRackApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Gyms'), findsOneWidget);
    expect(find.text('Peak Club Central'), findsOneWidget);
    expect(find.text('Log in'), findsNothing);
  });
}
