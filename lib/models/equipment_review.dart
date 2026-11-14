class EquipmentReview {
  final String id;
  final String equipmentId;
  final String authorId;
  final String authorUsername;
  final int condition;
  final String availability;
  final String? comment;
  final DateTime? lastSeenWorking;
  final bool isSample;
  final DateTime createdAt;

  const EquipmentReview({
    required this.id,
    required this.equipmentId,
    required this.authorId,
    required this.authorUsername,
    required this.condition,
    required this.availability,
    this.comment,
    this.lastSeenWorking,
    this.isSample = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'equipmentId': equipmentId,
        'authorId': authorId,
        'authorUsername': authorUsername,
        'condition': condition,
        'availability': availability,
        'comment': comment,
        'lastSeenWorking': lastSeenWorking?.toIso8601String(),
        'isSample': isSample,
        'createdAt': createdAt.toIso8601String(),
      };

  factory EquipmentReview.fromMap(Map<dynamic, dynamic> map) => EquipmentReview(
        id: map['id'] as String,
        equipmentId: map['equipmentId'] as String,
        authorId: map['authorId'] as String,
        authorUsername: map['authorUsername'] as String? ?? 'unknown',
        condition: map['condition'] as int,
        availability: map['availability'] as String,
        comment: map['comment'] as String?,
        lastSeenWorking: map['lastSeenWorking'] == null
            ? null
            : DateTime.parse(map['lastSeenWorking'] as String),
        isSample: map['isSample'] as bool? ?? false,
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
}

class ReviewWithMeta {
  final EquipmentReview review;
  final int upvoteCount;
  final bool votedByMe;
  final String equipmentName;
  final String equipmentId;
  final String gymId;
  final String gymName;
  final String gymDistrict;

  const ReviewWithMeta({
    required this.review,
    required this.upvoteCount,
    required this.votedByMe,
    required this.equipmentName,
    required this.equipmentId,
    required this.gymId,
    required this.gymName,
    required this.gymDistrict,
  });
}
