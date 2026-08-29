import '../../domain/entities/job_visit.dart';
import 'base_snapshot.dart';

/// Mergeable fields
enum MergeField { status, gps, photo }

/// Which side supplied a winning field value.
enum MergeWinner { local, remote }

/// Outcome of a three-way merge: the merged [JobVisit] plus, per field, whether either side changed it since the baseline. [participated] is the engine's trigger — it must only write/push a visit whose result reports true.
class VisitMergeResult {
  const VisitMergeResult({
    required this.merged,
    required this.conflictedFields,
    required this.localChangedFields,
    required this.remoteChangedFields,
  });

  final JobVisit merged;

  /// Non-empty iff the merged [JobVisit.syncState] is `conflict_resolved`.
  final Set<MergeField> conflictedFields;

  /// Fields where the local record differs from the baseline snapshot.
  final Set<MergeField> localChangedFields;

  /// Fields where the remote record differs from the baseline snapshot.
  final Set<MergeField> remoteChangedFields;

  /// Participatory → false when neither side changed anything since the baseline; the sync engine MUST skip write + push, or a sticky `conflict_resolved` state silently reverts to `synced` on the next sync round. Adopt paths (no baseline, remote-created, first push) are inherently participatory.
  bool get participated =>
      localChangedFields.isNotEmpty || remoteChangedFields.isNotEmpty;
}

/// Pure three-way field-level merge. No Drift, sync-service, or UI dependency —
/// testable in isolation.
class JobVisitMerger {
  const JobVisitMerger();

  VisitMergeResult merge({
    required JobVisit? local,
    required JobVisit? remote,
  }) {
    if (local == null && remote == null) {
      throw ArgumentError('at least one of local/remote must be non-null');
    }
    if (local == null) {
      return _adoptSingleSide(remote!);
    }
    if (remote == null) {
      return _adoptSingleSide(local);
    }
    if (local.baseSnapshot == null) {
      return _adoptSingleSide(remote);
    }
    return _threeWayMerge(local, remote);
  }

  /// Adopts a visit wholesale with a fresh baseline. Inherently participatory:
  /// the visit either is brand new (remote-created/pushed) or was never synced
  /// (no [JobVisit.baseSnapshot]), so it must be written regardless.
  VisitMergeResult _adoptSingleSide(JobVisit visit) {
    return VisitMergeResult(
      merged: visit.copyWith(
        syncState: JobVisitSyncState.synced,
        baseSnapshot: BaseSnapshot.fromVisit(visit).toJsonString(),
      ),
      conflictedFields: const {},
      localChangedFields: const {
        MergeField.status,
        MergeField.gps,
        MergeField.photo,
      },
      remoteChangedFields: const {
        MergeField.status,
        MergeField.gps,
        MergeField.photo,
      },
    );
  }

  VisitMergeResult _threeWayMerge(JobVisit local, JobVisit remote) {
    final base = BaseSnapshot.fromJsonString(local.baseSnapshot!);

    final conflicted = <MergeField>{};
    final localChanged = <MergeField>{};
    final remoteChanged = <MergeField>{};

    void onOutcome(MergeField field, _FieldDecision decision) {
      if (decision.conflicted) conflicted.add(field);
      if (decision.localChanged) localChanged.add(field);
      if (decision.remoteChanged) remoteChanged.add(field);
    }

    final statusDecision = _decide(
      baseUpdatedAt: base.status.updatedAt,
      localUpdatedAt: local.statusUpdatedAt,
      remoteUpdatedAt: remote.statusUpdatedAt,
      localDeviceId: local.deviceId,
      remoteDeviceId: remote.deviceId,
    );
    onOutcome(MergeField.status, statusDecision);

    final gpsDecision = _decide(
      baseUpdatedAt: base.gps.updatedAt,
      localUpdatedAt: local.gpsUpdatedAt,
      remoteUpdatedAt: remote.gpsUpdatedAt,
      localDeviceId: local.deviceId,
      remoteDeviceId: remote.deviceId,
    );
    onOutcome(MergeField.gps, gpsDecision);

    final photoDecision = _decide(
      baseUpdatedAt: base.photo.updatedAt,
      localUpdatedAt: local.photoUpdatedAt,
      remoteUpdatedAt: remote.photoUpdatedAt,
      localDeviceId: local.deviceId,
      remoteDeviceId: remote.deviceId,
    );
    onOutcome(MergeField.photo, photoDecision);

    final statusL = statusDecision.winner == MergeWinner.local;
    final gpsL = gpsDecision.winner == MergeWinner.local;
    final photoL = photoDecision.winner == MergeWinner.local;

    final merged = JobVisit(
      id: local.id,
      createdAt: local.createdAt,
      // Record-level deviceId approximates the last writing device; local identity is kept for deterministic tie-breaks and mock backend behavior.
      deviceId: local.deviceId,
      status: statusL ? local.status : remote.status,
      statusUpdatedAt: statusL ? local.statusUpdatedAt : remote.statusUpdatedAt,
      gpsLat: gpsL ? local.gpsLat : remote.gpsLat,
      gpsLng: gpsL ? local.gpsLng : remote.gpsLng,
      gpsUpdatedAt: gpsL ? local.gpsUpdatedAt : remote.gpsUpdatedAt,
      photoPath: photoL ? local.photoPath : remote.photoPath,
      photoUpdatedAt: photoL ? local.photoUpdatedAt : remote.photoUpdatedAt,
      syncState: conflicted.isEmpty
          ? JobVisitSyncState.synced
          : JobVisitSyncState.conflictResolved,
      baseSnapshot: BaseSnapshot(
        status: StatusSnapshot(
          value: (statusL ? local.status : remote.status).storageValue,
          updatedAt: statusL ? local.statusUpdatedAt : remote.statusUpdatedAt,
        ),
        gps: GpsSnapshot(
          lat: gpsL ? local.gpsLat : remote.gpsLat,
          lng: gpsL ? local.gpsLng : remote.gpsLng,
          updatedAt: gpsL ? local.gpsUpdatedAt : remote.gpsUpdatedAt,
        ),
        photo: PhotoSnapshot(
          path: photoL ? local.photoPath : remote.photoPath,
          updatedAt: photoL ? local.photoUpdatedAt : remote.photoUpdatedAt,
        ),
      ).toJsonString(),
    );

    return VisitMergeResult(
      merged: merged,
      conflictedFields: Set.unmodifiable(conflicted),
      localChangedFields: Set.unmodifiable(localChanged),
      remoteChangedFields: Set.unmodifiable(remoteChanged),
    );
  }

  _FieldDecision _decide({
    required int? baseUpdatedAt,
    required int? localUpdatedAt,
    required int? remoteUpdatedAt,
    required String localDeviceId,
    required String remoteDeviceId,
  }) {
    final localChanged = localUpdatedAt != baseUpdatedAt;
    final remoteChanged = remoteUpdatedAt != baseUpdatedAt;

    if (localChanged && remoteChanged) {
      if (localUpdatedAt == remoteUpdatedAt) {
        final localWins = localDeviceId.compareTo(remoteDeviceId) <= 0;
        return _FieldDecision(
          winner: localWins ? MergeWinner.local : MergeWinner.remote,
          localChanged: true,
          remoteChanged: true,
          conflicted: true,
        );
      }
      final localWins = (localUpdatedAt ?? 0) > (remoteUpdatedAt ?? 0);
      return _FieldDecision(
        winner: localWins ? MergeWinner.local : MergeWinner.remote,
        localChanged: true,
        remoteChanged: true,
        conflicted: true,
      );
    }

    if (remoteChanged) {
      return _FieldDecision(
        winner: MergeWinner.remote,
        localChanged: false,
        remoteChanged: true,
        conflicted: false,
      );
    }
    return _FieldDecision(
      winner: MergeWinner.local,
      localChanged: localChanged,
      remoteChanged: false,
      conflicted: false,
    );
  }
}

class _FieldDecision {
  const _FieldDecision({
    required this.winner,
    required this.localChanged,
    required this.remoteChanged,
    required this.conflicted,
  });

  final MergeWinner winner;
  final bool localChanged;
  final bool remoteChanged;
  final bool conflicted;
}
