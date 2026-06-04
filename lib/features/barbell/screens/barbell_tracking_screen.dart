import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../services/vbt_barbell_service.dart';
import '../../../services/ai_barbell_detection_service.dart';

// ---------------------------------------------------------------------------
// Detection mode
// ---------------------------------------------------------------------------

enum _DetectionMode { ai, colorMarker }

// ---------------------------------------------------------------------------
// Painters
// ---------------------------------------------------------------------------

/// Draws the barbell trajectory path and a bounding box on the camera preview.
class _TrajectoryPainter extends CustomPainter {
  final List<BarbellPosition> positions;
  final AiDetectionResult? latestDetection;
  final Size frameSize; // actual camera frame dimensions

  const _TrajectoryPainter({
    required this.positions,
    required this.frameSize,
    this.latestDetection,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (positions.isEmpty) return;

    // Scale factors from camera frame pixels to widget pixels.
    final sx = size.width / frameSize.width;
    final sy = size.height / frameSize.height;

    // Draw trajectory path.
    final trailPaint = Paint()
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 1; i < positions.length; i++) {
      // Fade older points.
      final opacity = (i / positions.length).clamp(0.2, 1.0);
      trailPaint.color = Colors.cyanAccent.withOpacity(opacity);
      canvas.drawLine(
        Offset(positions[i - 1].x * sx, positions[i - 1].y * sy),
        Offset(positions[i].x * sx, positions[i].y * sy),
        trailPaint,
      );
    }

    // Draw current position circle.
    final last = positions.last;
    final centerPx = Offset(last.x * sx, last.y * sy);
    final radiusPx = last.radius > 0 ? last.radius * sx : 20.0;

    final circlePaint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(centerPx, radiusPx, circlePaint);

    // Draw AI bounding box if available.
    if (latestDetection != null) {
      final box = latestDetection!.boundingBox;
      final rect = Rect.fromLTRB(
        box.left * size.width,
        box.top * size.height,
        box.right * size.width,
        box.bottom * size.height,
      );
      final boxPaint = Paint()
        ..color = Colors.greenAccent.withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawRect(rect, boxPaint);

      // Confidence label.
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${(latestDetection!.confidence * 100).toStringAsFixed(0)}%',
          style: const TextStyle(
            color: Colors.greenAccent,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
          canvas, Offset(rect.left + 4, rect.top - 16));
    }
  }

  @override
  bool shouldRepaint(_TrajectoryPainter old) =>
      old.positions != positions || old.latestDetection != latestDetection;
}

/// Draws a semi-circular velocity gauge.
class _VelocityGaugePainter extends CustomPainter {
  final double velocity; // m/s
  final double maxVelocity;

  static const _zones = [
    (0.0, 0.50, Color(0xFF3949AB)),    // strength — indigo
    (0.50, 0.75, Color(0xFF00897B)),   // strength-speed — teal
    (0.75, 1.00, Color(0xFFF57F17)),   // speed-strength — amber
    (1.00, 2.00, Color(0xFFE53935)),   // speed — red
  ];

  const _VelocityGaugePainter({
    required this.velocity,
    this.maxVelocity = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.85;
    final r = min(size.width, size.height) * 0.8;
    const startAngle = pi;
    const sweepAngle = pi;

    // Background arc.
    final bgPaint = Paint()
      ..color = Colors.grey[850]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    // Zone arcs.
    for (final (lo, hi, color) in _zones) {
      final clampedHi = min(hi, maxVelocity);
      final clampedLo = max(lo, 0.0);
      final zoneStart = startAngle + (clampedLo / maxVelocity) * sweepAngle;
      final zoneSweep = ((clampedHi - clampedLo) / maxVelocity) * sweepAngle;
      final zonePaint = Paint()
        ..color = color.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        zoneStart,
        zoneSweep,
        false,
        zonePaint,
      );
    }

    // Filled velocity arc.
    final fraction = (velocity / maxVelocity).clamp(0.0, 1.0);
    if (fraction > 0) {
      final fillColor = _velocityColor(velocity);
      final fillPaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        startAngle,
        sweepAngle * fraction,
        false,
        fillPaint,
      );
    }

    // Needle.
    final needleAngle = startAngle + sweepAngle * fraction;
    final needleEnd = Offset(
      cx + r * cos(needleAngle),
      cy + r * sin(needleAngle),
    );
    final needlePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx, cy), needleEnd, needlePaint);

    // Centre dot.
    canvas.drawCircle(Offset(cx, cy), 4, Paint()..color = Colors.white);

    // Velocity label.
    final textPainter = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: velocity.toStringAsFixed(2),
            style: TextStyle(
              color: _velocityColor(velocity),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const TextSpan(
            text: ' m/s',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(cx - textPainter.width / 2, cy - textPainter.height - 8),
    );
  }

  Color _velocityColor(double v) {
    if (v < 0.50) return const Color(0xFF7986CB); // indigo[300]
    if (v < 0.75) return const Color(0xFF4DB6AC); // teal[300]
    if (v < 1.00) return const Color(0xFFFFB300); // amber
    return const Color(0xFFEF5350);               // red
  }

  @override
  bool shouldRepaint(_VelocityGaugePainter old) => old.velocity != velocity;
}

// ---------------------------------------------------------------------------
// Main Screen
// ---------------------------------------------------------------------------

/// Live barbell velocity tracking screen.
///
/// Supports two detection modes:
/// - **AI mode**: Uses ML Kit object detection (no marker required)
/// - **Colour marker mode**: Uses HSV colour thresholding (requires green marker)
class BarbellTrackingScreen extends StatefulWidget {
  final double? barbellRadiusMm;
  final Function(BarbellMetrics)? onMetricsUpdate;
  final VoidCallback? onTrackingComplete;

  const BarbellTrackingScreen({
    super.key,
    this.barbellRadiusMm,
    this.onMetricsUpdate,
    this.onTrackingComplete,
  });

  @override
  State<BarbellTrackingScreen> createState() => _BarbellTrackingScreenState();
}

class _BarbellTrackingScreenState extends State<BarbellTrackingScreen>
    with TickerProviderStateMixin {
  // Camera & services
  CameraController? _cameraController;
  VbtBarbellService? _vbtService;
  final AiBarbellDetectionService _aiService = AiBarbellDetectionService();
  StreamController<BarbellPosition>? _aiPositionCtrl;

  // Detection mode
  _DetectionMode _detectionMode = _DetectionMode.ai;
  bool _aiAvailable = false;

  // Tracking state
  StreamSubscription<BarbellMetrics>? _metricsSub;
  bool _isInitialized = false;
  bool _isTracking = false;
  String _status = 'Initialising camera…';

  // Live metrics
  BarbellMetrics? _currentMetrics;
  AiDetectionResult? _latestDetection;
  Size _frameSize = const Size(1, 1);

  // Per-rep chart data (rep index → MCV)
  final List<FlSpot> _repSpots = [];

  // Guards against AI frame-processing backlog.
  bool _isProcessingFrame = false;

  // Tracks rep count seen in the last onMetrics call for haptic feedback.
  int _lastRepCount = 0;

  // Animation for velocity gauge
  late AnimationController _gaugeAnimCtrl;
  late Animation<double> _gaugeAnim;
  double _displayedVelocity = 0.0;

  @override
  void initState() {
    super.initState();
    _gaugeAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _gaugeAnim = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _gaugeAnimCtrl, curve: Curves.easeOut),
    );
    _gaugeAnim.addListener(() {
      setState(() => _displayedVelocity = _gaugeAnim.value);
    });
    _initCamera();
  }

  @override
  void dispose() {
    _metricsSub?.cancel();
    _vbtService?.stopTracking();
    _cameraController?.dispose();
    _aiService.dispose();
    _aiPositionCtrl?.close();
    _gaugeAnimCtrl.dispose();
    super.dispose();
  }

  // ---- Initialisation ----

  Future<void> _initCamera() async {
    try {
      _cameraController = await VbtCameraService.initializeCamera();
      await _cameraController!.initialize();

      _frameSize = Size(
        _cameraController!.value.previewSize?.height ?? 1,
        _cameraController!.value.previewSize?.width ?? 1,
      );

      _vbtService = VbtBarbellService(_cameraController!);

      // Try to initialise AI service.
      await _aiService.initialize();
      _aiAvailable = _aiService.isInitialized;

      setState(() {
        _isInitialized = true;
        _status = 'Ready — ${_aiAvailable ? 'AI' : 'Colour marker'} mode';
        if (!_aiAvailable) _detectionMode = _DetectionMode.colorMarker;
      });
    } catch (e) {
      setState(() => _status = 'Camera init failed: $e');
    }
  }

  // ---- Tracking control ----

  void _startTracking() {
    if (!_isInitialized || _vbtService == null) return;
    setState(() {
      _isTracking = true;
      _status = 'Tracking…';
      _repSpots.clear();
    });

    Stream<BarbellMetrics> metricsStream;

    if (_detectionMode == _DetectionMode.ai && _aiAvailable) {
      _aiPositionCtrl =
          StreamController<BarbellPosition>.broadcast();
      metricsStream = _vbtService!.startTrackingExternal(
        _aiPositionCtrl!.stream,
        barbellRadiusMm: widget.barbellRadiusMm ?? 225.0,
      );
      // Drive the AI detection from camera frames.
      _cameraController!.startImageStream((CameraImage image) async {
        if (!_isTracking || _isProcessingFrame) return;
        _isProcessingFrame = true;
        try {
          final result = await _aiService.detectBarbell(image);
          if (result != null && mounted) {
            _aiPositionCtrl?.add(result.position);
            setState(() => _latestDetection = result);
          }
        } finally {
          _isProcessingFrame = false;
        }
      });
    } else {
      metricsStream = _vbtService!.startTracking(
        barbellRadiusMm: widget.barbellRadiusMm ?? 225.0,
      );
    }

    _metricsSub = metricsStream.listen(_onMetrics);
  }

  void _onMetrics(BarbellMetrics metrics) {
    if (!mounted) return;
    setState(() {
      _currentMetrics = metrics;
      if (metrics.shouldEndSet) {
        _status = '⚠️ Velocity loss ${metrics.velocityLoss.toStringAsFixed(1)}% — consider ending set';
      }
      // Update per-rep chart.
      if (metrics.repHistory.length > _repSpots.length) {
        final rep = metrics.repHistory.last;
        _repSpots.add(FlSpot(
          rep.repNumber.toDouble(),
          rep.meanConcentricVelocity,
        ));
      }
    });

    // Animate gauge.
    _gaugeAnim = Tween<double>(
      begin: _displayedVelocity,
      end: metrics.averageVelocity,
    ).animate(CurvedAnimation(parent: _gaugeAnimCtrl, curve: Curves.easeOut));
    _gaugeAnimCtrl
      ..reset()
      ..forward();

    // Haptic feedback on rep detection.
    if (metrics.repHistory.length > _lastRepCount) {
      _lastRepCount = metrics.repHistory.length;
      HapticFeedback.mediumImpact();
    }

    widget.onMetricsUpdate?.call(metrics);
  }

  void _stopTracking() {
    setState(() {
      _isTracking = false;
      _status = 'Stopped';
    });
    _metricsSub?.cancel();
    _metricsSub = null;
    _vbtService?.stopTracking();
    _aiPositionCtrl?.close();
    _aiPositionCtrl = null;
    _latestDetection = null;
  }

  void _resetTracking() {
    _stopTracking();
    _vbtService?.reset();
    _aiService.reset();
    setState(() {
      _currentMetrics = null;
      _repSpots.clear();
      _displayedVelocity = 0;
      _status = 'Ready';
    });
  }

  void _completeTracking() {
    _stopTracking();
    widget.onTrackingComplete?.call();
    Navigator.pop(context);
  }

  // ---- Build ----

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Velocity Tracking'),
        backgroundColor: Colors.black87,
        actions: [
          if (_aiAvailable)
            IconButton(
              icon: Icon(
                _detectionMode == _DetectionMode.ai
                    ? Icons.smart_toy
                    : Icons.colorize,
                color: _detectionMode == _DetectionMode.ai
                    ? Colors.cyanAccent
                    : Colors.white,
              ),
              tooltip: _detectionMode == _DetectionMode.ai
                  ? 'Switch to colour marker'
                  : 'Switch to AI detection',
              onPressed: _isTracking
                  ? null
                  : () => setState(() {
                        _detectionMode =
                            _detectionMode == _DetectionMode.ai
                                ? _DetectionMode.colorMarker
                                : _DetectionMode.ai;
                      }),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetTracking,
            tooltip: 'Reset',
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _completeTracking,
            tooltip: 'Done',
          ),
        ],
      ),
      body: Column(
        children: [
          // Camera + overlay (flex 5)
          Expanded(flex: 5, child: _buildCameraArea()),
          // Velocity gauge + state badge (flex 3)
          Expanded(flex: 3, child: _buildGaugeAndState()),
          // Per-rep chart (flex 3)
          Expanded(flex: 3, child: _buildRepChart()),
          // Metrics grid (flex 4)
          Expanded(flex: 4, child: _buildMetricsPanel()),
        ],
      ),
      floatingActionButton: _buildFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // ---- Camera area ----

  Widget _buildCameraArea() {
    if (!_isInitialized || _cameraController == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.cyanAccent),
            const SizedBox(height: 12),
            Text(_status, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      );
    }

    final trajectory = _vbtService?.trajectoryHistory ?? [];

    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreview(_cameraController!),
        // Trajectory & bounding box overlay.
        if (trajectory.isNotEmpty)
          CustomPaint(
            painter: _TrajectoryPainter(
              positions: trajectory,
              frameSize: _frameSize,
              latestDetection: _latestDetection,
            ),
          ),
        // LIVE badge.
        if (_isTracking)
          Positioned(
            top: 10,
            left: 10,
            child: _liveBadge(),
          ),
        // Detection mode badge.
        Positioned(
          top: 10,
          right: 10,
          child: _modeBadge(),
        ),
        // State machine badge.
        if (_currentMetrics != null)
          Positioned(
            bottom: 10,
            left: 10,
            child: _stateBadge(_currentMetrics!.state),
          ),
        // Instructions when idle.
        if (!_isTracking && trajectory.isEmpty)
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: _instructionsOverlay(),
          ),
      ],
    );
  }

  Widget _liveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.85),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Row(
        children: [
          Icon(Icons.circle, color: Colors.white, size: 8),
          SizedBox(width: 4),
          Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _modeBadge() {
    final isAi = _detectionMode == _DetectionMode.ai && _aiAvailable;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isAi
            ? Colors.cyanAccent.withOpacity(0.2)
            : Colors.greenAccent.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isAi ? Colors.cyanAccent : Colors.greenAccent,
          width: 1,
        ),
      ),
      child: Text(
        isAi ? '🤖 AI' : '🎯 Marker',
        style: TextStyle(
          color: isAi ? Colors.cyanAccent : Colors.greenAccent,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _stateBadge(VbtState state) {
    const labels = {
      VbtState.idle: ('IDLE', Colors.grey),
      VbtState.eccentric: ('↓ ECCENTRIC', Colors.orangeAccent),
      VbtState.concentric: ('↑ CONCENTRIC', Colors.greenAccent),
    };
    final (label, color) = labels[state]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _instructionsOverlay() {
    final isAi = _detectionMode == _DetectionMode.ai && _aiAvailable;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isAi
            ? '🤖 AI mode — no marker needed.\nPoint camera at the barbell and tap Start.'
            : '🎯 Colour mode — attach a lime-green marker to the barbell end,\nthen tap Start.',
        style: const TextStyle(color: Colors.white70, fontSize: 12),
      ),
    );
  }

  // ---- Gauge + state ----

  Widget _buildGaugeAndState() {
    return Container(
      color: Colors.grey[920] ?? const Color(0xFF111111),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          // Gauge
          Expanded(
            flex: 3,
            child: CustomPaint(
              painter: _VelocityGaugePainter(velocity: _displayedVelocity),
              size: const Size(double.infinity, double.infinity),
            ),
          ),
          // Zone + set status
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_currentMetrics != null) ...[
                  _zoneChip(_currentMetrics!.zone),
                  const SizedBox(height: 8),
                  _metricRow(
                    'Rep',
                    '${_currentMetrics!.repCount}',
                    Colors.white,
                  ),
                  _metricRow(
                    'V-Loss',
                    '${_currentMetrics!.velocityLoss.toStringAsFixed(1)}%',
                    _currentMetrics!.velocityLoss > 20
                        ? Colors.redAccent
                        : Colors.greenAccent,
                  ),
                ] else
                  Text(
                    _status,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _zoneChip(VelocityZone zone) {
    final colors = {
      VelocityZone.strength: Colors.indigo[300]!,
      VelocityZone.strengthSpeed: Colors.teal[300]!,
      VelocityZone.speedStrength: Colors.amber,
      VelocityZone.speed: Colors.redAccent,
    };
    final color = colors[zone]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        zone.label,
        style: TextStyle(
            color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _metricRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Text('$label: ',
              style: const TextStyle(color: Colors.white54, fontSize: 12)),
          Text(value,
              style: TextStyle(
                  color: valueColor,
                  fontSize: 13,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ---- Per-rep chart ----

  Widget _buildRepChart() {
    if (_repSpots.isEmpty) {
      return Container(
        color: Colors.grey[900],
        child: Center(
          child: Text(
            'Per-rep MCV will appear here',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ),
      );
    }

    final maxY = (_repSpots.map((s) => s.y).reduce(max) * 1.3).clamp(0.5, 3.0);

    return Container(
      color: Colors.grey[900],
      padding: const EdgeInsets.only(left: 8, right: 16, top: 8, bottom: 4),
      child: LineChart(
        LineChartData(
          minX: 1,
          maxX: max(_repSpots.length.toDouble(), 5),
          minY: 0,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            getDrawingHorizontalLine: (_) => FlLine(
              color: Colors.white10,
              strokeWidth: 1,
            ),
            drawVerticalLine: false,
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (v, _) => Text(
                  v.toStringAsFixed(1),
                  style: const TextStyle(color: Colors.white38, fontSize: 9),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) => Text(
                  'R${v.toInt()}',
                  style: const TextStyle(color: Colors.white38, fontSize: 9),
                ),
              ),
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: _repSpots,
              isCurved: true,
              color: Colors.cyanAccent,
              barWidth: 2,
              dotData: FlDotData(
                getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                  radius: 3,
                  color: Colors.cyanAccent,
                  strokeWidth: 0,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.cyanAccent.withOpacity(0.08),
              ),
            ),
            // 20% velocity-loss threshold line.
            if (_repSpots.isNotEmpty)
              LineChartBarData(
                spots: [
                  FlSpot(1, _repSpots.first.y * 0.8),
                  FlSpot(max(_repSpots.length.toDouble(), 5),
                      _repSpots.first.y * 0.8),
                ],
                isCurved: false,
                color: Colors.redAccent.withOpacity(0.5),
                barWidth: 1,
                dotData: const FlDotData(show: false),
                dashArray: [4, 4],
              ),
          ],
        ),
      ),
    );
  }

  // ---- Metrics panel ----

  Widget _buildMetricsPanel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: const Color(0xFF1A1A1A),
      child: _currentMetrics != null
          ? _buildMetricsGrid(_currentMetrics!)
          : Center(
              child: Icon(Icons.fitness_center,
                  size: 36, color: Colors.grey[700]),
            ),
    );
  }

  Widget _buildMetricsGrid(BarbellMetrics m) {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 2.8,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _metricCard(
          'Avg Velocity',
          '${m.averageVelocity.toStringAsFixed(2)} m/s',
          _velocityColor(m.averageVelocity),
        ),
        _metricCard(
          'Peak Velocity',
          '${m.peakVelocity.toStringAsFixed(2)} m/s',
          _velocityColor(m.peakVelocity),
        ),
        _metricCard(
          'Displacement',
          '${m.displacement.toStringAsFixed(0)} mm',
          Colors.lightBlue,
        ),
        _metricCard(
          'V-Loss',
          '${m.velocityLoss.toStringAsFixed(1)}%',
          m.velocityLoss > 20 ? Colors.redAccent : Colors.greenAccent,
        ),
      ],
    );
  }

  Widget _metricCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,
              style: const TextStyle(color: Colors.white54, fontSize: 11)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ---- FAB ----

  Widget _buildFab() {
    return FloatingActionButton.extended(
      onPressed: _isInitialized
          ? () => _isTracking ? _stopTracking() : _startTracking()
          : null,
      icon: Icon(_isTracking ? Icons.stop : Icons.play_arrow),
      label: Text(_isTracking ? 'Stop' : 'Start Tracking'),
      backgroundColor: _isTracking ? Colors.redAccent : Colors.cyanAccent,
      foregroundColor: Colors.black,
    );
  }

  // ---- Helpers ----

  Color _velocityColor(double v) {
    if (v > 1.0) return Colors.redAccent;
    if (v > 0.75) return Colors.amber;
    if (v > 0.50) return const Color(0xFF4DB6AC);
    return const Color(0xFF7986CB);
  }
}
