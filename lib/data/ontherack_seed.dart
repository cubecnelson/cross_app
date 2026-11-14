/// Sample Hong Kong data for OnTheRack.
/// All rows are flagged isSample and shown with a "Sample data" badge.
/// Names and ratings are illustrative, not official or verified gym data.
library;

const String kSeedUserId = 'user-ontherack-seed';
const String kMeiId = 'user-mei';
const String kAlexId = 'user-alex';
const String kKwokId = 'user-kwok';

const String kGymPeak = 'gym-peak-club-central';
const String kGymShatin = 'gym-sha-tin-sports-centre';
const String kGymIron = 'gym-ironhour-24-mong-kok';
const String kGymEast = 'gym-east-box-kwun-tong';

const String kPeakTread = 'eq-peak-tread';
const String kPeakChest = 'eq-peak-chest';
const String kPeakRack = 'eq-peak-rack';
const String kPeakDb = 'eq-peak-db';
const String kStTread = 'eq-st-tread';
const String kStCable = 'eq-st-cable';
const String kStBar = 'eq-st-bar';
const String kIhTread = 'eq-ih-tread';
const String kIhSmith = 'eq-ih-smith';
const String kIhBench = 'eq-ih-bench';
const String kEbRig = 'eq-eb-rig';
const String kEbBike = 'eq-eb-bike';

const String kReviewPeakTreadMei = 'rev-peak-tread-mei';
const String kReviewPeakRackAlex = 'rev-peak-rack-alex';
const String kReviewPeakDbKwok = 'rev-peak-db-kwok';
const String kReviewPeakChestMei = 'rev-peak-chest-mei';
const String kReviewStTreadMei = 'rev-st-tread-mei';
const String kReviewStCableAlex = 'rev-st-cable-alex';
const String kReviewIhTreadKwok = 'rev-ih-tread-kwok';
const String kReviewIhSmithMei = 'rev-ih-smith-mei';
const String kReviewEbRigAlex = 'rev-eb-rig-alex';
const String kReviewEbBikeKwok = 'rev-eb-bike-kwok';
const String kReviewIhBenchAlex = 'rev-ih-bench-alex';

class SeedUserSpec {
  final String id;
  final String username;
  const SeedUserSpec(this.id, this.username);
}

const List<SeedUserSpec> kSeedUsers = [
  SeedUserSpec(kSeedUserId, 'ontherack_seed'),
  SeedUserSpec(kMeiId, 'mei'),
  SeedUserSpec(kAlexId, 'alex'),
  SeedUserSpec(kKwokId, 'kwok'),
];

class SeedGymSpec {
  final String id;
  final String name;
  final String district;
  final String address;
  final String? chain;
  final String? hours;
  const SeedGymSpec({
    required this.id,
    required this.name,
    required this.district,
    required this.address,
    this.chain,
    this.hours,
  });
}

const List<SeedGymSpec> kSeedGyms = [
  SeedGymSpec(
    id: kGymPeak,
    name: 'Peak Club Central',
    district: 'Central',
    address: "3/F, 8 Queen's Road Central, Central, Hong Kong",
    chain: 'Peak Club (fictional Pure-style chain)',
    hours: 'Mon–Fri 06:00–23:00 · Sat–Sun 08:00–21:00',
  ),
  SeedGymSpec(
    id: kGymShatin,
    name: 'Sha Tin Sports Centre',
    district: 'Sha Tin',
    address: '6 Yuen Wo Road, Sha Tin, New Territories',
    chain: 'LCSD-style public sports centre (sample)',
    hours:
        'Typical public-centre hours — confirm on site. Sample listing, not official LCSD data.',
  ),
  SeedGymSpec(
    id: kGymIron,
    name: 'IronHour 24 Mong Kok',
    district: 'Mong Kok',
    address: '12/F, 88 Nathan Road, Mong Kok, Kowloon',
    chain: 'IronHour (independent, fictional)',
    hours: 'Open 24 hours',
  ),
  SeedGymSpec(
    id: kGymEast,
    name: 'East Box Kwun Tong',
    district: 'Kwun Tong',
    address: 'Unit 5, 3/F, 21 How Ming Street, Kwun Tong, Kowloon',
    chain: 'Independent box (fictional)',
    hours: '06:30–21:30, closed Sunday',
  ),
];

class SeedEquipmentSpec {
  final String id;
  final String gymId;
  final String name;
  final String category;
  final String? notes;
  const SeedEquipmentSpec({
    required this.id,
    required this.gymId,
    required this.name,
    required this.category,
    this.notes,
  });
}

const List<SeedEquipmentSpec> kSeedEquipment = [
  SeedEquipmentSpec(
    id: kPeakTread,
    gymId: kGymPeak,
    name: 'Treadmill (Technogym-style)',
    category: 'CARDIO',
    notes: 'Four units facing the harbour-side windows.',
  ),
  SeedEquipmentSpec(
    id: kPeakChest,
    gymId: kGymPeak,
    name: 'Chest press (plate-loaded)',
    category: 'STRENGTH_MACHINES',
    notes: 'Hammer-style, next to the free-weight floor.',
  ),
  SeedEquipmentSpec(
    id: kPeakRack,
    gymId: kGymPeak,
    name: 'Squat rack',
    category: 'RACKS_BENCHES',
    notes: 'Two half-racks with bumper plates nearby.',
  ),
  SeedEquipmentSpec(
    id: kPeakDb,
    gymId: kGymPeak,
    name: 'Dumbbells 2.5–50 kg',
    category: 'FREE_WEIGHTS',
    notes: 'Full rack, 2.5 kg increments.',
  ),
  SeedEquipmentSpec(
    id: kStTread,
    gymId: kGymShatin,
    name: 'Treadmill',
    category: 'CARDIO',
    notes: 'Three units in the fitness room.',
  ),
  SeedEquipmentSpec(
    id: kStCable,
    gymId: kGymShatin,
    name: 'Cable crossover',
    category: 'STRENGTH_MACHINES',
    notes: 'Dual pulley, mid-room.',
  ),
  SeedEquipmentSpec(
    id: kStBar,
    gymId: kGymShatin,
    name: 'Olympic bar and plates',
    category: 'FREE_WEIGHTS',
    notes: 'Shared platform; limited bumper plates.',
  ),
  SeedEquipmentSpec(
    id: kIhTread,
    gymId: kGymIron,
    name: 'Treadmill bank',
    category: 'CARDIO',
    notes: 'Three units along the window wall.',
  ),
  SeedEquipmentSpec(
    id: kIhSmith,
    gymId: kGymIron,
    name: 'Smith machine',
    category: 'STRENGTH_MACHINES',
  ),
  SeedEquipmentSpec(
    id: kIhBench,
    gymId: kGymIron,
    name: 'Adjustable benches',
    category: 'RACKS_BENCHES',
    notes: 'Two benches near the dumbbell rack.',
  ),
  SeedEquipmentSpec(
    id: kEbRig,
    gymId: kGymEast,
    name: 'Rig and pull-up bay',
    category: 'FUNCTIONAL',
    notes: 'Wall-mounted rig, rings and bands stored on the side.',
  ),
  SeedEquipmentSpec(
    id: kEbBike,
    gymId: kGymEast,
    name: 'Assault bike',
    category: 'CARDIO',
  ),
];

class SeedReviewSpec {
  final String id;
  final String equipmentId;
  final String authorId;
  final String authorUsername;
  final int condition;
  final String availability;
  final String? comment;
  final int daysAgo;
  final bool hasLastSeen;
  const SeedReviewSpec({
    required this.id,
    required this.equipmentId,
    required this.authorId,
    required this.authorUsername,
    required this.condition,
    required this.availability,
    this.comment,
    required this.daysAgo,
    this.hasLastSeen = true,
  });
}

const List<SeedReviewSpec> kSeedReviews = [
  SeedReviewSpec(
    id: kReviewPeakTreadMei,
    equipmentId: kPeakTread,
    authorId: kMeiId,
    authorUsername: 'mei',
    condition: 4,
    availability: 'SOME_WAIT',
    comment:
        'Tuesday 7pm — two of four were free after a short wait. Consoles are a bit dated but the belts run true.',
    daysAgo: 2,
  ),
  SeedReviewSpec(
    id: kReviewPeakRackAlex,
    equipmentId: kPeakRack,
    authorId: kAlexId,
    authorUsername: 'alex',
    condition: 5,
    availability: 'CROWDED',
    comment:
        'Both racks busy at 6:30pm on a weekday. Bars and collars in good shape. Safety pins all present.',
    daysAgo: 4,
  ),
  SeedReviewSpec(
    id: kReviewPeakDbKwok,
    equipmentId: kPeakDb,
    authorId: kKwokId,
    authorUsername: 'kwok',
    condition: 5,
    availability: 'PLENTY',
    comment:
        'Full set, 2.5 kg jumps up to 50. A few worn grips, nothing missing when I was there mid-morning.',
    daysAgo: 6,
  ),
  SeedReviewSpec(
    id: kReviewPeakChestMei,
    equipmentId: kPeakChest,
    authorId: kMeiId,
    authorUsername: 'mei',
    condition: 4,
    availability: 'SOME_WAIT',
    comment:
        'One person ahead of me at lunch. Seat adjustment is smooth; a little paint wear on the frame.',
    daysAgo: 3,
  ),
  SeedReviewSpec(
    id: kReviewStTreadMei,
    equipmentId: kStTread,
    authorId: kMeiId,
    authorUsername: 'mei',
    condition: 3,
    availability: 'SOME_WAIT',
    comment:
        "Public-centre wear, as you'd expect. One unit was out; the other two were fine on a Saturday morning. This is a personal observation, not official data.",
    daysAgo: 5,
  ),
  SeedReviewSpec(
    id: kReviewStCableAlex,
    equipmentId: kStCable,
    authorId: kAlexId,
    authorUsername: 'alex',
    condition: 4,
    availability: 'PLENTY',
    comment:
        'Mid-morning weekday. Pulleys felt smooth. A little rust on the frame, nothing that stopped me using it.',
    daysAgo: 8,
  ),
  SeedReviewSpec(
    id: kReviewIhTreadKwok,
    equipmentId: kIhTread,
    authorId: kKwokId,
    authorUsername: 'kwok',
    condition: 3,
    availability: 'PLENTY',
    comment:
        'Passed through around 2am — two of three running. The left unit rattles on an incline.',
    daysAgo: 1,
  ),
  SeedReviewSpec(
    id: kReviewIhSmithMei,
    equipmentId: kIhSmith,
    authorId: kMeiId,
    authorUsername: 'mei',
    condition: 4,
    availability: 'PLENTY',
    comment:
        "Clean and greased. The 24-hour access is the whole point — I had it to myself after 11pm.",
    daysAgo: 7,
  ),
  SeedReviewSpec(
    id: kReviewEbRigAlex,
    equipmentId: kEbRig,
    authorId: kAlexId,
    authorUsername: 'alex',
    condition: 5,
    availability: 'PLENTY',
    comment:
        'Solid independent box. Bands and rings stored neatly. Small floor, no wait mid-afternoon.',
    daysAgo: 3,
  ),
  SeedReviewSpec(
    id: kReviewEbBikeKwok,
    equipmentId: kEbBike,
    authorId: kKwokId,
    authorUsername: 'kwok',
    condition: 2,
    availability: 'OUT_OF_SERVICE',
    comment:
        "Monitor was dead and there was a handwritten note on the seat last Saturday. Asking around if it's been fixed.",
    daysAgo: 4,
    hasLastSeen: false,
  ),
  SeedReviewSpec(
    id: kReviewIhBenchAlex,
    equipmentId: kIhBench,
    authorId: kAlexId,
    authorUsername: 'alex',
    condition: 4,
    availability: 'SOME_WAIT',
    comment:
        'Pads are holding up. One bench was taken for a long superset around 8pm — the other was free.',
    daysAgo: 2,
  ),
];

class SeedUpvoteSpec {
  final String reviewId;
  final String userId;
  const SeedUpvoteSpec(this.reviewId, this.userId);
}

const List<SeedUpvoteSpec> kSeedUpvotes = [
  SeedUpvoteSpec(kReviewPeakTreadMei, kAlexId),
  SeedUpvoteSpec(kReviewPeakTreadMei, kKwokId),
  SeedUpvoteSpec(kReviewPeakRackAlex, kMeiId),
  SeedUpvoteSpec(kReviewStCableAlex, kMeiId),
  SeedUpvoteSpec(kReviewStCableAlex, kKwokId),
  SeedUpvoteSpec(kReviewEbRigAlex, kMeiId),
  SeedUpvoteSpec(kReviewEbRigAlex, kKwokId),
];
