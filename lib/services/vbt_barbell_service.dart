import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;

// vector_math imported for potential future 3-D tracking; suppressed unused
// warning via the alias.
// ignore: unused_import
import 'package:vector_math/vector_math.dart' as vm;

// ---------------------------------------------------------------------------
// Movement state machine
// ---------------------------------------------------------------------------

/// Phases of a single barbell rep.
enum VbtState {
  /// No significant movement detected.
  idle,

  /// Barbell is moving downward (loading phase — squat descent, bench
  /// lowering, deadlift drop).
  eccentric,

  /// Barbell is moving upward (effort phase — the phase VBT cares about most).
  concentric,
}

// ---------------------------------------------------------------------------
// Velocity zone classification (based on force-velocity curve)
// ---------------------------------------------------------------------------

/// VBT velocity zones aligned to the force-velocity continuum.
enum VelocityZone {
  /// < 0.50 m/s — maximal strength zone.
  strength,

  /// 0.50–0.75 m/s — strength-speed zone.
  strengthSpeed,

  /// 0.75–1.00 m/s — speed-strength (power) zone.
  speedStrength,

  /// > 1.00 m/s — speed/ballistic zone.
  speed,
}

extension VelocityZoneX on VelocityZone {
  String get label {
    switch (this) {
      case VelocityZone.strength:
        return 'Strength';
      case VelocityZone.strengthSpeed:
        return 'Strength-Speed';
      case VelocityZone.speedStrength:
        return 'Speed-Strength';
      case VelocityZone.speed:
        return 'Speed';
    }
  }

  /// Classify a mean concentric velocity value into a zone.
  static VelocityZone fromVelocity(double v) {
    if (v < 0.50) return VelocityZone.strength;
    if (v < 0.75) return VelocityZone.strengthSpeed;
    if (v < 1.00) return VelocityZone.speedStrength;
    return VelocityZone.speed;
  }
}

// ---------------------------------------------------------------------------
// Data models
// ---------------------------------------------------------------------------

/// Result for a single completed rep.
class RepResult {
  /// Mean concentric velocity (MCV) in m/s.
  final double meanConcentricVelocity;
  final double peakVelocity; // m/s
  final double displacement; // mm
  final VelocityZone zone;
  final int repNumber;
  final DateTime timestamp;

  const RepResult({
    required this.meanConcentricVelocity,
    required this.peakVelocity,
    required this.displacement,
    required this.zone,
    required this.repNumber,
    required this.timestamp,
  });
}

/// Live barbell metrics emitted every frame while tracking.
class BarbellMetrics {
  final double averageVelocity; // m/s (current concentric phase or last rep)
  final double peakVelocity;    // m/s
  final double displacement;    // mm
  final double velocityLoss;    // percentage relative to first rep
  final int repCount;
  final bool shouldEndSet;
  final VbtState state;
  final VelocityZone zone;
  final List<RepResult> repHistory;
  final DateTime timestamp;

  const BarbellMetrics({
    required this.averageVelocity,
    required this.peakVelocity,
    required this.displacement,
    required this.velocityLoss,
    required this.repCount,
    required this.shouldEndSet,
    required this.state,
    required this.zone,
    required this.repHistory,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'BarbellMetrics('
        'state: ${state.name}, '
        'zone: ${zone.label}, '
        'avgVel: ${averageVelocity.toStringAsFixed(2)} m/s, '
        'peakVel: ${peakVelocity.toStringAsFixed(2)} m/s, '
        'disp: ${displacement.toStringAsFixed(0)} mm, '
        'loss: ${velocityLoss.toStringAsFixed(1)}%, '
        'reps: $repCount, '
        'endSet: $shouldEndSet)';
  }
}

// ---------------------------------------------------------------------------
// BarbellPosition — shared data class
// ---------------------------------------------------------------------------

/// Detected barbell centre position in pixel coordinates.
class BarbellPosition {
  final double x;      // pixels
  final double y;      // pixels
  final double radius; // pixels
  final DateTime timestamp;

  BarbellPosition({
    required this.x,
    required this.y,
    required this.radius,
    required this.timestamp,
  });

  double distanceTo(BarbellPosition other) =>
      sqrt(pow(x - other.x, 2) + pow(y - other.y, 2));
}

// ---------------------------------------------------------------------------
// VbtBarbellService — state-machine based VBT tracker
// ---------------------------------------------------------------------------

/// Velocity-Based Training barbell tracking service.
///
/// Implements a three-state movement machine (idle → eccentric → concentric)
/// so that Mean Concentric Velocity (MCV) is computed only during the upward
/// (effort) phase of each rep — the metric that correlates with training load
/// in VBT literature.
///
/// Detection falls back to HSV colour thresholding when the AI model is not
/// available. Inject [externalPositionStream] to drive the service from the
/// [AiBarbellDetectionService] instead of the built-in colour detector.
class VbtBarbellService {
  // ---- Constants ----
  static const double _defaultBarbellRadiusMm = 225.0; // Half of 45 cm plate
  static const double _velocityLossThreshold = 20.0;   // % before suggesting set end
  static const double _minMovementPxPerFrame = 2.0;    // Noise floor
  static const double _directionWindowSec = 0.15;      // Window to compute direction
  static const int _historyLimit = 500;

  // Color detection defaults (lime-green marker, HSV 0-180 scale)
  static const List<int> _defaultColorLower = [33, 46, 80];
  static const List<int> _defaultColorUpper = [86, 156, 255];

  // ---- State ----
  late CameraController _cameraController;
  bool _isAnalyzing = false;
  StreamController<BarbellMetrics>? _metricsStreamCtrl;

  // Position & velocity history for the entire set.
  final List<BarbellPosition> _setPositionHistory = [];

  // Per-phase (current rep) buffers.
  final List<BarbellPosition> _phasePositions = [];
  final List<double> _phaseVelocities = [];

  // Rep result list.
  final List<RepResult> _repHistory = [];

  // Current state-machine state.
  VbtState _state = VbtState.idle;

  // Calibration: mm per pixel, computed from detected radius.
  double _mmPerPixel = 0.0;
  double _barbellRadiusMm = _defaultBarbellRadiusMm;

  // Running metrics.
  double _currentAvgVelocity = 0.0;
  double _currentPeakVelocity = 0.0;
  double _currentDisplacement = 0.0;
  double _velocityLoss = 0.0;

  // Color range (overrideable).
  List<int> _colorLower = _defaultColorLower;
  List<int> _colorUpper = _defaultColorUpper;

  /// Optional external position stream from AI detection service.
  StreamSubscription<BarbellPosition>? _externalSub;

  VbtBarbellService(CameraController cameraController) {
    _cameraController = cameraController;
  }

  // ---- Public API ----

  int get repCount => _repHistory.length;
  VbtState get currentState => _state;
  List<RepResult> get repHistory => List.unmodifiable(_repHistory);
  List<BarbellPosition> get trajectoryHistory =>
      List.unmodifiable(_setPositionHistory);

  /// Start tracking using the internal colour detector.
  Stream<BarbellMetrics> startTracking({
    double barbellRadiusMm = _defaultBarbellRadiusMm,
    List<int>? colorLower,
    List<int>? colorUpper,
  }) {
    _barbellRadiusMm = barbellRadiusMm;
    _metricsStreamCtrl = StreamController<BarbellMetrics>.broadcast();
    _isAnalyzing = true;

    if (colorLower != null) _colorLower = colorLower;
    if (colorUpper != null) _colorUpper = colorUpper;

    _cameraController.startImageStream((CameraImage image) {
      if (!_isAnalyzing) return;
      try {
        final processed = _processCameraImage(image);
        if (processed == null) return;
        final position = _detectBarbell(processed);
        if (position == null) return;
        _ingestPosition(position);
        _metricsStreamCtrl?.add(_buildMetrics());
      } catch (_) {}
    });

    return _metricsStreamCtrl!.stream;
  }

  /// Start tracking using an external [BarbellPosition] stream (e.g. from
  /// [AiBarbellDetectionService]).
  Stream<BarbellMetrics> startTrackingExternal(
    Stream<BarbellPosition> positions, {
    double barbellRadiusMm = _defaultBarbellRadiusMm,
  }) {
    _barbellRadiusMm = barbellRadiusMm;
    _metricsStreamCtrl = StreamController<BarbellMetrics>.broadcast();
    _isAnalyzing = true;

    _externalSub = positions.listen((position) {
      if (!_isAnalyzing) return;
      _ingestPosition(position);
      _metricsStreamCtrl?.add(_buildMetrics());
    });

    return _metricsStreamCtrl!.stream;
  }

  void stopTracking() {
    _isAnalyzing = false;
    try {
      _cameraController.stopImageStream();
    } catch (_) {}
    _externalSub?.cancel();
    _externalSub = null;
    _metricsStreamCtrl?.close();
    _metricsStreamCtrl = null;
  }

  void reset() {
    _setPositionHistory.clear();
    _phasePositions.clear();
    _phaseVelocities.clear();
    _repHistory.clear();
    _state = VbtState.idle;
    _currentAvgVelocity = 0.0;
    _currentPeakVelocity = 0.0;
    _currentDisplacement = 0.0;
    _velocityLoss = 0.0;
  }

  void updateColorRange(List<int> lower, List<int> upper) {
    _colorLower = lower;
    _colorUpper = upper;
  }

  // ---- State machine ----

  void _ingestPosition(BarbellPosition position) {
    // Auto-calibrate mmPerPixel from detected radius when available.
    if (position.radius > 0) {
      _mmPerPixel = _barbellRadiusMm / position.radius;
    }

    _setPositionHistory.add(position);
    if (_setPositionHistory.length > _historyLimit) {
      _setPositionHistory.removeAt(0);
    }

    final double instantVel = _instantVelocity(position);
    final _Direction dir = _movementDirection();

    switch (_state) {
      case VbtState.idle:
        if (dir == _Direction.down) {
          _state = VbtState.eccentric;
          _phasePositions.clear();
          _phaseVelocities.clear();
        } else if (dir == _Direction.up) {
          _state = VbtState.concentric;
          _phasePositions.clear();
          _phaseVelocities.clear();
        }
        break;

      case VbtState.eccentric:
        _phasePositions.add(position);
        if (dir == _Direction.up) {
          _state = VbtState.concentric;
          _phasePositions.clear();
          _phaseVelocities.clear();
        }
        break;

      case VbtState.concentric:
        _phasePositions.add(position);
        if (instantVel > 0) _phaseVelocities.add(instantVel);
        if (dir == _Direction.idle || dir == _Direction.down) {
          _finaliseRep();
          _state = VbtState.idle;
        }
        break;
    }
  }

  _Direction _movementDirection() {
    if (_setPositionHistory.length < 2) return _Direction.idle;
    final now = _setPositionHistory.last.timestamp;
    final windowStart = now.subtract(
        Duration(milliseconds: (_directionWindowSec * 1000).toInt()));
    double totalDy = 0;
    int count = 0;
    for (int i = _setPositionHistory.length - 1; i > 0; i--) {
      final p = _setPositionHistory[i];
      if (p.timestamp.isBefore(windowStart)) break;
      final prev = _setPositionHistory[i - 1];
      totalDy += p.y - prev.y;
      count++;
    }
    if (count == 0) return _Direction.idle;
    final avgDy = totalDy / count;
    if (avgDy > _minMovementPxPerFrame) return _Direction.down;
    if (avgDy < -_minMovementPxPerFrame) return _Direction.up;
    return _Direction.idle;
  }

  double _instantVelocity(BarbellPosition current) {
    if (_setPositionHistory.length < 2) return 0.0;
    final prev = _setPositionHistory[_setPositionHistory.length - 2];
    final dtMs = current.timestamp.difference(prev.timestamp).inMilliseconds;
    if (dtMs <= 0) return 0.0;
    final pixelDist = current.distanceTo(prev);
    if (_mmPerPixel <= 0) return 0.0;
    return (pixelDist * _mmPerPixel) / 1000.0 / (dtMs / 1000.0);
  }

  void _finaliseRep() {
    if (_phaseVelocities.isEmpty) return;
    final mcv =
        _phaseVelocities.reduce((a, b) => a + b) / _phaseVelocities.length;
    final peak = _phaseVelocities.reduce(max);
    final disp = _phasePositions.length >= 2
        ? (_phasePositions.first.y - _phasePositions.last.y).abs() *
            (_mmPerPixel > 0 ? _mmPerPixel : 1.0)
        : 0.0;
    final rep = RepResult(
      meanConcentricVelocity: mcv,
      peakVelocity: peak,
      displacement: disp,
      zone: VelocityZoneX.fromVelocity(mcv),
      repNumber: _repHistory.length + 1,
      timestamp: DateTime.now(),
    );
    _repHistory.add(rep);
    _currentAvgVelocity = mcv;
    _currentPeakVelocity = peak;
    _currentDisplacement = disp;
    if (_repHistory.length > 1) {
      final firstMcv = _repHistory.first.meanConcentricVelocity;
      _velocityLoss = firstMcv > 0
          ? ((firstMcv - mcv) / firstMcv) * 100.0
          : 0.0;
    } else {
      _velocityLoss = 0.0;
    }
  }

  BarbellMetrics _buildMetrics() {
    return BarbellMetrics(
      averageVelocity: _currentAvgVelocity,
      peakVelocity: _currentPeakVelocity,
      displacement: _currentDisplacement,
      velocityLoss: _velocityLoss,
      repCount: _repHistory.length,
      shouldEndSet: _velocityLoss > _velocityLossThreshold,
      state: _state,
      zone: VelocityZoneX.fromVelocity(_currentAvgVelocity),
      repHistory: List.unmodifiable(_repHistory),
      timestamp: DateTime.now(),
    );
  }

  // ---- Colour-based detection (fallback) ----

  img.Image? _processCameraImage(CameraImage image) {
    try {
      if (image.format.group == ImageFormatGroup.yuv420) {
        return _yuv420ToImage(image);
      } else if (image.format.group == ImageFormatGroup.bgra8888) {
        return img.Image.fromBytes(
          width: image.width,
          height: image.height,
          bytes: image.planes[0].bytes.buffer,
          numChannels: 4,
        );
      }
    } catch (_) {}
    return null;
  }

  img.Image _yuv420ToImage(CameraImage image) {
    final out = img.Image(width: image.width, height: image.height);
    for (int row = 0; row < image.height; row++) {
      for (int col = 0; col < image.width; col++) {
        final yIdx = row * image.planes[0].bytesPerRow + col;
        final uvRow = row ~/ 2;
        final uvCol = col ~/ 2;
        final uvIdx = uvRow * image.planes[1].bytesPerRow + uvCol;
        final yVal = image.planes[0].bytes[yIdx];
        final uVal = image.planes[1].bytes[uvIdx];
        final vVal = image.planes[2].bytes[uvIdx];
        final r = (yVal + 1.402 * (vVal - 128)).clamp(0, 255).toInt();
        final g = (yVal - 0.344136 * (uVal - 128) - 0.714136 * (vVal - 128))
            .clamp(0, 255)
            .toInt();
        final b = (yVal + 1.772 * (uVal - 128)).clamp(0, 255).toInt();
        out.setPixelRgba(col, row, r, g, b, 255);
      }
    }
    return out;
  }

  BarbellPosition? _detectBarbell(img.Image image) {
    double totalX = 0, totalY = 0;
    int count = 0;
    double minX = image.width.toDouble(), maxX = 0;
    double minY = image.height.toDouble(), maxY = 0;

    for (int row = 0; row < image.height; row++) {
      for (int col = 0; col < image.width; col++) {
        final p = image.getPixel(col, row);
        final rN = p.r / 255.0, gN = p.g / 255.0, bN = p.b / 255.0;
        final maxC = max(rN, max(gN, bN));
        final minC = min(rN, min(gN, bN));
        final delta = maxC - minC;
        double h = 0, s = 0;
        if (delta != 0) {
          s = delta / maxC;
          if (maxC == rN) {
            h = 60 * (((gN - bN) / delta) % 6);
          } else if (maxC == gN) {
            h = 60 * (((bN - rN) / delta) + 2);
          } else {
            h = 60 * (((rN - gN) / delta) + 4);
          }
        }
        if (h < 0) h += 360;
        final hI = (h / 2).toInt();
        final sI = (s * 255).toInt();
        final vI = (maxC * 255).toInt();
        if (hI >= _colorLower[0] && hI <= _colorUpper[0] &&
            sI >= _colorLower[1] && sI <= _colorUpper[1] &&
            vI >= _colorLower[2] && vI <= _colorUpper[2]) {
          totalX += col;
          totalY += row;
          count++;
          if (col < minX) minX = col.toDouble();
          if (col > maxX) maxX = col.toDouble();
          if (row < minY) minY = row.toDouble();
          if (row > maxY) maxY = row.toDouble();
        }
      }
    }
    if (count == 0) return null;
    return BarbellPosition(
      x: totalX / count,
      y: totalY / count,
      radius: max(maxX - minX, maxY - minY) / 2,
      timestamp: DateTime.now(),
    );
  }
}

// Internal movement direction enum.
enum _Direction { up, down, idle }

// ---------------------------------------------------------------------------
// VbtCameraService — camera initialisation helper
// ---------------------------------------------------------------------------

class VbtCameraService {
  static Future<CameraController> initializeCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );
    return CameraController(camera, ResolutionPreset.medium, enableAudio: false);
  }
}
