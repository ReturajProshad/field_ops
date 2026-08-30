import '../../domain/entities/job_visit.dart';

/// Thrown by the mock backend when failure injection fires or an auth token is
/// missing. The sync engine treats any `SyncBackendException` as a mid-batch
/// failure: rows already committed stay committed, in-flight rows stay pending.
class SyncBackendException implements Exception {
  const SyncBackendException(this.message);

  final String message;

  @override
  String toString() => 'SyncBackendException: $message';
}

/// The remote surface the sync engine talks to. Deliberately tiny — this is a
/// fake service, not a backend architecture. The engine never calls secure
/// storage directly; it receives records and headers through this boundary.
abstract class SyncBackend {
  Future<JobVisit?> getVisit(String id);
  Future<void> upsertVisit(JobVisit visit);
  Future<List<JobVisit>> getAllVisits();
}