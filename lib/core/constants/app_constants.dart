class AppConstants {
  // App Info
  static const String appName = 'Cross';
  static const String appVersion = '1.0.0';
  
  // Database Tables
  static const String usersTable = 'users';
  static const String exercisesTable = 'exercises';
  static const String workoutsTable = 'workouts';
  static const String setsTable = 'sets';
  static const String routinesTable = 'routines';
  
  // Storage Keys
  static const String themeKey = 'theme_mode';
  static const String unitsKey = 'units_preference';
  static const String notificationsKey = 'notifications_enabled';
  
  // Units
  static const String metric = 'metric';
  static const String imperial = 'imperial';
  
  // Exercise Categories
  static const List<String> exerciseCategories = [
    'Chest',
    'Back',
    'Shoulders',
    'Legs',
    'Arms',
    'Core',
    'Cardio',
    'Other',
  ];
  
  // RPE Scale
  static const List<int> rpeScale = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  
  // Validation
  static const int minPasswordLength = 8;
  static const int maxExerciseNameLength = 100;
  static const int maxNotesLength = 500;
  
  // Timing
  static const Duration defaultRestTime = Duration(seconds: 90);
  static const Duration sessionTimeout = Duration(minutes: 30);
  
  // Pagination
  static const int itemsPerPage = 20;
}

