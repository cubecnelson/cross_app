import 'dart:math';

import '../models/personal_record.dart';
import '../models/workout.dart';
import '../models/workout_set.dart';
import 'barbell_service.dart';

class PrService {
  /// Detect and return new personal records from completed workout sets
  static List<PersonalRecord> detectPRs({
    required List<PersonalRecord> existingPRs,
    required List<Workout> recentWorkouts,
    required String userId,
  }) {
    final newPRs = <PersonalRecord>[];

    // Group existing PRs by exercise
    final existingPRsByExercise = <String, List<PersonalRecord>>{};
    for (final pr in existingPRs) {
      existingPRsByExercise.putIfAbsent(pr.exerciseId, () => []).add(pr);
    }

    // Process each workout
    for (final workout in recentWorkouts) {
      // Process each completed set
      for (final set in workout.sets) {
        if (!set.isCompleted || !set.isStrength || set.weight == null || set.reps == null) {
          continue;
        }

        final weight = set.weight!;
        final reps = set.reps!;
        final exerciseId = set.exerciseId;
        final exerciseName = set.exerciseName;

        // Calculate estimated 1RM
        final oneRepMax = BarbellService.calculateOneRepMax(
          weight: weight,
          reps: reps,
        )['average'];

        // Check for 1RM PR (reps == 1)
        if (reps == 1) {
          final isNew1RM = _isNew1RM(
            weight,
            existingPRsByExercise[exerciseId] ?? [],
            userId,
            workout,
            set,
            oneRepMax,
          );

          if (isNew1RM != null) {
            newPRs.add(isNew1RM);
          }
        }

        // Check for rep max PRs (e.g., 3RM, 5RM, 8RM, etc.)
        final isNewRepMax = _isNewRepMax(
          weight,
          reps,
          exerciseId,
          exerciseName,
          existingPRsByExercise[exerciseId] ?? [],
          userId,
          workout,
          set,
          oneRepMax,
        );

        if (isNewRepMax != null) {
          newPRs.add(isNewRepMax);
        }

        // Check for estimated 1RM PR (using calculated 1RM)
        if (oneRepMax != null) {
          final isNewEstimated1RM = _isNewEstimated1RM(
            oneRepMax,
            exerciseId,
            exerciseName,
            existingPRsByExercise[exerciseId] ?? [],
            userId,
            workout,
            set,
            weight,
            reps,
          );

          if (isNewEstimated1RM != null) {
            newPRs.add(isNewEstimated1RM);
          }
        }
      }
    }

    return newPRs;
  }

  /// Check if a set is a new 1RM (actual 1 rep max)
  static PersonalRecord? _isNew1RM(
    double weight,
    List<PersonalRecord> existingExercisePRs,
    String userId,
    Workout workout,
    WorkoutSet set,
    double? estimatedOneRepMax,
  ) {
    // Find existing 1RM for this exercise
    final existing1RM = existingExercisePRs
        .where((pr) => pr.reps == 1)
        .fold<PersonalRecord?>(
          null,
          (best, pr) => best == null || pr.weight > best.weight ? pr : best,
        );

    // Check if this is a new 1RM
    if (existing1RM == null || weight > existing1RM.weight) {
      return PersonalRecord(
        userId: userId,
        exerciseId: set.exerciseId,
        exerciseName: set.exerciseName,
        weight: weight,
        reps: 1,
        estimatedOneRepMax: estimatedOneRepMax,
        date: workout.date,
        workoutId: workout.id,
        workoutSetId: set.id,
        notes: 'New 1RM! Previous: ${existing1RM?.weight.toStringAsFixed(1) ?? "None"} kg',
      );
    }

    return null;
  }

  /// Check if a set is a new rep max (e.g., 3RM, 5RM, etc.)
  static PersonalRecord? _isNewRepMax(
    double weight,
    int reps,
    String exerciseId,
    String exerciseName,
    List<PersonalRecord> existingExercisePRs,
    String userId,
    Workout workout,
    WorkoutSet set,
    double? estimatedOneRepMax,
  ) {
    // Find existing PR for this exact rep count
    final existingRepMax = existingExercisePRs
        .where((pr) => pr.reps == reps)
        .fold<PersonalRecord?>(
          null,
          (best, pr) => best == null || pr.weight > best.weight ? pr : best,
        );

    // Check if this is a new rep max
    if (existingRepMax == null || weight > existingRepMax.weight) {
      return PersonalRecord(
        userId: userId,
        exerciseId: exerciseId,
        exerciseName: exerciseName,
        weight: weight,
        reps: reps,
        estimatedOneRepMax: estimatedOneRepMax,
        date: workout.date,
        workoutId: workout.id,
        workoutSetId: set.id,
        notes: 'New ${reps}RM! Previous: ${existingRepMax?.weight.toStringAsFixed(1) ?? "None"} kg',
      );
    }

    return null;
  }

  /// Check if a set results in a new estimated 1RM PR
  static PersonalRecord? _isNewEstimated1RM(
    double estimated1RM,
    String exerciseId,
    String exerciseName,
    List<PersonalRecord> existingExercisePRs,
    String userId,
    Workout workout,
    WorkoutSet set,
    double actualWeight,
    int actualReps,
  ) {
    // Find existing estimated 1RM PRs
    final existingEstimated1RMs = existingExercisePRs
        .where((pr) => pr.estimatedOneRepMax != null)
        .toList();

    final bestEstimated1RM = existingEstimated1RMs
        .fold<PersonalRecord?>(
          null,
          (best, pr) => best == null || pr.estimatedOneRepMax! > best.estimatedOneRepMax! ? pr : best,
        );

    // Check if this is a new estimated 1RM
    if (bestEstimated1RM == null || estimated1RM > bestEstimated1RM.estimatedOneRepMax!) {
      return PersonalRecord(
        userId: userId,
        exerciseId: exerciseId,
        exerciseName: exerciseName,
        weight: actualWeight,
        reps: actualReps,
        estimatedOneRepMax: estimated1RM,
        date: workout.date,
        workoutId: workout.id,
        workoutSetId: set.id,
        notes: 'New estimated 1RM: ${estimated1RM.toStringAsFixed(1)} kg (from ${actualWeight.toStringAsFixed(1)} kg × $actualReps)',
      );
    }

    return null;
  }

  /// Get all PRs for a user, sorted by date (newest first)
  static List<PersonalRecord> getSortedPRs(List<PersonalRecord> allPRs) {
    final sorted = List<PersonalRecord>.from(allPRs)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  /// Get PRs grouped by exercise
  static Map<String, List<PersonalRecord>> groupPRsByExercise(List<PersonalRecord> prs) {
    final grouped = <String, List<PersonalRecord>>{};
    
    for (final pr in prs) {
      grouped.putIfAbsent(pr.exerciseId, () => []).add(pr);
    }

    // Sort each group by weight descending
    for (final exerciseId in grouped.keys) {
      grouped[exerciseId]!.sort((a, b) => b.weight.compareTo(a.weight));
    }

    return grouped;
  }

  /// Get best PR for each exercise
  static Map<String, PersonalRecord> getBestPRsByExercise(List<PersonalRecord> prs) {
    final bestPRs = <String, PersonalRecord>{};
    
    for (final pr in prs) {
      final currentBest = bestPRs[pr.exerciseId];
      if (currentBest == null || pr.isBetterThan(currentBest)) {
        bestPRs[pr.exerciseId] = pr;
      }
    }

    return bestPRs;
  }

  /// Calculate PR streak (consecutive workouts with new PRs)
  static int calculatePRStreak(List<PersonalRecord> prs) {
    if (prs.isEmpty) return 0;

    final sorted = getSortedPRs(prs);
    int streak = 1;
    
    // Check if PRs are on consecutive days
    for (int i = 1; i < sorted.length; i++) {
      final previousDate = sorted[i - 1].date;
      final currentDate = sorted[i].date;
      final daysBetween = currentDate.difference(previousDate).inDays;
      
      if (daysBetween == 1) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  /// Get PR statistics
  static Map<String, dynamic> getPRStatistics(List<PersonalRecord> prs) {
    if (prs.isEmpty) {
      return {
        'totalPRs': 0,
        'total1RMs': 0,
        'best1RM': null,
        'recentPRs': 0,
        'streak': 0,
      };
    }

    final sorted = getSortedPRs(prs);
    final last30Days = DateTime.now().subtract(const Duration(days: 30));
    final recentPRs = sorted.where((pr) => pr.date.isAfter(last30Days)).length;

    final oneRMs = sorted.where((pr) => pr.reps == 1).toList();
    final best1RM = oneRMs.isNotEmpty
        ? oneRMs.reduce((a, b) => a.weight > b.weight ? a : b)
        : null;

    return {
      'totalPRs': sorted.length,
      'total1RMs': oneRMs.length,
      'best1RM': best1RM?.weight,
      'best1RMExercise': best1RM?.exerciseName,
      'recentPRs': recentPRs,
      'streak': calculatePRStreak(sorted),
    };
  }

  /// Get PR progression over time for a specific exercise
  static List<Map<String, dynamic>> getExerciseProgression(
    List<PersonalRecord> prs,
    String exerciseId,
  ) {
    final exercisePRs = prs
        .where((pr) => pr.exerciseId == exerciseId)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return exercisePRs.map((pr) {
      return {
        'date': pr.date,
        'weight': pr.weight,
        'reps': pr.reps,
        'estimated1RM': pr.calculatedOneRepMax,
        'type': pr.type,
      };
    }).toList();
  }

  /// Get milestone achievements based on PRs
  static List<Map<String, dynamic>> getMilestones(List<PersonalRecord> prs) {
    final milestones = <Map<String, dynamic>>[];
    
    // Count PRs by exercise
    final prCountByExercise = <String, int>{};
    for (final pr in prs) {
      prCountByExercise[pr.exerciseId] = (prCountByExercise[pr.exerciseId] ?? 0) + 1;
    }

    // Check for milestones
    final totalPRs = prs.length;
    if (totalPRs >= 1) {
      milestones.add({
        'title': 'First PR',
        'description': 'Achieved your first personal record',
        'icon': '🏆',
        'achieved': true,
      });
    }

    if (totalPRs >= 5) {
      milestones.add({
        'title': '5 PRs',
        'description': 'Achieved 5 personal records',
        'icon': '⭐',
        'achieved': true,
      });
    }

    if (totalPRs >= 10) {
      milestones.add({
        'title': '10 PRs',
        'description': 'Achieved 10 personal records',
        'icon': '🌟',
        'achieved': true,
      });
    }

    // Check for 1RM milestones
    final oneRMs = prs.where((pr) => pr.reps == 1).length;
    if (oneRMs >= 1) {
      milestones.add({
        'title': 'First 1RM',
        'description': 'Lifted your first 1 rep max',
        'icon': '💪',
        'achieved': true,
      });
    }

    // Check for exercise variety
    final uniqueExercises = prCountByExercise.keys.length;
    if (uniqueExercises >= 3) {
      milestones.add({
        'title': 'Versatile Athlete',
        'description': 'Set PRs in 3 different exercises',
        'icon': '🏋️',
        'achieved': true,
      });
    }

    return milestones;
  }
}