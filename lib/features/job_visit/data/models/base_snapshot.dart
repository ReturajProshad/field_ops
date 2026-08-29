import 'dart:convert';

import '../../domain/entities/job_visit.dart';

class StatusSnapshot {
  const StatusSnapshot({required this.value, required this.updatedAt});

  final String value;
  final int updatedAt;

  JobVisitStatus get status => JobVisitStatus.fromStorage(value);

  factory StatusSnapshot.fromJson(Map<String, dynamic> json) => StatusSnapshot(
        value: json['value'] as String,
        updatedAt: json['updatedAt'] as int,
      );

  Map<String, dynamic> toJson() => {'value': value, 'updatedAt': updatedAt};
}

class GpsSnapshot {
  const GpsSnapshot({this.lat, this.lng, this.updatedAt});

  final double? lat;
  final double? lng;
  final int? updatedAt;

  factory GpsSnapshot.fromJson(Map<String, dynamic> json) => GpsSnapshot(
        lat: (json['lat'] as num?)?.toDouble(),
        lng: (json['lng'] as num?)?.toDouble(),
        updatedAt: json['updatedAt'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lng': lng,
        'updatedAt': updatedAt,
      };
}

class PhotoSnapshot {
  const PhotoSnapshot({this.path, this.updatedAt});

  final String? path;
  final int? updatedAt;

  factory PhotoSnapshot.fromJson(Map<String, dynamic> json) => PhotoSnapshot(
        path: json['path'] as String?,
        updatedAt: json['updatedAt'] as int?,
      );

  Map<String, dynamic> toJson() => {'path': path, 'updatedAt': updatedAt};
}

/// Serialized per-field values + int-ms edit timestamps captured at the last
/// successful sync. Lives in [JobVisit.baseSnapshot]; the three-way merge
/// compares current local/remote fields against it.
class BaseSnapshot {
  const BaseSnapshot({
    required this.status,
    required this.gps,
    required this.photo,
  });

  factory BaseSnapshot.fromVisit(JobVisit visit) => BaseSnapshot(
        status: StatusSnapshot(
          value: visit.status.storageValue,
          updatedAt: visit.statusUpdatedAt,
        ),
        gps: GpsSnapshot(
          lat: visit.gpsLat,
          lng: visit.gpsLng,
          updatedAt: visit.gpsUpdatedAt,
        ),
        photo: PhotoSnapshot(
          path: visit.photoPath,
          updatedAt: visit.photoUpdatedAt,
        ),
      );

  final StatusSnapshot status;
  final GpsSnapshot gps;
  final PhotoSnapshot photo;

  factory BaseSnapshot.fromJsonString(String source) =>
      BaseSnapshot.fromJson(jsonDecode(source) as Map<String, dynamic>);

  factory BaseSnapshot.fromJson(Map<String, dynamic> json) => BaseSnapshot(
        status: StatusSnapshot.fromJson(json['status'] as Map<String, dynamic>),
        gps: GpsSnapshot.fromJson(json['gps'] as Map<String, dynamic>),
        photo: PhotoSnapshot.fromJson(json['photo'] as Map<String, dynamic>),
      );

  String toJsonString() => jsonEncode(toJson());

  Map<String, dynamic> toJson() => {
        'status': status.toJson(),
        'gps': gps.toJson(),
        'photo': photo.toJson(),
      };
}