import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:field_ops/core/di/database_provider.dart';
import 'package:field_ops/features/job_visit/data/local/app_database.dart';
import 'package:field_ops/main.dart';

ProviderScope buildTestApp(AppDatabase db) {
  return ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
    ],
    child: const FieldOpsApp(),
  );
}

void main() {
  testWidgets('app boots to the job visit list (empty state)', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(() => db.close());

    await tester.pumpWidget(buildTestApp(db));
    await tester.pumpAndSettle();

    expect(find.text('Job Visits'), findsOneWidget);
    expect(find.textContaining('No job visits yet'), findsOneWidget);

    // Close the DB (cancels the drift stream) and unmount before the binding
    // checks for pending timers.
    await db.close();
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}