import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';
import '../services/vbt_barbell_service.dart';

/// VBT (Velocity-Based Training) session data persisted to Supabase.
class VbtSession {
  final String? id;
  final String userId;
  final String? workoutSetId;
  final String? exerciseName;
  final double loadKg;
  final List<VbtRepData> reps;
  final double firstRepMcv;
  final double bestRepMcv;
  final double velocityLossPct;
  final DateTime recordedAt;

  const VbtSession({
    this.id,
    required this.userId,
    this.workoutSetId,
    this.exerciseName,
    required this.loadKg,
    required this.reps,
    required this.firstRepMcv,
    required this.bestRepMcv,
    required this.velocityLossPct,
    required this.recordedAt,
  });

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'user_id': userId,
        if (workoutSetId != null) 'workout_set_id': workoutSetId,
        if (exerciseName != null) 'exercise_name': exerciseName,
        'load_kg': loadKg,
        'reps': reps.map((r) => r.toJson()).toList(),
        'first_rep_mcv': firstRepMcv,
        'best_rep_mcv': bestRepMcv,
        'velocity_loss_pct': velocityLossPct,
        'recorded_at': recordedAt.toIso8601String(),
      };

  factory VbtSession.fromJson(Map<String, dynamic> json) => VbtSession(
        id: json['id'] as String?,
        userId: json['user_id'] as String,
        workoutSetId: json['workout_set_id'] as String?,
        exerciseName: json['exercise_name'] as String?,
        loadKg: (json['load_kg'] as num).toDouble(),
        reps: (json['reps'] as List<dynamic>)
            .map((r) => VbtRepData.fromJson(r as Map<String, dynamic>))
            .toList(),
        firstRepMcv: (json['first_rep_mcv'] as num).toDouble(),
        bestRepMcv: (json['best_rep_mcv'] as num).toDouble(),
        velocityLossPct: (json['velocity_loss_pct'] as num).toDouble(),
        recordedAt: DateTime.parse(json['recorded_at'] as String),
      );

  /// Build a [VbtSession] from a list of [RepResult]s collected during a set.
  factory VbtSession.fromRepResults({
    required String userId,
    required List<RepResult> reps,
    required double loadKg,
    String? workoutSetId,
    String? exerciseName,
  }) {
    if (reps.isEmpty) {
      return VbtSession(
        userId: userId,
        workoutSetId: workoutSetId,
        exerciseName: exerciseName,
        loadKg: loadKg,
        reps: const [],
        firstRepMcv: 0,
        bestRepMcv: 0,
        velocityLossPct: 0,
        recordedAt: DateTime.now(),
      );
    }

    final mcvList = reps.map((r) => r.meanConcentricVelocity).toList();
    final firstMcv = mcvList.first;
    final bestMcv = mcvList.reduce((a, b) => a > b ? a : b);
    final velocityLoss = firstMcv > 0
        ? ((firstMcv - mcvList.last) / firstMcv) * 100.0
        : 0.0;

    return VbtSession(
      userId: userId,
      workoutSetId: workoutSetId,
      exerciseName: exerciseName,
      loadKg: loadKg,
      reps: reps
          .map((r) => VbtRepData(
                repNumber: r.repNumber,
                mcv: r.meanConcentricVelocity,
                peakVelocity: r.peakVelocity,
                displacementMm: r.displacement,
                zone: r.zone.name,
              ))
          .toList(),
      firstRepMcv: firstMcv,
      bestRepMcv: bestMcv,
      velocityLossPct: velocityLoss,
      recordedAt: DateTime.now(),
    );
  }
}

/// Per-rep velocity data stored inside a [VbtSession].
class VbtRepData {
  final int repNumber;
  final double mcv;             // mean concentric velocity (m/s)
  final double peakVelocity;   // m/s
  final double displacementMm; // mm
  final String zone;           // VelocityZone.name

  const VbtRepData({
    required this.repNumber,
    required this.mcv,
    required this.peakVelocity,
    required this.displacementMm,
    required this.zone,
  });

  Map<String, dynamic> toJson() => {
        'rep_number': repNumber,
        'mcv': mcv,
        'peak_velocity': peakVelocity,
        'displacement_mm': displacementMm,
        'zone': zone,
      };

  factory VbtRepData.fromJson(Map<String, dynamic> json) => VbtRepData(
        repNumber: json['rep_number'] as int,
        mcv: (json['mcv'] as num).toDouble(),
        peakVelocity: (json['peak_velocity'] as num).toDouble(),
        displacementMm: (json['displacement_mm'] as num).toDouble(),
        zone: json['zone'] as String,
      );
}

/// Repository for persisting VBT sessions to/from Supabase.
///
/// The `vbt_sessions` table schema (add via Supabase SQL editor):
/// ```sql
/// create table if not exists vbt_sessions (
///   id uuid primary key default gen_random_uuid(),
///   user_id uuid references auth.users not null,
///   workout_set_id uuid references workout_sets(id),
///   exercise_name text,
///   load_kg numeric not null default 0,
///   reps jsonb not null default '[]',
///   first_rep_mcv numeric not null default 0,
///   best_rep_mcv numeric not null default 0,
///   velocity_loss_pct numeric not null default 0,
///   recorded_at timestamptz not null default now()
/// );
/// alter table vbt_sessions enable row level security;
/// create policy "Users manage own vbt sessions"
///   on vbt_sessions for all using (auth.uid() = user_id);
/// ```
class VbtRepository {
  static const String _table = 'vbt_sessions';
  final SupabaseClient _client = SupabaseConfig.client;

  /// Save a [VbtSession] and return its generated ID.
  Future<String?> saveSession(VbtSession session) async {
    try {
      final response = await _client
          .from(_table)
          .insert(session.toJson())
          .select('id')
          .single();
      return response['id'] as String?;
    } catch (e) {
      throw Exception('Failed to save VBT session: $e');
    }
  }

  /// Fetch all VBT sessions for a user, newest first.
  Future<List<VbtSession>> getSessionsByUser(String userId) async {
    try {
      final response = await _client
          .from(_table)
          .select()
          .eq('user_id', userId)
          .order('recorded_at', ascending: false);
      return (response as List<dynamic>)
          .map((json) => VbtSession.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load VBT sessions: $e');
    }
  }

  /// Fetch VBT sessions for a specific exercise (for velocity-load profiling).
  Future<List<VbtSession>> getSessionsByExercise(
    String userId,
    String exerciseName,
  ) async {
    try {
      final response = await _client
          .from(_table)
          .select()
          .eq('user_id', userId)
          .eq('exercise_name', exerciseName)
          .order('recorded_at', ascending: false);
      return (response as List<dynamic>)
          .map((json) => VbtSession.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load VBT sessions for exercise: $e');
    }
  }

  /// Estimate 1RM from a velocity-load profile using the minimum velocity
  /// threshold (MVT) method.  Requires at least two data points.
  ///
  /// Returns estimated 1RM in kg, or null when insufficient data.
  double? estimateOneRepMax({
    required List<VbtSession> sessions,
    double mvt = 0.17, // Typical MVT for compound lifts (m/s)
  }) {
    if (sessions.length < 2) return null;

    // Extract (load, mcv) pairs for regression.
    final points = sessions
        .where((s) => s.firstRepMcv > 0 && s.loadKg > 0)
        .map((s) => (s.loadKg, s.firstRepMcv))
        .toList();

    if (points.length < 2) return null;

    // Simple linear regression: MCV = a + b * load
    final n = points.length.toDouble();
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
    for (final (x, y) in points) {
      sumX += x;
      sumY += y;
      sumXY += x * y;
      sumX2 += x * x;
    }
    final b = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    final a = (sumY - b * sumX) / n;

    // Extrapolate to MVT: load@MVT = (MVT - a) / b
    if (b >= 0) return null; // Regression must have negative slope
    return (mvt - a) / b;
  }
}
