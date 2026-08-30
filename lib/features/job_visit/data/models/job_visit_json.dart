import '../../domain/entities/job_visit.dart';

/// JSON codec for [JobVisit] as stored in the mock backend's file and passed
/// over the fake wire. Storage keys mirror the domain entity (and thus the
/// Drift row), so the remote record and local row have the same shape.
class JobVisitJson {
  static Map<String, dynamic> encode(JobVisit v) => {
        'id': v.id,
        'createdAt': v.createdAt,
        'status': v.status.storageValue,
        'statusUpdatedAt': v.statusUpdatedAt,
        'gpsLat': v.gpsLat,
        'gpsLng': v.gpsLng,
        'gpsUpdatedAt': v.gpsUpdatedAt,
        'photoPath': v.photoPath,
        'photoUpdatedAt': v.photoUpdatedAt,
        'syncState': v.syncState.storageValue,
        'deviceId': v.deviceId,
        'baseSnapshot': v.baseSnapshot,
      };

  static JobVisit decode(Map<String, dynamic> json) => JobVisit(
        id: json['id'] as String,
        createdAt: json['createdAt'] as int,
        status: JobVisitStatus.fromStorage(json['status'] as String),
        statusUpdatedAt: json['statusUpdatedAt'] as int,
        gpsLat: (json['gpsLat'] as num?)?.toDouble(),
        gpsLng: (json['gpsLng'] as num?)?.toDouble(),
        gpsUpdatedAt: json['gpsUpdatedAt'] as int?,
        photoPath: json['photoPath'] as String?,
        photoUpdatedAt: json['photoUpdatedAt'] as int?,
        syncState: JobVisitSyncState.fromStorage(json['syncState'] as String),
        deviceId: json['deviceId'] as String,
        baseSnapshot: json['baseSnapshot'] as String?,
      );
}