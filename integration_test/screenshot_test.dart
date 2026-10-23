import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

import 'package:cross/app.dart';
import 'package:cross/core/theme/app_theme.dart';
import 'package:cross/features/auth/screens/register_screen.dart';
import 'package:cross/features/auth/screens/forgot_password_screen.dart';
import 'package:cross/features/settings/screens/settings_screen.dart';
import 'package:cross/features/settings/screens/notification_settings_screen.dart';
import 'package:cross/features/settings/screens/data_export_screen.dart';
import 'package:cross/features/settings/screens/health_settings_screen.dart';
import 'package:cross/features/workouts/screens/active_workout_screen.dart';
import 'package:cross/features/workouts/screens/workouts_list_screen.dart';
import 'package:cross/features/workouts/screens/session_rpe_screen.dart';
import 'package:cross/features/routines/screens/routines_list_screen.dart';
import 'package:cross/features/routines/screens/create_routine_screen.dart';
import 'package:cross/features/progress/screens/training_load_screen.dart';
import 'package:cross/features/exercises/screens/exercise_picker_screen.dart';

import 'screenshot_helper.dart';
import 'screenshot_mocks.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final screenshotCapture = ScreenshotCapture(
    outputDirectory: Directory('screenshots'),
  );

  final testDeviceSizes = [DeviceSize.genericPhone];

  void setViewport(WidgetTester tester, DeviceSize size) {
    tester.view.physicalSize = size.physicalSize;
    tester.view.devicePixelRatio = size.devicePixelRatio;
  }

  Future<void> captureScreen(WidgetTester tester, ScreenshotCapture capture,
      String name, List<DeviceSize> sizes) async {
    for (final size in sizes) {
      setViewport(tester, size);
      await tester.pumpAndSettle();
      await capture.capture(tester, '${name}_${size.name}');
    }
  }

  Widget wrapWithProviders(Widget child, List<Override> overrides) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: AppTheme.lightTheme(),
        home: child,
      ),
    );
  }

  group('Auth Screens', () {
    testWidgets('Login', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: signedOutOverrides(),
          child: CrossApp(shorebirdCodePush: ShorebirdUpdater()),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await captureScreen(tester, screenshotCapture, 'login', testDeviceSizes);
    });

    testWidgets('Register', (tester) async {
      await tester.pumpWidget(wrapWithProviders(
        const RegisterScreen(),
        signedOutOverrides(),
      ));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await captureScreen(tester, screenshotCapture, 'register', testDeviceSizes);
    });

    testWidgets('Forgot Password', (tester) async {
      await tester.pumpWidget(wrapWithProviders(
        const ForgotPasswordScreen(),
        signedOutOverrides(),
      ));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await captureScreen(
          tester, screenshotCapture, 'forgot_password', testDeviceSizes);
    });
  });

  group('Home Tabs', () {
    testWidgets('Dashboard', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: signedInOverrides(),
          child: CrossApp(shorebirdCodePush: ShorebirdUpdater()),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await captureScreen(tester, screenshotCapture, 'dashboard', testDeviceSizes);
    });

    testWidgets('Workouts', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: signedInOverrides(),
          child: CrossApp(shorebirdCodePush: ShorebirdUpdater()),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await tester.tap(find.text('Workouts'));
      await tester.pumpAndSettle();
      await captureScreen(tester, screenshotCapture, 'workouts', testDeviceSizes);
    });

    testWidgets('Progress', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: signedInOverrides(),
          child: CrossApp(shorebirdCodePush: ShorebirdUpdater()),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await tester.tap(find.text('Progress'));
      await tester.pumpAndSettle();
      await captureScreen(tester, screenshotCapture, 'progress', testDeviceSizes);
    });

    testWidgets('Profile', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: signedInOverrides(),
          child: CrossApp(shorebirdCodePush: ShorebirdUpdater()),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      await captureScreen(tester, screenshotCapture, 'profile', testDeviceSizes);
    });
  });

  group('Settings & Sub-screens', () {
    testWidgets('Settings', (tester) async {
      await tester.pumpWidget(wrapWithProviders(
        const SettingsScreen(),
        signedInOverrides(),
      ));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await captureScreen(tester, screenshotCapture, 'settings', testDeviceSizes);
    });

    testWidgets('Notification Settings', (tester) async {
      await tester.pumpWidget(wrapWithProviders(
        const NotificationSettingsScreen(),
        signedInOverrides(),
      ));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await captureScreen(tester, screenshotCapture, 'notification_settings',
          testDeviceSizes);
    });

    testWidgets('Data Export', (tester) async {
      await tester.pumpWidget(wrapWithProviders(
        const DataExportScreen(),
        signedInOverrides(),
      ));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await captureScreen(
          tester, screenshotCapture, 'data_export', testDeviceSizes);
    });

    testWidgets('Health Settings', (tester) async {
      await tester.pumpWidget(wrapWithProviders(
        const HealthSettingsScreen(),
        signedInOverrides(),
      ));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await captureScreen(
          tester, screenshotCapture, 'health_settings', testDeviceSizes);
    });
  });

  group('Workout & Exercise Screens', () {
    testWidgets('Active Workout', (tester) async {
      await tester.pumpWidget(wrapWithProviders(
        const ActiveWorkoutScreen(),
        signedInOverrides(),
      ));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await captureScreen(
          tester, screenshotCapture, 'active_workout', testDeviceSizes);
    });

    testWidgets('Workouts List', (tester) async {
      await tester.pumpWidget(wrapWithProviders(
        const WorkoutsListScreen(),
        signedInOverrides(),
      ));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await captureScreen(
          tester, screenshotCapture, 'workouts_list', testDeviceSizes);
    });

    testWidgets('Session RPE', (tester) async {
      await tester.pumpWidget(wrapWithProviders(
        SessionRpeScreen(workout: mockWorkout, isPostWorkout: false),
        signedInOverrides(),
      ));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await captureScreen(
          tester, screenshotCapture, 'session_rpe', testDeviceSizes);
    });

    testWidgets('Exercise Picker', (tester) async {
      await tester.pumpWidget(wrapWithProviders(
        const ExercisePickerScreen(),
        signedInOverrides(),
      ));
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await captureScreen(
          tester, screenshotCapture, 'exercise_picker', testDeviceSizes);
    });
  });

  group('Routines & Progress', () {
    testWidgets('Routines List', (tester) async {
      await tester.pumpWidget(wrapWithProviders(
        const RoutinesListScreen(),
        signedInOverrides(),
      ));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await captureScreen(
          tester, screenshotCapture, 'routines_list', testDeviceSizes);
    });

    testWidgets('Create Routine', (tester) async {
      await tester.pumpWidget(wrapWithProviders(
        const CreateRoutineScreen(),
        signedInOverrides(),
      ));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await captureScreen(
          tester, screenshotCapture, 'create_routine', testDeviceSizes);
    });

    testWidgets('Training Load', (tester) async {
      await tester.pumpWidget(wrapWithProviders(
        const TrainingLoadScreen(),
        signedInOverrides(),
      ));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await captureScreen(
          tester, screenshotCapture, 'training_load', testDeviceSizes);
    });
  });
}
