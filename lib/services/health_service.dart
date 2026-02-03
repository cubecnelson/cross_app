import 'dart:async';
import 'package:health/health.dart';

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
      // Note: health package handles both iOS HealthKit and Android Google Fit
      // We'll use health package for both platforms
      _isInitialized = await _initializeHealthPackage();
      
      if (_isInitialized) {
        // Determine which platform we're on
        // For now, we'll assume iOS if we get Apple Health data
        _platform = HealthPlatform.appleHealth; // Default assumption
      }

      return _isInitialized;
    } catch (e) {
      print('Health initialization failed: $e');
      return false;
    }
  }

  Future<bool> _initializeHealthPackage() async {
    try {
      // Request permissions for health data types
      final hasPermissions = await Health.requestAuthorization(_healthDataTypes);
      return hasPermissions;
    } catch (e) {
      print('Health package initialization failed: $e');
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
      return await _getHealthSummary(startOfDay, endOfDay);
    } catch (e) {
      print('Failed to get health summary: $e');
      return null;
    }
  }

  Future<HealthData?> _getHealthSummary(
      DateTime start, DateTime end) async {
    try {
      // Get steps
      final stepsData = await Health.getHealthDataFromTypes(start, end, [HealthDataType.STEPS]);
      double? steps = stepsData.isNotEmpty ? stepsData.last.value : null;

      // Get calories
      final caloriesData = await Health.getHealthDataFromTypes(start, end, [HealthDataType.ACTIVE_ENERGY_BURNED]);
      double? calories = caloriesData.isNotEmpty ? caloriesData.last.value : null;

      // Get distance
      final distanceData = await Health.getHealthDataFromTypes(start, end, [HealthDataType.DISTANCE_WALKING_RUNNING]);
      double? distance = distanceData.isNotEmpty ? distanceData.last.value : null;

      // Get heart rate (average)
      final heartRateData = await Health.getHealthDataFromTypes(start, end, [HealthDataType.HEART_RATE]);
      double? heartRate = heartRateData.isNotEmpty 
          ? heartRateData.map((d) => d.value).reduce((a, b) => a + b) / heartRateData.length
          : null;

      // Get workouts for active minutes
      final workoutData = await Health.getHealthDataFromTypes(start, end, [HealthDataType.WORKOUT]);
      Duration? activeMinutes;
      if (workoutData.isNotEmpty) {
        double totalMinutes = 0;
        for (final workout in workoutData) {
          if (workout.value != null) {
            totalMinutes += workout.value!;
          }
        }
        activeMinutes = Duration(minutes: totalMinutes.toInt());
      }

      return HealthData(
        date: start,
        steps: steps,
        calories: calories,
        distance: distance,
        heartRate: heartRate,
        activeMinutes: activeMinutes,
      );
    } catch (e) {
      print('Health summary failed: $e');
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
        dayData = await _getHealthSummary(startOfDay, endOfDay);
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

      // Use health package to write workout data
      final workoutData = HealthDataPoint(
        type: HealthDataType.WORKOUT,
        value: duration.inMinutes.toDouble(),
        dateFrom: startTime,
        dateTo: endTime,
        unit: HealthDataUnit.MINUTES,
        deviceId: "Cross App",
        sourceId: "cross_app",
        platform: "iOS", // or "Android" based on platform
      );

      // Write workout data
      final success = await Health.writeHealthData(workoutData);
      if (!success) {
        print('Failed to write workout data');
      }
    } catch (e) {
      print('Failed to sync workout to health: $e');
    }
  }

  String _getWorkoutType(String workoutType) {
    // Map Cross workout types to health workout types
    switch (workoutType.toLowerCase()) {
      case 'strength training':
      case 'weight training':
        return 'Traditional Strength Training';
      case 'cardio':
      case 'running':
        return 'Running';
      case 'cycling':
        return 'Cycling';
      case 'swimming':
        return 'Swimming';
      case 'walking':
        return 'Walking';
      default:
        return 'Other';
    }
  }

  HealthPlatform get platform => _platform;
  bool get isAvailable => _platform != HealthPlatform.none;
  bool get isInitialized => _isInitialized;
}