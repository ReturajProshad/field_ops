import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:field_ops/core/di/database_provider.dart';
import 'package:field_ops/core/router/app_router.dart';
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

  Future<void> seed({
    JobVisitStatus status = JobVisitStatus.onSite,
    JobVisitSyncState syncState = JobVisitSyncState.synced,
    int createdAt = 1000,
  }) async {
    await repository.upsert(
      JobVisit(
        id: 'v-$createdAt-${syncState.name}',
        createdAt: createdAt,
        status: status,
        statusUpdatedAt: createdAt,
        syncState: syncState,
        deviceId: 'device-a',
      ),
    );
  }

  Future<void> pumpList(WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: MaterialApp.router(routerConfig: buildTestRouter()),
    ));
    await tester.pumpAndSettle();
  }

  double yOf(WidgetTester tester, String key) {
    return tester.getTopLeft(find.byKey(Key(key))).dy;
  }

  /// Mirrors the existing repo pattern: drift's stream-query timer must be
  /// fully torn down before the test body returns. Closing in-body (not in
  /// tearDown) and unmounting the tree avoids the pending-timer assertion.
  Future<void> teardownWidget(WidgetTester tester) async {
    await db.close();
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  }

  testWidgets('all three sync states render on the list', (tester) async {
    await seed(syncState: JobVisitSyncState.pending, createdAt: 3000);
    await seed(syncState: JobVisitSyncState.conflictResolved, createdAt: 2000);
    await seed(syncState: JobVisitSyncState.synced, createdAt: 1000);

    await pumpList(tester);

    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('Conflict resolved'), findsOneWidget);
    expect(find.text('Synced'), findsOneWidget);

    await teardownWidget(tester);
  });

  testWidgets('sort by sync state: pending → conflict → synced', (tester) async {
    await seed(syncState: JobVisitSyncState.pending, createdAt: 1000);
    await seed(syncState: JobVisitSyncState.synced, createdAt: 2000);
    await seed(syncState: JobVisitSyncState.conflictResolved, createdAt: 3000);

    await pumpList(tester);

    // Default mode is by status; switch to by sync state.
    await tester.tap(find.text('By sync state'));
    await tester.pumpAndSettle();

    // Pending first, conflict second, synced third.
    final pendingY = yOf(tester, 'sync_chip_v-1000-pending');
    final conflictY = yOf(tester, 'sync_chip_v-3000-conflictResolved');
    final syncedY = yOf(tester, 'sync_chip_v-2000-synced');

    expect(pendingY, lessThan(conflictY));
    expect(conflictY, lessThan(syncedY));

    await teardownWidget(tester);
  });

  testWidgets('sort by status groups by enum order with newest first',
      (tester) async {
    await seed(
        status: JobVisitStatus.enRoute,
        syncState: JobVisitSyncState.pending,
        createdAt: 5000);
    await seed(
        status: JobVisitStatus.completed,
        syncState: JobVisitSyncState.synced,
        createdAt: 4000);
    await seed(
        status: JobVisitStatus.onSite,
        syncState: JobVisitSyncState.conflictResolved,
        createdAt: 3000);

    await pumpList(tester);

    // Default sort is by status: enRoute, onSite, completed.
    final enY = yOf(tester, 'sync_chip_v-5000-pending');
    final onY = yOf(tester, 'sync_chip_v-3000-conflictResolved');
    final completedY = yOf(tester, 'sync_chip_v-4000-synced');

    expect(enY, lessThan(onY));
    expect(onY, lessThan(completedY));

    await teardownWidget(tester);
  });

  testWidgets('pending sorts above conflict > synced regardless of status group',
      (tester) async {
    await seed(
        status: JobVisitStatus.enRoute,
        syncState: JobVisitSyncState.synced,
        createdAt: 100);
    await seed(
        status: JobVisitStatus.completed,
        syncState: JobVisitSyncState.pending,
        createdAt: 200);
    await seed(
        status: JobVisitStatus.blocked,
        syncState: JobVisitSyncState.conflictResolved,
        createdAt: 300);

    await pumpList(tester);
    await tester.tap(find.text('By sync state'));
    await tester.pumpAndSettle();

    final pendingY = yOf(tester, 'sync_chip_v-200-pending');
    final conflictY = yOf(tester, 'sync_chip_v-300-conflictResolved');
    final syncedY = yOf(tester, 'sync_chip_v-100-synced');

    expect(pendingY, lessThan(conflictY));
    expect(conflictY, lessThan(syncedY));

    await teardownWidget(tester);
  });
}