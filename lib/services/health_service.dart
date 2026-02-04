import 'dart:async';

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

// Stub HealthFactory to avoid compilation errors
class HealthFactory {
  Future<bool> requestAuthorization(List<dynamic> types) async {
    return false;
  }

  Future<List<dynamic>> getHealthDataFromTypes(
      DateTime start, DateTime end, List<dynamic> types) async {
    return [];
  }

  Future<bool> writeHealthData(dynamic data) async {
    return false;
  }
}

class HealthService {
  final HealthPlatform _platform = HealthPlatform.none;
  bool _isInitialized = false;

  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Stub initialization - always fails
      _isInitialized = false;
      return _isInitialized;
    } catch (e) {
      return false;
    }
  }

  Future<HealthData?> getTodaySummary() async {
    // Return dummy data for compilation
    return HealthData(
      date: DateTime.now(),
      steps: 1000,
      calories: 200.0,
      distance: 5000.0,
      heartRate: 72.0,
      activeMinutes: Duration(minutes: 30),
    );
  }

  Future<List<HealthData>> getWeeklySummary() async {
    final List<HealthData> weeklyData = [];

    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      weeklyData.add(HealthData(
        date: date,
        steps: 1000 + i * 100,
        calories: 200.0 + i * 10,
        distance: 5000.0 + i * 500,
        heartRate: 72.0 + i.toDouble(),
        activeMinutes: Duration(minutes: 30 + i * 5),
      ));
    }

    return weeklyData;
  }

  Future<void> syncWorkoutToHealth(
      String workoutType, Duration duration, double calories) async {
    // Stub - do nothing
    await Future.delayed(Duration.zero);
  }

  HealthPlatform get platform => _platform;
  bool get isAvailable => _platform != HealthPlatform.none;
  bool get isInitialized => _isInitialized;
}