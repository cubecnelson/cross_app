package com.cross.app

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.ImageFormat
import android.graphics.Rect
import android.graphics.YuvImage
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodCall
import java.io.ByteArrayOutputStream
import kotlin.math.roundToInt

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.cross.app/opencv_barbell"

    // Simple Lucas-Kanade-style bounding-box tracker using ARGB bitmap correlation.
    private var trackerBitmap: Bitmap? = null
    private var trackerBox: android.graphics.RectF? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result -> handleMethodCall(call, result) }
    }

    private fun handleMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {

            // ---------------------------------------------------------------- //
            //  Optical-flow bounding-box tracking                              //
            // ---------------------------------------------------------------- //

            "trackObject" -> {
                val frameData = call.argument<ByteArray>("frameData") ?: run {
                    result.success(null)
                    return
                }
                val width = call.argument<Int>("width") ?: run { result.success(null); return }
                val height = call.argument<Int>("height") ?: run { result.success(null); return }
                val bbox = call.argument<Map<String, Any>>("bbox") ?: run {
                    result.success(null)
                    return
                }

                val left = (bbox["left"] as? Number)?.toFloat() ?: 0f
                val top = (bbox["top"] as? Number)?.toFloat() ?: 0f
                val right = (bbox["right"] as? Number)?.toFloat() ?: 1f
                val bottom = (bbox["bottom"] as? Number)?.toFloat() ?: 1f

                val tracked = trackBoundingBox(
                    frameData, width, height,
                    android.graphics.RectF(left, top, right, bottom)
                )

                if (tracked != null) {
                    result.success(
                        mapOf(
                            "left" to tracked.left.toDouble(),
                            "top" to tracked.top.toDouble(),
                            "right" to tracked.right.toDouble(),
                            "bottom" to tracked.bottom.toDouble(),
                            "confidence" to 0.7,
                        )
                    )
                } else {
                    result.success(null)
                }
            }

            // ---------------------------------------------------------------- //
            //  OpenCV stub calls (kept for fallback / future OpenCV use)       //
            // ---------------------------------------------------------------- //

            "checkOpenCvAvailable" -> result.success(false)

            "initializeOpenCv" -> result.success(null)

            "processFrame" -> {
                result.success(mapOf("x" to 0.0, "y" to 0.0, "radius" to 0.0))
            }

            "analyzeForRep" -> {
                result.success(
                    mapOf(
                        "isRep" to false,
                        "avgVel" to 0.0,
                        "peakVel" to 0.0,
                        "displacement" to 0.0
                    )
                )
            }

            "setColorRange" -> result.success(null)

            "reset" -> {
                trackerBitmap = null
                trackerBox = null
                result.success(null)
            }

            "getVersion" -> result.success("Android bbox tracker (ML Kit stream mode + OpenCV stub)")

            else -> result.notImplemented()
        }
    }

    // ---- Bounding-box tracker ----

    /**
     * Track [prevBox] from the previously stored frame into the current [frameData].
     *
     * Strategy: template-matching using sum-of-absolute-differences (SAD) on the
     * Y (luminance) plane.  This is fast on-device without OpenCV or ML Kit, and
     * good enough for slow-moving barbells at 30 fps.
     *
     * Returns the updated normalised bounding box or null on failure.
     */
    private fun trackBoundingBox(
        frameData: ByteArray,
        width: Int,
        height: Int,
        prevBox: android.graphics.RectF,
    ): android.graphics.RectF? {
        val prevBitmap = trackerBitmap
        val prevBox2 = trackerBox

        // Convert current Y-plane to a grayscale bitmap for this frame.
        val currentBitmap = yPlaneToBitmap(frameData, width, height)
        trackerBitmap = currentBitmap

        if (prevBitmap == null || prevBox2 == null) {
            // First call – store box and return it unchanged.
            trackerBox = prevBox
            return prevBox
        }

        // Template: the patch inside prevBox from the previous frame.
        val pxLeft = (prevBox2.left * width).roundToInt().coerceIn(0, width - 1)
        val pxTop = (prevBox2.top * height).roundToInt().coerceIn(0, height - 1)
        val pxRight = (prevBox2.right * width).roundToInt().coerceIn(pxLeft + 1, width)
        val pxBottom = (prevBox2.bottom * height).roundToInt().coerceIn(pxTop + 1, height)

        val tmplW = pxRight - pxLeft
        val tmplH = pxBottom - pxTop
        if (tmplW <= 0 || tmplH <= 0) {
            trackerBox = prevBox
            return prevBox
        }

        // Search area: ±20% of frame around the previous box centre.
        val cx = (pxLeft + pxRight) / 2
        val cy = (pxTop + pxBottom) / 2
        val searchR = (width * 0.20).roundToInt()

        val searchLeft = (cx - searchR - tmplW / 2).coerceIn(0, width - tmplW)
        val searchTop = (cy - searchR - tmplH / 2).coerceIn(0, height - tmplH)
        val searchRight = (cx + searchR - tmplW / 2).coerceIn(0, width - tmplW)
        val searchBottom = (cy + searchR - tmplH / 2).coerceIn(0, height - tmplH)

        var bestSad = Long.MAX_VALUE
        var bestX = pxLeft
        var bestY = pxTop

        // SAD template matching on the Y plane.
        for (sy in searchTop..searchBottom step 2) {
            for (sx in searchLeft..searchRight step 2) {
                var sad = 0L
                for (row in 0 until tmplH step 2) {
                    for (col in 0 until tmplW step 2) {
                        val prevPx = prevBitmap.getPixel(pxLeft + col, pxTop + row) and 0xFF
                        val curPx = currentBitmap.getPixel(sx + col, sy + row) and 0xFF
                        sad += Math.abs(prevPx - curPx).toLong()
                    }
                }
                if (sad < bestSad) {
                    bestSad = sad
                    bestX = sx
                    bestY = sy
                }
            }
        }

        val newBox = android.graphics.RectF(
            bestX.toFloat() / width,
            bestY.toFloat() / height,
            (bestX + tmplW).toFloat() / width,
            (bestY + tmplH).toFloat() / height,
        )
        trackerBox = newBox
        return newBox
    }

    /** Convert raw Y-plane bytes to a grayscale ARGB_8888 [Bitmap]. */
    private fun yPlaneToBitmap(yPlane: ByteArray, width: Int, height: Int): Bitmap {
        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        val pixels = IntArray(width * height)
        val limit = minOf(yPlane.size, pixels.size)
        for (i in 0 until limit) {
            val y = yPlane[i].toInt() and 0xFF
            pixels[i] = 0xFF000000.toInt() or (y shl 16) or (y shl 8) or y
        }
        bitmap.setPixels(pixels, 0, width, 0, 0, width, height)
        return bitmap
    }
}
