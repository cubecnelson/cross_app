class Routine {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final List<RoutineExercise> exercises;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Routine({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.exercises = const [],
    required this.createdAt,
    this.updatedAt,
  });

  factory Routine.fromJson(Map<String, dynamic> json) {
    return Routine(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      exercises: json['exercises'] != null
          ? (json['exercises'] as List)
              .map((exerciseJson) => RoutineExercise.fromJson(exerciseJson))
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
      'name': name,
      'description': description,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Routine copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    List<RoutineExercise>? exercises,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Routine(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      exercises: exercises ?? this.exercises,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class RoutineExercise {
  final String exerciseId;
  final String exerciseName;
  final int sets;
  final int reps;
  final double? weight;
  final int? restTime;
  final int order;
  final String? notes;

  RoutineExercise({
    required this.exerciseId,
    required this.exerciseName,
    required this.sets,
    required this.reps,
    this.weight,
    this.restTime,
    required this.order,
    this.notes,
  });

  factory RoutineExercise.fromJson(Map<String, dynamic> json) {
    return RoutineExercise(
      exerciseId: json['exercise_id'] as String,
      exerciseName: json['exercise_name'] as String,
      sets: json['sets'] as int,
      reps: json['reps'] as int,
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      restTime: json['rest_time'] as int?,
      order: json['order'] as int,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exercise_id': exerciseId,
      'exercise_name': exerciseName,
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'rest_time': restTime,
      'order': order,
      'notes': notes,
    };
  }

  RoutineExercise copyWith({
    String? exerciseId,
    String? exerciseName,
    int? sets,
    int? reps,
    double? weight,
    int? restTime,
    int? order,
    String? notes,
  }) {
    return RoutineExercise(
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      restTime: restTime ?? this.restTime,
      order: order ?? this.order,
      notes: notes ?? this.notes,
    );
  }
}

