class EquipmentItem {
  final String id;
  final String gymId;
  final String name;
  final String category;
  final String? notes;
  final String? imageUrl;
  final bool isSample;
  final String addedById;
  final String addedByUsername;
  final DateTime createdAt;

  const EquipmentItem({
    required this.id,
    required this.gymId,
    required this.name,
    required this.category,
    this.notes,
    this.imageUrl,
    this.isSample = false,
    required this.addedById,
    required this.addedByUsername,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'gymId': gymId,
        'name': name,
        'category': category,
        'notes': notes,
        'imageUrl': imageUrl,
        'isSample': isSample,
        'addedById': addedById,
        'addedByUsername': addedByUsername,
        'createdAt': createdAt.toIso8601String(),
      };

  factory EquipmentItem.fromMap(Map<dynamic, dynamic> map) => EquipmentItem(
        id: map['id'] as String,
        gymId: map['gymId'] as String,
        name: map['name'] as String,
        category: map['category'] as String,
        notes: map['notes'] as String?,
        imageUrl: map['imageUrl'] as String?,
        isSample: map['isSample'] as bool? ?? false,
        addedById: map['addedById'] as String,
        addedByUsername: map['addedByUsername'] as String? ?? 'unknown',
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
}

class EquipmentSummary {
  final EquipmentItem item;
  final int reviewCount;
  final double? avgCondition;
  final String? latestAvailability;

  const EquipmentSummary({
    required this.item,
    required this.reviewCount,
    required this.avgCondition,
    required this.latestAvailability,
  });
}
