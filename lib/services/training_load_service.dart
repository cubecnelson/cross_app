import '../models/workout.dart';

class TrainingLoadService {
  /// Calculate Arbitrary Units (AU) for a workout
  /// AU = sRPE (0-10) × Duration (minutes)
  static double calculateAU(Workout workout) {
    return workout.au;
  }

  /// Calculate daily AU total for a given day
  static double calculateDailyAU(List<Workout> workouts, DateTime date) {
    final dayWorkouts = workouts.where((w) => 
      w.date.year == date.year &&
      w.date.month == date.month &&
      w.date.day == date.day
    ).toList();
    
    return dayWorkouts.fold(0.0, (sum, workout) => sum + workout.au);
  }

  /// Calculate weekly acute load (sum of AU for last 7 days)
  static double calculateAcuteLoad(List<Workout> workouts, DateTime asOfDate) {
    final endDate = asOfDate;
    final startDate = endDate.subtract(const Duration(days: 6));
    
    double total = 0.0;
    DateTime currentDate = startDate;
    
    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      total += calculateDailyAU(workouts, currentDate);
      currentDate = currentDate.add(const Duration(days: 1));
    }
    
    return total;
  }

  /// Calculate chronic load (4-week rolling average)
  /// Chronic = (Week-4 AU + Week-3 AU + Week-2 AU + Week-1 AU) ÷ 4
  static double calculateChronicLoad(List<Workout> workouts, DateTime asOfDate) {
    final weekTotals = <double>[];
    
    for (int i = 1; i <= 4; i++) {
      final weekEndDate = asOfDate.subtract(Duration(days: 7 * (i - 1)));
      final weekStartDate = weekEndDate.subtract(const Duration(days: 6));
      
      double weekTotal = 0.0;
      DateTime currentDate = weekStartDate;
      
      while (currentDate.isBefore(weekEndDate) || currentDate.isAtSameMomentAs(weekEndDate)) {
        weekTotal += calculateDailyAU(workouts, currentDate);
        currentDate = currentDate.add(const Duration(days: 1));
      }
      
      weekTotals.add(weekTotal);
    }
    
    if (weekTotals.isEmpty) return 0.0;
    return weekTotals.reduce((a, b) => a + b) / weekTotals.length;
  }

  /// Calculate preferred weekly AU target
  /// Preferred Target = Chronic Load × k (where k = 1.05 for steady progression)
  static double calculatePreferredTarget(double chronicLoad, {double k = 1.05}) {
    return chronicLoad * k;
  }

  /// Calculate Acute:Chronic Workload Ratio (ACWR)
  /// ACWR = Acute Load ÷ Chronic Load
  static double calculateACWR(double acuteLoad, double chronicLoad) {
    if (chronicLoad == 0) return 0.0;
    return acuteLoad / chronicLoad;
  }

  /// Determine training status based on ACWR
  static String determineTrainingStatus(double acwr) {
    if (acwr < 0.8) {
      return 'Under-training';
    } else if (acwr > 1.3) {
      return 'Spike! Risk';
    } else {
      return 'Sweet Spot ✅';
    }
  }

  /// Get safe range for AU (sweet spot range)
  /// Lower bound: Chronic × 0.80, Upper bound: Chronic × 1.30
  static Map<String, double> getSafeRange(double chronicLoad) {
    return {
      'lower': chronicLoad * 0.80,
      'upper': chronicLoad * 1.30,
    };
  }

  /// Calculate weekly totals for the last n weeks
  static Map<DateTime, double> getWeeklyTotals(List<Workout> workouts, int weeks) {
    final result = <DateTime, double>{};
    final today = DateTime.now();
    
    for (int i = 0; i < weeks; i++) {
      final weekEndDate = today.subtract(Duration(days: 7 * i));
      final weekStartDate = weekEndDate.subtract(const Duration(days: 6));
      
      double weekTotal = 0.0;
      DateTime currentDate = weekStartDate;
      
      while (currentDate.isBefore(weekEndDate) || currentDate.isAtSameMomentAs(weekEndDate)) {
        weekTotal += calculateDailyAU(workouts, currentDate);
        currentDate = currentDate.add(const Duration(days: 1));
      }
      
      result[weekEndDate] = weekTotal;
    }
    
    return result;
  }

  /// Calculate exponentially weighted moving average (EWMA) for chronic load
  /// More sophisticated version that weights recent weeks more heavily
  static double calculateEWMAChronicLoad(List<Workout> workouts, DateTime asOfDate, {double alpha = 0.7}) {
    final weeklyTotals = getWeeklyTotals(workouts, 4);
    final weeks = weeklyTotals.values.toList();
    
    if (weeks.isEmpty) return 0.0;
    if (weeks.length == 1) return weeks.first;
    
    double ewma = weeks.first; // Start with oldest week
    
    for (int i = 1; i < weeks.length; i++) {
      ewma = alpha * weeks[i] + (1 - alpha) * ewma;
    }
    
    return ewma;
  }

  /// Get hybrid athlete weekly AU target ranges based on experience level
  static Map<String, List<double>> getHybridTargetRanges() {
    return {
      'Beginner': [1200.0, 2000.0],
      'Intermediate': [2000.0, 3500.0],
      'Advanced': [3500.0, 6000.0],
    };
  }
}