import 'package:hive_flutter/hive_flutter.dart';

class LocalStorageService {
  static const String _workoutsBox = 'workouts_cache';
  static const String _exercisesBox = 'exercises_cache';
  static const String _routinesBox = 'routines_cache';
  static const String _userBox = 'user_cache';

  static Future<void> initialize() async {
    await Hive.initFlutter();
  }

  // Workouts Cache
  static Future<void> cacheWorkouts(List<Map<String, dynamic>> workouts) async {
    final box = await Hive.openBox(_workoutsBox);
    await box.put('data', workouts);
    await box.put('last_updated', DateTime.now().toIso8601String());
  }

  static Future<List<Map<String, dynamic>>?> getCachedWorkouts() async {
    final box = await Hive.openBox(_workoutsBox);
    final data = box.get('data');
    return data != null ? List<Map<String, dynamic>>.from(data) : null;
  }

  // Exercises Cache
  static Future<void> cacheExercises(List<Map<String, dynamic>> exercises) async {
    final box = await Hive.openBox(_exercisesBox);
    await box.put('data', exercises);
    await box.put('last_updated', DateTime.now().toIso8601String());
  }

  static Future<List<Map<String, dynamic>>?> getCachedExercises() async {
    final box = await Hive.openBox(_exercisesBox);
    final data = box.get('data');
    return data != null ? List<Map<String, dynamic>>.from(data) : null;
  }

  // Routines Cache
  static Future<void> cacheRoutines(List<Map<String, dynamic>> routines) async {
    final box = await Hive.openBox(_routinesBox);
    await box.put('data', routines);
    await box.put('last_updated', DateTime.now().toIso8601String());
  }

  static Future<List<Map<String, dynamic>>?> getCachedRoutines() async {
    final box = await Hive.openBox(_routinesBox);
    final data = box.get('data');
    return data != null ? List<Map<String, dynamic>>.from(data) : null;
  }

  // User Profile Cache
  static Future<void> cacheUserProfile(Map<String, dynamic> profile) async {
    final box = await Hive.openBox(_userBox);
    await box.put('profile', profile);
    await box.put('last_updated', DateTime.now().toIso8601String());
  }

  static Future<Map<String, dynamic>?> getCachedUserProfile() async {
    final box = await Hive.openBox(_userBox);
    final data = box.get('profile');
    return data != null ? Map<String, dynamic>.from(data) : null;
  }

  // Clear all caches
  static Future<void> clearAllCaches() async {
    await Hive.deleteBoxFromDisk(_workoutsBox);
    await Hive.deleteBoxFromDisk(_exercisesBox);
    await Hive.deleteBoxFromDisk(_routinesBox);
    await Hive.deleteBoxFromDisk(_userBox);
  }

  // Check if cache is stale (older than specified duration)
  static Future<bool> isCacheStale(
    String boxName,
    Duration maxAge,
  ) async {
    try {
      final box = await Hive.openBox(boxName);
      final lastUpdatedString = box.get('last_updated');
      
      if (lastUpdatedString == null) return true;
      
      final lastUpdated = DateTime.parse(lastUpdatedString);
      final age = DateTime.now().difference(lastUpdated);
      
      return age > maxAge;
    } catch (e) {
      return true;
    }
  }

  // Generic cache getter
  static Future<dynamic> getFromCache(String boxName, String key) async {
    try {
      final box = await Hive.openBox(boxName);
      return box.get(key);
    } catch (e) {
      return null;
    }
  }

  // Generic cache setter
  static Future<void> saveToCache(
    String boxName,
    String key,
    dynamic value,
  ) async {
    final box = await Hive.openBox(boxName);
    await box.put(key, value);
  }
}

