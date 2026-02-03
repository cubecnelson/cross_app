import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/health_service.dart';
import './auth_provider.dart';

final healthServiceProvider = Provider<HealthService>((ref) {
  return HealthService();
});

final healthAvailabilityProvider = FutureProvider<bool>((ref) async {
  final healthService = ref.read(healthServiceProvider);
  return await healthService.initialize();
});

final healthSummaryProvider = FutureProvider<HealthData?>((ref) async {
  final healthService = ref.read(healthServiceProvider);
  final isAvailable = await ref.read(healthAvailabilityProvider.future);

  if (!isAvailable) return null;

  return await healthService.getTodaySummary();
});

final healthWeeklyProvider = FutureProvider<List<HealthData>>((ref) async {
  final healthService = ref.read(healthServiceProvider);
  final isAvailable = await ref.read(healthAvailabilityProvider.future);

  if (!isAvailable) return [];

  return await healthService.getWeeklySummary();
});

final healthWorkoutSyncProvider =
    StateNotifierProvider<HealthWorkoutSyncNotifier, AsyncValue<void>>((ref) {
  final healthService = ref.read(healthServiceProvider);
  return HealthWorkoutSyncNotifier(healthService);
});

class HealthWorkoutSyncNotifier extends StateNotifier<AsyncValue<void>> {
  final HealthService _healthService;

  HealthWorkoutSyncNotifier(this._healthService) : super(const AsyncValue.data(null));

  Future<void> syncWorkout(
      String workoutType, Duration duration, double calories) async {
    state = const AsyncValue.loading();

    try {
      await _healthService.syncWorkoutToHealth(workoutType, duration, calories);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final healthPermissionsProvider = Provider<HealthPermissions>((ref) {
  return HealthPermissions(ref);
});

class HealthPermissions {
  final Ref _ref;

  HealthPermissions(this._ref);

  Future<bool> requestPermissions() async {
    final healthService = _ref.read(healthServiceProvider);
    return await healthService.initialize();
  }

  Future<void> disconnect() async {
    // Note: Health platforms don't have a standard "disconnect" API
    // This would need to be implemented per platform if needed
  }

  String get platformName {
    final healthService = _ref.read(healthServiceProvider);
    switch (healthService.platform) {
      case HealthPlatform.appleHealth:
        return 'Apple Health';
      case HealthPlatform.googleFit:
        return 'Google Fit';
      case HealthPlatform.none:
        return 'Not Available';
    }
  }

  bool get isAvailable {
    final healthService = _ref.read(healthServiceProvider);
    return healthService.isAvailable;
  }

  bool get isInitialized {
    final healthService = _ref.read(healthServiceProvider);
    return healthService.isInitialized;
  }
}