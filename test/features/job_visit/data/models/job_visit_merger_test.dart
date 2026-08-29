import 'package:flutter_test/flutter_test.dart';

import 'package:field_ops/features/job_visit/data/models/base_snapshot.dart';
import 'package:field_ops/features/job_visit/data/models/job_visit_merger.dart';
import 'package:field_ops/features/job_visit/domain/entities/job_visit.dart';

void main() {
  const merger = JobVisitMerger();

  JobVisit make(
    JobVisit from, {
    JobVisitStatus? status,
    int? statusUpdatedAt,
    double? gpsLat,
    double? gpsLng,
    int? gpsUpdatedAt,
    String? photoPath,
    int? photoUpdatedAt,
    JobVisitSyncState? syncState,
    String deviceId = 'device-a',
    String? baseSnapshot,
  }) {
    return JobVisit(
      id: from.id,
      createdAt: from.createdAt,
      status: status ?? from.status,
      statusUpdatedAt: statusUpdatedAt ?? from.statusUpdatedAt,
      gpsLat: gpsLat ?? from.gpsLat,
      gpsLng: gpsLng ?? from.gpsLng,
      gpsUpdatedAt: gpsUpdatedAt ?? from.gpsUpdatedAt,
      photoPath: photoPath ?? from.photoPath,
      photoUpdatedAt: photoUpdatedAt ?? from.photoUpdatedAt,
      syncState: syncState ?? from.syncState,
      deviceId: deviceId,
      baseSnapshot: baseSnapshot ?? from.baseSnapshot,
    );
  }

  JobVisit base({
    JobVisitStatus status = JobVisitStatus.enRoute,
    String deviceId = 'device-a',
  }) {
    return JobVisit(
      id: 'visit-1',
      createdAt: 1000,
      status: status,
      statusUpdatedAt: 1000,
      gpsLat: 1.0,
      gpsLng: 2.0,
      gpsUpdatedAt: 1000,
      photoPath: '/base.png',
      photoUpdatedAt: 1000,
      syncState: JobVisitSyncState.synced,
      deviceId: deviceId,
    );
  }

  /// The last-synced snapshot for [v], as a visit whose [JobVisit.baseSnapshot]
  /// records it — what the local DB holds after a successful sync.
  JobVisit synced(JobVisit v) => v.copyWith(
        syncState: JobVisitSyncState.synced,
        baseSnapshot: BaseSnapshot.fromVisit(v).toJsonString(),
      );

  group('three-way merge', () {
    test('(a) different fields edited on both sides → clean merge, synced',
        () {
      final last = synced(base());

      final local = make(last,
          status: JobVisitStatus.onSite, statusUpdatedAt: 2000);
      final remote = make(last,
          gpsLat: 3.0, gpsLng: 4.0, gpsUpdatedAt: 2000, deviceId: 'device-b');

      final result = merger.merge(local: local, remote: remote);

      expect(result.conflictedFields, isEmpty);
      expect(result.merged.syncState, JobVisitSyncState.synced);
      expect(result.merged.status, JobVisitStatus.onSite);
      expect(result.merged.statusUpdatedAt, 2000);
      expect(result.merged.gpsLat, 3.0);
      expect(result.merged.gpsLng, 4.0);
      expect(result.merged.gpsUpdatedAt, 2000);
      expect(result.merged.photoPath, '/base.png');
    });

    test('(b) same field edited on both sides → LWW + conflict_resolved', () {
      final last = synced(base());

      final local = make(last,
          status: JobVisitStatus.onSite, statusUpdatedAt: 2000);
      final remote = make(last,
          status: JobVisitStatus.completed,
          statusUpdatedAt: 3000,
          deviceId: 'device-b');

      final result = merger.merge(local: local, remote: remote);

      expect(result.conflictedFields, {MergeField.status});
      expect(result.merged.syncState, JobVisitSyncState.conflictResolved);
      expect(result.merged.status, JobVisitStatus.completed);
      expect(result.merged.statusUpdatedAt, 3000);
    });

    test('(c) field edited on one side only → kept, no conflict', () {
      final last = synced(base());

      final local = make(last,
          status: JobVisitStatus.onSite, statusUpdatedAt: 2000, deviceId: 'device-a');
      final remote = make(last, deviceId: 'device-b');

      final result = merger.merge(local: local, remote: remote);

      expect(result.conflictedFields, isEmpty);
      expect(result.merged.syncState, JobVisitSyncState.synced);
      expect(result.merged.status, JobVisitStatus.onSite);
    });

    test('(d) equal timestamps on same field → lexically smaller deviceId wins',
        () {
      final last = synced(base(deviceId: 'device-a'));

      final local = make(last,
          status: JobVisitStatus.onSite, statusUpdatedAt: 2000, deviceId: 'device-a');
      final remote = make(last,
          status: JobVisitStatus.completed,
          statusUpdatedAt: 2000,
          deviceId: 'device-b');

      final result = merger.merge(local: local, remote: remote);

      expect(result.conflictedFields, {MergeField.status});
      expect(result.merged.syncState, JobVisitSyncState.conflictResolved);
      expect(result.merged.status, JobVisitStatus.onSite);
    });

    test('(d-reverse) smaller deviceId on remote side wins the tie', () {
      final last = synced(base(deviceId: 'device-b'));

      final local = make(last,
          status: JobVisitStatus.onSite, statusUpdatedAt: 2000, deviceId: 'device-b');
      final remote = make(last,
          status: JobVisitStatus.completed,
          statusUpdatedAt: 2000,
          deviceId: 'device-a');

      final result = merger.merge(local: local, remote: remote);

      expect(result.merged.status, JobVisitStatus.completed);
      expect(result.merged.syncState, JobVisitSyncState.conflictResolved);
    });

    test('(e) clean pull with no local changes → remote wins, synced, no flag',
        () {
      final last = synced(base());

      final local = make(last, deviceId: 'device-a');
      final remote = make(last,
          status: JobVisitStatus.completed,
          statusUpdatedAt: 2000,
          deviceId: 'device-b');

      final result = merger.merge(local: local, remote: remote);

      expect(result.conflictedFields, isEmpty);
      expect(result.merged.syncState, JobVisitSyncState.synced);
      expect(result.merged.status, JobVisitStatus.completed);
    });

    test('(f) A changes status, B changes photo → both survive', () {
      final last = synced(base());

      final local = make(last,
          status: JobVisitStatus.onSite, statusUpdatedAt: 2000, deviceId: 'device-a');
      final remote = make(last,
          photoPath: '/b.png', photoUpdatedAt: 2000, deviceId: 'device-b');

      final result = merger.merge(local: local, remote: remote);

      expect(result.conflictedFields, isEmpty);
      expect(result.merged.syncState, JobVisitSyncState.synced);
      expect(result.merged.status, JobVisitStatus.onSite);
      expect(result.merged.photoPath, '/b.png');
      expect(result.merged.photoUpdatedAt, 2000);
      expect(result.merged.statusUpdatedAt, 2000);
    });

    test('merged baseSnapshot advances to the merged values', () {
      final last = synced(base());

      final local = make(last,
          status: JobVisitStatus.onSite, statusUpdatedAt: 2000, deviceId: 'device-a');
      final remote = make(last,
          photoPath: '/b.png', photoUpdatedAt: 2000, deviceId: 'device-b');

      final result = merger.merge(local: local, remote: remote);
      final snap = BaseSnapshot.fromJsonString(result.merged.baseSnapshot!);

      expect(snap.status.updatedAt, 2000);
      expect(snap.status.value, JobVisitStatus.onSite.storageValue);
      expect(snap.photo.path, '/b.png');
      expect(snap.photo.updatedAt, 2000);
    });

    test('re-merging a stable record stays synced (no phantom conflict)', () {
      final last = synced(base());

      final local = make(last, deviceId: 'device-a');
      final remote = make(last, deviceId: 'device-b');

      final once = merger.merge(local: local, remote: remote);
      final twice = merger.merge(local: once.merged, remote: remote);

      expect(twice.conflictedFields, isEmpty);
      expect(twice.merged.syncState, JobVisitSyncState.synced);
      expect(twice.merged.status, JobVisitStatus.enRoute);
    });

    test('the no-op re-pull reports participated = false (engine must skip it)',
        () {
      final last = synced(base());

      final local = make(last, deviceId: 'device-a');
      final remote = make(last, deviceId: 'device-b');

      final once = merger.merge(local: local, remote: remote);
      final twice = merger.merge(local: once.merged, remote: remote);

      expect(twice.participated, isFalse);
      expect(twice.localChangedFields, isEmpty);
      expect(twice.remoteChangedFields, isEmpty);
    });

    test('participated is true when either side changed since baseline', () {
      final last = synced(base());

      final remoteOnly = merger.merge(
        local: make(last, deviceId: 'device-a'),
        remote: make(last,
            status: JobVisitStatus.completed,
            statusUpdatedAt: 2000,
            deviceId: 'device-b'),
      );
      expect(remoteOnly.participated, isTrue);
      expect(remoteOnly.remoteChangedFields, hasLength(1));

      final localOnly = merger.merge(
        local: make(last,
            status: JobVisitStatus.onSite, statusUpdatedAt: 2000, deviceId: 'device-a'),
        remote: make(last, deviceId: 'device-b'),
      );
      expect(localOnly.participated, isTrue);
      expect(localOnly.localChangedFields, hasLength(1));
    });

    test('a conflict merge reports both sides changed that field', () {
      final last = synced(base());

      final result = merger.merge(
        local: make(last,
            status: JobVisitStatus.onSite, statusUpdatedAt: 2000, deviceId: 'device-a'),
        remote: make(last,
            status: JobVisitStatus.completed,
            statusUpdatedAt: 3000,
            deviceId: 'device-b'),
      );

      expect(result.participated, isTrue);
      expect(result.localChangedFields, {MergeField.status});
      expect(result.remoteChangedFields, {MergeField.status});
    });

    test('both-null inputs throw a clear contract error, not a null crash',
        () {
      expect(
        () => merger.merge(local: null, remote: null),
        throwsArgumentError,
      );
    });

    test('remote-only gps change is a clean incoming update', () {
      final last = synced(base());

      final local = make(last, deviceId: 'device-a');
      final remote = make(last,
          gpsLat: 9.0, gpsLng: 9.0, gpsUpdatedAt: 2500, deviceId: 'device-b');

      final result = merger.merge(local: local, remote: remote);

      expect(result.conflictedFields, isEmpty);
      expect(result.merged.syncState, JobVisitSyncState.synced);
      expect(result.merged.gpsLat, 9.0);
      expect(result.merged.gpsLng, 9.0);
      expect(result.merged.gpsUpdatedAt, 2500);
    });

    test('local-only photo change survives a remote status change', () {
      final last = synced(base());

      final local = make(last,
          photoPath: '/local.png', photoUpdatedAt: 2000, deviceId: 'device-a');
      final remote = make(last,
          status: JobVisitStatus.blocked,
          statusUpdatedAt: 3000,
          deviceId: 'device-b');

      final result = merger.merge(local: local, remote: remote);

      expect(result.conflictedFields, isEmpty);
      expect(result.merged.syncState, JobVisitSyncState.synced);
      expect(result.merged.photoPath, '/local.png');
      expect(result.merged.status, JobVisitStatus.blocked);
    });
  });

  group('no-baseline branches', () {
    test('(g) local exists, no baseSnapshot yet, remote exists → adopt remote',
        () {
      final local = JobVisit(
        id: 'visit-1',
        createdAt: 1000,
        status: JobVisitStatus.onSite,
        statusUpdatedAt: 2000,
        syncState: JobVisitSyncState.pending,
        deviceId: 'device-a',
      );
      final remote = JobVisit(
        id: 'visit-1',
        createdAt: 1000,
        status: JobVisitStatus.completed,
        statusUpdatedAt: 3000,
        gpsLat: 5.0,
        gpsLng: 6.0,
        gpsUpdatedAt: 3000,
        photoPath: '/remote.png',
        photoUpdatedAt: 3000,
        syncState: JobVisitSyncState.synced,
        deviceId: 'device-b',
      );

      final result = merger.merge(local: local, remote: remote);

      expect(result.conflictedFields, isEmpty);
      expect(result.merged.syncState, JobVisitSyncState.synced);
      expect(result.merged.status, JobVisitStatus.completed);
      expect(result.merged.gpsLat, 5.0);
      expect(result.merged.photoPath, '/remote.png');

      final snap = BaseSnapshot.fromJsonString(result.merged.baseSnapshot!);
      expect(snap.status.updatedAt, 3000);
      expect(snap.photo.path, '/remote.png');
    });

    test('(h) visit exists remotely but not locally → remote adopted as-is', () {
      final remote = JobVisit(
        id: 'remote-only',
        createdAt: 5000,
        status: JobVisitStatus.onSite,
        statusUpdatedAt: 5000,
        gpsLat: 7.0,
        gpsLng: 8.0,
        gpsUpdatedAt: 5000,
        photoPath: '/remote-only.png',
        photoUpdatedAt: 5000,
        syncState: JobVisitSyncState.synced,
        deviceId: 'device-b',
      );

      final result = merger.merge(local: null, remote: remote);

      expect(result.conflictedFields, isEmpty);
      expect(result.merged.syncState, JobVisitSyncState.synced);
      expect(result.merged.status, JobVisitStatus.onSite);
      expect(result.merged.photoPath, '/remote-only.png');
      expect(result.participated, isTrue);

      final snap = BaseSnapshot.fromJsonString(result.merged.baseSnapshot!);
      expect(snap.status.updatedAt, 5000);
      expect(snap.gps.lat, 7.0);
    });

    test('first-ever push (local exists, no remote record) → adopt local', () {
      final local = JobVisit(
        id: 'fresh',
        createdAt: 100,
        status: JobVisitStatus.enRoute,
        statusUpdatedAt: 100,
        photoPath: '/fresh.png',
        photoUpdatedAt: 100,
        syncState: JobVisitSyncState.pending,
        deviceId: 'device-a',
      );

      final result = merger.merge(local: local, remote: null);

      expect(result.merged.syncState, JobVisitSyncState.synced);
      expect(result.merged.id, 'fresh');
      expect(result.merged.deviceId, 'device-a');
      expect(result.participated, isTrue);

      final snap = BaseSnapshot.fromJsonString(result.merged.baseSnapshot!);
      expect(snap.photo.path, '/fresh.png');
      expect(snap.status.updatedAt, 100);
    });

    test('never-synced, no remote record, no baseSnapshot → adopt local', () {
      final local = JobVisit(
        id: 'naked',
        createdAt: 10,
        status: JobVisitStatus.onSite,
        statusUpdatedAt: 10,
        syncState: JobVisitSyncState.pending,
        deviceId: 'device-a',
      );

      final result = merger.merge(local: local, remote: null);

      expect(result.merged.syncState, JobVisitSyncState.synced);
      expect(result.merged.status, JobVisitStatus.onSite);
      expect(result.merged.baseSnapshot, isNotNull);
      expect(result.participated, isTrue);
    });
  });

  group('baseSnapshot serialization', () {
    test('round-trips all three fields with int-ms timestamps', () {
      final v = base();
      final encoded =
          BaseSnapshot.fromVisit(v).toJsonString();
      final decoded = BaseSnapshot.fromJsonString(encoded);

      expect(decoded.status.value, JobVisitStatus.enRoute.storageValue);
      expect(decoded.status.updatedAt, 1000);
      expect(decoded.gps.lat, 1.0);
      expect(decoded.gps.lng, 2.0);
      expect(decoded.gps.updatedAt, 1000);
      expect(decoded.photo.path, '/base.png');
      expect(decoded.photo.updatedAt, 1000);
    });
  });
}