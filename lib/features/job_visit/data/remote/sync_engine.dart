import '../../domain/entities/job_visit.dart';
import '../../domain/repositories/job_visit_repository.dart';
import '../models/job_visit_merger.dart';
import 'sync_backend.dart';

/// Called once per visit, immediately AFTER the merged row + baseline are
/// committed locally. The notification service (and anything else that reacts
/// to a sync) consumes this — the engine itself stays free of platform code.
typedef VisitSyncedHandler =
    void Function({
      required JobVisit merged,
      required JobVisit? previousLocal,
      required Set<MergeField> remoteChangedFields,
    });

/// Outcome of one sync run. [synced] counts the visits whose merged row +
/// baseline were actually committed locally and pushed this round; [failure]
/// is non-null when the run aborted mid-batch.
///
/// [skipped] distinguishes "this call was rejected by the single-flight guard
/// because another sync was already running" from a real run that synced
/// zero visits — the demo log must not claim a skipped call succeeded.
class SyncResult {
  const SyncResult({required this.synced, this.failure, this.skipped = false});

  final int synced;
  final Object? failure;
  final bool skipped;

  bool get succeeded => failure == null && !skipped;
}

/// The pull → merge → push (per visit) protocol from master plan §3.

class SyncEngine {
  SyncEngine({
    required this._repository,
    required this._backend,
    required this._merger,
    this._onEvent,
    this.onVisitSynced,
  });

  final JobVisitRepository _repository;
  final SyncBackend _backend;
  final JobVisitMerger _merger;
  final void Function(String event)? _onEvent;
  final VisitSyncedHandler? onVisitSynced;

  bool _inFlight = false;

  /// Single-flight guard: rejected entirely if another sync run is in progress
  /// (the offline/online toggle is a control that gets clicked twice). The
  /// rejection is distinguishable via [SyncResult.skipped].
  Future<SyncResult> sync() async {
    if (_inFlight) return const SyncResult(synced: 0, skipped: true);
    _inFlight = true;
    try {
      return await _run();
    } on Object catch (failure) {
      _log('sync failed before any visit: $failure');
      return SyncResult(synced: 0, failure: failure);
    } finally {
      _inFlight = false;
    }
  }

  Future<SyncResult> _run() async {
    final localAll = await _repository.getAll();
    final remoteAll = await _backend.getAllVisits();

    final localById = {for (final v in localAll) v.id: v};
    final remoteById = {for (final v in remoteAll) v.id: v};
    final ids = {...localById.keys, ...remoteById.keys}.toList()..sort();

    _log('sync run: ${ids.length} visit(s) on watch: ${ids.join(', ')}');

    var synced = 0;
    try {
      for (final id in ids) {
        // 1. Pull the remote record for this id (may be absent).
        final remote = remoteById[id];
        final local = localById[id];

        _log(
          '  [$id] pull: ${remote == null ? 'no remote record' : 'remote found'} · local: ${local == null ? 'absent (remote-created)' : 'present'}',
        );

        // 2. Compute the merge fully in memory — nothing written yet.
        final result = _merger.merge(local: local, remote: remote);

        if (!result.participated) {
          _log(
            '  [$id] skip: neither side changed since baseline — state preserved',
          );
          continue;
        }

        if (result.conflictedFields.isNotEmpty) {
          _log(
            '  [$id] merge: CONFLICT on ${_fieldNames(result.conflictedFields)} '
            '→ last-writer-wins (deviceId tie-break) → ${result.merged.syncState.storageValue}',
          );
        } else if (local == null ||
            remote == null ||
            local.baseSnapshot == null) {
          _log(
            '  [$id] merge: no-baseline branch → adopt the only existing side',
          );
        } else {
          _log('  [$id] merge: clean — ${_logSidedChanges(result)}');
        }

        // 3. Push the MERGED record (never the raw local record).
        //    On failure: commit nothing locally; this visit stays pending.
        await _backend.upsertVisit(result.merged);
        _log('  [$id] push: merged record accepted by backend');

        // 4. Commit the merged row + its new baseSnapshot + its syncState in
        //    ONE local transaction — only after the backend accepted it.
        //    Known window (not demo-reachable): if this commit fails after the
        //    push succeeded, the retry re-merges local vs merged-remote →
        //    both sides changed → values converge but syncState may surface a
        //    phantom conflict_resolved. Acknowledged; impossible to hit here
        //    because the failure injection throws on push, never on commit.
        await _repository.upsert(result.merged);
        _log(
          '  [$id] commit: row + baseSnapshot + syncState='
          '${result.merged.syncState.storageValue} (one local transaction)',
        );

        onVisitSynced?.call(
          merged: result.merged,
          previousLocal: local,
          remoteChangedFields: result.remoteChangedFields,
        );
        synced++;
      }
      _log('sync run: done — $synced visit(s) synced');
      return SyncResult(synced: synced);
    } on Object catch (failure) {
      _log('sync run: aborted — $synced visit(s) committed before the failure');
      return SyncResult(synced: synced, failure: failure);
    }
  }

  String _fieldNames(Set<MergeField> fields) =>
      fields.isEmpty ? 'nothing' : fields.map((f) => f.name).join(', ');

  String _logSidedChanges(VisitMergeResult result) {
    final parts = <String>[
      if (result.localChangedFields.isNotEmpty)
        'local changed ${_fieldNames(result.localChangedFields)}',
      if (result.remoteChangedFields.isNotEmpty)
        'remote changed ${_fieldNames(result.remoteChangedFields)}',
    ];
    return '${parts.join(' · ')} since baseline';
  }

  void _log(String event) => _onEvent?.call(event);
}
