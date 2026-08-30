import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:field_ops/features/job_visit/data/local/app_database.dart';
import 'package:field_ops/features/job_visit/data/models/base_snapshot.dart';
import 'package:field_ops/features/job_visit/data/models/job_visit_merger.dart';
import 'package:field_ops/features/job_visit/data/remote/mock_sync_service.dart';
import 'package:field_ops/features/job_visit/data/remote/sync_backend.dart';
import 'package:field_ops/features/job_visit/data/remote/sync_engine.dart';
import 'package:field_ops/features/job_visit/data/repositories/job_visit_repository_impl.dart';
import 'package:field_ops/features/job_visit/domain/entities/job_visit.dart';

void main() {
  late AppDatabase db;
  late JobVisitRepositoryImpl repository;
  late Directory tempDir;
  late MockSyncService backend;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repository = JobVisitRepositoryImpl(db);
    tempDir = await Directory.systemTemp.createTemp('field_ops_sync_test');
    backend = MockSyncService(
      file: File('${tempDir.path}/backend.json'),
      tokenProvider: () async => 'test-token',
    );
  });

  tearDown(() async {
    await db.close();
    await tempDir.delete(recursive: true);
  });

  const merger = JobVisitMerger();

  JobVisit makeVisit({
    String id = 'visit-1',
    JobVisitStatus status = JobVisitStatus.enRoute,
    int statusUpdatedAt = 1000,
    String? photoPath,
    int? photoUpdatedAt,
    JobVisitSyncState syncState = JobVisitSyncState.synced,
    String deviceId = 'device-a',
    String? base,
  }) {
    return JobVisit(
      id: id,
      createdAt: 1000,
      status: status,
      statusUpdatedAt: statusUpdatedAt,
      photoPath: photoPath,
      photoUpdatedAt: photoUpdatedAt,
      syncState: syncState,
      deviceId: deviceId,
      baseSnapshot: base,
    );
  }

  /// Baseline "last synced" state for [v], stored the way the engine writes it.
  String snapshotFor(JobVisit v) => BaseSnapshot.fromVisit(v).toJsonString();

  JobVisit syncedBaseline(JobVisit v) => v.copyWith(
        syncState: JobVisitSyncState.synced,
        baseSnapshot: snapshotFor(v),
      );

  test(
      'case (f): A edits status, B edits photo — BOTH survive a full sync run '
      '(status in local, photo pulled from backend)', () async {
    // Last successfully synced state on both sides.
    final baseline = makeVisit();
    final baselineSynced = syncedBaseline(baseline);

    await repository.upsert(baselineSynced);
    await backend.upsertVisit(baselineSynced);

    // Device A edits status offline.
    await repository.upsert(
      baselineSynced.copyWith(
        status: JobVisitStatus.onSite,
        statusUpdatedAt: 2000,
        syncState: JobVisitSyncState.pending,
      ),
    );

    // Device B edits the photo directly into the backend store.
    await backend.upsertVisit(
      baselineSynced.copyWith(
        photoPath: '/device-b/photo.png',
        photoUpdatedAt: 2000,
        deviceId: 'device-b',
      ),
    );

    final engine = SyncEngine(
      repository: repository,
      backend: backend,
      merger: merger,
    );

    final result = await engine.sync();

    expect(result.succeeded, isTrue);

    final local = await repository.getById('visit-1');
    expect(local!.status, JobVisitStatus.onSite, reason: "A's status survived");
    expect(local.photoPath, '/device-b/photo.png',
        reason: "B's photo survived the push-first trap");
    expect(local.photoUpdatedAt, 2000);
    expect(local.statusUpdatedAt, 2000);
    expect(local.syncState, JobVisitSyncState.synced,
        reason: 'different fields → clean merge, not a conflict');

    // The backend must also hold the merged record (merged, not A's raw push).
    final remote = await backend.getVisit('visit-1');
    expect(remote!.status, JobVisitStatus.onSite);
    expect(remote.photoPath, '/device-b/photo.png');

    // Baseline advanced to the merged values.
    final nextBase = BaseSnapshot.fromJsonString(local.baseSnapshot!);
    expect(nextBase.status.updatedAt, 2000);
    expect(nextBase.photo.updatedAt, 2000);
  });

  test('sticky state: conflict_resolved stays put on a later no-op sync', () async {
    final baseline = syncedBaseline(makeVisit());
    await repository.upsert(baseline);
    await backend.upsertVisit(baseline);

    // A and B both edit status → real conflict.
    await repository.upsert(
      baseline.copyWith(
        status: JobVisitStatus.onSite,
        statusUpdatedAt: 2000,
        syncState: JobVisitSyncState.pending,
      ),
    );
    await backend.upsertVisit(
      baseline.copyWith(
        status: JobVisitStatus.completed,
        statusUpdatedAt: 3000,
        deviceId: 'device-b',
      ),
    );

    final engine = SyncEngine(
      repository: repository,
      backend: backend,
      merger: merger,
    );

    expect((await engine.sync()).succeeded, isTrue);
    expect(
      (await repository.getById('visit-1'))!.syncState,
      JobVisitSyncState.conflictResolved,
    );

    // Nothing changed anywhere; a second sync must NOT reset the flag.
    final second = await engine.sync();
    expect(second.synced, 0);
    expect(
      (await repository.getById('visit-1'))!.syncState,
      JobVisitSyncState.conflictResolved,
      reason: 'non-participating visits must be skipped, never rewritten',
    );
  });

  test('first sync of a locally-created visit pushes it and sets a baseline',
      () async {
    final created = makeVisit(
      id: 'fresh',
      syncState: JobVisitSyncState.pending,
      base: null,
    );
    await repository.upsert(created);

    final engine = SyncEngine(
      repository: repository,
      backend: backend,
      merger: merger,
    );

    final result = await engine.sync();

    expect(result.succeeded, isTrue);
    expect(result.synced, 1);

    final local = await repository.getById('fresh');
    expect(local!.syncState, JobVisitSyncState.synced);
    expect(local.baseSnapshot, isNotNull);

    final remote = await backend.getVisit('fresh');
    expect(remote, isNotNull);
    expect(remote!.id, 'fresh');
    expect(remote.syncState, JobVisitSyncState.synced);
  });

  test('remote-created visit (not local) is pulled and inserted locally', () async {
    final remoteOnly = syncedBaseline(
      makeVisit(
        id: 'remote-only',
        status: JobVisitStatus.completed,
        statusUpdatedAt: 5000,
      ),
    );
    await backend.upsertVisit(remoteOnly);

    final engine = SyncEngine(
      repository: repository,
      backend: backend,
      merger: merger,
    );

    final result = await engine.sync();

    expect(result.succeeded, isTrue);
    final local = await repository.getById('remote-only');
    expect(local, isNotNull);
    expect(local!.status, JobVisitStatus.completed);
    expect(local.syncState, JobVisitSyncState.synced);
  });

  test('mid-batch failure: earlier rows stay synced, later rows stay pending',
      () async {
    for (var i = 0; i < 3; i++) {
      await repository.upsert(
        makeVisit(
          id: 'visit-$i',
          syncState: JobVisitSyncState.pending,
          base: null,
        ),
      );
    }

    final engine = SyncEngine(
      repository: repository,
      backend: backend,
      merger: merger,
    );
    backend.failAfterRecords(2);

    final result = await engine.sync();

    expect(result.succeeded, isFalse);
    expect(result.synced, 2);

    expect(
      (await repository.getById('visit-0'))!.syncState,
      JobVisitSyncState.synced,
    );
    expect(
      (await repository.getById('visit-1'))!.syncState,
      JobVisitSyncState.synced,
    );
    final failed = await repository.getById('visit-2');
    expect(failed!.syncState, JobVisitSyncState.pending,
        reason: 'row at the failure point stays pending, nothing committed');

    // Next run (injection disarmed) only retries the still-pending row.
    backend.failAfterRecords(null);
    final retry = await engine.sync();
    expect(retry.succeeded, isTrue);
    expect(retry.synced, 1);
    expect(
      (await repository.getById('visit-2'))!.syncState,
      JobVisitSyncState.synced,
    );
  });

  test('single-flight: a second sync call while running is ignored', () async {
    for (var i = 0; i < 3; i++) {
      await repository.upsert(
        makeVisit(
          id: 'visit-$i',
          syncState: JobVisitSyncState.pending,
          base: null,
        ),
      );
    }

    // Slow backend: waits for a latch on the *first* upsert so the test can
    // observe a genuinely overlapping sync() invocation.
    final latch = Completer<void>();
    final gatedBackend = _GatedBackend(backend, latch);

    final engine = SyncEngine(
      repository: repository,
      backend: gatedBackend,
      merger: merger,
    );

    final first = engine.sync();
    await gatedBackend.firstUpsertStarted.future;
    final second = await engine.sync();
    latch.complete();
    await first;

    expect(second.synced, 0, reason: 'single-flight guard swallowed the second run');
    expect(second.skipped, isTrue, reason: 'must be distinguishable from a real 0-synced run');
  });

  test('backend requires an auth token and records what it attached', () async {
    final noToken = await backend.getVisit('visit-1');
    expect(noToken, isNull);
    expect(
      backend.lastAttachedRequestHeaders?['authorization'],
      startsWith('Bearer test-token'),
    );
  });

  test('onEvent narrates each protocol step for the developer log', () async {
    final baseline = syncedBaseline(makeVisit());
    await repository.upsert(baseline);
    await backend.upsertVisit(baseline);

    await repository.upsert(
      baseline.copyWith(
        status: JobVisitStatus.onSite,
        statusUpdatedAt: 2000,
        syncState: JobVisitSyncState.pending,
      ),
    );
    await backend.upsertVisit(
      baseline.copyWith(
        photoPath: '/device-b/photo.png',
        photoUpdatedAt: 2000,
        deviceId: 'device-b',
      ),
    );

    final events = <String>[];
    final engine = SyncEngine(
      repository: repository,
      backend: backend,
      merger: merger,
      onEvent: events.add,
    );

    await engine.sync();

    final logText = events.join('\n');
    expect(logText, contains('sync run:'));
    expect(logText, contains('[visit-1] pull:'));
    expect(logText, contains('[visit-1] merge: clean'));
    expect(logText, contains('local changed status'));
    expect(logText, contains('remote changed photo'));
    expect(logText, contains('[visit-1] push: merged record accepted'));
    expect(logText, contains('[visit-1] commit: row + baseSnapshot'));
    expect(logText, contains('sync run: done — 1 visit(s) synced'));
  });
}

class _GatedBackend implements SyncBackend {
  _GatedBackend(this.inner, this.latch);

  final MockSyncService inner;
  final Completer<void> latch;
  final Completer<void> firstUpsertStarted = Completer<void>();
  bool _gated = false;

  @override
  Future<JobVisit?> getVisit(String id) => inner.getVisit(id);

  @override
  Future<List<JobVisit>> getAllVisits() => inner.getAllVisits();

  @override
  Future<void> upsertVisit(JobVisit visit) async {
    if (!_gated) {
      _gated = true;
      firstUpsertStarted.complete();
      await latch.future;
    }
    await inner.upsertVisit(visit);
  }
}