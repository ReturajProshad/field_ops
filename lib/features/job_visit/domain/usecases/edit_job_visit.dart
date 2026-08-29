import '../entities/job_visit.dart';
import '../repositories/job_visit_repository.dart';

/// A single, atomic set of edits to a job visit.
///
/// Each non-null/flag field stamps its own `*UpdatedAt` to "now" so the sync
/// layer can later detect exactly which fields changed since the baseline.
class JobVisitPatch {
  final JobVisitStatus? status;
  final double? gpsLat;
  final double? gpsLng;
  final String? photoPath;

  /// Clears the GPS coordinate (also nulls `gpsUpdatedAt`).
  final bool clearGps;

  /// Clears the photo (also nulls `photoUpdatedAt`).
  final bool clearPhoto;

  const JobVisitPatch({
    this.status,
    this.gpsLat,
    this.gpsLng,
    this.photoPath,
    this.clearGps = false,
    this.clearPhoto = false,
  });
}

/// Applies [JobVisitPatch] to a visit and persists the result.
///
/// Always forces `syncState = pending` and records the local `deviceId` — per
/// memory.md, any new local edit immediately marks the visit dirty regardless
/// of its previous state.
class EditJobVisit {
  EditJobVisit(this._repository, this._deviceId);

  final JobVisitRepository _repository;
  final String _deviceId;

  Future<JobVisit> call({
    required JobVisit current,
    required JobVisitPatch patch,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    var updated = current;
    if (patch.status != null) {
      updated = updated.copyWith(status: patch.status, statusUpdatedAt: now);
    }
    if (patch.gpsLat != null && patch.gpsLng != null) {
      updated = updated.copyWith(
        gpsLat: patch.gpsLat,
        gpsLng: patch.gpsLng,
        gpsUpdatedAt: now,
      );
    }
    if (patch.clearGps) {
      updated = updated.copyWith(clearGps: true);
    }
    if (patch.photoPath != null) {
      updated = updated.copyWith(photoPath: patch.photoPath, photoUpdatedAt: now);
    }
    if (patch.clearPhoto) {
      updated = updated.copyWith(clearPhoto: true);
    }

    updated = updated.copyWith(
      syncState: JobVisitSyncState.pending,
      deviceId: _deviceId,
    );

    await _repository.upsert(updated);
    return updated;
  }
}