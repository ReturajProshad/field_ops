import '../local/app_database.dart';

/// Location-tick persistence boundary. Backs the background tracking trail
/// (Phases 9–10). Deliberately tiny — insert + watch, nothing more.
class LocationPointRepository {
  const LocationPointRepository(this._db);

  final AppDatabase _db;

  /// Persists one tick from the tracking service's platform channel. Callers
  /// build the [LocationPointsCompanion]; this only writes it.
  Future<void> insert(LocationPointsCompanion point) {
    return _db.insertLocationPoint(point);
  }

  /// Live trail for a visit, oldest first.
  Stream<List<LocationPoint>> watchByVisit(String visitId) {
    return _db.watchLocationPointsByVisit(visitId);
  }
}