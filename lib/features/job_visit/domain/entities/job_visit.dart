enum JobVisitStatus {
  enRoute,
  onSite,
  completed,
  blocked;

  String get storageValue => name;

  static JobVisitStatus fromStorage(String value) => values.byName(value);
}

enum JobVisitSyncState {
  pending,
  synced,
  conflictResolved;

  String get storageValue => switch (this) {
    JobVisitSyncState.pending => 'pending',
    JobVisitSyncState.synced => 'synced',
    JobVisitSyncState.conflictResolved => 'conflict_resolved',
  };

  static JobVisitSyncState fromStorage(String value) => switch (value) {
    'pending' => JobVisitSyncState.pending,
    'synced' => JobVisitSyncState.synced,
    'conflict_resolved' => JobVisitSyncState.conflictResolved,
    _ => throw ArgumentError.value(value, 'value', 'Unknown sync state'),
  };
}

class JobVisit {
  final String id;
  final int createdAt;

  final JobVisitStatus status;
  final int statusUpdatedAt;

  final double? gpsLat;
  final double? gpsLng;
  final int? gpsUpdatedAt;

  final String? photoPath;
  final int? photoUpdatedAt;

  final JobVisitSyncState syncState;
  final String deviceId;

  final String? baseSnapshot;

  const JobVisit({
    required this.id,
    required this.createdAt,
    required this.status,
    required this.statusUpdatedAt,
    this.gpsLat,
    this.gpsLng,
    this.gpsUpdatedAt,
    this.photoPath,
    this.photoUpdatedAt,
    required this.syncState,
    required this.deviceId,
    this.baseSnapshot,
  });

  JobVisit copyWith({
    String? id,
    int? createdAt,
    JobVisitStatus? status,
    int? statusUpdatedAt,
    double? gpsLat,
    double? gpsLng,
    int? gpsUpdatedAt,
    String? photoPath,
    int? photoUpdatedAt,
    JobVisitSyncState? syncState,
    String? deviceId,
    String? baseSnapshot,
    bool clearGps = false,
    bool clearPhoto = false,
    bool clearBaseSnapshot = false,
  }) {
    return JobVisit(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      statusUpdatedAt: statusUpdatedAt ?? this.statusUpdatedAt,
      gpsLat: clearGps ? null : gpsLat ?? this.gpsLat,
      gpsLng: clearGps ? null : gpsLng ?? this.gpsLng,
      gpsUpdatedAt: clearGps ? null : gpsUpdatedAt ?? this.gpsUpdatedAt,
      photoPath: clearPhoto ? null : photoPath ?? this.photoPath,
      photoUpdatedAt: clearPhoto ? null : photoUpdatedAt ?? this.photoUpdatedAt,
      syncState: syncState ?? this.syncState,
      deviceId: deviceId ?? this.deviceId,
      baseSnapshot: clearBaseSnapshot
          ? null
          : baseSnapshot ?? this.baseSnapshot,
    );
  }
}
