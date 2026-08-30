import 'package:flutter/services.dart';

/// The one Dart contract both native sides implement (memory.md: keep native
/// message names + payload shapes identical across platforms).
///
/// **Methods** (`MethodChannel fieldops/location`):
/// - `start` {visitId} → begins background tracking for that visit
/// - `stop` → stops tracking
///
/// **Events** (`EventChannel fieldops/location/events`) — each event is a map:
/// - `{'type':'point','visitId':…,'lat':…,'lng':…,'timestamp':…,'accuracy':…}`
/// - `{'type':'status','value': 'tracking'|'stopped'|'permission_denied'|
///      'background_denied'|'downgraded','message':…}`
///
/// The native side only CAPTURES — persistence to `LocationPoints` happens
/// here, in Dart, so the merge engine's `JobVisits.gpsUpdatedAt` is never
/// polluted by per-tick GPS.
class LocationTrackingService {
  static const _methodChannel = MethodChannel('fieldops/location');
  static const _eventChannel = EventChannel('fieldops/location/events');

  /// True once the native side has *initiated* the start flow (permission
  /// prompts resolve asynchronously and surface via [events]).
  Future<bool> start(String visitId) async {
    try {
      return await _methodChannel.invokeMethod<bool>('start', {
            'visitId': visitId,
          }) ??
          false;
    } catch (_) {
      return false; // no native handler (unsupported platform) → stay off
    }
  }

  Future<void> stop() async {
    try {
      await _methodChannel.invokeMethod<void>('stop');
    } catch (_) {
      // Unsupported platform — nothing to stop.
    }
  }

  Stream<LocationTrackingEvent> get events =>
      _eventChannel.receiveBroadcastStream().map(_parseEvent);

  LocationTrackingEvent _parseEvent(dynamic raw) {
    final map = (raw as Map).cast<String, Object?>();
    switch (map['type']) {
      case 'point':
        return TrackingPoint(
          visitId: map['visitId']! as String,
          lat: (map['lat']! as num).toDouble(),
          lng: (map['lng']! as num).toDouble(),
          capturedAt: (map['timestamp']! as num).toInt(),
          accuracyMeters: (map['accuracy'] as num?)?.toInt(),
        );
      case 'status':
        return TrackingStatusEvent(
          status: TrackingStatus.fromValue(map['value']! as String),
          message: map['message'] as String?,
        );
      default:
        return const TrackingStatusEvent(status: TrackingStatus.idle);
    }
  }
}

enum TrackingStatus {
  idle,
  tracking,
  permissionDenied,
  backgroundDenied,
  downgraded;

  static TrackingStatus fromValue(String value) => switch (value) {
    'tracking' => TrackingStatus.tracking,
    'permission_denied' => TrackingStatus.permissionDenied,
    'background_denied' => TrackingStatus.backgroundDenied,
    'downgraded' => TrackingStatus.downgraded,
    _ => TrackingStatus.idle,
  };
}

sealed class LocationTrackingEvent {
  const LocationTrackingEvent();
}

class TrackingPoint extends LocationTrackingEvent {
  const TrackingPoint({
    required this.visitId,
    required this.lat,
    required this.lng,
    required this.capturedAt,
    this.accuracyMeters,
  });

  final String visitId;
  final double lat;
  final double lng;
  final int capturedAt;
  final int? accuracyMeters;
}

/// Native-side state signal (permission outcome, background downgrade, …).
class TrackingStatusEvent extends LocationTrackingEvent {
  const TrackingStatusEvent({required this.status, this.message});

  final TrackingStatus status;
  final String? message;
}
