import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:vector_math/vector_math.dart';

/// Barbell metrics from VBT analysis
class BarbellMetrics {
  final double averageVelocity; // m/s
  final double peakVelocity;    // m/s
  final double displacement;    // mm
  final double velocityLoss;    // percentage
  final int repCount;
  final bool shouldEndSet;
  final DateTime timestamp;

  BarbellMetrics({
    required this.averageVelocity,
    required this.peakVelocity,
    required this.displacement,
    required this.velocityLoss,
    required this.repCount,
    required this.shouldEndSet,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'BarbellMetrics(avgVel: ${averageVelocity.toStringAsFixed(2)} m/s, peakVel: ${peakVelocity.toStringAsFixed(2)} m/s, disp: ${displacement.toStringAsFixed(0)} mm, loss: ${velocityLoss.toStringAsFixed(1)}%, reps: $repCount, endSet: $shouldEndSet)';
  }
}

/// Represents a detected barbell position
class BarbellPosition {
  final double x; // pixel position
  final double y; // pixel position
  final double radius; // in pixels
  final DateTime timestamp;

  BarbellPosition({
    required this.x,
    required this.y,
    required this.radius,
    required this.timestamp,
  });

  double distanceTo(BarbellPosition other) {
    return sqrt(pow(x - other.x, 2) + pow(y - other.y, 2));
  }
}

/// Service for Velocity-Based Training (VBT) barbell tracking
/// Uses computer vision to track barbell movement in real-time
class VbtBarbellService {
  static const double _defaultBarbellRadiusMm = 25.0; // Standard 50mm diameter
  static const double _velocityLossThreshold = 20.0; // Percentage
  static const double _minVelocityForRep = 0.1; // m/s
  static const double _restThresholdMs = 80.0;
  static const int _historySize = 10000;
  static const int _vectorThreshold = 8;
  
  late CameraController _cameraController;
  bool _isAnalyzing = false;
  StreamController<BarbellMetrics>? _metricsStream;
  final List<BarbellPosition> _positionHistory = [];
  final List<double> _velocityHistory = [];
  final List<double> _avgVelocities = [];
  final List<double> _peakVelocities = [];
  
  int _repCount = 0;
  double _firstVelocity = 0.0;
  double _currentAvgVelocity = 0.0;
  double _currentPeakVelocity = 0.0;
  double _currentDisplacement = 0.0;
  double _velocityLoss = 0.0;
  bool _shouldEndSet = false;
  
  /// Color range for detection (in HSV)
  /// Default: Lime green (for painted barbell end)
  static const List<int> _defaultColorLower = [33, 46, 80];   // HSV
  static const List<int> _defaultColorUpper = [86, 156, 255]; // HSV
  
  List<int> _colorLower = _defaultColorLower;
  List<int> _colorUpper = _defaultColorUpper;
  
  /// Initialize with camera controller
  VbtBarbellService(CameraController cameraController) {
    _cameraController = cameraController;
  }
  
  /// Start real-time barbell tracking
  Stream<BarbellMetrics> startTracking({
    double barbellRadiusMm = _defaultBarbellRadiusMm,
    List<int>? colorLower,
    List<int>? colorUpper,
  }) {
    _metricsStream = StreamController<BarbellMetrics>();
    _isAnalyzing = true;
    
    if (colorLower != null) _colorLower = colorLower;
    if (colorUpper != null) _colorUpper = colorUpper;
    
    // Start image stream analysis
    _cameraController.startImageStream((CameraImage image) {
      if (!_isAnalyzing) return;
      
      try {
        final metrics = _analyzeFrame(image, barbellRadiusMm);
        if (metrics != null) {
          _metricsStream?.add(metrics);
        }
      } catch (e) {
        print('Error analyzing frame: $e');
      }
    });
    
    return _metricsStream!.stream;
  }
  
  /// Stop tracking
  void stopTracking() {
    _isAnalyzing = false;
    _cameraController.stopImageStream();
    _metricsStream?.close();
    _metricsStream = null;
    _resetAnalysis();
  }
  
  /// Reset analysis state
  void reset() {
    _resetAnalysis();
  }
  
  /// Update color detection range
  void updateColorRange(List<int> lower, List<int> upper) {
    _colorLower = lower;
    _colorUpper = upper;
  }
  
  /// Analyze a single camera frame
  BarbellMetrics? _analyzeFrame(CameraImage image, double barbellRadiusMm) {
    // Convert CameraImage to processable format
    final img.Image? processedImage = _processCameraImage(image);
    if (processedImage == null) return null;
    
    // Detect barbell position
    final BarbellPosition? position = _detectBarbell(processedImage);
    if (position == null) return null;
    
    // Calculate velocity
    final double velocity = _calculateVelocity(position);
    
    // Update history
    _updateHistory(position, velocity);
    
    // Analyze for rep
    final bool isRep = _analyzeForRep();
    
    if (isRep) {
      _repCount++;
      _updateRepMetrics();
    }
    
    // Check if set should end
    _shouldEndSet = _velocityLoss > _velocityLossThreshold;
    
    return BarbellMetrics(
      averageVelocity: _currentAvgVelocity,
      peakVelocity: _currentPeakVelocity,
      displacement: _currentDisplacement,
      velocityLoss: _velocityLoss,
      repCount: _repCount,
      shouldEndSet: _shouldEndSet,
      timestamp: DateTime.now(),
    );
  }
  
  /// Convert CameraImage to img.Image for processing
  img.Image? _processCameraImage(CameraImage image) {
    try {
      if (image.format.group == ImageFormatGroup.yuv420) {
        // Convert YUV to RGB
        return _yuv420ToImage(image);
      } else if (image.format.group == ImageFormatGroup.bgra8888) {
        // Already BGRA
        return img.Image.fromBytes(
          width: image.width,
          height: image.height,
          bytes: image.planes[0].bytes.buffer,
          numChannels: 4,
        );
      }
    } catch (e) {
      print('Error processing image: $e');
    }
    return null;
  }
  
  /// Convert YUV420 to RGB image
  img.Image _yuv420ToImage(CameraImage image) {
    final img.Image rgbImage = img.Image(width: image.width, height: image.height);
    
    // Simplified YUV to RGB conversion
    // For production, use more accurate conversion
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final int yIndex = y * image.width + x;
        final int uvIndex = (y ~/ 2) * (image.width ~/ 2) + (x ~/ 2);
        
        final int yValue = image.planes[0].bytes[yIndex];
        final int uValue = image.planes[1].bytes[uvIndex];
        final int vValue = image.planes[2].bytes[uvIndex];
        
        // YUV to RGB conversion
        final int r = (yValue + 1.402 * (vValue - 128)).clamp(0, 255).toInt();
        final int g = (yValue - 0.344136 * (uValue - 128) - 0.714136 * (vValue - 128)).clamp(0, 255).toInt();
        final int b = (yValue + 1.772 * (uValue - 128)).clamp(0, 255).toInt();
        
        rgbImage.setPixelRgba(x, y, r, g, b, 255);
      }
    }
    
    return rgbImage;
  }
  
  /// Detect barbell position using color-based detection
  BarbellPosition? _detectBarbell(img.Image image) {
    // Convert to HSV for color detection
    final img.Image hsvImage = _rgbToHsv(image);
    
    // Create mask for target color range
    final img.Image mask = img.Image(width: image.width, height: image.height);
    
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final p = hsvImage.getPixel(x, y);
        final int h = p.r.toInt();
        final int s = p.g.toInt();
        final int v = p.b.toInt();
        
        if (h >= _colorLower[0] && h <= _colorUpper[0] &&
            s >= _colorLower[1] && s <= _colorUpper[1] &&
            v >= _colorLower[2] && v <= _colorUpper[2]) {
          mask.setPixelRgba(x, y, 255, 255, 255, 255);
        } else {
          mask.setPixelRgba(x, y, 0, 0, 0, 255);
        }
      }
    }
    
    // Find contours (simplified - find largest connected region)
    double totalX = 0;
    double totalY = 0;
    int pixelCount = 0;
    double minX = image.width.toDouble();
    double maxX = 0;
    double minY = image.height.toDouble();
    double maxY = 0;
    
    for (int y = 0; y < mask.height; y++) {
      for (int x = 0; x < mask.width; x++) {
        if (mask.getPixel(x, y).r > 0) {
          totalX += x;
          totalY += y;
          pixelCount++;
          minX = min(minX, x.toDouble());
          maxX = max(maxX, x.toDouble());
          minY = min(minY, y.toDouble());
          maxY = max(maxY, y.toDouble());
        }
      }
    }
    
    if (pixelCount == 0) return null;
    
    final double centerX = totalX / pixelCount;
    final double centerY = totalY / pixelCount;
    final double radius = max(maxX - minX, maxY - minY) / 2;
    
    return BarbellPosition(
      x: centerX,
      y: centerY,
      radius: radius,
      timestamp: DateTime.now(),
    );
  }
  
  /// Convert RGB image to HSV
  img.Image _rgbToHsv(img.Image image) {
    final img.Image hsvImage = img.Image(width: image.width, height: image.height);
    
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final p = image.getPixel(x, y);
        final int r = p.r.toInt();
        final int g = p.g.toInt();
        final int b = p.b.toInt();
        
        // RGB to HSV conversion
        final double rNorm = r / 255.0;
        final double gNorm = g / 255.0;
        final double bNorm = b / 255.0;
        
        final double maxVal = max(rNorm, max(gNorm, bNorm));
        final double minVal = min(rNorm, min(gNorm, bNorm));
        final double delta = maxVal - minVal;
        
        double h = 0;
        double s = 0;
        double v = maxVal;
        
        if (delta != 0) {
          s = delta / maxVal;
          
          if (maxVal == rNorm) {
            h = 60 * (((gNorm - bNorm) / delta) % 6);
          } else if (maxVal == gNorm) {
            h = 60 * (((bNorm - rNorm) / delta) + 2);
          } else {
            h = 60 * (((rNorm - gNorm) / delta) + 4);
          }
        }
        
        if (h < 0) h += 360;
        
        final int hInt = (h / 2).toInt(); // Scale to 0-180 for OpenCV compatibility
        final int sInt = (s * 255).toInt();
        final int vInt = (v * 255).toInt();
        
        hsvImage.setPixelRgba(x, y, hInt, sInt, vInt, 255);
      }
    }
    
    return hsvImage;
  }
  
  /// Calculate velocity from position history
  double _calculateVelocity(BarbellPosition currentPosition) {
    if (_positionHistory.isEmpty) return 0.0;
    
    final BarbellPosition lastPosition = _positionHistory.last;
    final double timeDiff = currentPosition.timestamp.difference(lastPosition.timestamp).inMilliseconds / 1000.0;
    if (timeDiff == 0) return 0.0;
    
    // Calculate pixel distance
    final double pixelDistance = currentPosition.distanceTo(lastPosition);
    
    // Convert to mm using barbell radius as reference
    // Assuming barbell end is circular and we know its actual size
    final double mmPerPixel = _defaultBarbellRadiusMm / currentPosition.radius;
    final double mmDistance = pixelDistance * mmPerPixel;
    
    // Convert to m/s
    final double velocity = mmDistance / 1000 / timeDiff;
    
    return velocity;
  }
  
  /// Update position and velocity history
  void _updateHistory(BarbellPosition position, double velocity) {
    _positionHistory.add(position);
    _velocityHistory.add(velocity);
    
    // Limit history size
    if (_positionHistory.length > _historySize) {
      _positionHistory.removeAt(0);
      _velocityHistory.removeAt(0);
    }
  }
  
  /// Analyze movement history to detect a rep
  bool _analyzeForRep() {
    if (_positionHistory.length < 2 * _vectorThreshold) {
      return false;
    }
    
    // Simplified rep detection logic
    // In production, implement full logic from Python code
    
    // Check for significant vertical movement
    double totalYDisp = 0;
    for (int i = 1; i <= min(_vectorThreshold, _positionHistory.length); i++) {
      final BarbellPosition pos1 = _positionHistory[_positionHistory.length - i];
      final BarbellPosition pos2 = _positionHistory[_positionHistory.length - i - 1];
      totalYDisp += (pos2.y - pos1.y).abs();
    }
    
    // If significant vertical movement and velocity > threshold
    final double avgVelocity = _velocityHistory.isNotEmpty
        ? _velocityHistory.reduce((a, b) => a + b) / _velocityHistory.length
        : 0.0;
    
    return totalYDisp > 50 && avgVelocity > _minVelocityForRep;
  }
  
  /// Update metrics after a detected rep
  void _updateRepMetrics() {
    if (_velocityHistory.isEmpty) return;
    
    // Calculate average and peak velocity for the rep
    double sumVelocity = 0;
    double peakVelocity = 0;
    
    for (final velocity in _velocityHistory) {
      sumVelocity += velocity;
      if (velocity > peakVelocity) {
        peakVelocity = velocity;
      }
    }
    
    final double avgVelocity = sumVelocity / _velocityHistory.length;
    
    // Store velocities
    _avgVelocities.add(avgVelocity);
    _peakVelocities.add(peakVelocity);
    
    // Update current metrics
    _currentAvgVelocity = avgVelocity;
    _currentPeakVelocity = peakVelocity;
    
    // Calculate displacement (simplified)
    if (_positionHistory.length >= 2) {
      final double firstY = _positionHistory.first.y;
      final double lastY = _positionHistory.last.y;
      final double mmPerPixel = _defaultBarbellRadiusMm / _positionHistory.last.radius;
      _currentDisplacement = (lastY - firstY).abs() * mmPerPixel;
    }
    
    // Calculate velocity loss
    if (_avgVelocities.length > 1) {
      _firstVelocity = _avgVelocities.first;
      final double currentVelocity = _avgVelocities.last;
      _velocityLoss = ((_firstVelocity - currentVelocity) / _firstVelocity) * 100;
    } else if (_avgVelocities.length == 1) {
      _firstVelocity = _avgVelocities.first;
      _velocityLoss = 0.0;
    }
    
    // Clear history for next rep
    _positionHistory.clear();
    _velocityHistory.clear();
  }
  
  /// Reset analysis state
  void _resetAnalysis() {
    _positionHistory.clear();
    _velocityHistory.clear();
    _avgVelocities.clear();
    _peakVelocities.clear();
    _repCount = 0;
    _firstVelocity = 0.0;
    _currentAvgVelocity = 0.0;
    _currentPeakVelocity = 0.0;
    _currentDisplacement = 0.0;
    _velocityLoss = 0.0;
    _shouldEndSet = false;
  }
}

/// Helper service for camera setup and VBT tracking
class VbtCameraService {
  static Future<CameraController> initializeCamera() async {
    final cameras = await availableCameras();
    final CameraDescription camera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );
    
    return CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );
  }
  
  static Future<void> startVbtTracking({
    required CameraController cameraController,
    required Function(BarbellMetrics) onMetricsUpdate,
    double barbellRadiusMm = 25.0,
  }) async {
    await cameraController.initialize();
    
    final vbtService = VbtBarbellService(cameraController);
    final metricsStream = vbtService.startTracking(
      barbellRadiusMm: barbellRadiusMm,
    );
    
    metricsStream.listen(onMetricsUpdate);
  }
}