import 'dart:math';

import '../models/workout_set.dart';

/// Service for barbell-specific calculations and utilities
class BarbellService {
  // static const double _defaultBarWeightKg = 20.0; // Standard Olympic barbell
  // static const double _defaultBarWeightLb = 45.0; // Standard Olympic barbell

  /// Available plate sizes in kg (Olympic standard)
  static const List<double> kgPlates = [25.0, 20.0, 15.0, 10.0, 5.0, 2.5, 1.25, 1.0, 0.5];

  /// Available plate sizes in lb (Olympic standard)
  static const List<double> lbPlates = [45.0, 35.0, 25.0, 10.0, 5.0, 2.5];

  /// Calculate plates needed for a target weight
  /// Returns list of plates per side (not total)
  static List<double> calculatePlates({
    required double targetWeight,
    double barWeight = 20.0,
    List<double> availablePlates = const [25.0, 20.0, 15.0, 10.0, 5.0, 2.5, 1.25],
    bool includeBarWeight = true,
  }) {
    if (targetWeight <= 0) return [];

    double weightToLoad = targetWeight;
    if (includeBarWeight) {
      weightToLoad -= barWeight;
    }

    // Weight per side
    double weightPerSide = weightToLoad / 2;

    if (weightPerSide <= 0) {
      return [];
    }

    // Sort plates in descending order
    List<double> sortedPlates = List.from(availablePlates)..sort((a, b) => b.compareTo(a));
    List<double> platesPerSide = [];
    double remainingWeight = weightPerSide;

    for (double plate in sortedPlates) {
      while (remainingWeight >= plate - 0.01) { // Account for floating point errors
        platesPerSide.add(plate);
        remainingWeight -= plate;
      }
    }

    // If we can't make exact weight with available plates, return empty
    if (remainingWeight > 0.1) { // Allow small tolerance
      return [];
    }

    return platesPerSide;
  }

  /// Calculate total weight from plates
  static double calculateTotalWeight({
    required List<double> platesPerSide,
    double barWeight = 20.0,
  }) {
    double totalWeight = barWeight;
    for (double plate in platesPerSide) {
      totalWeight += plate * 2; // Both sides
    }
    return totalWeight;
  }

  /// Calculate warm-up sets based on working weight
  /// Returns list of warm-up sets with weights and reps
  static List<Map<String, dynamic>> generateWarmupSets({
    required double workingWeight,
    required int workingReps,
    double barWeight = 20.0,
    List<double> warmupPercentages = const [0.4, 0.6, 0.8],
    List<int> warmupReps = const [8, 5, 3],
  }) {
    if (warmupPercentages.length != warmupReps.length) {
      throw ArgumentError('warmupPercentages and warmupReps must have same length');
    }

    List<Map<String, dynamic>> warmupSets = [];

    for (int i = 0; i < warmupPercentages.length; i++) {
      double percentage = warmupPercentages[i];
      int reps = warmupReps[i];
      double weight = (workingWeight * percentage).roundToNearest(2.5);

      // Ensure weight is at least bar weight
      weight = max(weight, barWeight);

      warmupSets.add({
        'setNumber': i + 1,
        'weight': weight,
        'reps': reps,
        'percentage': percentage,
        'platesPerSide': calculatePlates(
          targetWeight: weight,
          barWeight: barWeight,
          availablePlates: kgPlates,
          includeBarWeight: true,
        ),
      });
    }

    return warmupSets;
  }

  /// Calculate estimated one-rep max using various formulas
  static Map<String, double> calculateOneRepMax({
    required double weight,
    required int reps,
  }) {
    if (reps < 1 || weight <= 0) {
      return {};
    }

    return {
      'epley': _epleyFormula(weight, reps),
      'brzycki': _brzyckiFormula(weight, reps),
      'lombardi': _lombardiFormula(weight, reps),
      'oconner': _oconnerFormula(weight, reps),
      'wathan': _wathanFormula(weight, reps),
      'average': _averageOneRepMax(weight, reps),
    };
  }

  /// Calculate training volume (tonnage)
  static double calculateVolume(List<WorkoutSet> sets) {
    return sets.fold(0.0, (total, set) {
      if (set.weight != null && set.reps != null) {
        return total + (set.weight! * set.reps!);
      }
      return total;
    });
  }

  /// Calculate intensity (% of estimated 1RM)
  static double calculateIntensity({
    required double weight,
    required int reps,
    required String formula,
  }) {
    final oneRepMax = calculateOneRepMax(weight: weight, reps: reps);
    final estimated1RM = oneRepMax[formula] ?? oneRepMax['average'] ?? weight;

    if (estimated1RM <= 0) return 0.0;
    return (weight / estimated1RM) * 100;
  }

  /// Suggest next weight based on performance
  static double suggestNextWeight({
    required double currentWeight,
    required int repsCompleted,
    required int targetReps,
    required double rpe, // Rate of Perceived Exertion (1-10)
    double increment = 2.5,
    double rpeThreshold = 8.0,
  }) {
    // If RPE is low (easy), increase weight
    if (rpe < rpeThreshold && repsCompleted >= targetReps) {
      return currentWeight + increment;
    }
    // If RPE is high and reps are below target, decrease or maintain
    else if (rpe > rpeThreshold && repsCompleted < targetReps) {
      return currentWeight - increment;
    }
    // Otherwise maintain current weight
    return currentWeight;
  }

  /// Convert kg to lb
  static double kgToLb(double kg) => kg * 2.20462;

  /// Convert lb to kg
  static double lbToKg(double lb) => lb / 2.20462;

  // Private helper methods for 1RM formulas

  static double _epleyFormula(double weight, int reps) {
    return weight * (1 + reps / 30);
  }

  static double _brzyckiFormula(double weight, int reps) {
    return weight * (36 / (37 - reps));
  }

  static double _lombardiFormula(double weight, int reps) {
    return weight * pow(reps, 0.1);
  }

  static double _oconnerFormula(double weight, int reps) {
    return weight * (1 + reps / 40);
  }

  static double _wathanFormula(double weight, int reps) {
    return weight * (100 / (48.8 + 53.8 * exp(-0.075 * reps)));
  }

  static double _averageOneRepMax(double weight, int reps) {
    final formulas = [
      _epleyFormula(weight, reps),
      _brzyckiFormula(weight, reps),
      _lombardiFormula(weight, reps),
      _oconnerFormula(weight, reps),
      _wathanFormula(weight, reps),
    ];
    return formulas.reduce((a, b) => a + b) / formulas.length;
  }
}

/// Extension for rounding weights to nearest plate increment
extension WeightRounding on double {
  double roundToNearest(double increment) {
    return (this / increment).roundToDouble() * increment;
  }
}