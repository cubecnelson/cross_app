import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_session.dart';
import '../models/equipment_item.dart';
import '../models/equipment_review.dart';
import '../models/gym.dart';
import '../services/catalog_service.dart';
import '../services/local_auth_service.dart';

/// Overridden in main() / tests after the catalog is initialized.
final catalogServiceProvider = Provider<CatalogService>((ref) {
  throw StateError('catalogServiceProvider must be overridden');
});

final localAuthServiceProvider = Provider<LocalAuthService>((ref) {
  throw StateError('localAuthServiceProvider must be overridden');
});

class SessionNotifier extends StateNotifier<AppSession?> {
  SessionNotifier(this._auth) : super(_auth.session);

  final LocalAuthService _auth;

  Future<void> signIn({
    required String username,
    required String password,
  }) async {
    state = await _auth.signIn(username: username, password: password);
  }

  Future<void> register({
    required String username,
    required String password,
  }) async {
    state = await _auth.register(username: username, password: password);
  }

  Future<void> signOut() async {
    await _auth.signOut();
    state = null;
  }
}

final sessionProvider =
    StateNotifierProvider<SessionNotifier, AppSession?>((ref) {
  final auth = ref.watch(localAuthServiceProvider);
  return SessionNotifier(auth);
});

class GymFilter {
  final String query;
  final String? district;
  const GymFilter({this.query = '', this.district});

  GymFilter copyWith({String? query, String? district, bool clearDistrict = false}) {
    return GymFilter(
      query: query ?? this.query,
      district: clearDistrict ? null : (district ?? this.district),
    );
  }
}

class GymFilterNotifier extends StateNotifier<GymFilter> {
  GymFilterNotifier() : super(const GymFilter());

  void setQuery(String query) => state = state.copyWith(query: query);

  void setDistrict(String? district) {
    if (district == null || district.isEmpty) {
      state = state.copyWith(clearDistrict: true);
    } else {
      state = state.copyWith(district: district);
    }
  }
}

final gymFilterProvider =
    StateNotifierProvider<GymFilterNotifier, GymFilter>((ref) {
  return GymFilterNotifier();
});

/// Bumped after writes so list screens refresh.
final catalogTickProvider = StateProvider<int>((ref) => 0);

void bumpCatalog(WidgetRef ref) {
  ref.read(catalogTickProvider.notifier).state++;
}

final gymListProvider = Provider<List<GymSummary>>((ref) {
  ref.watch(catalogTickProvider);
  final catalog = ref.watch(catalogServiceProvider);
  final filter = ref.watch(gymFilterProvider);
  return catalog.listGyms(query: filter.query, district: filter.district);
});

final districtListProvider = Provider<List<String>>((ref) {
  ref.watch(catalogTickProvider);
  return ref.watch(catalogServiceProvider).listDistricts();
});

final catalogCountsProvider = Provider<({int gyms, int equipment, int reviews})>((ref) {
  ref.watch(catalogTickProvider);
  final c = ref.watch(catalogServiceProvider);
  return (gyms: c.gymCount, equipment: c.equipmentCount, reviews: c.reviewCount);
});

final gymDetailProvider = Provider.family<GymSummary?, String>((ref, id) {
  ref.watch(catalogTickProvider);
  return ref.watch(catalogServiceProvider).gymSummary(id);
});

final gymEquipmentProvider =
    Provider.family<List<EquipmentSummary>, String>((ref, gymId) {
  ref.watch(catalogTickProvider);
  return ref.watch(catalogServiceProvider).equipmentForGym(gymId);
});

final equipmentItemProvider =
    Provider.family<EquipmentItem?, String>((ref, id) {
  ref.watch(catalogTickProvider);
  return ref.watch(catalogServiceProvider).getEquipment(id);
});

final equipmentReviewsProvider =
    Provider.family<List<ReviewWithMeta>, String>((ref, equipmentId) {
  ref.watch(catalogTickProvider);
  final session = ref.watch(sessionProvider);
  return ref.watch(catalogServiceProvider).reviewsForEquipment(
        equipmentId,
        viewerId: session?.userId,
      );
});

final recentReviewsProvider = Provider<List<ReviewWithMeta>>((ref) {
  ref.watch(catalogTickProvider);
  final session = ref.watch(sessionProvider);
  return ref.watch(catalogServiceProvider).recentReviews(
        viewerId: session?.userId,
      );
});
