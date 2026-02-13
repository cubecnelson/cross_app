import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import '../models/workout.dart';
import '../models/workout_set.dart';

class ExportService {
  /// Export workouts to CSV format
  Future<void> exportWorkoutsToCSV(List<Workout> workouts) async {
    if (workouts.isEmpty) {
      throw Exception('No workouts to export');
    }

    try {
      // Create CSV content
      final csvContent = _createCSVContent(workouts);
      
      // Write to file
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final file = File('${directory.path}/workouts_$timestamp.csv');
      
      await file.writeAsString(csvContent, flush: true);
      
      // Share the file
      await Share.shareXFiles([XFile(file.path)],
          text: 'Exported ${workouts.length} workouts from Cross App');
      
      // Optionally delete after sharing (or keep for user)
      // await Future.delayed(Duration(seconds: 10));
      // await file.delete();
      
    } catch (e) {
      throw Exception('Failed to export CSV: $e');
    }
  }

  /// Create CSV content from workouts
  String _createCSVContent(List<Workout> workouts) {
    final csvBuffer = StringBuffer();
    
    // CSV Headers
    csvBuffer.writeln(
        'Date,Workout Name,Routine,Notes,Duration (min),Exercise Name,Set Number,'
        'Reps,Weight (kg),Rest Time (s),Distance (km),Duration (s),Pace (min/km),'
        'Heart Rate (bpm),Calories,Elevation Gain (m),RPE,Set Notes,Total Volume (kg)');
    
    for (final workout in workouts) {
      final workoutDate = DateFormat('yyyy-MM-dd').format(workout.date);
      final durationMin = workout.duration != null
          ? (workout.duration!.inMinutes).toStringAsFixed(1)
          : '';
      
      if (workout.sets.isEmpty) {
        // Write workout row without set details
        csvBuffer.writeln(
            '$workoutDate,${workout.routineName ?? "Custom Workout"},'
            '${workout.routineName ?? ""},'
            '${_escapeCSV(workout.notes ?? "")},$durationMin,'
            ',,0,,,,,,,,,,,,');
      } else {
        for (final set in workout.sets) {
          // Calculate set volume
          final volume = set.weight != null && set.reps != null
              ? (set.weight! * set.reps!).toStringAsFixed(1)
              : '';
          
          csvBuffer.writeln(
              '$workoutDate,${workout.routineName ?? "Custom Workout"},'
              '${workout.routineName ?? ""},'
              '${_escapeCSV(workout.notes ?? "")},$durationMin,'
              '${_escapeCSV(set.exerciseName)},${set.setNumber},'
              '${set.reps ?? ""},${set.weight ?? ""},${set.restTime ?? ""},'
              '${set.distance ?? ""},${set.duration ?? ""},${set.pace ?? ""},'
              '${set.heartRate ?? ""},${set.calories ?? ""},${set.elevationGain ?? ""},'
              '${set.rpe ?? ""},${_escapeCSV(set.notes ?? "")},$volume');
        }
      }
    }
    
    return csvBuffer.toString();
  }

  /// Export workout summary to PDF
  Future<void> exportWorkoutsToPDF(List<Workout> workouts) async {
    if (workouts.isEmpty) {
      throw Exception('No workouts to export');
    }

    // For now, create a simple text file as PDF placeholder
    // In a real implementation, use pdf or printing package
    try {
      final pdfContent = _createPDFContent(workouts);
      
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final file = File('${directory.path}/workouts_$timestamp.pdf');
      
      await file.writeAsString(pdfContent, flush: true);
      
      await Share.shareXFiles([XFile(file.path)],
          text: 'Exported ${workouts.length} workouts from Cross App (PDF)');
      
    } catch (e) {
      throw Exception('Failed to export PDF: $e');
    }
  }

  /// Create PDF content (placeholder - would use PDF library in real implementation)
  String _createPDFContent(List<Workout> workouts) {
    final buffer = StringBuffer();
    final dateFormat = DateFormat('yyyy-MM-dd');
    
    buffer.writeln('Cross Workout History');
    buffer.writeln('=====================');
    buffer.writeln('Generated: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}');
    buffer.writeln('Total Workouts: ${workouts.length}');
    buffer.writeln();
    
    for (final workout in workouts) {
      final workoutDate = dateFormat.format(workout.date);
      final duration = workout.duration != null
          ? '${workout.duration!.inMinutes} min'
          : 'N/A';
      
      buffer.writeln('Workout: ${workout.routineName ?? "Custom Workout"}');
      buffer.writeln('Date: $workoutDate');
      buffer.writeln('Duration: $duration');
      if (workout.notes != null && workout.notes!.isNotEmpty) {
        buffer.writeln('Notes: ${workout.notes}');
      }
      
      if (workout.sets.isNotEmpty) {
        buffer.writeln('Exercises:');
        
        // Group sets by exercise
        final exerciseGroups = <String, List<WorkoutSet>>{};
        for (final set in workout.sets) {
          exerciseGroups.putIfAbsent(set.exerciseName, () => []).add(set);
        }
        
        for (final entry in exerciseGroups.entries) {
          final exerciseName = entry.key;
          final sets = entry.value;
          
          buffer.writeln('  $exerciseName:');
          
          // Determine if it's strength or cardio based on first set
          final firstSet = sets.first;
          if (firstSet.isStrength) {
            buffer.writeln('    Sets:');
            for (final set in sets) {
              buffer.writeln(
                  '      Set ${set.setNumber}: ${set.reps ?? 0} reps × ${set.weight ?? 0.0} kg');
            }
          } else if (firstSet.isCardio) {
            buffer.writeln('    Cardio:');
            for (final set in sets) {
              if (set.distance != null) {
                buffer.writeln(
                    '      Set ${set.setNumber}: ${set.distance} km in ${set.duration}s');
              }
            }
          }
        }
        
        // Workout totals
        if (workout.totalVolume > 0) {
          buffer.writeln('  Total Volume: ${workout.totalVolume.toStringAsFixed(1)} kg');
        }
        buffer.writeln('  Total Sets: ${workout.totalSets}');
        buffer.writeln('  Total Reps: ${workout.totalReps}');
      }
      
      buffer.writeln();
      buffer.writeln('---');
      buffer.writeln();
    }
    
    // Summary statistics
    buffer.writeln('Summary Statistics');
    buffer.writeln('==================');
    
    final totalWorkouts = workouts.length;
    final totalSets = workouts.fold(0, (sum, workout) => sum + workout.totalSets);
    final totalVolume = workouts.fold(0.0, (sum, workout) => sum + workout.totalVolume);
    final totalReps = workouts.fold(0, (sum, workout) => sum + workout.totalReps);
    
    buffer.writeln('Total Workouts: $totalWorkouts');
    buffer.writeln('Total Sets: $totalSets');
    buffer.writeln('Total Reps: $totalReps');
    buffer.writeln('Total Volume: ${totalVolume.toStringAsFixed(1)} kg');
    
    if (workouts.isNotEmpty) {
      final firstWorkout = workouts.last; // Oldest
      final lastWorkout = workouts.first; // Newest
      final daysBetween = lastWorkout.date.difference(firstWorkout.date).inDays;
      
      if (daysBetween > 0) {
        buffer.writeln('Time Period: $daysBetween days');
        buffer.writeln('Workouts per Week: ${(totalWorkouts / (daysBetween / 7)).toStringAsFixed(1)}');
      }
    }
    
    return buffer.toString();
  }

  /// Export to both CSV and PDF (combined option)
  Future<void> exportWorkouts(List<Workout> workouts, {bool csv = true, bool pdf = false}) async {
    if (csv) {
      await exportWorkoutsToCSV(workouts);
    }
    if (pdf) {
      await exportWorkoutsToPDF(workouts);
    }
  }

  /// Escape CSV special characters
  String _escapeCSV(String text) {
    if (text.contains(',') || text.contains('"') || text.contains('\n')) {
      return '"${text.replaceAll('"', '""')}"';
    }
    return text;
  }

  /// Get workout statistics for display
  Map<String, dynamic> getExportStats(List<Workout> workouts) {
    if (workouts.isEmpty) {
      return {
        'totalWorkouts': 0,
        'totalSets': 0,
        'totalVolume': 0.0,
        'dateRange': 'No workouts',
      };
    }
    
    final totalWorkouts = workouts.length;
    final totalSets = workouts.fold(0, (sum, workout) => sum + workout.totalSets);
    final totalVolume = workouts.fold(0.0, (sum, workout) => sum + workout.totalVolume);
    
    final firstWorkout = workouts.last; // Oldest (list is sorted newest to oldest)
    final lastWorkout = workouts.first; // Newest
    final dateFormat = DateFormat('yyyy-MM-dd');
    
    String dateRange;
    if (firstWorkout.date.year == lastWorkout.date.year &&
        firstWorkout.date.month == lastWorkout.date.month) {
      dateRange = '${dateFormat.format(firstWorkout.date)} - ${lastWorkout.date.day}';
    } else {
      dateRange = '${dateFormat.format(firstWorkout.date)} - ${dateFormat.format(lastWorkout.date)}';
    }
    
    return {
      'totalWorkouts': totalWorkouts,
      'totalSets': totalSets,
      'totalVolume': totalVolume.toStringAsFixed(1),
      'dateRange': dateRange,
    };
  }
}