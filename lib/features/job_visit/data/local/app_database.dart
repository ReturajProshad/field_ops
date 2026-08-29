import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [JobVisits, LocationPoints])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);
  factory AppDatabase.open() {
    return AppDatabase(driftDatabase(name: 'field_ops'));
  }

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
