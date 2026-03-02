# OpenCV VBT Barbell Tracking Implementation Guide

## Overview

This document provides instructions for implementing the OpenCV-based Velocity-Based Training (VBT) barbell tracking system in the Cross app, based on the reference implementation from [VBT-Barbell-Tracker](https://github.com/kostecky/VBT-Barbell-Tracker).

## Current Status

✅ **Platform Architecture Implemented:**
- Method channel for Flutter ↔ Native communication
- iOS stub with OpenCV Pod dependency
- Android stub with OpenCV Gradle dependency
- Dart service layer with hybrid fallback

🔧 **OpenCV Algorithm Pending:**
- Native OpenCV implementation of barbell tracking algorithm
- Camera calibration and fisheye correction
- Color-based barbell detection
- Rep detection and velocity calculation

## Reference Implementation

The reference Python implementation (`vbt_barbell_tracker.py`) uses:

```python
# Key OpenCV functions used:
cv2.VideoCapture()          # Camera input
cv2.remap()                 # Fisheye correction
cv2.cvtColor()              # BGR to HSV conversion
cv2.inRange()               # Color thresholding
cv2.erode(), cv2.dilate()   # Morphological operations
cv2.findContours()          # Contour detection
cv2.minEnclosingCircle()    # Circle fitting
```

## Implementation Steps

### 1. iOS OpenCV Implementation

**File:** `ios/Runner/AppDelegate.swift` (or create separate plugin)

**Required:**
1. Import OpenCV: `import OpenCV`
2. Implement `processFrame` method with OpenCV algorithm
3. Add camera calibration support (fisheye correction)
4. Implement rep detection logic from Python code

**Key Functions to Implement:**

```swift
func processFrameWithOpenCV(frameData: Data, width: Int, height: Int) -> [String: Any] {
    // 1. Convert frame data to OpenCV Mat
    // 2. Apply fisheye correction using calibration data
    // 3. Convert to HSV color space
    // 4. Apply color thresholding (green by default)
    // 5. Apply morphological operations (erode/dilate)
    // 6. Find contours
    // 7. Get largest contour and min enclosing circle
    // 8. Calculate barbell position and radius
    // 9. Track across frames for velocity calculation
}
```

### 2. Android OpenCV Implementation

**File:** `android/app/src/main/kotlin/com/cross/app/MainActivity.kt`

**Required:**
1. Import OpenCV: `import org.opencv.*`
2. Implement `processFrame` with OpenCV algorithm
3. Load OpenCV library: `System.loadLibrary("opencv_java4")`
4. Implement same algorithm as iOS

**Key Functions to Implement:**

```kotlin
private fun processFrameOpenCV(
    frameData: ByteArray, 
    width: Int, 
    height: Int
): Map<String, Any> {
    // Same algorithm as iOS
    // Use OpenCV Java bindings
}
```

### 3. Algorithm Details

#### Camera Calibration
The reference implementation requires camera calibration to remove fisheye/barrel distortion:

1. Take 10+ images of chessboard pattern
2. Run calibration script to generate `fisheye_calibration_data.json`
3. Use calibration data in `cv2.fisheye` functions

#### Barbell Detection
1. **Color-based:** Detect lime green marker on barbell end (HSV: 33-86, 46-156, 80-255)
2. **Circle detection:** Use `cv2.minEnclosingCircle()` on largest contour
3. **Calibration:** Measure actual barbell diameter (default: 50mm) for pixel→mm conversion

#### Velocity Calculation
1. Track barbell position across frames
2. Calculate pixel distance between frames
3. Convert to mm using `mmPerPixel = barbellRadiusMm / detectedRadius`
4. Calculate velocity: `velocity = mmDistance / 1000 / timeBetweenFrames`

#### Rep Detection
Implement `analyze_for_rep()` function from Python code:

```python
def analyze_for_rep(history, reps):
    # 1. Determine movement direction from last X points
    # 2. Track displacement until inflection point
    # 3. Check for complete rep (concentric + eccentric phases)
    # 4. Calculate average and peak velocity for the rep
```

## Testing Setup

### 1. Hardware Requirements
- iOS or Android device with camera
- Barbell with lime green marker on end (50mm diameter circle)
- Good lighting conditions

### 2. Calibration Process
1. Print chessboard pattern from OpenCV
2. Take calibration images covering entire frame
3. Run calibration script (Python)
4. Save calibration data to app

### 3. Testing Procedure
1. Place phone on tripod facing barbell
2. Position barbell in camera view
3. Start tracking in app
4. Perform lifts
5. Verify velocity measurements match expectations

## Performance Considerations

### 1. Frame Rate
- Target: 30 FPS for accurate velocity calculation
- Adjust resolution for performance: 800×600 recommended

### 2. Processing Pipeline
```
Camera → Frame capture → Undistort → Resize → 
HSV conversion → Color mask → Erode/Dilate →
Contour detection → Circle fitting → 
Position tracking → Velocity calculation → 
Rep detection → Metrics output
```

### 3. Optimization
- Process frames on background thread
- Use lower resolution for detection
- Implement frame skipping if needed
- Cache calibration maps

## Integration with Existing Code

### 1. Service Architecture
```
BarbellTrackingScreen
    ↓
HybridBarbellService
    ├── OpenCvBarbellService (if OpenCV available)
    └── VbtBarbellService (Dart fallback)
```

### 2. Data Flow
```
Camera → [Native OpenCV] → BarbellPosition → 
[Dart Service] → BarbellMetrics → UI
```

### 3. Configuration
- Color range: Adjustable via UI
- Barbell radius: Configurable (default 25mm)
- Velocity thresholds: Configurable
- Calibration data: Load from file

## Troubleshooting

### Common Issues

1. **No barbell detected:**
   - Check lighting conditions
   - Adjust color range
   - Ensure marker is fully visible

2. **Inaccurate velocity:**
   - Verify camera calibration
   - Check actual barbell diameter measurement
   - Ensure stable frame rate

3. **Missed reps:**
   - Adjust rep detection thresholds
   - Check movement history size
   - Verify inflection point detection

### Debugging Tools
- Frame visualization overlay
- Detection mask display
- Position history graph
- Velocity chart

## Next Steps

### Phase 1: Basic OpenCV Integration
1. Implement `processFrame` on both platforms
2. Test barbell detection
3. Verify position tracking

### Phase 2: Full Algorithm
1. Implement rep detection
2. Add camera calibration
3. Integrate velocity calculation

### Phase 3: Optimization
1. Performance tuning
2. Memory optimization
3. Battery efficiency

## Resources

1. **OpenCV Documentation:** https://docs.opencv.org/
2. **Reference Python Code:** https://github.com/kostecky/VBT-Barbell-Tracker
3. **OpenCV iOS:** https://opencv.org/ios/
4. **OpenCV Android:** https://opencv.org/android/
5. **VBT Theory:** https://www.scienceforsport.com/velocity-based-training/

## Notes

- The Dart fallback implementation (`VbtBarbellService`) provides basic functionality but lacks OpenCV's accuracy
- For production use, complete the native OpenCV implementations
- Consider adding machine learning-based barbell detection in the future
- Test extensively with different lighting conditions and barbell types