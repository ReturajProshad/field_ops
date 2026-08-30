import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/di/database_provider.dart';
import '../../../../services/location/location_tracking_service.dart';
import '../../data/local/app_database.dart';
import '../../data/repositories/location_point_repository.dart';

final locationPointRepositoryProvider = Provider<LocationPointRepository>(
  (ref) => LocationPointRepository(ref.watch(appDatabaseProvider)),
);

final locationTrackingServiceProvider = Provider<LocationTrackingService>(
  (ref) => LocationTrackingService(),
);

@immutable
class TrackingState {
  const TrackingState({
    this.status = TrackingStatus.idle,
    this.activeVisitId,
    this.message,
  });

  final TrackingStatus status;
  final String? activeVisitId;
  final String? message;

  TrackingState copyWith({
    TrackingStatus? status,
    String? activeVisitId,
    bool clearVisit = false,
    String? message,
  }) {
    return TrackingState(
      status: status ?? this.status,
      activeVisitId: clearVisit ? null : activeVisitId ?? this.activeVisitId,
      message: message ?? this.message,
    );
  }
}

/// App-lifetime controller for background location tracking.
///
/// Persists every [TrackingPoint] into `LocationPoints` — the trailing pipe
/// from "ticks → platform channel → LocationPoints only". `JobVisits` GPS
/// fields are never touched here (structural: native code has no DB access).
///
/// Known limitation (deadline-accepted, review): if the Activity is destroyed
/// while the FGS keeps running (rare OEM swipe-away paths), the fresh Dart
/// isolate's controller reports Idle while ticks still flow into
/// `LocationPoints` (the native bridge re-registers its sink on the new
/// engine's `onListen`). Data stays correct; only the toggle lies. A
/// `getState` method-channel query would close it.
class LocationTrackingController extends Notifier<TrackingState> {
  final Uuid _uuid = const Uuid();
  StreamSubscription<LocationTrackingEvent>? _sub;

  @override
  TrackingState build() {
    final service = ref.watch(locationTrackingServiceProvider);
    final repo = ref.watch(locationPointRepositoryProvider);
    _sub = service.events.listen((event) => _onEvent(event, repo));
    ref.onDispose(() => _sub?.cancel());
    return const TrackingState();
  }

  Future<void> start(String visitId) async {
    final ok = await ref.read(locationTrackingServiceProvider).start(visitId);
    if (!ok) {
      state = TrackingState(
        status: TrackingStatus.permissionDenied,
        activeVisitId: visitId,
        message: 'Tracking is unavailable on this device.',
      );
      return;
    }
    state = TrackingState(
      status: TrackingStatus.tracking,
      activeVisitId: visitId,
    );
  }

  Future<void> stop() async {
    await ref.read(locationTrackingServiceProvider).stop();
    state = const TrackingState();
  }

  void _onEvent(LocationTrackingEvent event, LocationPointRepository repo) {
    if (event is TrackingPoint) {
      repo.insert(
        LocationPointsCompanion.insert(
          id: _uuid.v4(),
          jobVisitId: event.visitId,
          lat: event.lat,
          lng: event.lng,
          capturedAt: event.capturedAt,
          accuracyMeters: Value(event.accuracyMeters),
        ),
      );
      state = state.copyWith(
        status: TrackingStatus.tracking,
        activeVisitId: event.visitId,
      );
    } else if (event is TrackingStatusEvent) {
      state = state.copyWith(status: event.status, message: event.message);
    }
  }
}

final locationTrackingControllerProvider =
    NotifierProvider<LocationTrackingController, TrackingState>(
      LocationTrackingController.new,
    );

/// Live trail for one visit (oldest first) — the trail indicator's data.
final locationPointsByVisitProvider =
    StreamProvider.family<List<LocationPoint>, String>((ref, visitId) {
      return ref.watch(locationPointRepositoryProvider).watchByVisit(visitId);
    });
