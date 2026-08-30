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

  /// Appends a location tick. The *only* persistence path for the background
  /// tracking service — `JobVisits.gpsLat/gpsLng/gpsUpdatedAt` are NEVER
  /// touched by tracking (memory.md rule), so sync never sees a per-tick GPS
  /// change.
  Future<void> insertLocationPoint(LocationPointsCompanion point) {
    return into(locationPoints).insert(point);
  }

  /// Live trail for one visit, oldest first — the trail indicator's data
  /// source (Phases 9–10).
  Stream<List<LocationPoint>> watchLocationPointsByVisit(String visitId) {
    final query = select(locationPoints)
      ..where((t) => t.jobVisitId.equals(visitId))
      ..orderBy([(t) => OrderingTerm.asc(t.capturedAt)]);
    return query.watch();
  }
}
