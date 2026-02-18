// Basic Flutter widget smoke test for Cross app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import 'package:cross/app.dart';
import 'package:cross/providers/shorebird_provider.dart';

void main() {
  testWidgets('Cross app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          shorebirdCodePushProvider.overrideWithValue(ShorebirdUpdater()),
        ],
        child: CrossApp(shorebirdCodePush: ShorebirdUpdater()),
      ),
    );

    // Verify app loads and shows MaterialApp
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
