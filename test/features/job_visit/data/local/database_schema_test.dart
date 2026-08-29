import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:field_ops/features/job_visit/data/local/app_database.dart';
import 'package:field_ops/features/job_visit/domain/entities/job_visit.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('field_ops_test');
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  test('schema survives a close/reopen (persists across restart)', () async {
    final file = File('${tempDir.path}/field_ops_test.db');

    final db1 = AppDatabase(NativeDatabase(file));
    await db1
        .into(db1.jobVisits)
        .insert(JobVisitsCompanion.insert(
          id: 'visit-1',
          createdAt: 1000,
          status: JobVisitStatus.enRoute.storageValue,
          statusUpdatedAt: 1000,
          syncState: JobVisitSyncState.pending.storageValue,
          deviceId: 'device-a',
        ));
    await db1.close();

    final db2 = AppDatabase(NativeDatabase(file));
    final rows = await db2.select(db2.jobVisits).get();
    expect(rows, hasLength(1));
    expect(rows.single.id, 'visit-1');
    expect(rows.single.syncState, 'pending');
    expect(rows.single.baseSnapshot, isNull);
    await db2.close();
  });

  test('LocationPoints stay on the separate table, not JobVisits', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await db
        .into(db.jobVisits)
        .insert(JobVisitsCompanion.insert(
          id: 'visit-1',
          createdAt: 1000,
          status: JobVisitStatus.onSite.storageValue,
          statusUpdatedAt: 2000,
          syncState: JobVisitSyncState.synced.storageValue,
          deviceId: 'device-a',
          gpsLat: const Value(40.0),
          gpsLng: const Value(-73.0),
          gpsUpdatedAt: const Value(2000),
        ));

    final ts = DateTime.now().millisecondsSinceEpoch;
    await db
        .into(db.locationPoints)
        .insert(LocationPointsCompanion.insert(
          id: 'point-1',
          jobVisitId: 'visit-1',
          lat: 40.0001,
          lng: -73.0001,
          capturedAt: ts,
        ));

    final points = await (db.select(db.locationPoints)
      ..where((p) => p.jobVisitId.equals('visit-1')))
    .get();
    expect(points, hasLength(1));
    expect(points.single.capturedAt, ts);
  });

  test('LocationPoints FK is enforced (points must belong to a visit)', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await expectLater(
      db.locationPoints.insertOne(LocationPointsCompanion.insert(
        id: 'orphan',
        jobVisitId: 'no-such-visit',
        lat: 10.0,
        lng: 20.0,
        capturedAt: 1000,
      )),
      throwsA(anything),
    );
  });

  test('enum storage round-trips through their exact strings', () {
    expect(JobVisitStatus.enRoute.storageValue, 'enRoute');
    expect(JobVisitStatus.completed.storageValue, 'completed');

    expect(JobVisitSyncState.pending.storageValue, 'pending');
    expect(JobVisitSyncState.conflictResolved.storageValue, 'conflict_resolved');

    expect(JobVisitStatus.fromStorage('onSite'), JobVisitStatus.onSite);
    expect(
      JobVisitSyncState.fromStorage('conflict_resolved'),
      JobVisitSyncState.conflictResolved,
    );
  });
}