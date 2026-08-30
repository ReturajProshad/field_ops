import '../entities/job_visit.dart';

/// Persistence boundary for job visits. Local-only for now; sync joins later
/// without changing this interface.
abstract class JobVisitRepository {
  /// Streams all visits, re-emitting whenever the underlying set changes.
  Stream<List<JobVisit>> watchAll();

  /// Streams a single visit, or null when the id is unknown.
  Stream<JobVisit?> watchById(String id);

  /// Returns the current value of [watchById] once.
  Future<JobVisit?> getById(String id);

  /// All visits, newest first, as a one-shot read — the sync engine iterates
  /// over this to build the local-side id set.
  Future<List<JobVisit>> getAll();

  /// Inserts or overwrites [visit] by id. Persisting is the repository's only
  /// job — it does NOT stamp or normalize fields (the caller owns that).
  Future<void> upsert(JobVisit visit);
}