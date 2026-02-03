import 'dart:async';
import 'package:health/health.dart';
import 'package:healthkit/healthkit.dart';
// import 'package:google_fit/google_fit.dart';  // Package not available

enum HealthPlatform {
  appleHealth,
  googleFit,
  none,
}

class HealthData {
  final DateTime date;
  final double? steps;
  final double? calories;
  final double? distance; // in meters
  final double? heartRate;
  final Duration? activeMinutes;

  HealthData({
    required this.date,
    this.steps,
    this.calories,
    this.distance,
    this.heartRate,
    this.activeMinutes,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'steps': steps,
      'calories': calories,
      'distance': distance,
      'heart_rate': heartRate,
      'active_minutes': activeMinutes?.inMinutes,
    };
  }

  factory HealthData.fromJson(Map<String, dynamic> json) {
    return HealthData(
      date: DateTime.parse(json['date']),
      steps: json['steps']?.toDouble(),
      calories: json['calories']?.toDouble(),
      distance: json['distance']?.toDouble(),
      heartRate: json['heart_rate']?.toDouble(),
      activeMinutes: json['active_minutes'] != null
          ? Duration(minutes: json['active_minutes'] as int)
          : null,
    );
  }
}

class HealthService {
  HealthPlatform _platform = HealthPlatform.none;
  bool _isInitialized = false;

  // Health data types we want to access
  static final List<HealthDataType> _healthDataTypes = [
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.DISTANCE_WALKING_RUNNING,
    HealthDataType.HEART_RATE,
    HealthDataType.WORKOUT,
  ];

  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Try to detect platform
      if (await HealthKitFactory.isAvailable) {
        _platform = HealthPlatform.appleHealth;
        _isInitialized = await _initializeAppleHealth();
      } else if (await GoogleFitFactory.isAvailable) {
        _platform = HealthPlatform.googleFit;
        _isInitialized = await _initializeGoogleFit();
      }

      return _isInitialized;
    } catch (e) {
      print('Health initialization failed: $e');
      return false;
    }
  }

  Future<bool> _initializeAppleHealth() async {
    try {
      final healthKit = HealthKitFactory();
      final typesToRead = [
        HKQuantityTypeIdentifier.stepCount,
        HKQuantityTypeIdentifier.activeEnergyBurned,
        HKQuantityTypeIdentifier.distanceWalkingRunning,
        HKQuantityTypeIdentifier.heartRate,
        HKWorkoutTypeIdentifier,
      ];

      // Request authorization
      final authorized = await healthKit.requestAuthorization(
        typesToRead: typesToRead,
      );

      return authorized;
    } catch (e) {
      print('Apple Health initialization failed: $e');
      return false;
    }
  }

  Future<bool> _initializeGoogleFit() async {
    try {
      // Google Fit package is not available on pub.dev
      // We'll need to implement alternative approach or skip Google Fit
      return false;
    } catch (e) {
      print('Google Fit initialization failed: $e');
      return false;
    }
  }

  Future<HealthData?> getTodaySummary() async {
    if (!_isInitialized) {
      await initialize();
      if (!_isInitialized) return null;
    }

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    try {
      switch (_platform) {
        case HealthPlatform.appleHealth:
          return await _getAppleHealthSummary(startOfDay, endOfDay);
        case HealthPlatform.googleFit:
          return await _getGoogleFitSummary(startOfDay, endOfDay);
        case HealthPlatform.none:
          return null;
      }
    } catch (e) {
      print('Failed to get health summary: $e');
      return null;
    }
  }

  Future<HealthData?> _getAppleHealthSummary(
      DateTime start, DateTime end) async {
    try {
      final healthKit = HealthKitFactory();

      // Get steps
      final steps = await healthKit.getTotalSteps(start, end);

      // Get calories
      final calories = await healthKit.getTotalCalories(start, end);

      // Get distance
      final distance = await healthKit.getTotalDistance(start, end);

      // Get heart rate (average)
      final heartRate = await healthKit.getAverageHeartRate(start, end);

      // Get active minutes from workouts
      final activeMinutes = await _getAppleHealthActiveMinutes(start, end);

      return HealthData(
        date: start,
        steps: steps?.toDouble(),
        calories: calories?.toDouble(),
        distance: distance,
        heartRate: heartRate,
        activeMinutes: activeMinutes,
      );
    } catch (e) {
      print('Apple Health summary failed: $e');
      return null;
    }
  }

  Future<Duration?> _getAppleHealthActiveMinutes(
      DateTime start, DateTime end) async {
    try {
      final healthKit = HealthKitFactory();
      final workouts = await healthKit.getWorkouts(start, end);

      if (workouts.isEmpty) return null;

      Duration totalDuration = Duration.zero;
      for (final workout in workouts) {
        totalDuration += workout.duration;
      }

      return totalDuration;
    } catch (e) {
      print('Failed to get active minutes: $e');
      return null;
    }
  }

  Future<HealthData?> _getGoogleFitSummary(
      DateTime start, DateTime end) async {
    try {
      // Google Fit package is not available on pub.dev
      // We'll need to implement alternative approach or skip Google Fit
      return null;
    } catch (e) {
      print('Google Fit summary failed: $e');
      return null;
    }
  }

  Future<List<HealthData>> getWeeklySummary() async {
    final List<HealthData> weeklyData = [];

    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      HealthData? dayData;
      try {
        switch (_platform) {
          case HealthPlatform.appleHealth:
            dayData = await _getAppleHealthSummary(startOfDay, endOfDay);
            break;
          case HealthPlatform.googleFit:
            dayData = await _getGoogleFitSummary(startOfDay, endOfDay);
            break;
          case HealthPlatform.none:
            continue;
        }
      } catch (e) {
        print('Failed to get day $i data: $e');
      }

      if (dayData != null) {
        weeklyData.add(dayData);
      }
    }

    return weeklyData;
  }

  Future<void> syncWorkoutToHealth(
      String workoutType, Duration duration, double calories) async {
    if (!_isInitialized) {
      await initialize();
      if (!_isInitialized) return;
    }

    try {
      final now = DateTime.now();
      final startTime = now.subtract(duration);
      final endTime = now;

      switch (_platform) {
        case HealthPlatform.appleHealth:
          await _syncWorkoutToAppleHealth(
              workoutType, startTime, endTime, calories);
          break;
        case HealthPlatform.googleFit:
          await _syncWorkoutToGoogleFit(
              workoutType, startTime, endTime, calories);
          break;
        case HealthPlatform.none:
          break;
      }
    } catch (e) {
      print('Failed to sync workout to health: $e');
    }
  }

  Future<void> _syncWorkoutToAppleHealth(
      String workoutType,
      DateTime startTime,
      DateTime endTime,
      double calories) async {
    try {
      final healthKit = HealthKitFactory();
      final workoutTypeId = _getAppleHealthWorkoutType(workoutType);

      await healthKit.saveWorkout(
        workoutTypeId: workoutTypeId,
        start: startTime,
        end: endTime,
        calories: calories,
      );
    } catch (e) {
      print('Failed to sync to Apple Health: $e');
    }
  }

  Future<void> _syncWorkoutToGoogleFit(
      String workoutType,
      DateTime startTime,
      DateTime endTime,
      double calories) async {
    try {
      // Google Fit package is not available on pub.dev
      // We'll need to implement alternative approach or skip Google Fit
      print('Google Fit sync not implemented - package unavailable');
    } catch (e) {
      print('Failed to sync to Google Fit: $e');
    }
  }

  String _getAppleHealthWorkoutType(String workoutType) {
    // Map Cross workout types to Apple Health workout types
    switch (workoutType.toLowerCase()) {
      case 'strength training':
      case 'weight training':
        return HKWorkoutTypeIdentifier.traditionalStrengthTraining;
      case 'cardio':
      case 'running':
        return HKWorkoutTypeIdentifier.running;
      case 'cycling':
        return HKWorkoutTypeIdentifier.cycling;
      case 'swimming':
        return HKWorkoutTypeIdentifier.swimming;
      case 'walking':
        return HKWorkoutTypeIdentifier.walking;
      default:
        return HKWorkoutTypeIdentifier.other;
    }
  }

  HealthPlatform get platform => _platform;
  bool get isAvailable => _platform != HealthPlatform.none;
  bool get isInitialized => _isInitialized;
}