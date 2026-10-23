import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'vbt_barbell_service.dart';

/// OpenCV-based barbell tracking service using platform channels
/// This service delegates to native OpenCV implementations on iOS/Android
/// Falls back to Dart implementation if OpenCV is not available
class OpenCvBarbellService {
  static const String _channelName = 'com.cross.app/opencv_barbell';
  static const MethodChannel _channel = MethodChannel(_channelName);
  
  static bool _isOpenCvAvailable = false;
  static bool _initialized = false;
  
  /// Check if OpenCV is available on the platform
  static Future<bool> checkOpenCvAvailable() async {
    if (_initialized) return _isOpenCvAvailable;
    
    try {
      final result = await _channel.invokeMethod<bool>('checkOpenCvAvailable');
      _isOpenCvAvailable = result ?? false;
      _initialized = true;
      return _isOpenCvAvailable;
    } catch (e) {
      print('OpenCV check failed: $e');
      _isOpenCvAvailable = false;
      _initialized = true;
      return false;
    }
  }
  
  /// Initialize OpenCV with camera calibration data
  static Future<void> initializeOpenCv({
    required String calibrationDataJson,
    int imageWidth = 800,
    int imageHeight = 600,
  }) async {
    try {
      await _channel.invokeMethod('initializeOpenCv', {
        'calibrationData': calibrationDataJson,
        'imageWidth': imageWidth,
        'imageHeight': imageHeight,
      });
    } catch (e) {
      print('OpenCV initialization failed: $e');
      throw Exception('OpenCV initialization failed: $e');
    }
  }
  
  /// Process a camera frame with OpenCV
  /// Returns barbell position and metrics
  static Future<BarbellPosition?> processFrameWithOpenCv(
    Uint8List frameData,
    int width,
    int height,
    int format, // 0: NV21, 1: YUV420, 2: BGRA, etc.
    double barbellRadiusMm,
    List<int> colorLower,
    List<int> colorUpper,
  ) async {
    try {
      final result = await _channel.invokeMethod<Map?>('processFrame', {
        'frameData': frameData,
        'width': width,
        'height': height,
        'format': format,
        'barbellRadiusMm': barbellRadiusMm,
        'colorLower': colorLower,
        'colorUpper': colorUpper,
      });
      
      if (result == null) return null;
      
      return BarbellPosition(
        x: result['x']?.toDouble() ?? 0.0,
        y: result['y']?.toDouble() ?? 0.0,
        radius: result['radius']?.toDouble() ?? 0.0,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      print('OpenCV frame processing failed: $e');
      return null;
    }
  }
  
  /// Analyze movement history for a rep (OpenCV implementation)
  static Future<Map<String, dynamic>> analyzeForRepOpenCv(
    List<Map<String, dynamic>> history,
    int reps,
  ) async {
    try {
      final result = await _channel.invokeMethod<Map>('analyzeForRep', {
        'history': history,
        'reps': reps,
      });
      
      return Map<String, dynamic>.from(result ?? {
        'isRep': false,
        'avgVel': 0.0,
        'peakVel': 0.0,
        'displacement': 0.0,
      });
    } catch (e) {
      print('OpenCV rep analysis failed: $e');
      return {
        'isRep': false,
        'avgVel': 0.0,
        'peakVel': 0.0,
        'displacement': 0.0,
      };
    }
  }
  
  /// Set color detection range
  static Future<void> setColorRange(
    List<int> lower,
    List<int> upper,
  ) async {
    try {
      await _channel.invokeMethod('setColorRange', {
        'lower': lower,
        'upper': upper,
      });
    } catch (e) {
      print('OpenCV set color range failed: $e');
    }
  }
  
  /// Reset OpenCV tracking
  static Future<void> resetOpenCv() async {
    try {
      await _channel.invokeMethod('reset');
    } catch (e) {
      print('OpenCV reset failed: $e');
    }
  }
  
  /// Get OpenCV version info
  static Future<String> getOpenCvVersion() async {
    try {
      final version = await _channel.invokeMethod<String>('getVersion');
      return version ?? 'OpenCV not available';
    } catch (e) {
      return 'OpenCV check failed: $e';
    }
  }
}

/// Instructions for setting up OpenCV on each platform:
/// 
/// iOS Setup:
/// 1. Add OpenCV to Podfile: `pod 'OpenCV', '~> 4.5.0'`
/// 2. Create OpenCvBarbellPlugin.swift that implements method channel
/// 3. Register plugin in AppDelegate
/// 
/// Android Setup:
/// 1. Add OpenCV to build.gradle: `implementation 'org.opencv:opencv:4.5.0'`
/// 2. Create OpenCvBarbellPlugin.kt that implements method channel
/// 3. Register plugin in MainActivity
/// 
/// Native implementations should:
/// 1. Load OpenCV library
/// 2. Implement camera calibration (fisheye correction)
/// 3. Implement color-based barbell detection
/// 4. Implement rep detection algorithm from VBT-Barbell-Tracker
/// 
/// See: https://github.com/kostecky/VBT-Barbell-Tracker for reference algorithm