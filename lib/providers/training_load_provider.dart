import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/training_load_service.dart';
import '../models/workout.dart';
import 'workout_provider.dart';

final trainingLoadProvider = Provider<TrainingLoadService>((ref) {
  return TrainingLoadService();
});

final weeklyTotalsProvider = Provider<Map<DateTime, double>>((ref) {
  final workouts = ref.watch(workoutNotifierProvider);
  return workouts.maybeWhen(
    data: (workoutsList) => TrainingLoadService.getWeeklyTotals(workoutsList, 4),
    orElse: () => {},
  );
});

final currentWeekAUProvider = Provider<double>((ref) {
  final workouts = ref.watch(workoutNotifierProvider);
  final today = DateTime.now();
  
  return workouts.maybeWhen(
    data: (workoutsList) => TrainingLoadService.calculateAcuteLoad(workoutsList, today),
    orElse: () => 0.0,
  );
});

final chronicLoadProvider = Provider<double>((ref) {
  final workouts = ref.watch(workoutNotifierProvider);
  final today = DateTime.now();
  
  return workouts.maybeWhen(
    data: (workoutsList) => TrainingLoadService.calculateChronicLoad(workoutsList, today),
    orElse: () => 0.0,
  );
});

final acwrProvider = Provider<double>((ref) {
  final acute = ref.watch(currentWeekAUProvider);
  final chronic = ref.watch(chronicLoadProvider);
  
  if (chronic == 0) return 0.0;
  return TrainingLoadService.calculateACWR(acute, chronic);
});

final preferredTargetProvider = Provider<double>((ref) {
  final chronic = ref.watch(chronicLoadProvider);
  return TrainingLoadService.calculatePreferredTarget(chronic);
});

final safeRangeProvider = Provider<Map<String, double>>((ref) {
  final chronic = ref.watch(chronicLoadProvider);
  return TrainingLoadService.getSafeRange(chronic);
});

final trainingStatusProvider = Provider<String>((ref) {
  final acwr = ref.watch(acwrProvider);
  return TrainingLoadService.determineTrainingStatus(acwr);
});

class TrainingLoadNotifier extends StateNotifier<TrainingLoadState> {
  final Ref _ref;
  
  TrainingLoadNotifier(this._ref) : super(TrainingLoadState.initial());

  void updateSRPE(double sRPE) {
    state = state.copyWith(sRPE: sRPE);
  }

  void reset() {
    state = TrainingLoadState.initial();
  }
}

class TrainingLoadState {
  final double? sRPE;
  final double acuteLoad;
  final double chronicLoad;
  final double acwr;
  final double preferredTarget;
  final Map<String, double> safeRange;
  final String trainingStatus;

  const TrainingLoadState({
    this.sRPE,
    required this.acuteLoad,
    required this.chronicLoad,
    required this.acwr,
    required this.preferredTarget,
    required this.safeRange,
    required this.trainingStatus,
  });

  factory TrainingLoadState.initial() {
    return TrainingLoadState(
      sRPE: null,
      acuteLoad: 0.0,
      chronicLoad: 0.0,
      acwr: 0.0,
      preferredTarget: 0.0,
      safeRange: {'lower': 0.0, 'upper': 0.0},
      trainingStatus: 'No data',
    );
  }

  TrainingLoadState copyWith({
    double? sRPE,
    double? acuteLoad,
    double? chronicLoad,
    double? acwr,
    double? preferredTarget,
    Map<String, double>? safeRange,
    String? trainingStatus,
  }) {
    return TrainingLoadState(
      sRPE: sRPE ?? this.sRPE,
      acuteLoad: acuteLoad ?? this.acuteLoad,
      chronicLoad: chronicLoad ?? this.chronicLoad,
      acwr: acwr ?? this.acwr,
      preferredTarget: preferredTarget ?? this.preferredTarget,
      safeRange: safeRange ?? this.safeRange,
      trainingStatus: trainingStatus ?? this.trainingStatus,
    );
  }
}

final trainingLoadNotifierProvider = StateNotifierProvider<TrainingLoadNotifier, TrainingLoadState>((ref) {
  return TrainingLoadNotifier(ref);
});