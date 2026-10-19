package com.snapn.design

import android.Manifest
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.google.ar.core.ArCoreApk
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger

        flutterEngine.platformViewsController.registry
            .registerViewFactory("kaiyaletz/ar_measure_view", ArMeasureFactory(messenger))

        // Dart calls this before showing the AR view: camera permission, then
        // ARCore availability. Replies "ok", "denied", "install" or "unsupported".
        MethodChannel(messenger, "kaiyaletz/ar_prepare").setMethodCallHandler { call, result ->
            if (call.method != "prepare") return@setMethodCallHandler result.notImplemented()
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA)
                == PackageManager.PERMISSION_GRANTED
            ) {
                result.success(checkArCore())
            } else {
                pendingResult = result
                ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.CAMERA), 4711)
            }
        }
    }

    private fun checkArCore(): String =
        try {
            when (ArCoreApk.getInstance().requestInstall(this, true)) {
                ArCoreApk.InstallStatus.INSTALLED -> "ok"
                ArCoreApk.InstallStatus.INSTALL_REQUESTED -> "install"
            }
        } catch (e: Exception) {
            "unsupported"
        }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != 4711) return
        val granted = grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED
        pendingResult?.success(if (granted) checkArCore() else "denied")
        pendingResult = null
    }
}
