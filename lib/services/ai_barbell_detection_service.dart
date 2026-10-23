import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:path_provider/path_provider.dart';
import 'vbt_barbell_service.dart';

/// Classification zones used by ML Kit label filtering.
const _barbellLabels = {
  'barbell', 'dumbbell', 'weight', 'gym equipment', 'sports equipment',
  'exercise equipment', 'fitness equipment',
};

/// Detection result from the AI model including confidence score.
class AiDetectionResult {
  final BarbellPosition position;
  final double confidence;
  final Rect boundingBox; // normalised 0..1

  const AiDetectionResult({
    required this.position,
    required this.confidence,
    required this.boundingBox,
  });
}

/// Normalised bounding box (values 0..1 relative to frame dimensions).
class Rect {
  final double left;
  final double top;
  final double right;
  final double bottom;

  const Rect({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  double get width => right - left;
  double get height => bottom - top;
  double get centerX => (left + right) / 2;
  double get centerY => (top + bottom) / 2;

  @override
  String toString() =>
      'Rect(l:${left.toStringAsFixed(3)}, t:${top.toStringAsFixed(3)}, '
      'r:${right.toStringAsFixed(3)}, b:${bottom.toStringAsFixed(3)})';
}

/// On-device AI barbell detection service backed by Google ML Kit object
/// detection.  Falls back gracefully if ML Kit is unavailable.
///
/// Usage:
/// ```dart
/// final service = AiBarbellDetectionService();
/// await service.initialize();
/// final result = await service.detectBarbell(cameraImage);
/// await service.dispose();
/// ```
class AiBarbellDetectionService {
  ObjectDetector? _detector;
  bool _isInitialized = false;

  // Optical-flow tracking via platform channel (iOS Vision / Android ML Kit
  // stream mode).  Falls back to full detection every frame when unavailable.
  static const _channel = MethodChannel('com.cross.app/opencv_barbell');

  // Confidence assigned to optical-flow results (native tracker gives no score).
  static const double _opticalFlowConfidence = 0.6;

  // Minimum confidence to accept a detection.
  static const double _minConfidence = 0.45;

  // Frames between full ML detections (optical flow fills the gap).
  static const int _detectionInterval = 3;
  int _frameCount = 0;
  AiDetectionResult? _lastDetection;

  /// Initialize the ML Kit object detector.
  ///
  /// When a custom `barbell_detector.tflite` is bundled in `assets/models/`,
  /// it is used; otherwise the default ML Kit model is used.
  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      final customModelPath = await _tryLoadCustomModel();
      final ObjectDetectorOptions options;
      if (customModelPath != null) {
        final modelPath = LocalObjectDetectorOptions(
          mode: DetectionMode.stream,
          modelPath: customModelPath,
          classifyObjects: true,
          multipleObjects: false,
        );
        options = modelPath;
      } else {
        options = ObjectDetectorOptions(
          mode: DetectionMode.stream,
          classifyObjects: true,
          multipleObjects: false,
        );
      }
      _detector = ObjectDetector(options: options);
      _isInitialized = true;
    } catch (e) {
      // Graceful degradation – service will return null detections.
      _isInitialized = false;
    }
  }

  /// Attempt to copy the bundled model to a temp directory where ML Kit can
  /// load it.  Returns the file path or null if the asset doesn't exist.
  Future<String?> _tryLoadCustomModel() async {
    try {
      final byteData =
          await rootBundle.load('assets/models/barbell_detector.tflite');
      final tmpDir = await getTemporaryDirectory();
      final file =
          File('${tmpDir.path}/barbell_detector.tflite');
      await file.writeAsBytes(byteData.buffer.asUint8List());
      return file.path;
    } catch (_) {
      return null;
    }
  }

  /// Detect the barbell in a [CameraImage] frame.
  ///
  /// Returns [AiDetectionResult] on success or null when:
  /// - Service not initialised
  /// - No relevant object detected with sufficient confidence
  Future<AiDetectionResult?> detectBarbell(
    CameraImage image, {
    InputImageRotation rotation = InputImageRotation.rotation0deg,
    double? knownDiameterPx,
  }) async {
    if (!_isInitialized || _detector == null) return null;

    _frameCount++;
    final runFullDetection = (_frameCount % _detectionInterval == 0) ||
        _lastDetection == null;

    if (!runFullDetection && _lastDetection != null) {
      // Delegate to optical-flow tracking between full detections.
      final tracked = await _trackWithOpticalFlow(
        image,
        _lastDetection!.boundingBox,
      );
      if (tracked != null) return tracked;
    }

    // Full ML detection.
    final inputImage = _buildInputImage(image, rotation);
    if (inputImage == null) return null;

    try {
      final detected = await _detector!.processImage(inputImage);
      final result = _bestDetection(detected, image.width, image.height);
      if (result != null) {
        _lastDetection = result;
      }
      return result;
    } catch (_) {
      return null;
    }
  }

  /// Convert [DetectedObject] list to the best matching [AiDetectionResult].
  AiDetectionResult? _bestDetection(
    List<DetectedObject> objects,
    int frameWidth,
    int frameHeight,
  ) {
    DetectedObject? best;
    double bestScore = _minConfidence;

    for (final obj in objects) {
      final score = _barbellScore(obj);
      if (score > bestScore) {
        bestScore = score;
        best = obj;
      }
    }

    if (best == null) return null;

    final box = best.boundingBox;
    final normLeft = box.left / frameWidth;
    final normTop = box.top / frameHeight;
    final normRight = box.right / frameWidth;
    final normBottom = box.bottom / frameHeight;

    final centerX = (box.left + box.right) / 2;
    final centerY = (box.top + box.bottom) / 2;
    final radius = (box.width > box.height ? box.width : box.height) / 2;

    return AiDetectionResult(
      position: BarbellPosition(
        x: centerX,
        y: centerY,
        radius: radius,
        timestamp: DateTime.now(),
      ),
      confidence: bestScore,
      boundingBox: Rect(
        left: normLeft,
        top: normTop,
        right: normRight,
        bottom: normBottom,
      ),
    );
  }

  /// Score for how likely an object is to be barbell-related.
  double _barbellScore(DetectedObject obj) {
    if (obj.labels.isEmpty) {
      // No labels means the default model couldn't classify; return low score.
      return _minConfidence;
    }
    double best = 0;
    for (final label in obj.labels) {
      final lower = label.text.toLowerCase();
      for (final kw in _barbellLabels) {
        if (lower.contains(kw)) {
          best = best > label.confidence ? best : label.confidence;
        }
      }
    }
    return best;
  }

  /// Convert [CameraImage] to ML Kit [InputImage].
  InputImage? _buildInputImage(CameraImage image, InputImageRotation rotation) {
    try {
      if (image.format.group == ImageFormatGroup.bgra8888) {
        // iOS.
        return InputImage.fromBytes(
          bytes: image.planes[0].bytes,
          metadata: InputImageMetadata(
            size: Size(image.width.toDouble(), image.height.toDouble()),
            rotation: rotation,
            format: InputImageFormat.bgra8888,
            bytesPerRow: image.planes[0].bytesPerRow,
          ),
        );
      } else if (image.format.group == ImageFormatGroup.yuv420) {
        // Android — convert to NV21.
        final nv21 = _yuv420ToNv21(image);
        return InputImage.fromBytes(
          bytes: nv21,
          metadata: InputImageMetadata(
            size: Size(image.width.toDouble(), image.height.toDouble()),
            rotation: rotation,
            format: InputImageFormat.nv21,
            bytesPerRow: image.width,
          ),
        );
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  /// Convert YUV420 planes to NV21 byte buffer for Android ML Kit.
  Uint8List _yuv420ToNv21(CameraImage image) {
    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];

    final ySize = yPlane.bytes.length;
    final uvSize = image.width * image.height ~/ 2;
    final nv21 = Uint8List(ySize + uvSize);

    // Copy Y plane.
    nv21.setRange(0, ySize, yPlane.bytes);

    // Interleave V and U for NV21.
    int uvIndex = ySize;
    final uvLen = uPlane.bytes.length;
    for (int i = 0; i < uvLen; i++) {
      nv21[uvIndex++] = vPlane.bytes[i];
      nv21[uvIndex++] = uPlane.bytes[i];
    }

    return nv21;
  }

  /// Delegate to the native optical-flow method channel to track the bounding
  /// box between full ML detections.
  Future<AiDetectionResult?> _trackWithOpticalFlow(
    CameraImage image,
    Rect lastBox,
  ) async {
    try {
      // Flatten the first plane for the channel.
      final frameBytes = image.planes[0].bytes;
      final result = await _channel.invokeMethod<Map?>('trackObject', {
        'frameData': frameBytes,
        'width': image.width,
        'height': image.height,
        'bbox': {
          'left': lastBox.left,
          'top': lastBox.top,
          'right': lastBox.right,
          'bottom': lastBox.bottom,
        },
      });
      if (result == null) return null;

      final left = (result['left'] as num).toDouble();
      final top = (result['top'] as num).toDouble();
      final right = (result['right'] as num).toDouble();
      final bottom = (result['bottom'] as num).toDouble();
      final confidence = (result['confidence'] as num?)?.toDouble() ?? _opticalFlowConfidence;

      final centerX = ((left + right) / 2) * image.width;
      final centerY = ((top + bottom) / 2) * image.height;
      final radius =
          (((right - left) * image.width) + ((bottom - top) * image.height)) /
              4;

      final tracked = AiDetectionResult(
        position: BarbellPosition(
          x: centerX,
          y: centerY,
          radius: radius,
          timestamp: DateTime.now(),
        ),
        confidence: confidence,
        boundingBox: Rect(
          left: left,
          top: top,
          right: right,
          bottom: bottom,
        ),
      );
      _lastDetection = tracked;
      return tracked;
    } catch (_) {
      return null;
    }
  }

  /// Reset the detector's tracking state (call between sets).
  Future<void> reset() async {
    _frameCount = 0;
    _lastDetection = null;
    try {
      await _channel.invokeMethod('reset');
    } catch (_) {}
  }

  /// Release ML Kit resources.
  Future<void> dispose() async {
    await _detector?.close();
    _detector = null;
    _isInitialized = false;
  }

  bool get isInitialized => _isInitialized;
}
