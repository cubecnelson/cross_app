import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

/// Screenshot capture utility for integration tests
class ScreenshotCapture {
  /// Directory where screenshots will be saved
  final Directory outputDirectory;

  /// Creates a ScreenshotCapture instance
  ScreenshotCapture({required this.outputDirectory});

  /// Capture a screenshot from the current widget tester state
  Future<void> capture(WidgetTester tester, String screenshotName) async {
    try {
      // Check if screenshot capture is disabled (default: enabled for screenshot tests)
      final disabled = Platform.environment['CAPTURE_SCREENSHOTS'] == 'false' ||
          Platform.environment['DISABLE_SCREENSHOTS'] == 'true';
      
      if (disabled) {
        print('ℹ️ Screenshot capture disabled by DISABLE_SCREENSHOTS');
        return;
      }

      // Ensure output directory exists
      await outputDirectory.create(recursive: true);

      // Take screenshot
      final screenshotBytes = await tester.takeScreenshot();

      // Generate filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = '${screenshotName}_${timestamp}.png';
      final file = File(path.join(outputDirectory.path, filename));

      // Save screenshot
      await file.writeAsBytes(screenshotBytes);
      
      print('✅ Screenshot captured: $filename');
      print('   Saved to: ${file.path}');
    } catch (e) {
      print('❌ Failed to capture screenshot "$screenshotName": $e');
    }
  }

  /// Capture screenshots for multiple device sizes (simulated)
  Future<void> captureForMultipleSizes(
    WidgetTester tester,
    String screenshotName,
    List<DeviceSize> deviceSizes,
  ) async {
    for (final deviceSize in deviceSizes) {
      // Set viewport size (simulating different devices)
      tester.view.physicalSize = deviceSize.physicalSize;
      tester.view.devicePixelRatio = deviceSize.devicePixelRatio;
      await tester.pumpAndSettle();
      
      await capture(tester, '${screenshotName}_${deviceSize.name}');
    }
  }
}

/// Represents a device size for screenshot capture
class DeviceSize {
  final String name;
  final Size physicalSize;
  final double devicePixelRatio;

  const DeviceSize({
    required this.name,
    required this.physicalSize,
    required this.devicePixelRatio,
  });

  /// iPhone 14 Pro Max (6.7 inch)
  static const iphone14ProMax = DeviceSize(
    name: 'iphone_14_pro_max',
    physicalSize: Size(1290, 2796), // Points: 430 × 932
    devicePixelRatio: 3.0,
  );

  /// iPhone 14 (6.1 inch)
  static const iphone14 = DeviceSize(
    name: 'iphone_14',
    physicalSize: Size(1170, 2532), // Points: 390 × 844
    devicePixelRatio: 3.0,
  );

  /// iPhone 8 Plus (5.5 inch)
  static const iphone8Plus = DeviceSize(
    name: 'iphone_8_plus',
    physicalSize: Size(1242, 2208), // Points: 414 × 736
    devicePixelRatio: 3.0,
  );

  /// Common iPhone sizes for app store screenshots
  static const List<DeviceSize> appStoreIphoneSizes = [
    iphone14ProMax,
    iphone14,
    iphone8Plus,
  ];

  /// Generic phone size for testing
  static const genericPhone = DeviceSize(
    name: 'phone',
    physicalSize: Size(1080, 1920), // 1080p
    devicePixelRatio: 2.0,
  );
}

/// Extension on WidgetTester for easy screenshot capture
extension ScreenshotExtension on WidgetTester {
  /// Capture a screenshot with the given name
  Future<void> captureScreenshot(String name) async {
    final capture = ScreenshotCapture(
      outputDirectory: Directory('screenshots'),
    );
    await capture.capture(this, name);
  }
}