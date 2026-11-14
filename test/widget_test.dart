// Smoke test: OnTheRack lets guests browse seeded Hong Kong gyms.

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

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

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
  }

  testWidgets('guest can browse seeded gyms without logging in', (tester) async {
    await pumpApp(tester);

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('OnTheRack'), findsWidgets);
    expect(find.text('Peak Club Central'), findsOneWidget);
    expect(find.text('Sha Tin Sports Centre'), findsOneWidget);
    expect(find.text('IronHour 24 Mong Kok'), findsOneWidget);
    expect(find.text('East Box Kwun Tong'), findsOneWidget);
  });

  testWidgets('search filter narrows the gym list', (tester) async {
    await pumpApp(tester);

    await tester.enterText(find.byType(TextField), 'sha tin');
    await tester.pump();

    expect(find.text('Sha Tin Sports Centre'), findsOneWidget);
    expect(find.text('Peak Club Central'), findsNothing);
  });
}
