import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:cross/models/workout.dart';
import 'package:cross/models/routine.dart';
import 'package:cross/models/user_profile.dart';
import 'package:cross/providers/auth_provider.dart';
import 'package:cross/providers/workout_provider.dart';
import 'package:cross/providers/routine_provider.dart';
import 'package:cross/providers/theme_provider.dart';
import 'package:cross/providers/shorebird_provider.dart';
import 'package:cross/providers/exercise_provider.dart';
import 'package:cross/providers/export_provider.dart';
import 'package:cross/providers/health_provider.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

/// Mock session for screenshot tests (signed-in state)
Session get mockSession => Session.fromJson({
  'access_token': 'mock_access_token',
  'refresh_token': 'mock_refresh_token',
  'expires_at': (DateTime.now().add(const Duration(days: 1)).millisecondsSinceEpoch / 1000).round(),
  'expires_in': 86400,
  'token_type': 'bearer',
  'user': {
    'id': 'test_user_123',
    'email': 'test@example.com',
    'app_metadata': {},
    'user_metadata': {},
    'aud': 'authenticated',
    'created_at': DateTime.now().toIso8601String(),
  },
})!;

/// Mock user profile for screenshot tests
UserProfile get mockUserProfile => UserProfile(
  id: 'test_user_123',
  email: 'test@example.com',
  name: 'Test User',
  createdAt: DateTime.now(),
);

/// Mock workout for screenshot tests
Workout get mockWorkout => Workout(
  id: 'workout_1',
  userId: 'test_user_123',
  date: DateTime.now(),
  routineName: 'Sample Workout',
  duration: const Duration(minutes: 45),
  createdAt: DateTime.now(),
);

class MockThemeNotifier extends ThemeNotifier {
  MockThemeNotifier(ThemeMode initialMode) : super() {
    state = initialMode;
  }
}

/// Base provider overrides for signed-in screenshot tests
List<Override> signedInOverrides() => [
  authStateProvider.overrideWith(
      (ref) => Stream.value(AuthState(AuthChangeEvent.signedIn, mockSession))),
  themeProvider.overrideWith((ref) => MockThemeNotifier(ThemeMode.light)),
  shorebirdCodePushProvider.overrideWithValue(ShorebirdUpdater()),
  userProfileProvider.overrideWith((ref) => Future.value(mockUserProfile)),
  workoutsProvider.overrideWith((ref) => Future.value([])),
  routinesProvider.overrideWith((ref) => Future.value([])),
  exercisesProvider.overrideWith((ref) => Future.value([])),
  exportStatsProvider.overrideWith((ref) => Future.value(<String, dynamic>{})),
  healthAvailabilityProvider.overrideWith((ref) => Future.value(false)),
  healthSummaryProvider.overrideWith((ref) => Future.value(null)),
];

/// Base provider overrides for signed-out screenshot tests
List<Override> signedOutOverrides() => [
  authStateProvider.overrideWith((ref) => Stream.value(AuthState(AuthChangeEvent.signedOut, null))),
  themeProvider.overrideWith((ref) => MockThemeNotifier(ThemeMode.light)),
  shorebirdCodePushProvider.overrideWithValue(ShorebirdUpdater()),
];
