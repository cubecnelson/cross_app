import 'package:uuid/uuid.dart';

class PersonalRecord {
  final String id;
  final String userId;
  final String exerciseId;
  final String exerciseName;
  final double weight;
  final int reps;
  final double? estimatedOneRepMax; // Calculated 1RM
  final double? velocity; // For future VBT integration
  final String? videoPath; // For future VBT integration
  final DateTime date;
  final String workoutId;
  final String workoutSetId;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PersonalRecord({
    String? id,
    required this.userId,
    required this.exerciseId,
    required this.exerciseName,
    required this.weight,
    required this.reps,
    this.estimatedOneRepMax,
    this.velocity,
    this.videoPath,
    required this.date,
    required this.workoutId,
    required this.workoutSetId,
    this.notes,
    DateTime? createdAt,
    this.updatedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  factory PersonalRecord.fromJson(Map<String, dynamic> json) {
    return PersonalRecord(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      exerciseId: json['exercise_id'] as String,
      exerciseName: json['exercise_name'] as String,
      weight: (json['weight'] as num).toDouble(),
      reps: json['reps'] as int,
      estimatedOneRepMax: json['estimated_one_rep_max'] != null
          ? (json['estimated_one_rep_max'] as num).toDouble()
          : null,
      velocity: json['velocity'] != null
          ? (json['velocity'] as num).toDouble()
          : null,
      videoPath: json['video_path'] as String?,
      date: DateTime.parse(json['date'] as String),
      workoutId: json['workout_id'] as String,
      workoutSetId: json['workout_set_id'] as String,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'exercise_id': exerciseId,
      'exercise_name': exerciseName,
      'weight': weight,
      'reps': reps,
      'estimated_one_rep_max': estimatedOneRepMax,
      'velocity': velocity,
      'video_path': videoPath,
      'date': date.toIso8601String(),
      'workout_id': workoutId,
      'workout_set_id': workoutSetId,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  PersonalRecord copyWith({
    String? id,
    String? userId,
    String? exerciseId,
    String? exerciseName,
    double? weight,
    int? reps,
    double? estimatedOneRepMax,
    double? velocity,
    String? videoPath,
    DateTime? date,
    String? workoutId,
    String? workoutSetId,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PersonalRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      estimatedOneRepMax: estimatedOneRepMax ?? this.estimatedOneRepMax,
      velocity: velocity ?? this.velocity,
      videoPath: videoPath ?? this.videoPath,
      date: date ?? this.date,
      workoutId: workoutId ?? this.workoutId,
      workoutSetId: workoutSetId ?? this.workoutSetId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if this PR is a new record compared to another PR
  /// Returns true if this PR is better (heavier weight or same weight with more reps)
  bool isBetterThan(PersonalRecord other) {
    if (weight > other.weight) return true;
    if (weight == other.weight && reps > other.reps) return true;
    return false;
  }

  /// Get display text for the PR
  String get displayText {
    if (reps == 1) {
      return '${weight.toStringAsFixed(1)} kg 1RM';
    } else {
      return '${weight.toStringAsFixed(1)} kg × $reps reps';
    }
  }

  /// Get PR type
  String get type {
    if (reps == 1) return '1RM';
    if (reps <= 3) return 'Heavy Triple';
    if (reps <= 5) return '5RM';
    if (reps <= 8) return '8RM';
    if (reps <= 12) return '12RM';
    return 'Volume PR';
  }

  /// Calculate estimated 1RM using Epley formula if not already set
  double get calculatedOneRepMax {
    if (estimatedOneRepMax != null) return estimatedOneRepMax!;
    if (reps == 1) return weight;
    return weight * (1 + reps / 30);
  }
}