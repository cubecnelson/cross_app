class OnTheRackConstants {
  static const String appName = 'OnTheRack';
  static const String tagline = "See what's on the floor before you go.";
  static const String seedVersion = '1';
  static const String demoPassword = 'ontherack-demo';

  static const String disclaimer =
      'All listings and ratings are user-generated (or labelled sample data) '
      'and may be incomplete, outdated, or wrong. OnTheRack is a personal '
      'project and is not affiliated with any gym, chain, or government '
      'operator (including LCSD). Confirm hours and access with the venue.';

  static const int minPasswordLength = 8;
  static const int maxName = 120;
  static const int maxAddress = 240;
  static const int maxComment = 2000;
  static const int maxNotes = 500;
  static const int maxUrl = 500;
  static final RegExp usernamePattern = RegExp(r'^[a-zA-Z0-9_]{3,24}$');
}

class EquipmentCategory {
  final String value;
  final String label;
  const EquipmentCategory(this.value, this.label);
}

class AvailabilityOption {
  final String value;
  final String label;
  final String hint;
  const AvailabilityOption(this.value, this.label, this.hint);
}

const List<EquipmentCategory> kEquipmentCategories = [
  EquipmentCategory('CARDIO', 'Cardio'),
  EquipmentCategory('STRENGTH_MACHINES', 'Strength machines'),
  EquipmentCategory('FREE_WEIGHTS', 'Free weights'),
  EquipmentCategory('RACKS_BENCHES', 'Racks & benches'),
  EquipmentCategory('FUNCTIONAL', 'Functional'),
  EquipmentCategory('OTHER', 'Other'),
];

const List<AvailabilityOption> kAvailabilityOptions = [
  AvailabilityOption('PLENTY', 'Plenty', 'Little or no wait'),
  AvailabilityOption('SOME_WAIT', 'Some wait', 'A short queue or one person ahead'),
  AvailabilityOption('CROWDED', 'Crowded', 'Long wait or all units taken'),
  AvailabilityOption('OUT_OF_SERVICE', 'Out of service', 'Broken, taped off, or missing'),
];

String categoryLabel(String value) {
  for (final c in kEquipmentCategories) {
    if (c.value == value) return c.label;
  }
  return value;
}

AvailabilityOption availabilityMeta(String value) {
  for (final a in kAvailabilityOptions) {
    if (a.value == value) return a;
  }
  return AvailabilityOption(value, value, '');
}
