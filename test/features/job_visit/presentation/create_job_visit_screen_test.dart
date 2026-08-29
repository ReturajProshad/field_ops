import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:field_ops/core/di/database_provider.dart';
import 'package:field_ops/core/router/app_router.dart';
import 'package:field_ops/features/job_visit/data/local/app_database.dart';
import 'package:field_ops/features/job_visit/presentation/providers/job_visit_providers.dart';
import 'package:field_ops/services/location/current_location.dart';

void main() {
  testWidgets('create visit flow: capture gps, save, land on detail', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    // Best-effort: guarantees the DB closes even if an expect fails mid-test.
    // A plain addTearDown(db.close) alone deadlocks here — drift's close does
    // real async work that the test binding never pumps post-body — so the
    // in-body close below runs first and the teardown is then a safe no-op
    // (drift close is idempotent).
    addTearDown(db.close);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        currentLocationProvider.overrideWithValue(
          _FakeLocation(const CurrentPosition(lat: 10.5, lng: 20.5)),
        ),
      ],
      child: MaterialApp.router(routerConfig: buildTestRouter()),
    ));
    await tester.pumpAndSettle();

    // Start on the list (empty). Navigate to create.
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('New Job Visit'), findsOneWidget);

    // GPS capture runs off the fake provider.
    expect(find.textContaining('10.5'), findsOneWidget);

    // Save.
    await tester.tap(find.text('Create visit'));
    await tester.pumpAndSettle();

    // Now on detail screen for that visit.
    expect(find.text('Job Visit'), findsOneWidget);

    await db.close();
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets('create visit flow: no GPS available, still creates', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        currentLocationProvider.overrideWithValue(_FakeLocation(null)),
      ],
      child: MaterialApp.router(routerConfig: buildTestRouter()),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('GPS not captured'), findsOneWidget);

    await tester.tap(find.text('Create visit'));
    await tester.pumpAndSettle();

    expect(find.text('Job Visit'), findsOneWidget);

    await db.close();
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}

class _FakeLocation implements CurrentLocation {
  _FakeLocation(this._result);

  final CurrentPosition? _result;

  @override
  Future<CurrentPosition?> fetch() async => _result;
}