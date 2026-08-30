package com.fieldops.app

import android.location.Location
import io.flutter.plugin.common.EventChannel

/// Same-process pipe from the [ForegroundLocationService] (which may outlive
/// the Activity) to the Dart `fieldops/location/events` EventChannel. The
/// Activity owns the sink (set on `onListen`); the service just emits.
object LocationEventBridge {
    @Volatile
    var sink: EventChannel.EventSink? = null

    fun emitPoint(visitId: String, location: Location) {
        emit(
            mapOf(
                "type" to "point",
                "visitId" to visitId,
                "lat" to location.latitude,
                "lng" to location.longitude,
                "timestamp" to location.time,
                "accuracy" to location.accuracy.toInt(),
            ),
        )
    }

    fun emitStatus(value: String, message: String? = null) {
        emit(mapOf("type" to "status", "value" to value, "message" to message))
    }

    private fun emit(payload: Map<String, Any?>) {
        try {
            sink?.success(payload)
        } catch (_: Throwable) {
            // No Dart listener (yet) — the next point is delivered fine.
        }
    }
}