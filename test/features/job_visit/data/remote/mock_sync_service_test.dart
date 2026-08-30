import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:field_ops/features/job_visit/data/remote/mock_sync_service.dart';
import 'package:field_ops/features/job_visit/data/remote/sync_backend.dart';
import 'package:field_ops/features/job_visit/domain/entities/job_visit.dart';

void main() {
  late Directory tempDir;
  late File backendFile;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('field_ops_backend_test');
    backendFile = File('${tempDir.path}/backend.json');
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  MockSyncService backend({String? token}) => MockSyncService(
        file: backendFile,
        tokenProvider: () async => token,
      );

  JobVisit visit({String id = 'visit-1'}) => JobVisit(
        id: id,
        createdAt: 1000,
        status: JobVisitStatus.enRoute,
        statusUpdatedAt: 1000,
        syncState: JobVisitSyncState.synced,
        deviceId: 'device-a',
      );

  test('upsert → getVisit and getAllVisits round-trip', () async {
    final service = backend(token: 'token-a');

    await service.upsertVisit(visit());

    expect((await service.getVisit('visit-1'))!.status, JobVisitStatus.enRoute);
    expect(await service.getVisit('missing'), isNull);
    expect(await service.getAllVisits(), hasLength(1));
  });

  test('records persist across a fresh service instance (app restart)', () async {
    final first = backend(token: 'token-a');
    await first.upsertVisit(visit());
    await first.upsertVisit(visit(id: 'visit-2'));

    // "Relaunch": a brand-new service reading the same JSON file.
    final second = backend(token: 'token-b');
    expect(await second.getAllVisits(), hasLength(2));
    expect((await second.getVisit('visit-2'))!.id, 'visit-2');

    // The on-disk store is real JSON, not empty.
    expect(await backendFile.readAsString(), contains('visit-1'));
  });

  test('auth token is required and attached to every request', () async {
    final service = backend(token: 'secret-token');

    await service.upsertVisit(visit());
    expect(
      service.lastAttachedRequestHeaders?['authorization'],
      'Bearer secret-token',
    );

    final unauthenticated = backend(token: null);
    expect(
      () => unauthenticated.upsertVisit(visit(id: 'visit-2')),
      throwsA(isA<SyncBackendException>()),
    );
  });

  test('failure injection throws after N records and is disarmable', () async {
    final service = backend(token: 'token-a');
    service.failAfterRecords(2);

    await service.upsertVisit(visit(id: 'a'));
    await service.upsertVisit(visit(id: 'b'));

    await expectLater(
      service.upsertVisit(visit(id: 'c')),
      throwsA(isA<SyncBackendException>()),
    );

    // Disarm and confirm the store still works.
    service.failAfterRecords(null);
    await service.upsertVisit(visit(id: 'c'));
    expect(await service.getAllVisits(), hasLength(3));
  });

  test('corrupt backend file is quarantined, not silently treated as empty',
      () async {
    // Simulate a crash mid-write: truncated/non-JSON contents.
    await backendFile.writeAsString('{"visit-1": {"id": "visit-1", ');

    final service = backend(token: 'token-a');
    await service.upsertVisit(visit(id: 'fresh'));

    // Fresh store is usable, and the corrupt file was moved aside — the next
    // clean sync will NOT overwrite the corrupted history in place.
    expect((await service.getVisit('fresh'))!.id, 'fresh');
    expect(await backendFile.exists(), isTrue);
    expect(await backendFile.readAsString(), contains('fresh'));
    expect(await File('${backendFile.path}.corrupt').exists(), isTrue);
  });
}