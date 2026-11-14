class Gym {
  final String id;
  final String name;
  final String district;
  final String address;
  final String? chain;
  final String? website;
  final String? hours;
  final String? mapsUrl;
  final bool isSample;
  final String addedById;
  final String addedByUsername;
  final DateTime createdAt;

  const Gym({
    required this.id,
    required this.name,
    required this.district,
    required this.address,
    this.chain,
    this.website,
    this.hours,
    this.mapsUrl,
    this.isSample = false,
    required this.addedById,
    required this.addedByUsername,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'district': district,
        'address': address,
        'chain': chain,
        'website': website,
        'hours': hours,
        'mapsUrl': mapsUrl,
        'isSample': isSample,
        'addedById': addedById,
        'addedByUsername': addedByUsername,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Gym.fromMap(Map<dynamic, dynamic> map) => Gym(
        id: map['id'] as String,
        name: map['name'] as String,
        district: map['district'] as String,
        address: map['address'] as String,
        chain: map['chain'] as String?,
        website: map['website'] as String?,
        hours: map['hours'] as String?,
        mapsUrl: map['mapsUrl'] as String?,
        isSample: map['isSample'] as bool? ?? false,
        addedById: map['addedById'] as String,
        addedByUsername: map['addedByUsername'] as String? ?? 'unknown',
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
}

class GymSummary {
  final Gym gym;
  final int equipmentCount;
  final int reviewCount;
  final double? avgCondition;

  const GymSummary({
    required this.gym,
    required this.equipmentCount,
    required this.reviewCount,
    required this.avgCondition,
  });
}
