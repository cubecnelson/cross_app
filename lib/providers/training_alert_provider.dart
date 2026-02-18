import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/workout.dart';
import '../services/training_alert_service.dart';

final trainingAlertServiceProvider = Provider<TrainingAlertService>((ref) {
  return TrainingAlertService();
});

// Settings providers
final acwrAlertsEnabledProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(trainingAlertServiceProvider);
  return await service.getAcwrAlertsEnabled();
});

final weeklySummaryEnabledProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(trainingAlertServiceProvider);
  return await service.getWeeklySummaryEnabled();
});

final achievementAlertsEnabledProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(trainingAlertServiceProvider);
  return await service.getAchievementAlertsEnabled();
});

final underTrainingAlertsEnabledProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(trainingAlertServiceProvider);
  return await service.getUnderTrainingAlertsEnabled();
});

final overTrainingAlertsEnabledProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(trainingAlertServiceProvider);
  return await service.getOverTrainingAlertsEnabled();
});

// Notification state
class NotificationState {
  final bool hasPendingNotifications;
  final DateTime? lastDailyCheck;
  final DateTime? lastWeeklySummary;
  final int unreadAchievements;

  const NotificationState({
    required this.hasPendingNotifications,
    this.lastDailyCheck,
    this.lastWeeklySummary,
    required this.unreadAchievements,
  });

  NotificationState copyWith({
    bool? hasPendingNotifications,
    DateTime? lastDailyCheck,
    DateTime? lastWeeklySummary,
    int? unreadAchievements,
  }) {
    return NotificationState(
      hasPendingNotifications: hasPendingNotifications ?? this.hasPendingNotifications,
      lastDailyCheck: lastDailyCheck ?? this.lastDailyCheck,
      lastWeeklySummary: lastWeeklySummary ?? this.lastWeeklySummary,
      unreadAchievements: unreadAchievements ?? this.unreadAchievements,
    );
  }
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  final TrainingAlertService _service;
  final Ref _ref;

  NotificationNotifier(this._service, this._ref)
      : super(const NotificationState(
          hasPendingNotifications: false,
          unreadAchievements: 0,
        ));

  // Check if daily check should run (once per day)
  bool shouldRunDailyCheck() {
    final lastCheck = state.lastDailyCheck;
    if (lastCheck == null) return true;
    
    final now = DateTime.now();
    return now.difference(lastCheck).inHours >= 24;
  }

  // Check if weekly summary should run (once per week on Sunday)
  bool shouldRunWeeklySummary() {
    final lastSummary = state.lastWeeklySummary;
    if (lastSummary == null) return true;
    
    final now = DateTime.now();
    return now.difference(lastSummary).inDays >= 7 && now.weekday == DateTime.sunday;
  }

  // Run daily check
  Future<void> runDailyCheck(List<Workout> workouts) async {
    if (!shouldRunDailyCheck()) return;
    
    await _service.performDailyCheck(workouts);
    
    state = state.copyWith(
      lastDailyCheck: DateTime.now(),
    );
  }

  // Run ACWR check immediately
  Future<void> checkACWRNow(double acwr, double acuteLoad, double chronicLoad) async {
    await _service.checkAndNotifyACWR(acwr, acuteLoad, chronicLoad);
  }

  // Send weekly summary immediately
  Future<void> sendWeeklySummaryNow(
    double totalAU,
    double averageAU,
    int workoutCount,
    double acwr,
    String trainingStatus,
  ) async {
    await _service.sendWeeklySummary(
      totalAU,
      averageAU,
      workoutCount,
      acwr,
      trainingStatus,
    );
    
    state = state.copyWith(
      lastWeeklySummary: DateTime.now(),
    );
  }

  // Check achievements now
  Future<void> checkAchievementsNow(List<Workout> workouts) async {
    await _service.checkAndNotifyAchievements(workouts);
  }

  // Clear all notifications
  Future<void> clearAllNotifications() async {
    await _service.clearAllNotifications();
    state = state.copyWith(
      hasPendingNotifications: false,
      unreadAchievements: 0,
    );
  }

  // Request permissions
  Future<bool> requestPermissions() async {
    return await _service.requestPermissions();
  }

  // Update settings
  Future<void> updateAcwrAlertsEnabled(bool enabled) async {
    await _service.setAcwrAlertsEnabled(enabled);
  }

  Future<void> updateWeeklySummaryEnabled(bool enabled) async {
    await _service.setWeeklySummaryEnabled(enabled);
  }

  Future<void> updateAchievementAlertsEnabled(bool enabled) async {
    await _service.setAchievementAlertsEnabled(enabled);
  }

  Future<void> updateUnderTrainingAlertsEnabled(bool enabled) async {
    await _service.setUnderTrainingAlertsEnabled(enabled);
  }

  Future<void> updateOverTrainingAlertsEnabled(bool enabled) async {
    await _service.setOverTrainingAlertsEnabled(enabled);
  }

  // Mark achievement as read
  void markAchievementRead() {
    if (state.unreadAchievements > 0) {
      state = state.copyWith(
        unreadAchievements: state.unreadAchievements - 1,
      );
    }
  }

  // Set has pending notifications
  void setHasPendingNotifications(bool hasPending) {
    state = state.copyWith(
      hasPendingNotifications: hasPending,
    );
  }
}

final notificationNotifierProvider = StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  final service = ref.watch(trainingAlertServiceProvider);
  return NotificationNotifier(service, ref);
});