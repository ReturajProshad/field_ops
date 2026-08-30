import Flutter
import UIKit
import CoreLocation

/// iOS implementation of the `fieldops/location` contract — the same message
/// names/payloads as the Android side (memory.md: identical across platforms).
///
/// The CLLocationManager lifecycle, authorization handling (including the
/// When-In-Use downgrade the brief names), and background-mode wiring are our
/// code; the raw position fix comes from Apple's location stack.
///
/// Channel contract (mirrors Android):
/// - MethodChannel `fieldops/location`: `start` {visitId} / `stop`
/// - EventChannel `fieldops/location/events`: `point` / `status` events
class LocationTrackingHandler: NSObject,
    FlutterPlugin,
    FlutterStreamHandler,
    CLLocationManagerDelegate
{
    private static let methodChannelName = "fieldops/location"
    private static let eventChannelName = "fieldops/location/events"

    /// CLLocationManagerDelegate callbacks arrive on the manager's delegate;
    /// a singleton keeps the channel handlers and the manager on one object.
    static let shared = LocationTrackingHandler()

    private var eventSink: FlutterEventSink?
    private var locationManager: CLLocationManager?
    private var currentVisitId = ""

    // MARK: FlutterPlugin

    public static func register(with registrar: FlutterPluginRegistrar) {
        let method = FlutterMethodChannel(
            name: methodChannelName,
            binaryMessenger: registrar.messenger()
        )
        method.setMethodCallHandler(shared.handle)
        let events = FlutterEventChannel(
            name: eventChannelName,
            binaryMessenger: registrar.messenger()
        )
        events.setStreamHandler(shared)
        registrar.addApplicationDelegate(shared)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "start":
            let visitId = (call.arguments as? [String: Any])?["visitId"] as? String ?? ""
            startTracking(visitId: visitId)
            result(true)
        case "stop":
            stopTracking()
            result(true)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: FlutterStreamHandler

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
        -> FlutterError?
    {
        eventSink = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }

    // MARK: Tracking control

    private func startTracking(visitId: String) {
        currentVisitId = visitId
        let manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager.distanceFilter = 5
        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = false
        locationManager = manager

        switch authStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
            emitStatus("tracking", "Recording the location trail for this visit.")
        case .denied, .restricted:
            emitStatus("permission_denied", "Location permission denied.")
        default:
            // Tracking requires Always for screen-locked delivery; the
            // system prompt (or Settings guidance) follows.
            manager.requestAlwaysAuthorization()
        }
    }

    private func stopTracking() {
        locationManager?.stopUpdatingLocation()
        locationManager?.allowsBackgroundLocationUpdates = false
        locationManager?.delegate = nil
        locationManager = nil
        currentVisitId = ""
        emitStatus("stopped")
    }

    private var authStatus: CLAuthorizationStatus {
        if #available(iOS 14.0, *) {
            return locationManager?.authorizationStatus ?? .notDetermined
        }
        return CLLocationManager.authorizationStatus()
    }

    // MARK: CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch authStatus {
        case .authorizedAlways:
            guard let manager = locationManager, !currentVisitId.isEmpty else { return }
            manager.startUpdatingLocation()
            emitStatus("tracking", "Recording the location trail for this visit.")
        case .authorizedWhenInUse:
            // The brief names this exact case: granted When-In-Use, screen
            // locks → delivery stops silently. Surface it rather than die.
            emitStatus(
                "downgraded",
                "Background access is While-In-Use only — ticks pause when the screen locks. Open Settings to allow Always."
            )
        case .denied, .restricted:
            emitStatus("permission_denied", "Location permission denied.")
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }

    // iOS 13 fallback (the delegate method above is iOS 14+).
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationManagerDidChangeAuthorization(manager)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        emitPoint(visitId: currentVisitId, location: location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        emitStatus("downgraded", "Location unavailable: \(error.localizedDescription)")
    }

    // MARK: Channel emission

    private func emitPoint(visitId: String, location: CLLocation) {
        guard let sink = eventSink else { return }
        let accuracy = location.horizontalAccuracy >= 0
            ? Int(location.horizontalAccuracy.rounded())
            : nil
        sink([
            "type": "point",
            "visitId": visitId,
            "lat": location.coordinate.latitude,
            "lng": location.coordinate.longitude,
            "timestamp": (location.timestamp.timeIntervalSince1970 * 1000).rounded(),
            "accuracy": accuracy ?? NSNull(),
        ])
    }

    private func emitStatus(_ value: String, _ message: String? = nil) {
        eventSink?(["type": "status", "value": value, "message": message ?? NSNull()])
    }
}