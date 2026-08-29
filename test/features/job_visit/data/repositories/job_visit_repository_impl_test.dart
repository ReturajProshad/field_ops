import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:field_ops/features/job_visit/data/local/app_database.dart';
import 'package:field_ops/features/job_visit/data/repositories/job_visit_repository_impl.dart';
import 'package:field_ops/features/job_visit/domain/entities/job_visit.dart';

void main() {
  late AppDatabase db;
  late JobVisitRepositoryImpl repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = JobVisitRepositoryImpl(db);
  });

  tearDown(() => db.close());

  JobVisit makeVisit({
    String id = 'visit-1',
    JobVisitStatus status = JobVisitStatus.enRoute,
    int createdAt = 1000,
    String? photoPath,
    Set<String>? otherIds,
  }) {
    return JobVisit(
      id: id,
      createdAt: createdAt,
      status: status,
      statusUpdatedAt: createdAt,
      syncState: JobVisitSyncState.pending,
      deviceId: 'device-a',
      photoPath: photoPath,
      photoUpdatedAt: photoPath != null ? createdAt : null,
    );
  }

  test('upsert creates a visit readable via watch and getById', () async {
    final visit = makeVisit();

    await repository.upsert(visit);

    expect(await repository.getById('visit-1'), isNotNull);
    expect((await repository.getById('visit-1'))!.status, JobVisitStatus.enRoute);

    final streamed = await repository.watchAll().first;
    expect(streamed, hasLength(1));
    expect(streamed.single.id, 'visit-1');
    expect(streamed.single.syncState, JobVisitSyncState.pending);
  });

  test('create then offline edit (status change) persists the edited visit',
      () async {
    final created = makeVisit();
    await repository.upsert(created);

    final edited = created.copyWith(
      status: JobVisitStatus.onSite,
      statusUpdatedAt: 2000,
      syncState: JobVisitSyncState.pending,
    );
    await repository.upsert(edited);

    final stored = await repository.getById('visit-1');
    expect(stored!.status, JobVisitStatus.onSite);
    expect(stored.statusUpdatedAt, 2000);
    expect(stored.createdAt, 1000); // created-once value untouched
  });

  test('update does not silently change baseSnapshot or deviceId', () async {
    final created = makeVisit();
    await repository.upsert(created);

    final edited = created.copyWith(baseSnapshot: '{"status":"x"}');
    await repository.upsert(edited);

    final stored = await repository.getById('visit-1');
    expect(stored!.baseSnapshot, '{"status":"x"}');
    expect(stored.deviceId, 'device-a');
  });

  test('watchAll reorders by newest createdAt and watchById emits updates',
      () async {
    final older = makeVisit(id: 'visit-old', createdAt: 1000);
    final newer = makeVisit(id: 'visit-new', createdAt: 2000);
    await repository.upsert(older);
    await repository.upsert(newer);

    final streamed = await repository.watchAll().first;
    expect(streamed.map((v) => v.id).toList(), ['visit-new', 'visit-old']);

    final singleStream = repository.watchById('visit-old');
    final first = await singleStream.first;
    expect(first!.id, 'visit-old');
  });

  test('upsert overwrites by id (edit is idempotent per id)', () async {
    await repository.upsert(makeVisit());
    await repository.upsert(makeVisit(status: JobVisitStatus.completed, createdAt: 1000));

    final all = await repository.watchAll().first;
    expect(all, hasLength(1));
    expect(all.single.status, JobVisitStatus.completed);
  });
}