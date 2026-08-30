import 'package:drift/drift.dart';

import '../../domain/entities/job_visit.dart';
import '../../domain/repositories/job_visit_repository.dart';
import '../local/app_database.dart';

/// Drift-backed [JobVisitRepository].
class JobVisitRepositoryImpl implements JobVisitRepository {
  const JobVisitRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Stream<List<JobVisit>> watchAll() {
    final query = _db.select(_db.jobVisits)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.watch().map(_mapRows);
  }

  @override
  Stream<JobVisit?> watchById(String id) {
    final query = _db.select(_db.jobVisits)..where((t) => t.id.equals(id));
    return query.watchSingleOrNull().map(_mapRow);
  }

  @override
  Future<JobVisit?> getById(String id) async {
    final row = await (_db.select(
      _db.jobVisits,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return _mapRow(row);
  }

  @override
  Future<List<JobVisit>> getAll() async {
    final rows = await (_db.select(_db.jobVisits)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();
    return _mapRows(rows);
  }

  @override
  Future<void> upsert(JobVisit visit) async {
    await _db.into(_db.jobVisits).insertOnConflictUpdate(_toCompanion(visit));
  }

  List<JobVisit> _mapRows(List<JobVisitRow> rows) =>
      rows.map(_mapNonNull).toList();

  JobVisit _mapNonNull(JobVisitRow row) => JobVisit(
    id: row.id,
    createdAt: row.createdAt,
    status: JobVisitStatus.fromStorage(row.status),
    statusUpdatedAt: row.statusUpdatedAt,
    gpsLat: row.gpsLat,
    gpsLng: row.gpsLng,
    gpsUpdatedAt: row.gpsUpdatedAt,
    photoPath: row.photoPath,
    photoUpdatedAt: row.photoUpdatedAt,
    syncState: JobVisitSyncState.fromStorage(row.syncState),
    deviceId: row.deviceId,
    baseSnapshot: row.baseSnapshot,
  );

  JobVisit? _mapRow(JobVisitRow? row) {
    if (row == null) return null;
    return _mapNonNull(row);
  }

  JobVisitsCompanion _toCompanion(JobVisit v) {
    return JobVisitsCompanion(
      id: Value(v.id),
      createdAt: Value(v.createdAt),
      status: Value(v.status.storageValue),
      statusUpdatedAt: Value(v.statusUpdatedAt),
      gpsLat: Value(v.gpsLat),
      gpsLng: Value(v.gpsLng),
      gpsUpdatedAt: Value(v.gpsUpdatedAt),
      photoPath: Value(v.photoPath),
      photoUpdatedAt: Value(v.photoUpdatedAt),
      syncState: Value(v.syncState.storageValue),
      deviceId: Value(v.deviceId),
      baseSnapshot: Value(v.baseSnapshot),
    );
  }
}
