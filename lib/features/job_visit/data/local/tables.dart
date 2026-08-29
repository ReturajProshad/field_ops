import 'package:drift/drift.dart';

/// Drift would otherwise generate the row class as `JobVisit`, colliding with
/// the domain entity `JobVisit` — so the row is explicitly named `JobVisitRow`.
@DataClassName('JobVisitRow')
class JobVisits extends Table {
  TextColumn get id => text()();
  IntColumn get createdAt => integer()();
  TextColumn get status => text()(); // JobVisitStatus.storageValue
  IntColumn get statusUpdatedAt => integer()();
  RealColumn get gpsLat => real().nullable()();
  RealColumn get gpsLng => real().nullable()();
  IntColumn get gpsUpdatedAt => integer().nullable()();
  TextColumn get photoPath => text().nullable()();
  IntColumn get photoUpdatedAt => integer().nullable()();
  TextColumn get syncState => text()(); // JobVisitSyncState.storageValue
  TextColumn get deviceId => text()();
  TextColumn get baseSnapshot => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class LocationPoints extends Table {
  TextColumn get id => text()();
  TextColumn get jobVisitId => text().references(JobVisits, #id)();
  RealColumn get lat => real()();
  RealColumn get lng => real()();
  IntColumn get capturedAt => integer()();
  IntColumn get accuracyMeters => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
