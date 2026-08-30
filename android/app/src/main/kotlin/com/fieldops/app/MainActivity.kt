package com.fieldops.app

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private var pendingStartVisitId: String? = null

    /// Foreground (While-In-Use) request first. Background location is a
    /// separate permission requested AFTER this one lands — on Android 11+
    /// requesting it in the same array is silently ignored.
    private val locationPermissionLauncher =
        registerForActivityResult(ActivityResultContracts.RequestMultiplePermissions()) { grants ->
            val fine = grants[Manifest.permission.ACCESS_FINE_LOCATION] == true
            val coarse = grants[Manifest.permission.ACCESS_COARSE_LOCATION] == true
            if (!fine && !coarse) {
                LocationEventBridge.emitStatus("permission_denied", "Location permission not granted.")
                return@registerForActivityResult
            }
            requestBackgroundPermissionAndStart()
        }

    /// Android 10+: "Allow all the time" upgrade flow. Denying it doesn't kill
    /// tracking — foreground ticks still flow; screen-locked ticks pause, and
    /// the user sees the [background_denied] guidance in the UI.
    private val backgroundPermissionLauncher =
        registerForActivityResult(ActivityResultContracts.RequestPermission()) { granted ->
            val visitId = pendingStartVisitId
            pendingStartVisitId = null
            if (!granted) {
                LocationEventBridge.emitStatus(
                    "background_denied",
                    "\"Allow all the time\" is required for screen-locked ticks. Tracking still runs in the foreground.",
                )
            }
            startTracking(visitId)
        }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger

        MethodChannel(messenger, "fieldops/location").setMethodCallHandler { call, result ->
            when (call.method) {
                "start" -> {
                    val visitId = call.argument<String>("visitId").orEmpty()
                    handleStart(visitId)
                    result.success(true)
                }
                "stop" -> {
                    stopTracking()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        EventChannel(messenger, "fieldops/location/events")
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    // The service outlives the Activity; the bridge keeps the sink.
                    LocationEventBridge.sink = events
                }

                override fun onCancel(arguments: Any?) {
                    LocationEventBridge.sink = null
                }
            })
    }

    private fun handleStart(visitId: String) {
        pendingStartVisitId = visitId
        val fine = ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) ==
            PackageManager.PERMISSION_GRANTED
        val coarse = ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) ==
            PackageManager.PERMISSION_GRANTED
        if (!fine && !coarse) {
            locationPermissionLauncher.launch(
                arrayOf(
                    Manifest.permission.ACCESS_FINE_LOCATION,
                    Manifest.permission.ACCESS_COARSE_LOCATION,
                ),
            )
            return
        }
        requestBackgroundPermissionAndStart()
    }

    private fun requestBackgroundPermissionAndStart() {
        val hasBackground = ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.ACCESS_BACKGROUND_LOCATION,
        ) == PackageManager.PERMISSION_GRANTED
        if (hasBackground || Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            startTracking(pendingStartVisitId)
            return
        }
        backgroundPermissionLauncher.launch(Manifest.permission.ACCESS_BACKGROUND_LOCATION)
    }

    private fun startTracking(visitId: String?) {
        val targetId = visitId ?: pendingStartVisitId.orEmpty()
        val intent = Intent(this, ForegroundLocationService::class.java)
            .putExtra(ForegroundLocationService.EXTRA_VISIT_ID, targetId)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
    }

    private fun stopTracking() {
        LocationEventBridge.emitStatus("stopped")
        stopService(Intent(this, ForegroundLocationService::class.java))
    }
}