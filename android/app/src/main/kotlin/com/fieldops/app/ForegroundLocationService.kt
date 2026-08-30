package com.fieldops.app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.os.Build
import android.os.Bundle
import android.os.IBinder
import android.os.Looper

/// Foreground service that captures the raw GPS trail while the app is
/// backgrounded or the screen is locked. The service lifecycle, persistent
/// notification, and permission handling are our code; the position fix comes
/// from the framework's LocationManager — the master plan's allowed shape for
/// the raw tick.
///
/// Per memory.md: ticks are pushed through the platform channel and persisted
/// to `LocationPoints` in Dart — this service NEVER touches
/// `JobVisits.gpsUpdatedAt`, so background ticks can't pollute a merge.
class ForegroundLocationService : Service(), LocationListener {

    companion object {
        private const val CHANNEL_ID = "fieldops_location"
        private const val NOTIFICATION_ID = 2001
        const val EXTRA_VISIT_ID = "visitId"

        private const val UPDATE_INTERVAL_MS = 5000L
        private const val UPDATE_DISTANCE_M = 5f
    }

    private lateinit var locationManager: LocationManager
    private var visitId: String = ""

    override fun onCreate() {
        super.onCreate()
        locationManager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
        createChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // START_STICKY lets the system auto-restart us with a NULL intent after
        // process death — and calling startForeground for a location-type FGS
        // from a background restart throws SecurityException (the background
        // FGS-start restriction), which would crash the whole process. Never
        // re-enter foreground mode blind: if there's no original intent, stop.
        if (intent == null) {
            stopSelf()
            LocationEventBridge.emitStatus("stopped", "Tracking service restarted by the system without its start intent.")
            return START_NOT_STICKY
        }
        visitId = intent.getStringExtra(EXTRA_VISIT_ID).orEmpty()
        startAsForeground()
        startListening()
        LocationEventBridge.emitStatus("tracking", "Recording the location trail for this visit.")
        // Unconditional START_NOT_STICKY: the null-intent guard above already
        // forces a graceful stop on system restart, and Android 12+ actively
        // discourages background FGS restarts.
        return START_NOT_STICKY
    }

    /// `startForeground` with the location type — on Android 14 omitting the
    /// type (or holding no FOREGROUND_SERVICE_LOCATION permission) throws at
    /// startup, a crash this build must not ship. Any failure here must stop
    /// the service cleanly, never take the process down.
    private fun startAsForeground() {
        try {
            val notification = buildNotification()
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                startForeground(NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_LOCATION)
            } else {
                startForeground(NOTIFICATION_ID, notification)
            }
        } catch (e: Exception) {
            LocationEventBridge.emitStatus(
                "permission_denied",
                "Could not start background tracking: ${e.message}",
            )
            stopSelf()
        }
    }

    private fun createChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Background location",
                NotificationManager.IMPORTANCE_LOW,
            )
            channel.description =
                "Shown while FieldOps records the active job visit's location trail."
            (getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager)
                .createNotificationChannel(channel)
        }
    }

    private fun buildNotification(): Notification {
        val builder =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                Notification.Builder(this, CHANNEL_ID)
            } else {
                @Suppress("DEPRECATION")
                Notification.Builder(this)
            }
        return builder
            .setContentTitle("Tracking job visit")
            .setContentText("Recording the location trail.")
            .setSmallIcon(android.R.drawable.ic_menu_mylocation)
            .setOngoing(true)
            .build()
    }

    private fun startListening() {
        try {
            // GPS provider only: registering the network provider too can land
            // near-simultaneous fixes as duplicate trail points. GPS is the
            // reliable fix for the outdoor field-ops demo (emulator `geo fix`
            // drives GPS).
            if (locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER)) {
                locationManager.requestLocationUpdates(
                    LocationManager.GPS_PROVIDER,
                    UPDATE_INTERVAL_MS,
                    UPDATE_DISTANCE_M,
                    this,
                    Looper.getMainLooper(),
                )
            }
        } catch (_: SecurityException) {
            LocationEventBridge.emitStatus("permission_denied", "Location permission was revoked.")
            stopSelf()
        }
    }

    override fun onLocationChanged(location: Location) {
        LocationEventBridge.emitPoint(visitId, location)
    }

    @Deprecated("Location API 29+")
    override fun onStatusChanged(provider: String?, status: Int, extras: Bundle?) = Unit

    override fun onProviderEnabled(provider: String) = Unit
    override fun onProviderDisabled(provider: String) = Unit

    override fun onDestroy() {
        locationManager.removeUpdates(this)
        LocationEventBridge.emitStatus("stopped")
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}