import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';
import '../models/workout.dart';
import './training_load_service.dart';

class TrainingAlertService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _acwrAlertKey = 'acwr_alerts_enabled';
  static const String _weeklySummaryKey = 'weekly_summary_enabled';
  static const String _achievementAlertKey = 'achievement_alerts_enabled';
  static const String _underTrainingAlertKey = 'under_training_alerts_enabled';
  static const String _overTrainingAlertKey = 'over_training_alerts_enabled';

  TrainingAlertService() {
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );
    
    await _notificationsPlugin.initialize(initializationSettings);
  }

  // Settings management
  Future<bool> getAcwrAlertsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_acwrAlertKey) ?? true; // Enabled by default
  }

  Future<void> setAcwrAlertsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_acwrAlertKey, enabled);
  }

  Future<bool> getWeeklySummaryEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_weeklySummaryKey) ?? true;
  }

  Future<void> setWeeklySummaryEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_weeklySummaryKey, enabled);
  }

  Future<bool> getAchievementAlertsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_achievementAlertKey) ?? true;
  }

  Future<void> setAchievementAlertsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_achievementAlertKey, enabled);
  }

  Future<bool> getUnderTrainingAlertsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_underTrainingAlertKey) ?? true;
  }

  Future<void> setUnderTrainingAlertsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_underTrainingAlertKey, enabled);
  }

  Future<bool> getOverTrainingAlertsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_overTrainingAlertKey) ?? true;
  }

  Future<void> setOverTrainingAlertsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_overTrainingAlertKey, enabled);
  }

  // ACWR Alert Logic
  Future<void> checkAndNotifyACWR(double acwr, double acuteLoad, double chronicLoad) async {
    if (!await getAcwrAlertsEnabled()) return;

    String title = '';
    String body = '';
    Color color = Colors.green;

    if (acwr > 1.5) {
      title = '⚠️ Overtraining Alert';
      body = 'Your ACWR is ${acwr.toStringAsFixed(2)} (>1.5). Consider reducing training load to prevent injury.';
      color = Colors.red;
      if (await getOverTrainingAlertsEnabled()) {
        await _showNotification(title, body, color: color);
      }
    } else if (acwr > 1.3) {
      title = '📈 High Training Load';
      body = 'Your ACWR is ${acwr.toStringAsFixed(2)} (1.3-1.5). Monitor fatigue and consider a lighter day soon.';
      color = Colors.orange;
      if (await getOverTrainingAlertsEnabled()) {
        await _showNotification(title, body, color: color);
      }
    } else if (acwr < 0.8) {
      title = '📉 Undertraining Alert';
      body = 'Your ACWR is ${acwr.toStringAsFixed(2)} (<0.8). Consider adding some light activity to maintain fitness.';
      color = Colors.blue;
      if (await getUnderTrainingAlertsEnabled()) {
        await _showNotification(title, body, color: color);
      }
    } else {
      // Sweet spot - no alert needed
      return;
    }
  }

  // Weekly Summary
  Future<void> sendWeeklySummary(
    double totalAU,
    double averageAU,
    int workoutCount,
    double acwr,
    String trainingStatus,
  ) async {
    if (!await getWeeklySummaryEnabled()) return;

    final now = DateTime.now();
    final lastSunday = _getLastSunday(now);
    
    final title = '📊 Weekly Training Summary';
    final body = '''
Week ending ${lastSunday.day}/${lastSunday.month}:
• ${totalAU.toStringAsFixed(0)} total AU
• ${averageAU.toStringAsFixed(0)} avg daily AU
• $workoutCount workouts completed
• ACWR: ${acwr.toStringAsFixed(2)} ($trainingStatus)
''';

    await _showNotification(title, body, color: Colors.green);
  }

  // Achievement Alerts
  Future<void> checkAndNotifyAchievements(List<Workout> workouts) async {
    if (!await getAchievementAlertsEnabled()) return;

    final totalWorkouts = workouts.length;
    final totalAU = workouts.fold(0.0, (sum, workout) => sum + workout.au);
    
    // Check for milestones
    if (totalWorkouts >= 50 && totalWorkouts < 51) {
      await _showAchievement('🏋️‍♂️ 50 Workouts', 'You\'ve completed 50 workouts! Keep going!', Colors.orange);
    } else if (totalWorkouts >= 100 && totalWorkouts < 101) {
      await _showAchievement('💯 100 Workouts', 'Amazing! 100 workouts completed!', Colors.purple);
    }
    
    if (totalAU >= 10000 && totalAU < 10001) {
      await _showAchievement('🎯 10,000 AU', 'You\'ve accumulated 10,000 AU of training load!', Colors.green);
    } else if (totalAU >= 50000 && totalAU < 50001) {
      await _showAchievement('🏆 50,000 AU', 'Elite level: 50,000 AU total training!', Colors.blue);
    }

    // Check for streak
    final streak = _calculateWorkoutStreak(workouts);
    if (streak >= 7 && streak < 8) {
      await _showAchievement('🔥 7-Day Streak', 'You\'ve trained for 7 days straight!', Colors.red);
    } else if (streak >= 30 && streak < 31) {
      await _showAchievement('🌟 30-Day Streak', 'Incredible! 30-day training streak!', Colors.yellow);
    }
  }

  // Streak Calculation
  int _calculateWorkoutStreak(List<Workout> workouts) {
    if (workouts.isEmpty) return 0;
    
    // Sort by date descending
    workouts.sort((a, b) => b.date.compareTo(a.date));
    
    final today = DateTime.now();
    int streak = 0;
    DateTime currentDate = today;
    
    // Check if there's a workout today
    bool hasWorkoutToday = workouts.any((w) =>
      w.date.year == today.year &&
      w.date.month == today.month &&
      w.date.day == today.day);
    
    if (!hasWorkoutToday) {
      // Start from yesterday if no workout today
      currentDate = today.subtract(const Duration(days: 1));
    }
    
    // Count consecutive days with workouts
    while (true) {
      final hasWorkoutOnDate = workouts.any((w) =>
        w.date.year == currentDate.year &&
        w.date.month == currentDate.month &&
        w.date.day == currentDate.day);
      
      if (!hasWorkoutOnDate) break;
      
      streak++;
      currentDate = currentDate.subtract(const Duration(days: 1));
    }
    
    return streak;
  }

  // Daily Check
  Future<void> performDailyCheck(List<Workout> workouts) async {
    if (workouts.isEmpty) return;
    
    final today = DateTime.now();
    
    // Check ACWR
    final acuteLoad = TrainingLoadService.calculateAcuteLoad(workouts, today);
    final chronicLoad = TrainingLoadService.calculateChronicLoad(workouts, today);
    final acwr = TrainingLoadService.calculateACWR(acuteLoad, chronicLoad);
    
    await checkAndNotifyACWR(acwr, acuteLoad, chronicLoad);
    
    // Check achievements
    await checkAndNotifyAchievements(workouts);
    
    // Check if it's Sunday for weekly summary
    if (today.weekday == DateTime.sunday) {
      final weeklyTotals = TrainingLoadService.getWeeklyTotals(workouts, 1);
      final weeklyAU = weeklyTotals.values.firstOrNull ?? 0.0;
      final averageAU = weeklyAU / 7;
      final workoutCount = workouts.where((w) =>
        w.date.isAfter(today.subtract(const Duration(days: 7)))
      ).length;
      final trainingStatus = TrainingLoadService.determineTrainingStatus(acwr);
      
      await sendWeeklySummary(
        weeklyAU,
        averageAU,
        workoutCount,
        acwr,
        trainingStatus,
      );
    }
  }

  // Helper Methods
  DateTime _getLastSunday(DateTime date) {
    // Find the most recent Sunday
    final daysSinceSunday = date.weekday % 7; // 0 = Sunday, 1 = Monday, etc.
    return date.subtract(Duration(days: daysSinceSunday));
  }

  Future<void> _showNotification(String title, String body, {Color color = Colors.blue}) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'training_alerts_channel',
      'Training Alerts',
      channelDescription: 'Alerts for training load, achievements, and weekly summaries',
      importance: Importance.high,
      priority: Priority.high,
      color: Colors.orange,
      enableLights: true,
      enableVibration: true,
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notificationsPlugin.show(
      0, // Notification ID
      title,
      body,
      platformDetails,
    );
  }

  Future<void> _showAchievement(String title, String body, Color color) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'achievements_channel',
      'Achievements',
      channelDescription: 'Notifications for unlocked achievements and milestones',
      importance: Importance.max,
      priority: Priority.max,
      color: Colors.purple,
      enableLights: true,
      enableVibration: true,
      playSound: true,
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'achievement.aiff',
    );
    
    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notificationsPlugin.show(
      1, // Different ID for achievements
      title,
      body,
      platformDetails,
    );
  }

  // Clear all notifications
  Future<void> clearAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  // Request notification permissions
  Future<bool> requestPermissions() async {
    final bool? androidGranted = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    
    final bool? iosGranted = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    
    return (androidGranted ?? false) || (iosGranted ?? false);
  }
}