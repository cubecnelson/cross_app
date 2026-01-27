import 'workout_set.dart';

class Workout {
  final String id;
  final String userId;
  final DateTime date;
  final String? routineId;
  final String? routineName;
  final String? notes;
  final Duration? duration;
  final List<WorkoutSet> sets;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Workout({
    required this.id,
    required this.userId,
    required this.date,
    this.routineId,
    this.routineName,
    this.notes,
    this.duration,
    this.sets = const [],
    required this.createdAt,
    this.updatedAt,
  });

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      date: DateTime.parse(json['date'] as String),
      routineId: json['routine_id'] as String?,
      routineName: json['routine_name'] as String?,
      notes: json['notes'] as String?,
      duration: json['duration'] != null
          ? Duration(seconds: json['duration'] as int)
          : null,
      sets: json['sets'] != null
          ? (json['sets'] as List)
              .map((setJson) => WorkoutSet.fromJson(setJson))
              .toList()
          : [],
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
      'date': date.toIso8601String(),
      'routine_id': routineId,
      'routine_name': routineName,
      'notes': notes,
      'duration': duration?.inSeconds,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Workout copyWith({
    String? id,
    String? userId,
    DateTime? date,
    String? routineId,
    String? routineName,
    String? notes,
    Duration? duration,
    List<WorkoutSet>? sets,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Workout(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      routineId: routineId ?? this.routineId,
      routineName: routineName ?? this.routineName,
      notes: notes ?? this.notes,
      duration: duration ?? this.duration,
      sets: sets ?? this.sets,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  double get totalVolume {
    return sets.fold(
        0.0, (sum, set) => sum + ((set.weight ?? 0) * (set.reps ?? 0)));
  }

  int get totalSets => sets.length;

  int get totalReps {
    return sets.fold(0, (sum, set) => sum + (set.reps ?? 0));
  }
}
