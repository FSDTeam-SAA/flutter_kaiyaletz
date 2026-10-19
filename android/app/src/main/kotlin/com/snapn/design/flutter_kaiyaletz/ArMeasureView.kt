package com.snapn.design

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.opengl.GLES11Ext
import android.opengl.GLES20
import android.opengl.GLSurfaceView
import android.opengl.Matrix
import android.os.Handler
import android.os.Looper
import android.view.View
import android.view.WindowManager
import android.widget.FrameLayout
import com.google.ar.core.Config
import com.google.ar.core.Coordinates2d
import com.google.ar.core.DepthPoint
import com.google.ar.core.Plane
import com.google.ar.core.Point
import com.google.ar.core.Session
import com.google.ar.core.TrackingState
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.FloatBuffer
import javax.microedition.khronos.egl.EGLConfig
import javax.microedition.khronos.opengles.GL10
import kotlin.math.sqrt

/** Creates one [ArMeasureView] per Flutter `AndroidView('kaiyaletz/ar_measure_view')`. */
class ArMeasureFactory(private val messenger: BinaryMessenger) :
    PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView =
        ArMeasureView(context, viewId, messenger)
}

/**
 * ARCore camera view. Mirrors the iOS view: raycasts from the screen center
 * each frame, pins points on request, and streams state back to Dart.
 *
 * Rendering: the camera image is drawn with a small GL shader, and the pinned
 * points are projected to 2D and drawn by [OverlayView] on top.
 */
class ArMeasureView(
    private val context: Context,
    viewId: Int,
    messenger: BinaryMessenger,
) : PlatformView, GLSurfaceView.Renderer, EventChannel.StreamHandler,
    MethodChannel.MethodCallHandler {

    private val main = Handler(Looper.getMainLooper())
    private val root = FrameLayout(context)
    private val glView = GLSurfaceView(context)
    private val overlay = OverlayView(context)
    private val commands = MethodChannel(messenger, "kaiyaletz/ar_measure_$viewId")
    private val events = EventChannel(messenger, "kaiyaletz/ar_measure_events_$viewId")
    private var sink: EventChannel.EventSink? = null

    private var session: Session? = null
    private var message: String? = null

    // Shared between the main thread (commands) and the GL thread (frames).
    private val lock = Any()
    private val points = mutableListOf<FloatArray>()
    @Volatile private var currentHit: FloatArray? = null
    private var lastEmit = 0L

    // GL state (GL thread only).
    private var textureId = 0
    private var program = 0
    private var width = 1
    private var height = 1
    private val quadCoords = floatBuffer(floatArrayOf(-1f, -1f, 1f, -1f, -1f, 1f, 1f, 1f))
    private val quadTexCoords = floatBuffer(FloatArray(8))
    private val viewM = FloatArray(16)
    private val projM = FloatArray(16)
    private val vpM = FloatArray(16)

    init {
        commands.setMethodCallHandler(this)
        events.setStreamHandler(this)

        glView.preserveEGLContextOnPause = true
        glView.setEGLContextClientVersion(2)
        glView.setEGLConfigChooser(8, 8, 8, 8, 16, 0)
        glView.setRenderer(this)
        glView.renderMode = GLSurfaceView.RENDERMODE_CONTINUOUSLY
        root.addView(glView)
        root.addView(overlay)

        try {
            val s = Session(context)
            val config = Config(s).apply {
                planeFindingMode = Config.PlaneFindingMode.HORIZONTAL_AND_VERTICAL
                updateMode = Config.UpdateMode.LATEST_CAMERA_IMAGE
                focusMode = Config.FocusMode.AUTO
                if (s.isDepthModeSupported(Config.DepthMode.AUTOMATIC)) {
                    depthMode = Config.DepthMode.AUTOMATIC
                }
            }
            s.configure(config)
            s.resume()
            session = s
            glView.onResume()
        } catch (e: Exception) {
            // Not installed, not supported, or camera busy/denied.
            message = "AR is not available: ${e.javaClass.simpleName}"
            main.post { emit() }
        }
    }

    override fun getView(): View = root

    override fun dispose() {
        glView.onPause()
        session?.close()
        session = null
        commands.setMethodCallHandler(null)
        events.setStreamHandler(null)
    }

    // region Commands

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "addPoint" -> currentHit?.let { synchronized(lock) { points.add(it) } }
            "undo" -> synchronized(lock) { if (points.isNotEmpty()) points.removeAt(points.size - 1) }
            "clear" -> synchronized(lock) { points.clear() }
            else -> return result.notImplemented()
        }
        emit()
        result.success(null)
    }

    // endregion

    // region Stream to Dart

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        sink = events
        emit()
    }

    override fun onCancel(arguments: Any?) {
        sink = null
    }

    /** Main thread. Same payload shape as the iOS view. */
    private fun emit() {
        val pts = synchronized(lock) { points.toList() }
        val hit = currentHit
        val payload = hashMapOf<String, Any>(
            "points" to pts.map { listOf(it[0].toDouble(), it[1].toDouble(), it[2].toDouble()) },
            "tracking" to (hit != null),
            "lidar" to false,
        )
        if (hit != null && pts.isNotEmpty()) payload["live"] = distance(pts.last(), hit)
        message?.let { payload["message"] = it }
        sink?.success(payload)
    }

    private fun distance(a: FloatArray, b: FloatArray): Double {
        val dx = b[0] - a[0]
        val dy = b[1] - a[1]
        val dz = b[2] - a[2]
        return sqrt((dx * dx + dy * dy + dz * dz).toDouble())
    }

    // endregion

    // region GL renderer

    override fun onSurfaceCreated(gl: GL10?, config: EGLConfig?) {
        GLES20.glClearColor(0f, 0f, 0f, 1f)
        val tex = IntArray(1)
        GLES20.glGenTextures(1, tex, 0)
        textureId = tex[0]
        GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, textureId)
        GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_LINEAR)
        GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR)
        program = buildProgram()
        session?.setCameraTextureName(textureId)
    }

    override fun onSurfaceChanged(gl: GL10?, w: Int, h: Int) {
        width = w
        height = h
        GLES20.glViewport(0, 0, w, h)
        @Suppress("DEPRECATION")
        val rotation = (context.getSystemService(Context.WINDOW_SERVICE) as WindowManager)
            .defaultDisplay.rotation
        session?.setDisplayGeometry(rotation, w, h)
    }

    override fun onDrawFrame(gl: GL10?) {
        GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT)
        val s = session ?: return
        val frame = try {
            s.update()
        } catch (e: Exception) {
            return
        }

        if (frame.hasDisplayGeometryChanged()) {
            quadCoords.rewind()
            quadTexCoords.rewind()
            frame.transformCoordinates2d(
                Coordinates2d.OPENGL_NORMALIZED_DEVICE_COORDINATES, quadCoords,
                Coordinates2d.TEXTURE_NORMALIZED, quadTexCoords,
            )
        }
        if (frame.timestamp != 0L) drawBackground()

        val camera = frame.camera
        if (camera.trackingState != TrackingState.TRACKING) {
            currentHit = null
            publish(emptyList(), null)
            return
        }

        // Raycast from the screen center.
        val hit = frame.hitTest(width / 2f, height / 2f).firstOrNull {
            val t = it.trackable
            (t is Plane && t.isPoseInPolygon(it.hitPose)) || t is DepthPoint || t is Point
        }
        currentHit = hit?.hitPose?.translation

        camera.getViewMatrix(viewM, 0)
        camera.getProjectionMatrix(projM, 0, 0.05f, 50f)
        Matrix.multiplyMM(vpM, 0, projM, 0, viewM, 0)

        val pts = synchronized(lock) { points.toList() }
        publish(pts.map { project(it) }, currentHit?.let { project(it) })
    }

    /** World point to pixel coordinates, or null when behind the camera. */
    private fun project(p: FloatArray): FloatArray? {
        val out = FloatArray(4)
        Matrix.multiplyMV(out, 0, vpM, 0, floatArrayOf(p[0], p[1], p[2], 1f), 0)
        if (out[3] <= 0f) return null
        val x = (out[0] / out[3] * 0.5f + 0.5f) * width
        val y = (1f - (out[1] / out[3] * 0.5f + 0.5f)) * height
        return floatArrayOf(x, y)
    }

    /** GL thread: redraw the overlay every frame, emit to Dart at ~15 Hz. */
    private fun publish(screenPoints: List<FloatArray?>, screenHit: FloatArray?) {
        main.post { overlay.update(screenPoints, screenHit) }
        val now = System.nanoTime()
        if (now - lastEmit > 66_000_000L) {
            lastEmit = now
            main.post { emit() }
        }
    }

    private fun drawBackground() {
        GLES20.glDisable(GLES20.GL_DEPTH_TEST)
        GLES20.glDepthMask(false)
        GLES20.glUseProgram(program)
        GLES20.glActiveTexture(GLES20.GL_TEXTURE0)
        GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, textureId)
        val pos = GLES20.glGetAttribLocation(program, "a_Position")
        val tex = GLES20.glGetAttribLocation(program, "a_TexCoord")
        quadCoords.rewind()
        quadTexCoords.rewind()
        GLES20.glVertexAttribPointer(pos, 2, GLES20.GL_FLOAT, false, 0, quadCoords)
        GLES20.glVertexAttribPointer(tex, 2, GLES20.GL_FLOAT, false, 0, quadTexCoords)
        GLES20.glEnableVertexAttribArray(pos)
        GLES20.glEnableVertexAttribArray(tex)
        GLES20.glDrawArrays(GLES20.GL_TRIANGLE_STRIP, 0, 4)
        GLES20.glDisableVertexAttribArray(pos)
        GLES20.glDisableVertexAttribArray(tex)
        GLES20.glDepthMask(true)
    }

    private fun buildProgram(): Int {
        val vs = compile(
            GLES20.GL_VERTEX_SHADER,
            """
            attribute vec4 a_Position;
            attribute vec2 a_TexCoord;
            varying vec2 v_TexCoord;
            void main() { gl_Position = a_Position; v_TexCoord = a_TexCoord; }
            """.trimIndent(),
        )
        val fs = compile(
            GLES20.GL_FRAGMENT_SHADER,
            """
            #extension GL_OES_EGL_image_external : require
            precision mediump float;
            varying vec2 v_TexCoord;
            uniform samplerExternalOES sTexture;
            void main() { gl_FragColor = texture2D(sTexture, v_TexCoord); }
            """.trimIndent(),
        )
        return GLES20.glCreateProgram().also {
            GLES20.glAttachShader(it, vs)
            GLES20.glAttachShader(it, fs)
            GLES20.glLinkProgram(it)
        }
    }

    private fun compile(type: Int, src: String): Int =
        GLES20.glCreateShader(type).also {
            GLES20.glShaderSource(it, src)
            GLES20.glCompileShader(it)
        }

    private fun floatBuffer(data: FloatArray): FloatBuffer =
        ByteBuffer.allocateDirect(data.size * 4).order(ByteOrder.nativeOrder())
            .asFloatBuffer().apply { put(data); position(0) }

    // endregion

    /** Draws pinned dots, lines between them, and a line to the crosshair. */
    private class OverlayView(context: Context) : View(context) {
        private var pts: List<FloatArray?> = emptyList()
        private var hit: FloatArray? = null

        private val line = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.WHITE
            strokeWidth = 5f
        }
        private val liveLine = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.argb(160, 255, 255, 255)
            strokeWidth = 3f
        }
        private val dot = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = Color.rgb(255, 149, 0) }

        fun update(points: List<FloatArray?>, hitPoint: FloatArray?) {
            pts = points
            hit = hitPoint
            invalidate()
        }

        override fun onDraw(canvas: Canvas) {
            for (i in 1 until pts.size) {
                val a = pts[i - 1]
                val b = pts[i]
                if (a != null && b != null) canvas.drawLine(a[0], a[1], b[0], b[1], line)
            }
            val last = pts.lastOrNull()
            val h = hit
            if (last != null && h != null) canvas.drawLine(last[0], last[1], h[0], h[1], liveLine)
            for (p in pts) if (p != null) canvas.drawCircle(p[0], p[1], 14f, dot)
        }
    }
}
