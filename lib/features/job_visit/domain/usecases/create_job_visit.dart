import 'package:uuid/uuid.dart';

import '../entities/job_visit.dart';
import '../repositories/job_visit_repository.dart';

/// Creates a new job visit locally.
///
/// Owns creation discipline (repository does not stamp anything): id +
/// `createdAt` generated here, `syncState` forced to `pending`, the local
/// `deviceId` recorded as the last writer.
class CreateJobVisit {
  CreateJobVisit(this._repository, this._deviceId);

  final JobVisitRepository _repository;
  final String _deviceId;

  static const _uuid = Uuid();

  Future<JobVisit> call({
    required JobVisitStatus status,
    double? gpsLat,
    double? gpsLng,
    String? photoPath,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final visit = JobVisit(
      id: _uuid.v4(),
      createdAt: now,
      status: status,
      statusUpdatedAt: now,
      gpsLat: gpsLat,
      gpsLng: gpsLng,
      gpsUpdatedAt: (gpsLat != null && gpsLng != null) ? now : null,
      photoPath: photoPath,
      photoUpdatedAt: photoPath != null ? now : null,
      syncState: JobVisitSyncState.pending,
      deviceId: _deviceId,
    );
    await _repository.upsert(visit);
    return visit;
  }
}