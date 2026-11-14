import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/ontherack_constants.dart';
import '../data/ontherack_seed.dart';
import '../models/app_session.dart';
import '../models/equipment_item.dart';
import '../models/equipment_review.dart';
import '../models/gym.dart';
import 'password_hasher.dart';

abstract class CatalogBackend {
  Future<void> init();
  Map<dynamic, dynamic>? getUser(String id);
  Map<dynamic, dynamic>? getUserByUsername(String username);
  Future<void> putUser(String id, Map<String, dynamic> data);
  Map<dynamic, dynamic>? getGym(String id);
  Iterable<Map<dynamic, dynamic>> allGyms();
  Future<void> putGym(String id, Map<String, dynamic> data);
  Map<dynamic, dynamic>? getEquipment(String id);
  Iterable<Map<dynamic, dynamic>> allEquipment();
  Future<void> putEquipment(String id, Map<String, dynamic> data);
  Map<dynamic, dynamic>? getReview(String id);
  Iterable<Map<dynamic, dynamic>> allReviews();
  Future<void> putReview(String id, Map<String, dynamic> data);
  Iterable<Map<dynamic, dynamic>> allUpvotes();
  Future<void> putUpvote(String id, Map<String, dynamic> data);
  Future<void> deleteUpvote(String id);
  String? getMeta(String key);
  Future<void> setMeta(String key, String value);
}

class MemoryCatalogBackend implements CatalogBackend {
  final Map<String, Map<String, dynamic>> users = {};
  final Map<String, Map<String, dynamic>> gyms = {};
  final Map<String, Map<String, dynamic>> equipment = {};
  final Map<String, Map<String, dynamic>> reviews = {};
  final Map<String, Map<String, dynamic>> upvotes = {};
  final Map<String, String> meta = {};

  @override
  Future<void> init() async {}

  @override
  Map<dynamic, dynamic>? getUser(String id) => users[id];

  @override
  Map<dynamic, dynamic>? getUserByUsername(String username) {
    final needle = username.toLowerCase();
    for (final u in users.values) {
      if ((u['username'] as String).toLowerCase() == needle) return u;
    }
    return null;
  }

  @override
  Future<void> putUser(String id, Map<String, dynamic> data) async {
    users[id] = data;
  }

  @override
  Map<dynamic, dynamic>? getGym(String id) => gyms[id];

  @override
  Iterable<Map<dynamic, dynamic>> allGyms() => gyms.values;

  @override
  Future<void> putGym(String id, Map<String, dynamic> data) async {
    gyms[id] = data;
  }

  @override
  Map<dynamic, dynamic>? getEquipment(String id) => equipment[id];

  @override
  Iterable<Map<dynamic, dynamic>> allEquipment() => equipment.values;

  @override
  Future<void> putEquipment(String id, Map<String, dynamic> data) async {
    equipment[id] = data;
  }

  @override
  Map<dynamic, dynamic>? getReview(String id) => reviews[id];

  @override
  Iterable<Map<dynamic, dynamic>> allReviews() => reviews.values;

  @override
  Future<void> putReview(String id, Map<String, dynamic> data) async {
    reviews[id] = data;
  }

  @override
  Iterable<Map<dynamic, dynamic>> allUpvotes() => upvotes.values;

  @override
  Future<void> putUpvote(String id, Map<String, dynamic> data) async {
    upvotes[id] = data;
  }

  @override
  Future<void> deleteUpvote(String id) async {
    upvotes.remove(id);
  }

  @override
  String? getMeta(String key) => meta[key];

  @override
  Future<void> setMeta(String key, String value) async {
    meta[key] = value;
  }
}

class HiveCatalogBackend implements CatalogBackend {
  static const usersBox = 'otr_users';
  static const gymsBox = 'otr_gyms';
  static const equipmentBox = 'otr_equipment';
  static const reviewsBox = 'otr_reviews';
  static const upvotesBox = 'otr_upvotes';
  static const metaBox = 'otr_meta';

  late Box users;
  late Box gyms;
  late Box equipment;
  late Box reviews;
  late Box upvotes;
  late Box meta;

  @override
  Future<void> init() async {
    users = await Hive.openBox(usersBox);
    gyms = await Hive.openBox(gymsBox);
    equipment = await Hive.openBox(equipmentBox);
    reviews = await Hive.openBox(reviewsBox);
    upvotes = await Hive.openBox(upvotesBox);
    meta = await Hive.openBox(metaBox);
  }

  Map<dynamic, dynamic>? _asMap(dynamic value) {
    if (value == null) return null;
    return Map<dynamic, dynamic>.from(value as Map);
  }

  @override
  Map<dynamic, dynamic>? getUser(String id) => _asMap(users.get(id));

  @override
  Map<dynamic, dynamic>? getUserByUsername(String username) {
    final needle = username.toLowerCase();
    for (final value in users.values) {
      final map = _asMap(value);
      if (map != null &&
          (map['username'] as String).toLowerCase() == needle) {
        return map;
      }
    }
    return null;
  }

  @override
  Future<void> putUser(String id, Map<String, dynamic> data) =>
      users.put(id, data);

  @override
  Map<dynamic, dynamic>? getGym(String id) => _asMap(gyms.get(id));

  @override
  Iterable<Map<dynamic, dynamic>> allGyms() =>
      usersBoxGyms();

  Iterable<Map<dynamic, dynamic>> usersBoxGyms() sync* {
    for (final value in gyms.values) {
      final map = _asMap(value);
      if (map != null) yield map;
    }
  }

  @override
  Future<void> putGym(String id, Map<String, dynamic> data) =>
      gyms.put(id, data);

  @override
  Map<dynamic, dynamic>? getEquipment(String id) => _asMap(equipment.get(id));

  @override
  Iterable<Map<dynamic, dynamic>> allEquipment() sync* {
    for (final value in equipment.values) {
      final map = _asMap(value);
      if (map != null) yield map;
    }
  }

  @override
  Future<void> putEquipment(String id, Map<String, dynamic> data) =>
      equipment.put(id, data);

  @override
  Map<dynamic, dynamic>? getReview(String id) => _asMap(reviews.get(id));

  @override
  Iterable<Map<dynamic, dynamic>> allReviews() sync* {
    for (final value in reviews.values) {
      final map = _asMap(value);
      if (map != null) yield map;
    }
  }

  @override
  Future<void> putReview(String id, Map<String, dynamic> data) =>
      reviews.put(id, data);

  @override
  Iterable<Map<dynamic, dynamic>> allUpvotes() sync* {
    for (final value in upvotes.values) {
      final map = _asMap(value);
      if (map != null) yield map;
    }
  }

  @override
  Future<void> putUpvote(String id, Map<String, dynamic> data) =>
      upvotes.put(id, data);

  @override
  Future<void> deleteUpvote(String id) => upvotes.delete(id);

  @override
  String? getMeta(String key) => meta.get(key) as String?;

  @override
  Future<void> setMeta(String key, String value) => meta.put(key, value);
}

class CatalogService {
  CatalogService(this._backend);

  factory CatalogService.memory() => CatalogService(MemoryCatalogBackend());
  factory CatalogService.hive() => CatalogService(HiveCatalogBackend());

  final CatalogBackend _backend;
  final Uuid _uuid = const Uuid();

  CatalogBackend get backend => _backend;

  Future<void> initialize() async {
    await _backend.init();
    await seedIfNeeded();
  }

  Future<void> seedIfNeeded() async {
    if (_backend.getMeta('seedVersion') == OnTheRackConstants.seedVersion) {
      return;
    }
    await _applySeed();
    await _backend.setMeta('seedVersion', OnTheRackConstants.seedVersion);
  }

  /// Inserts missing sample rows only; never deletes user-contributed data.
  Future<void> _applySeed() async {
    final now = DateTime.now();
    final passwordHash = PasswordHasher.hash(
      OnTheRackConstants.demoPassword,
      PasswordHasher.seedSalt,
    );

    for (final user in kSeedUsers) {
      if (_backend.getUser(user.id) != null) continue;
      await _backend.putUser(user.id, {
        'id': user.id,
        'username': user.username,
        'passwordHash': passwordHash,
        'salt': PasswordHasher.seedSalt,
        'isSample': true,
        'createdAt': now.toIso8601String(),
      });
    }

    for (final gym in kSeedGyms) {
      if (_backend.getGym(gym.id) != null) continue;
      await _backend.putGym(
        gym.id,
        Gym(
          id: gym.id,
          name: gym.name,
          district: gym.district,
          address: gym.address,
          chain: gym.chain,
          hours: gym.hours,
          isSample: true,
          addedById: kSeedUserId,
          addedByUsername: 'ontherack_seed',
          createdAt: now,
        ).toMap(),
      );
    }

    for (final item in kSeedEquipment) {
      if (_backend.getEquipment(item.id) != null) continue;
      await _backend.putEquipment(
        item.id,
        EquipmentItem(
          id: item.id,
          gymId: item.gymId,
          name: item.name,
          category: item.category,
          notes: item.notes,
          isSample: true,
          addedById: kSeedUserId,
          addedByUsername: 'ontherack_seed',
          createdAt: now,
        ).toMap(),
      );
    }

    DateTime daysAgo(int n) {
      final d = now.subtract(Duration(days: n));
      return DateTime(d.year, d.month, d.day, 10 + (n % 8), (n * 17) % 60);
    }

    for (final review in kSeedReviews) {
      if (_backend.getReview(review.id) != null) continue;
      final created = daysAgo(review.daysAgo);
      await _backend.putReview(
        review.id,
        EquipmentReview(
          id: review.id,
          equipmentId: review.equipmentId,
          authorId: review.authorId,
          authorUsername: review.authorUsername,
          condition: review.condition,
          availability: review.availability,
          comment: review.comment,
          lastSeenWorking: review.hasLastSeen ? created : null,
          isSample: true,
          createdAt: created,
        ).toMap(),
      );
    }

    for (final vote in kSeedUpvotes) {
      final id = 'up-${vote.reviewId}-${vote.userId}';
      final exists = _backend.allUpvotes().any((u) =>
          u['reviewId'] == vote.reviewId && u['userId'] == vote.userId);
      if (exists) continue;
      await _backend.putUpvote(id, {
        'id': id,
        'reviewId': vote.reviewId,
        'userId': vote.userId,
        'createdAt': now.toIso8601String(),
      });
    }
  }

  List<Gym> listGymsRaw() =>
      _backend.allGyms().map((m) => Gym.fromMap(m)).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<EquipmentItem> listEquipmentRaw() =>
      _backend.allEquipment().map((m) => EquipmentItem.fromMap(m)).toList();

  List<EquipmentReview> listReviewsRaw() =>
      _backend.allReviews().map((m) => EquipmentReview.fromMap(m)).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  double? _average(Iterable<int> values) {
    final list = values.toList();
    if (list.isEmpty) return null;
    return list.reduce((a, b) => a + b) / list.length;
  }

  List<GymSummary> listGyms({String? query, String? district}) {
    final q = query?.trim().toLowerCase() ?? '';
    final d = district?.trim() ?? '';
    final equipment = listEquipmentRaw();
    final reviews = listReviewsRaw();

    final summaries = <GymSummary>[];
    for (final gym in listGymsRaw()) {
      if (d.isNotEmpty && gym.district != d) continue;
      if (q.isNotEmpty) {
        final hay =
            '${gym.name} ${gym.district} ${gym.address} ${gym.chain ?? ''}'
                .toLowerCase();
        if (!hay.contains(q)) continue;
      }
      final gymEq = equipment.where((e) => e.gymId == gym.id).toList();
      final ids = gymEq.map((e) => e.id).toSet();
      final gymReviews =
          reviews.where((r) => ids.contains(r.equipmentId)).toList();
      summaries.add(GymSummary(
        gym: gym,
        equipmentCount: gymEq.length,
        reviewCount: gymReviews.length,
        avgCondition: _average(gymReviews.map((r) => r.condition)),
      ));
    }
    return summaries;
  }

  List<String> listDistricts() {
    final set = listGymsRaw().map((g) => g.district).toSet().toList()..sort();
    return set;
  }

  Gym? getGym(String id) {
    final map = _backend.getGym(id);
    return map == null ? null : Gym.fromMap(map);
  }

  GymSummary? gymSummary(String id) {
    final matches = listGyms().where((s) => s.gym.id == id);
    return matches.isEmpty ? null : matches.first;
  }

  List<EquipmentSummary> equipmentForGym(String gymId) {
    final reviews = listReviewsRaw();
    final items = listEquipmentRaw().where((e) => e.gymId == gymId).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return items.map((item) {
      final itemReviews =
          reviews.where((r) => r.equipmentId == item.id).toList();
      return EquipmentSummary(
        item: item,
        reviewCount: itemReviews.length,
        avgCondition: _average(itemReviews.map((r) => r.condition)),
        latestAvailability:
            itemReviews.isEmpty ? null : itemReviews.first.availability,
      );
    }).toList();
  }

  EquipmentItem? getEquipment(String id) {
    final map = _backend.getEquipment(id);
    return map == null ? null : EquipmentItem.fromMap(map);
  }

  List<ReviewWithMeta> reviewsForEquipment(String equipmentId, {String? viewerId}) {
    return _reviewsWithMeta(
      listReviewsRaw().where((r) => r.equipmentId == equipmentId),
      viewerId: viewerId,
    );
  }

  List<ReviewWithMeta> recentReviews({int take = 12, String? viewerId}) {
    return _reviewsWithMeta(listReviewsRaw().take(take), viewerId: viewerId);
  }

  List<ReviewWithMeta> _reviewsWithMeta(
    Iterable<EquipmentReview> reviews, {
    String? viewerId,
  }) {
    final upvotes = _backend.allUpvotes().toList();
    final equipmentById = {
      for (final e in listEquipmentRaw()) e.id: e,
    };
    final gymsById = {for (final g in listGymsRaw()) g.id: g};
    return reviews.map((review) {
      final votes = upvotes
          .where((u) => u['reviewId'] == review.id)
          .toList();
      final item = equipmentById[review.equipmentId];
      final gym = item == null ? null : gymsById[item.gymId];
      return ReviewWithMeta(
        review: review,
        upvoteCount: votes.length,
        votedByMe: viewerId != null &&
            votes.any((u) => u['userId'] == viewerId),
        equipmentName: item?.name ?? 'Unknown equipment',
        equipmentId: review.equipmentId,
        gymId: gym?.id ?? '',
        gymName: gym?.name ?? 'Unknown gym',
        gymDistrict: gym?.district ?? '',
      );
    }).toList();
  }

  Future<Gym> addGym({
    required AppSession session,
    required String name,
    required String district,
    required String address,
    String? chain,
    String? website,
    String? hours,
    String? mapsUrl,
  }) async {
    final gym = Gym(
      id: _uuid.v4(),
      name: name.trim(),
      district: district.trim(),
      address: address.trim(),
      chain: _emptyToNull(chain),
      website: _emptyToNull(website),
      hours: _emptyToNull(hours),
      mapsUrl: _emptyToNull(mapsUrl),
      addedById: session.userId,
      addedByUsername: session.username,
      createdAt: DateTime.now(),
    );
    await _backend.putGym(gym.id, gym.toMap());
    return gym;
  }

  Future<EquipmentItem> addEquipment({
    required AppSession session,
    required String gymId,
    required String name,
    required String category,
    String? notes,
    String? imageUrl,
  }) async {
    if (getGym(gymId) == null) {
      throw StateError('Gym not found');
    }
    final item = EquipmentItem(
      id: _uuid.v4(),
      gymId: gymId,
      name: name.trim(),
      category: category,
      notes: _emptyToNull(notes),
      imageUrl: _emptyToNull(imageUrl),
      addedById: session.userId,
      addedByUsername: session.username,
      createdAt: DateTime.now(),
    );
    await _backend.putEquipment(item.id, item.toMap());
    return item;
  }

  Future<EquipmentReview> addReview({
    required AppSession session,
    required String equipmentId,
    required int condition,
    required String availability,
    String? comment,
    DateTime? lastSeenWorking,
  }) async {
    if (getEquipment(equipmentId) == null) {
      throw StateError('Equipment not found');
    }
    if (condition < 1 || condition > 5) {
      throw ArgumentError('Condition must be 1–5');
    }
    final review = EquipmentReview(
      id: _uuid.v4(),
      equipmentId: equipmentId,
      authorId: session.userId,
      authorUsername: session.username,
      condition: condition,
      availability: availability,
      comment: _emptyToNull(comment),
      lastSeenWorking: lastSeenWorking,
      createdAt: DateTime.now(),
    );
    await _backend.putReview(review.id, review.toMap());
    return review;
  }

  Future<void> toggleUpvote({
    required AppSession session,
    required String reviewId,
  }) async {
    if (_backend.getReview(reviewId) == null) {
      throw StateError('Review not found');
    }
    final existing = _backend.allUpvotes().where(
          (u) => u['reviewId'] == reviewId && u['userId'] == session.userId,
        );
    if (existing.isNotEmpty) {
      await _backend.deleteUpvote(existing.first['id'] as String);
      return;
    }
    final id = 'up-$reviewId-${session.userId}';
    await _backend.putUpvote(id, {
      'id': id,
      'reviewId': reviewId,
      'userId': session.userId,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  int get gymCount => _backend.allGyms().length;
  int get equipmentCount => _backend.allEquipment().length;
  int get reviewCount => _backend.allReviews().length;

  String? _emptyToNull(String? value) {
    final t = value?.trim();
    if (t == null || t.isEmpty) return null;
    return t;
  }
}
