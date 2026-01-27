class WorkoutSet {
  final String id;
  final String workoutId;
  final String exerciseId;
  final String exerciseName;
  final int setNumber;

  // Strength training attributes
  final int? reps;
  final double? weight;
  final int? restTime; // in seconds

  // Cardio attributes (like Strava)
  final double? distance; // in kilometers or miles
  final int? duration; // in seconds (also used for isometric hold time)
  final double? pace; // min per km or min per mile
  final int? heartRate; // average heart rate (bpm)
  final int? calories; // calories burned
  final double? elevationGain; // in meters or feet

  // Note: Isometric exercises use 'duration' field for hold time

  // Common attributes
  final int? rpe; // Rate of Perceived Exertion (1-10)
  final String? notes;
  final bool isCompleted;
  final DateTime createdAt;

  WorkoutSet({
    required this.id,
    required this.workoutId,
    required this.exerciseId,
    required this.exerciseName,
    required this.setNumber,
    // Strength
    this.reps,
    this.weight,
    this.restTime,
    // Cardio
    this.distance,
    this.duration,
    this.pace,
    this.heartRate,
    this.calories,
    this.elevationGain,
    // Common
    this.rpe,
    this.notes,
    this.isCompleted = false,
    required this.createdAt,
  });

  factory WorkoutSet.fromJson(Map<String, dynamic> json) {
    return WorkoutSet(
      id: json['id'] as String,
      workoutId: json['workout_id'] as String,
      exerciseId: json['exercise_id'] as String,
      exerciseName: json['exercise_name'] as String,
      setNumber: json['set_number'] as int,
      // Strength
      reps: json['reps'] as int?,
      weight:
          json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      restTime: json['rest_time'] as int?,
      // Cardio
      distance: json['distance'] != null
          ? (json['distance'] as num).toDouble()
          : null,
      duration: json['duration'] as int?,
      pace: json['pace'] != null ? (json['pace'] as num).toDouble() : null,
      heartRate: json['heart_rate'] as int?,
      calories: json['calories'] as int?,
      elevationGain: json['elevation_gain'] != null
          ? (json['elevation_gain'] as num).toDouble()
          : null,
      // Common
      rpe: json['rpe'] as int?,
      notes: json['notes'] as String?,
      isCompleted: json['is_completed'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workout_id': workoutId,
      'exercise_id': exerciseId,
      'exercise_name': exerciseName,
      'set_number': setNumber,
      // Strength
      'reps': reps,
      'weight': weight,
      'rest_time': restTime,
      // Cardio
      'distance': distance,
      'duration': duration,
      'pace': pace,
      'heart_rate': heartRate,
      'calories': calories,
      'elevation_gain': elevationGain,
      // Common
      'rpe': rpe,
      'notes': notes,
      'is_completed': isCompleted,
      'created_at': createdAt.toIso8601String(),
    };
  }

  WorkoutSet copyWith({
    String? id,
    String? workoutId,
    String? exerciseId,
    String? exerciseName,
    int? setNumber,
    // Strength
    int? reps,
    double? weight,
    int? restTime,
    // Cardio
    double? distance,
    int? duration,
    double? pace,
    int? heartRate,
    int? calories,
    double? elevationGain,
    // Common
    int? rpe,
    String? notes,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return WorkoutSet(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      setNumber: setNumber ?? this.setNumber,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      restTime: restTime ?? this.restTime,
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
      pace: pace ?? this.pace,
      heartRate: heartRate ?? this.heartRate,
      calories: calories ?? this.calories,
      elevationGain: elevationGain ?? this.elevationGain,
      rpe: rpe ?? this.rpe,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Strength training metrics
  double? get volume =>
      (weight != null && reps != null) ? weight! * reps! : null;

  // Estimate one-rep max using Epley formula (for strength)
  double? get estimatedOneRepMax {
    if (weight == null || reps == null) return null;
    if (reps == 1) return weight;
    return weight! * (1 + reps! / 30);
  }

  // Cardio metrics
  double? get averagePace {
    if (distance != null && duration != null && distance! > 0) {
      // Returns min/km or min/mile
      return (duration! / 60) / distance!;
    }
    return pace;
  }

  double? get speed {
    if (distance != null && duration != null && duration! > 0) {
      // Returns km/h or mph
      return (distance! / duration!) * 3600;
    }
    return null;
  }

  bool get isStrength => weight != null || reps != null;
  bool get isCardio => distance != null;
  bool get isIsometric =>
      duration != null && distance == null && weight == null;

  // Hold time for isometric exercises (same as duration)
  int? get holdTime => duration;
}
