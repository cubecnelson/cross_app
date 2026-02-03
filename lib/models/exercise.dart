enum ExerciseType {
  strength,
  cardio,
  isometric;

  String get name {
    switch (this) {
      case ExerciseType.strength:
        return 'strength';
      case ExerciseType.cardio:
        return 'cardio';
      case ExerciseType.isometric:
        return 'isometric';
    }
  }

  String get displayName {
    switch (this) {
      case ExerciseType.strength:
        return 'Strength';
      case ExerciseType.cardio:
        return 'Cardio';
      case ExerciseType.isometric:
        return 'Isometric';
    }
  }
}

class Exercise {
  final String id;
  final String name;
  final String category;
  final ExerciseType exerciseType;
  final String? description;
  final List<String> targetMuscles;
  final String? videoUrl;
  final String? tutorialUrl;
  final String? userId; // null for predefined exercises
  final bool isPredefined;
  final DateTime createdAt;

  Exercise({
    required this.id,
    required this.name,
    required this.category,
    this.exerciseType = ExerciseType.strength,
    this.description,
    this.targetMuscles = const [],
    this.videoUrl,
    this.tutorialUrl,
    this.userId,
    this.isPredefined = false,
    required this.createdAt,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      exerciseType: json['exercise_type'] != null
          ? ExerciseType.values.firstWhere(
              (e) => e.name == json['exercise_type'],
              orElse: () => ExerciseType.strength,
            )
          : ExerciseType.strength,
      description: json['description'] as String?,
      targetMuscles: json['target_muscles'] != null
          ? List<String>.from(json['target_muscles'] as List)
          : [],
      videoUrl: json['video_url'] as String?,
      tutorialUrl: json['tutorial_url'] as String?,
      userId: json['user_id'] as String?,
      isPredefined: json['is_predefined'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'exercise_type': exerciseType.name,
      'description': description,
      'target_muscles': targetMuscles,
      'video_url': videoUrl,
      'tutorial_url': tutorialUrl,
      'user_id': userId,
      'is_predefined': isPredefined,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Exercise copyWith({
    String? id,
    String? name,
    String? category,
    ExerciseType? exerciseType,
    String? description,
    List<String>? targetMuscles,
    String? videoUrl,
    String? tutorialUrl,
    String? userId,
    bool? isPredefined,
    DateTime? createdAt,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      exerciseType: exerciseType ?? this.exerciseType,
      description: description ?? this.description,
      targetMuscles: targetMuscles ?? this.targetMuscles,
      videoUrl: videoUrl ?? this.videoUrl,
      tutorialUrl: tutorialUrl ?? this.tutorialUrl,
      userId: userId ?? this.userId,
      isPredefined: isPredefined ?? this.isPredefined,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isStrength => exerciseType == ExerciseType.strength;
  bool get isCardio => exerciseType == ExerciseType.cardio;
  bool get isIsometric => exerciseType == ExerciseType.isometric;
}
