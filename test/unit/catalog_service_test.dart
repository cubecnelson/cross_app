import 'package:flutter_test/flutter_test.dart';
import 'package:cross/core/constants/ontherack_constants.dart';
import 'package:cross/data/ontherack_seed.dart';
import 'package:cross/models/app_session.dart';
import 'package:cross/services/catalog_service.dart';
import 'package:cross/services/local_auth_service.dart';

void main() {
  late CatalogService catalog;
  late LocalAuthService auth;

  setUp(() async {
    catalog = CatalogService.memory();
    await catalog.initialize();
    auth = LocalAuthService(catalog);
    await auth.initialize();
  });

  test('seed loads four gyms, twelve equipment items, and eleven reviews', () {
    expect(catalog.gymCount, 4);
    expect(catalog.equipmentCount, 12);
    expect(catalog.reviewCount, 11);
    expect(catalog.listDistricts(), ['Central', 'Kwun Tong', 'Mong Kok', 'Sha Tin']);
  });

  test('search and district filters work together', () {
    final all = catalog.listGyms();
    expect(all.length, 4);

    final shaTin = catalog.listGyms(district: 'Sha Tin');
    expect(shaTin, hasLength(1));
    expect(shaTin.first.gym.name, 'Sha Tin Sports Centre');

    final peak = catalog.listGyms(query: 'harbour');
    expect(peak, isEmpty); // harbour is in equipment notes, not gym fields

    final central = catalog.listGyms(query: 'queen');
    expect(central, hasLength(1));
    expect(central.first.gym.id, kGymPeak);

    final none = catalog.listGyms(query: 'central', district: 'Kwun Tong');
    expect(none, isEmpty);
  });

  test('writes require a session and persist in the catalog', () async {
    final session = await auth.signIn(
      username: 'mei',
      password: OnTheRackConstants.demoPassword,
    );

    final gym = await catalog.addGym(
      session: session,
      name: 'Harbour Loft',
      district: 'Wan Chai',
      address: '1 Hennessy Road, Wan Chai',
    );
    expect(gym.isSample, isFalse);
    expect(catalog.gymCount, 5);

    final item = await catalog.addEquipment(
      session: session,
      gymId: gym.id,
      name: 'Rowing machine',
      category: 'CARDIO',
    );
    final review = await catalog.addReview(
      session: session,
      equipmentId: item.id,
      condition: 5,
      availability: 'PLENTY',
      comment: 'Quiet mid-morning.',
    );
    expect(review.authorUsername, 'mei');
    expect(catalog.reviewCount, 12);

    await catalog.toggleUpvote(session: session, reviewId: review.id);
    final meta = catalog.reviewsForEquipment(item.id, viewerId: session.userId);
    expect(meta.first.upvoteCount, 1);
    expect(meta.first.votedByMe, isTrue);
  });

  test('seed does not wipe user data when applied again', () async {
    const session = AppSession(userId: kMeiId, username: 'mei');
    await catalog.addGym(
      session: session,
      name: 'User Gym',
      district: 'Tai Po',
      address: 'Tai Po',
    );
    await catalog.backend.setMeta('seedVersion', '');
    await catalog.seedIfNeeded();
    expect(catalog.gymCount, 5);
    expect(catalog.listGyms().any((g) => g.gym.name == 'User Gym'), isTrue);
  });

  test('demo login and new registration work; bad passwords fail', () async {
    final mei = await auth.signIn(
      username: 'mei',
      password: OnTheRackConstants.demoPassword,
    );
    expect(mei.username, 'mei');

    expect(
      () => auth.signIn(username: 'mei', password: 'wrong-password'),
      throwsA(isA<AuthException>()),
    );

    expect(
      () => auth.register(username: 'ab', password: 'longenough'),
      throwsA(isA<AuthException>()),
    );

    final created = await auth.register(
      username: 'new_user',
      password: 'longenough',
    );
    expect(created.username, 'new_user');

    await auth.signOut();
    expect(auth.session, isNull);
  });
}
