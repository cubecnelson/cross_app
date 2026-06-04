import Flutter
import UIKit
import Vision
// Note: OpenCV would be imported here when installed via Podfile
// import OpenCV

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {

  // Vision-based object tracker for optical flow between ML detections.
  private var vnRequest: VNTrackObjectRequest?
  private var lastObservation: VNDetectedObjectObservation?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController
    let openCvChannel = FlutterMethodChannel(
      name: "com.cross.app/opencv_barbell",
      binaryMessenger: controller.binaryMessenger
    )

    openCvChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall,
                                                       result: @escaping FlutterResult) in
      self?.handleMethodCall(call, result: result)
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {

    // ------------------------------------------------------------------ //
    //  Optical-flow tracking (Vision framework)                           //
    // ------------------------------------------------------------------ //

    case "trackObject":
      guard
        let args = call.arguments as? [String: Any],
        let frameData = args["frameData"] as? FlutterStandardTypedData,
        let width = args["width"] as? Int,
        let height = args["height"] as? Int,
        let bbox = args["bbox"] as? [String: Any],
        let left = bbox["left"] as? Double,
        let top = bbox["top"] as? Double,
        let right = bbox["right"] as? Double,
        let bottom = bbox["bottom"] as? Double
      else {
        result(FlutterError(code: "INVALID_ARGUMENTS",
                            message: "trackObject: missing arguments",
                            details: nil))
        return
      }

      trackObjectWithVision(
        frameData: frameData.data,
        width: width,
        height: height,
        normBbox: CGRect(x: left, y: top, width: right - left, height: bottom - top),
        result: result
      )

    // ------------------------------------------------------------------ //
    //  OpenCV stub calls (kept for fallback)                              //
    // ------------------------------------------------------------------ //

    case "checkOpenCvAvailable":
      result(false)

    case "initializeOpenCv":
      result(nil)

    case "processFrame":
      guard
        let args = call.arguments as? [String: Any],
        let _ = args["frameData"] as? FlutterStandardTypedData,
        let _ = args["width"] as? Int,
        let _ = args["height"] as? Int
      else {
        result(FlutterError(code: "INVALID_ARGUMENTS",
                            message: "Missing frame data",
                            details: nil))
        return
      }
      result(["x": 0.0, "y": 0.0, "radius": 0.0] as [String: Any])

    case "analyzeForRep":
      result([
        "isRep": false,
        "avgVel": 0.0,
        "peakVel": 0.0,
        "displacement": 0.0,
      ] as [String: Any])

    case "setColorRange":
      result(nil)

    case "reset":
      lastObservation = nil
      vnRequest = nil
      result(nil)

    case "getVersion":
      result("Vision optical-flow (iOS native), OpenCV stub")

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // ---- Vision optical flow ----

  /// Track a bounding box from the previous frame into the current frame
  /// using Apple's Vision framework `VNTrackObjectRequest`.
  ///
  /// - `normBbox`: normalised bounding box (0..1) from the previous frame.
  /// - Returns a map with updated normalised bounding box and confidence.
  private func trackObjectWithVision(
    frameData: Data,
    width: Int,
    height: Int,
    normBbox: CGRect,
    result: @escaping FlutterResult
  ) {
    // Build a CIImage from the raw Y-plane bytes (grayscale is sufficient for tracking).
    guard let ciImage = ciImageFromYPlane(frameData, width: width, height: height) else {
      result(nil)
      return
    }

    let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])

    // First call: create a new observation from the supplied bbox.
    if lastObservation == nil || vnRequest == nil {
      let observation = VNDetectedObjectObservation(
        boundingBox: CGRect(
          x: normBbox.minX,
          y: 1.0 - normBbox.maxY, // Vision uses bottom-left origin
          width: normBbox.width,
          height: normBbox.height
        )
      )
      lastObservation = observation
      vnRequest = VNTrackObjectRequest(detectedObjectObservation: observation)
      vnRequest?.trackingLevel = .accurate
    }

    guard let request = vnRequest, let observation = lastObservation else {
      result(nil)
      return
    }

    request.inputObservation = observation

    do {
      try handler.perform([request])
      guard let tracked = request.results?.first as? VNDetectedObjectObservation else {
        result(nil)
        return
      }

      lastObservation = tracked

      // Convert Vision bottom-left coordinates back to top-left.
      let trackedBox = tracked.boundingBox
      let topLeft = 1.0 - trackedBox.maxY
      let confidence = min(Double(tracked.confidence), 1.0)

      result([
        "left": Double(trackedBox.minX),
        "top": topLeft,
        "right": Double(trackedBox.maxX),
        "bottom": topLeft + Double(trackedBox.height),
        "confidence": confidence,
      ] as [String: Any])

    } catch {
      result(nil)
    }
  }

  /// Build a grayscale CIImage from a raw Y-plane byte buffer.
  private func ciImageFromYPlane(_ data: Data, width: Int, height: Int) -> CIImage? {
    let bytesPerRow = width
    guard data.count >= bytesPerRow * height else { return nil }
    return data.withUnsafeBytes { ptr -> CIImage? in
      guard let base = ptr.baseAddress else { return nil }
      let bitmap = CIImage(
        bitmapData: Data(bytes: base, count: bytesPerRow * height),
        bytesPerRow: bytesPerRow,
        size: CGSize(width: width, height: height),
        format: .L8,
        colorSpace: CGColorSpaceCreateDeviceGray()
      )
      return bitmap
    }
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
