import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/export_service.dart';
import './workout_provider.dart';

final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportService();
});

final exportStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final exportService = ref.watch(exportServiceProvider);
  final workoutsAsync = ref.watch(workoutsProvider);
  
  return workoutsAsync.when(
    data: (workouts) => exportService.getExportStats(workouts),
    loading: () => {
      'totalWorkouts': 0,
      'totalSets': 0,
      'totalVolume': '0.0',
      'dateRange': 'Loading...',
    },
    error: (error, stack) => {
      'totalWorkouts': 0,
      'totalSets': 0,
      'totalVolume': '0.0',
      'dateRange': 'Error loading data',
    },
  );
});