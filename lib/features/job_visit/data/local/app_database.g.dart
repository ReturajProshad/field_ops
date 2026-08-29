// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $JobVisitsTable extends JobVisits
    with TableInfo<$JobVisitsTable, JobVisit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JobVisitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusUpdatedAtMeta = const VerificationMeta(
    'statusUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> statusUpdatedAt = GeneratedColumn<int>(
    'status_updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gpsLatMeta = const VerificationMeta('gpsLat');
  @override
  late final GeneratedColumn<double> gpsLat = GeneratedColumn<double>(
    'gps_lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gpsLngMeta = const VerificationMeta('gpsLng');
  @override
  late final GeneratedColumn<double> gpsLng = GeneratedColumn<double>(
    'gps_lng',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gpsUpdatedAtMeta = const VerificationMeta(
    'gpsUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> gpsUpdatedAt = GeneratedColumn<int>(
    'gps_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoPathMeta = const VerificationMeta(
    'photoPath',
  );
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoUpdatedAtMeta = const VerificationMeta(
    'photoUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> photoUpdatedAt = GeneratedColumn<int>(
    'photo_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseSnapshotMeta = const VerificationMeta(
    'baseSnapshot',
  );
  @override
  late final GeneratedColumn<String> baseSnapshot = GeneratedColumn<String>(
    'base_snapshot',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    status,
    statusUpdatedAt,
    gpsLat,
    gpsLng,
    gpsUpdatedAt,
    photoPath,
    photoUpdatedAt,
    syncState,
    deviceId,
    baseSnapshot,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'job_visits';
  @override
  VerificationContext validateIntegrity(
    Insertable<JobVisit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('status_updated_at')) {
      context.handle(
        _statusUpdatedAtMeta,
        statusUpdatedAt.isAcceptableOrUnknown(
          data['status_updated_at']!,
          _statusUpdatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_statusUpdatedAtMeta);
    }
    if (data.containsKey('gps_lat')) {
      context.handle(
        _gpsLatMeta,
        gpsLat.isAcceptableOrUnknown(data['gps_lat']!, _gpsLatMeta),
      );
    }
    if (data.containsKey('gps_lng')) {
      context.handle(
        _gpsLngMeta,
        gpsLng.isAcceptableOrUnknown(data['gps_lng']!, _gpsLngMeta),
      );
    }
    if (data.containsKey('gps_updated_at')) {
      context.handle(
        _gpsUpdatedAtMeta,
        gpsUpdatedAt.isAcceptableOrUnknown(
          data['gps_updated_at']!,
          _gpsUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
      );
    }
    if (data.containsKey('photo_updated_at')) {
      context.handle(
        _photoUpdatedAtMeta,
        photoUpdatedAt.isAcceptableOrUnknown(
          data['photo_updated_at']!,
          _photoUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    } else if (isInserting) {
      context.missing(_syncStateMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('base_snapshot')) {
      context.handle(
        _baseSnapshotMeta,
        baseSnapshot.isAcceptableOrUnknown(
          data['base_snapshot']!,
          _baseSnapshotMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  JobVisit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JobVisit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      statusUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status_updated_at'],
      )!,
      gpsLat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gps_lat'],
      ),
      gpsLng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gps_lng'],
      ),
      gpsUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}gps_updated_at'],
      ),
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
      ),
      photoUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}photo_updated_at'],
      ),
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      baseSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_snapshot'],
      ),
    );
  }

  @override
  $JobVisitsTable createAlias(String alias) {
    return $JobVisitsTable(attachedDatabase, alias);
  }
}

class JobVisit extends DataClass implements Insertable<JobVisit> {
  final String id;
  final int createdAt;
  final String status;
  final int statusUpdatedAt;
  final double? gpsLat;
  final double? gpsLng;
  final int? gpsUpdatedAt;
  final String? photoPath;
  final int? photoUpdatedAt;
  final String syncState;
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
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<int>(createdAt);
    map['status'] = Variable<String>(status);
    map['status_updated_at'] = Variable<int>(statusUpdatedAt);
    if (!nullToAbsent || gpsLat != null) {
      map['gps_lat'] = Variable<double>(gpsLat);
    }
    if (!nullToAbsent || gpsLng != null) {
      map['gps_lng'] = Variable<double>(gpsLng);
    }
    if (!nullToAbsent || gpsUpdatedAt != null) {
      map['gps_updated_at'] = Variable<int>(gpsUpdatedAt);
    }
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    if (!nullToAbsent || photoUpdatedAt != null) {
      map['photo_updated_at'] = Variable<int>(photoUpdatedAt);
    }
    map['sync_state'] = Variable<String>(syncState);
    map['device_id'] = Variable<String>(deviceId);
    if (!nullToAbsent || baseSnapshot != null) {
      map['base_snapshot'] = Variable<String>(baseSnapshot);
    }
    return map;
  }

  JobVisitsCompanion toCompanion(bool nullToAbsent) {
    return JobVisitsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      status: Value(status),
      statusUpdatedAt: Value(statusUpdatedAt),
      gpsLat: gpsLat == null && nullToAbsent
          ? const Value.absent()
          : Value(gpsLat),
      gpsLng: gpsLng == null && nullToAbsent
          ? const Value.absent()
          : Value(gpsLng),
      gpsUpdatedAt: gpsUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(gpsUpdatedAt),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      photoUpdatedAt: photoUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(photoUpdatedAt),
      syncState: Value(syncState),
      deviceId: Value(deviceId),
      baseSnapshot: baseSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(baseSnapshot),
    );
  }

  factory JobVisit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JobVisit(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      status: serializer.fromJson<String>(json['status']),
      statusUpdatedAt: serializer.fromJson<int>(json['statusUpdatedAt']),
      gpsLat: serializer.fromJson<double?>(json['gpsLat']),
      gpsLng: serializer.fromJson<double?>(json['gpsLng']),
      gpsUpdatedAt: serializer.fromJson<int?>(json['gpsUpdatedAt']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      photoUpdatedAt: serializer.fromJson<int?>(json['photoUpdatedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      baseSnapshot: serializer.fromJson<String?>(json['baseSnapshot']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<int>(createdAt),
      'status': serializer.toJson<String>(status),
      'statusUpdatedAt': serializer.toJson<int>(statusUpdatedAt),
      'gpsLat': serializer.toJson<double?>(gpsLat),
      'gpsLng': serializer.toJson<double?>(gpsLng),
      'gpsUpdatedAt': serializer.toJson<int?>(gpsUpdatedAt),
      'photoPath': serializer.toJson<String?>(photoPath),
      'photoUpdatedAt': serializer.toJson<int?>(photoUpdatedAt),
      'syncState': serializer.toJson<String>(syncState),
      'deviceId': serializer.toJson<String>(deviceId),
      'baseSnapshot': serializer.toJson<String?>(baseSnapshot),
    };
  }

  JobVisit copyWith({
    String? id,
    int? createdAt,
    String? status,
    int? statusUpdatedAt,
    Value<double?> gpsLat = const Value.absent(),
    Value<double?> gpsLng = const Value.absent(),
    Value<int?> gpsUpdatedAt = const Value.absent(),
    Value<String?> photoPath = const Value.absent(),
    Value<int?> photoUpdatedAt = const Value.absent(),
    String? syncState,
    String? deviceId,
    Value<String?> baseSnapshot = const Value.absent(),
  }) => JobVisit(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    status: status ?? this.status,
    statusUpdatedAt: statusUpdatedAt ?? this.statusUpdatedAt,
    gpsLat: gpsLat.present ? gpsLat.value : this.gpsLat,
    gpsLng: gpsLng.present ? gpsLng.value : this.gpsLng,
    gpsUpdatedAt: gpsUpdatedAt.present ? gpsUpdatedAt.value : this.gpsUpdatedAt,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
    photoUpdatedAt: photoUpdatedAt.present
        ? photoUpdatedAt.value
        : this.photoUpdatedAt,
    syncState: syncState ?? this.syncState,
    deviceId: deviceId ?? this.deviceId,
    baseSnapshot: baseSnapshot.present ? baseSnapshot.value : this.baseSnapshot,
  );
  JobVisit copyWithCompanion(JobVisitsCompanion data) {
    return JobVisit(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      status: data.status.present ? data.status.value : this.status,
      statusUpdatedAt: data.statusUpdatedAt.present
          ? data.statusUpdatedAt.value
          : this.statusUpdatedAt,
      gpsLat: data.gpsLat.present ? data.gpsLat.value : this.gpsLat,
      gpsLng: data.gpsLng.present ? data.gpsLng.value : this.gpsLng,
      gpsUpdatedAt: data.gpsUpdatedAt.present
          ? data.gpsUpdatedAt.value
          : this.gpsUpdatedAt,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      photoUpdatedAt: data.photoUpdatedAt.present
          ? data.photoUpdatedAt.value
          : this.photoUpdatedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      baseSnapshot: data.baseSnapshot.present
          ? data.baseSnapshot.value
          : this.baseSnapshot,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JobVisit(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('status: $status, ')
          ..write('statusUpdatedAt: $statusUpdatedAt, ')
          ..write('gpsLat: $gpsLat, ')
          ..write('gpsLng: $gpsLng, ')
          ..write('gpsUpdatedAt: $gpsUpdatedAt, ')
          ..write('photoPath: $photoPath, ')
          ..write('photoUpdatedAt: $photoUpdatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('deviceId: $deviceId, ')
          ..write('baseSnapshot: $baseSnapshot')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    status,
    statusUpdatedAt,
    gpsLat,
    gpsLng,
    gpsUpdatedAt,
    photoPath,
    photoUpdatedAt,
    syncState,
    deviceId,
    baseSnapshot,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JobVisit &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.status == this.status &&
          other.statusUpdatedAt == this.statusUpdatedAt &&
          other.gpsLat == this.gpsLat &&
          other.gpsLng == this.gpsLng &&
          other.gpsUpdatedAt == this.gpsUpdatedAt &&
          other.photoPath == this.photoPath &&
          other.photoUpdatedAt == this.photoUpdatedAt &&
          other.syncState == this.syncState &&
          other.deviceId == this.deviceId &&
          other.baseSnapshot == this.baseSnapshot);
}

class JobVisitsCompanion extends UpdateCompanion<JobVisit> {
  final Value<String> id;
  final Value<int> createdAt;
  final Value<String> status;
  final Value<int> statusUpdatedAt;
  final Value<double?> gpsLat;
  final Value<double?> gpsLng;
  final Value<int?> gpsUpdatedAt;
  final Value<String?> photoPath;
  final Value<int?> photoUpdatedAt;
  final Value<String> syncState;
  final Value<String> deviceId;
  final Value<String?> baseSnapshot;
  final Value<int> rowid;
  const JobVisitsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.status = const Value.absent(),
    this.statusUpdatedAt = const Value.absent(),
    this.gpsLat = const Value.absent(),
    this.gpsLng = const Value.absent(),
    this.gpsUpdatedAt = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.photoUpdatedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.baseSnapshot = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JobVisitsCompanion.insert({
    required String id,
    required int createdAt,
    required String status,
    required int statusUpdatedAt,
    this.gpsLat = const Value.absent(),
    this.gpsLng = const Value.absent(),
    this.gpsUpdatedAt = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.photoUpdatedAt = const Value.absent(),
    required String syncState,
    required String deviceId,
    this.baseSnapshot = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       status = Value(status),
       statusUpdatedAt = Value(statusUpdatedAt),
       syncState = Value(syncState),
       deviceId = Value(deviceId);
  static Insertable<JobVisit> custom({
    Expression<String>? id,
    Expression<int>? createdAt,
    Expression<String>? status,
    Expression<int>? statusUpdatedAt,
    Expression<double>? gpsLat,
    Expression<double>? gpsLng,
    Expression<int>? gpsUpdatedAt,
    Expression<String>? photoPath,
    Expression<int>? photoUpdatedAt,
    Expression<String>? syncState,
    Expression<String>? deviceId,
    Expression<String>? baseSnapshot,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (status != null) 'status': status,
      if (statusUpdatedAt != null) 'status_updated_at': statusUpdatedAt,
      if (gpsLat != null) 'gps_lat': gpsLat,
      if (gpsLng != null) 'gps_lng': gpsLng,
      if (gpsUpdatedAt != null) 'gps_updated_at': gpsUpdatedAt,
      if (photoPath != null) 'photo_path': photoPath,
      if (photoUpdatedAt != null) 'photo_updated_at': photoUpdatedAt,
      if (syncState != null) 'sync_state': syncState,
      if (deviceId != null) 'device_id': deviceId,
      if (baseSnapshot != null) 'base_snapshot': baseSnapshot,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JobVisitsCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAt,
    Value<String>? status,
    Value<int>? statusUpdatedAt,
    Value<double?>? gpsLat,
    Value<double?>? gpsLng,
    Value<int?>? gpsUpdatedAt,
    Value<String?>? photoPath,
    Value<int?>? photoUpdatedAt,
    Value<String>? syncState,
    Value<String>? deviceId,
    Value<String?>? baseSnapshot,
    Value<int>? rowid,
  }) {
    return JobVisitsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      statusUpdatedAt: statusUpdatedAt ?? this.statusUpdatedAt,
      gpsLat: gpsLat ?? this.gpsLat,
      gpsLng: gpsLng ?? this.gpsLng,
      gpsUpdatedAt: gpsUpdatedAt ?? this.gpsUpdatedAt,
      photoPath: photoPath ?? this.photoPath,
      photoUpdatedAt: photoUpdatedAt ?? this.photoUpdatedAt,
      syncState: syncState ?? this.syncState,
      deviceId: deviceId ?? this.deviceId,
      baseSnapshot: baseSnapshot ?? this.baseSnapshot,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (statusUpdatedAt.present) {
      map['status_updated_at'] = Variable<int>(statusUpdatedAt.value);
    }
    if (gpsLat.present) {
      map['gps_lat'] = Variable<double>(gpsLat.value);
    }
    if (gpsLng.present) {
      map['gps_lng'] = Variable<double>(gpsLng.value);
    }
    if (gpsUpdatedAt.present) {
      map['gps_updated_at'] = Variable<int>(gpsUpdatedAt.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (photoUpdatedAt.present) {
      map['photo_updated_at'] = Variable<int>(photoUpdatedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (baseSnapshot.present) {
      map['base_snapshot'] = Variable<String>(baseSnapshot.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JobVisitsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('status: $status, ')
          ..write('statusUpdatedAt: $statusUpdatedAt, ')
          ..write('gpsLat: $gpsLat, ')
          ..write('gpsLng: $gpsLng, ')
          ..write('gpsUpdatedAt: $gpsUpdatedAt, ')
          ..write('photoPath: $photoPath, ')
          ..write('photoUpdatedAt: $photoUpdatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('deviceId: $deviceId, ')
          ..write('baseSnapshot: $baseSnapshot, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocationPointsTable extends LocationPoints
    with TableInfo<$LocationPointsTable, LocationPoint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocationPointsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jobVisitIdMeta = const VerificationMeta(
    'jobVisitId',
  );
  @override
  late final GeneratedColumn<String> jobVisitId = GeneratedColumn<String>(
    'job_visit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES job_visits (id)',
    ),
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
    'lng',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _capturedAtMeta = const VerificationMeta(
    'capturedAt',
  );
  @override
  late final GeneratedColumn<int> capturedAt = GeneratedColumn<int>(
    'captured_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accuracyMetersMeta = const VerificationMeta(
    'accuracyMeters',
  );
  @override
  late final GeneratedColumn<int> accuracyMeters = GeneratedColumn<int>(
    'accuracy_meters',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    jobVisitId,
    lat,
    lng,
    capturedAt,
    accuracyMeters,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'location_points';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocationPoint> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('job_visit_id')) {
      context.handle(
        _jobVisitIdMeta,
        jobVisitId.isAcceptableOrUnknown(
          data['job_visit_id']!,
          _jobVisitIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_jobVisitIdMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lng')) {
      context.handle(
        _lngMeta,
        lng.isAcceptableOrUnknown(data['lng']!, _lngMeta),
      );
    } else if (isInserting) {
      context.missing(_lngMeta);
    }
    if (data.containsKey('captured_at')) {
      context.handle(
        _capturedAtMeta,
        capturedAt.isAcceptableOrUnknown(data['captured_at']!, _capturedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_capturedAtMeta);
    }
    if (data.containsKey('accuracy_meters')) {
      context.handle(
        _accuracyMetersMeta,
        accuracyMeters.isAcceptableOrUnknown(
          data['accuracy_meters']!,
          _accuracyMetersMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocationPoint map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocationPoint(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      jobVisitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}job_visit_id'],
      )!,
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      )!,
      lng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lng'],
      )!,
      capturedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}captured_at'],
      )!,
      accuracyMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}accuracy_meters'],
      ),
    );
  }

  @override
  $LocationPointsTable createAlias(String alias) {
    return $LocationPointsTable(attachedDatabase, alias);
  }
}

class LocationPoint extends DataClass implements Insertable<LocationPoint> {
  final String id;
  final String jobVisitId;
  final double lat;
  final double lng;
  final int capturedAt;
  final int? accuracyMeters;
  const LocationPoint({
    required this.id,
    required this.jobVisitId,
    required this.lat,
    required this.lng,
    required this.capturedAt,
    this.accuracyMeters,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['job_visit_id'] = Variable<String>(jobVisitId);
    map['lat'] = Variable<double>(lat);
    map['lng'] = Variable<double>(lng);
    map['captured_at'] = Variable<int>(capturedAt);
    if (!nullToAbsent || accuracyMeters != null) {
      map['accuracy_meters'] = Variable<int>(accuracyMeters);
    }
    return map;
  }

  LocationPointsCompanion toCompanion(bool nullToAbsent) {
    return LocationPointsCompanion(
      id: Value(id),
      jobVisitId: Value(jobVisitId),
      lat: Value(lat),
      lng: Value(lng),
      capturedAt: Value(capturedAt),
      accuracyMeters: accuracyMeters == null && nullToAbsent
          ? const Value.absent()
          : Value(accuracyMeters),
    );
  }

  factory LocationPoint.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocationPoint(
      id: serializer.fromJson<String>(json['id']),
      jobVisitId: serializer.fromJson<String>(json['jobVisitId']),
      lat: serializer.fromJson<double>(json['lat']),
      lng: serializer.fromJson<double>(json['lng']),
      capturedAt: serializer.fromJson<int>(json['capturedAt']),
      accuracyMeters: serializer.fromJson<int?>(json['accuracyMeters']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'jobVisitId': serializer.toJson<String>(jobVisitId),
      'lat': serializer.toJson<double>(lat),
      'lng': serializer.toJson<double>(lng),
      'capturedAt': serializer.toJson<int>(capturedAt),
      'accuracyMeters': serializer.toJson<int?>(accuracyMeters),
    };
  }

  LocationPoint copyWith({
    String? id,
    String? jobVisitId,
    double? lat,
    double? lng,
    int? capturedAt,
    Value<int?> accuracyMeters = const Value.absent(),
  }) => LocationPoint(
    id: id ?? this.id,
    jobVisitId: jobVisitId ?? this.jobVisitId,
    lat: lat ?? this.lat,
    lng: lng ?? this.lng,
    capturedAt: capturedAt ?? this.capturedAt,
    accuracyMeters: accuracyMeters.present
        ? accuracyMeters.value
        : this.accuracyMeters,
  );
  LocationPoint copyWithCompanion(LocationPointsCompanion data) {
    return LocationPoint(
      id: data.id.present ? data.id.value : this.id,
      jobVisitId: data.jobVisitId.present
          ? data.jobVisitId.value
          : this.jobVisitId,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      capturedAt: data.capturedAt.present
          ? data.capturedAt.value
          : this.capturedAt,
      accuracyMeters: data.accuracyMeters.present
          ? data.accuracyMeters.value
          : this.accuracyMeters,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocationPoint(')
          ..write('id: $id, ')
          ..write('jobVisitId: $jobVisitId, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('accuracyMeters: $accuracyMeters')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, jobVisitId, lat, lng, capturedAt, accuracyMeters);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocationPoint &&
          other.id == this.id &&
          other.jobVisitId == this.jobVisitId &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.capturedAt == this.capturedAt &&
          other.accuracyMeters == this.accuracyMeters);
}

class LocationPointsCompanion extends UpdateCompanion<LocationPoint> {
  final Value<String> id;
  final Value<String> jobVisitId;
  final Value<double> lat;
  final Value<double> lng;
  final Value<int> capturedAt;
  final Value<int?> accuracyMeters;
  final Value<int> rowid;
  const LocationPointsCompanion({
    this.id = const Value.absent(),
    this.jobVisitId = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.accuracyMeters = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocationPointsCompanion.insert({
    required String id,
    required String jobVisitId,
    required double lat,
    required double lng,
    required int capturedAt,
    this.accuracyMeters = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       jobVisitId = Value(jobVisitId),
       lat = Value(lat),
       lng = Value(lng),
       capturedAt = Value(capturedAt);
  static Insertable<LocationPoint> custom({
    Expression<String>? id,
    Expression<String>? jobVisitId,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<int>? capturedAt,
    Expression<int>? accuracyMeters,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (jobVisitId != null) 'job_visit_id': jobVisitId,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (accuracyMeters != null) 'accuracy_meters': accuracyMeters,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocationPointsCompanion copyWith({
    Value<String>? id,
    Value<String>? jobVisitId,
    Value<double>? lat,
    Value<double>? lng,
    Value<int>? capturedAt,
    Value<int?>? accuracyMeters,
    Value<int>? rowid,
  }) {
    return LocationPointsCompanion(
      id: id ?? this.id,
      jobVisitId: jobVisitId ?? this.jobVisitId,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      capturedAt: capturedAt ?? this.capturedAt,
      accuracyMeters: accuracyMeters ?? this.accuracyMeters,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (jobVisitId.present) {
      map['job_visit_id'] = Variable<String>(jobVisitId.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<int>(capturedAt.value);
    }
    if (accuracyMeters.present) {
      map['accuracy_meters'] = Variable<int>(accuracyMeters.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocationPointsCompanion(')
          ..write('id: $id, ')
          ..write('jobVisitId: $jobVisitId, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('accuracyMeters: $accuracyMeters, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $JobVisitsTable jobVisits = $JobVisitsTable(this);
  late final $LocationPointsTable locationPoints = $LocationPointsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    jobVisits,
    locationPoints,
  ];
}

typedef $$JobVisitsTableCreateCompanionBuilder =
    JobVisitsCompanion Function({
      required String id,
      required int createdAt,
      required String status,
      required int statusUpdatedAt,
      Value<double?> gpsLat,
      Value<double?> gpsLng,
      Value<int?> gpsUpdatedAt,
      Value<String?> photoPath,
      Value<int?> photoUpdatedAt,
      required String syncState,
      required String deviceId,
      Value<String?> baseSnapshot,
      Value<int> rowid,
    });
typedef $$JobVisitsTableUpdateCompanionBuilder =
    JobVisitsCompanion Function({
      Value<String> id,
      Value<int> createdAt,
      Value<String> status,
      Value<int> statusUpdatedAt,
      Value<double?> gpsLat,
      Value<double?> gpsLng,
      Value<int?> gpsUpdatedAt,
      Value<String?> photoPath,
      Value<int?> photoUpdatedAt,
      Value<String> syncState,
      Value<String> deviceId,
      Value<String?> baseSnapshot,
      Value<int> rowid,
    });

final class $$JobVisitsTableReferences
    extends BaseReferences<_$AppDatabase, $JobVisitsTable, JobVisit> {
  $$JobVisitsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$LocationPointsTable, List<LocationPoint>>
  _locationPointsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.locationPoints,
    aliasName: 'job_visits__id__location_points__job_visit_id',
  );

  $$LocationPointsTableProcessedTableManager get locationPointsRefs {
    final manager = $$LocationPointsTableTableManager(
      $_db,
      $_db.locationPoints,
    ).filter((f) => f.jobVisitId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_locationPointsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$JobVisitsTableFilterComposer
    extends Composer<_$AppDatabase, $JobVisitsTable> {
  $$JobVisitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get statusUpdatedAt => $composableBuilder(
    column: $table.statusUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gpsLat => $composableBuilder(
    column: $table.gpsLat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gpsLng => $composableBuilder(
    column: $table.gpsLng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gpsUpdatedAt => $composableBuilder(
    column: $table.gpsUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get photoUpdatedAt => $composableBuilder(
    column: $table.photoUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get baseSnapshot => $composableBuilder(
    column: $table.baseSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> locationPointsRefs(
    Expression<bool> Function($$LocationPointsTableFilterComposer f) f,
  ) {
    final $$LocationPointsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.locationPoints,
      getReferencedColumn: (t) => t.jobVisitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocationPointsTableFilterComposer(
            $db: $db,
            $table: $db.locationPoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$JobVisitsTableOrderingComposer
    extends Composer<_$AppDatabase, $JobVisitsTable> {
  $$JobVisitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get statusUpdatedAt => $composableBuilder(
    column: $table.statusUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gpsLat => $composableBuilder(
    column: $table.gpsLat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gpsLng => $composableBuilder(
    column: $table.gpsLng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gpsUpdatedAt => $composableBuilder(
    column: $table.gpsUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get photoUpdatedAt => $composableBuilder(
    column: $table.photoUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get baseSnapshot => $composableBuilder(
    column: $table.baseSnapshot,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$JobVisitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $JobVisitsTable> {
  $$JobVisitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get statusUpdatedAt => $composableBuilder(
    column: $table.statusUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get gpsLat =>
      $composableBuilder(column: $table.gpsLat, builder: (column) => column);

  GeneratedColumn<double> get gpsLng =>
      $composableBuilder(column: $table.gpsLng, builder: (column) => column);

  GeneratedColumn<int> get gpsUpdatedAt => $composableBuilder(
    column: $table.gpsUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<int> get photoUpdatedAt => $composableBuilder(
    column: $table.photoUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get baseSnapshot => $composableBuilder(
    column: $table.baseSnapshot,
    builder: (column) => column,
  );

  Expression<T> locationPointsRefs<T extends Object>(
    Expression<T> Function($$LocationPointsTableAnnotationComposer a) f,
  ) {
    final $$LocationPointsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.locationPoints,
      getReferencedColumn: (t) => t.jobVisitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocationPointsTableAnnotationComposer(
            $db: $db,
            $table: $db.locationPoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$JobVisitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JobVisitsTable,
          JobVisit,
          $$JobVisitsTableFilterComposer,
          $$JobVisitsTableOrderingComposer,
          $$JobVisitsTableAnnotationComposer,
          $$JobVisitsTableCreateCompanionBuilder,
          $$JobVisitsTableUpdateCompanionBuilder,
          (JobVisit, $$JobVisitsTableReferences),
          JobVisit,
          PrefetchHooks Function({bool locationPointsRefs})
        > {
  $$JobVisitsTableTableManager(_$AppDatabase db, $JobVisitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JobVisitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JobVisitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JobVisitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> statusUpdatedAt = const Value.absent(),
                Value<double?> gpsLat = const Value.absent(),
                Value<double?> gpsLng = const Value.absent(),
                Value<int?> gpsUpdatedAt = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<int?> photoUpdatedAt = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String?> baseSnapshot = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JobVisitsCompanion(
                id: id,
                createdAt: createdAt,
                status: status,
                statusUpdatedAt: statusUpdatedAt,
                gpsLat: gpsLat,
                gpsLng: gpsLng,
                gpsUpdatedAt: gpsUpdatedAt,
                photoPath: photoPath,
                photoUpdatedAt: photoUpdatedAt,
                syncState: syncState,
                deviceId: deviceId,
                baseSnapshot: baseSnapshot,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAt,
                required String status,
                required int statusUpdatedAt,
                Value<double?> gpsLat = const Value.absent(),
                Value<double?> gpsLng = const Value.absent(),
                Value<int?> gpsUpdatedAt = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<int?> photoUpdatedAt = const Value.absent(),
                required String syncState,
                required String deviceId,
                Value<String?> baseSnapshot = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JobVisitsCompanion.insert(
                id: id,
                createdAt: createdAt,
                status: status,
                statusUpdatedAt: statusUpdatedAt,
                gpsLat: gpsLat,
                gpsLng: gpsLng,
                gpsUpdatedAt: gpsUpdatedAt,
                photoPath: photoPath,
                photoUpdatedAt: photoUpdatedAt,
                syncState: syncState,
                deviceId: deviceId,
                baseSnapshot: baseSnapshot,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$JobVisitsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({locationPointsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (locationPointsRefs) db.locationPoints,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (locationPointsRefs)
                    await $_getPrefetchedData<
                      JobVisit,
                      $JobVisitsTable,
                      LocationPoint
                    >(
                      currentTable: table,
                      referencedTable: $$JobVisitsTableReferences
                          ._locationPointsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$JobVisitsTableReferences(
                            db,
                            table,
                            p0,
                          ).locationPointsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.jobVisitId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$JobVisitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JobVisitsTable,
      JobVisit,
      $$JobVisitsTableFilterComposer,
      $$JobVisitsTableOrderingComposer,
      $$JobVisitsTableAnnotationComposer,
      $$JobVisitsTableCreateCompanionBuilder,
      $$JobVisitsTableUpdateCompanionBuilder,
      (JobVisit, $$JobVisitsTableReferences),
      JobVisit,
      PrefetchHooks Function({bool locationPointsRefs})
    >;
typedef $$LocationPointsTableCreateCompanionBuilder =
    LocationPointsCompanion Function({
      required String id,
      required String jobVisitId,
      required double lat,
      required double lng,
      required int capturedAt,
      Value<int?> accuracyMeters,
      Value<int> rowid,
    });
typedef $$LocationPointsTableUpdateCompanionBuilder =
    LocationPointsCompanion Function({
      Value<String> id,
      Value<String> jobVisitId,
      Value<double> lat,
      Value<double> lng,
      Value<int> capturedAt,
      Value<int?> accuracyMeters,
      Value<int> rowid,
    });

final class $$LocationPointsTableReferences
    extends BaseReferences<_$AppDatabase, $LocationPointsTable, LocationPoint> {
  $$LocationPointsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $JobVisitsTable _jobVisitIdTable(_$AppDatabase db) =>
      db.jobVisits.createAlias('location_points__job_visit_id__job_visits__id');

  $$JobVisitsTableProcessedTableManager get jobVisitId {
    final $_column = $_itemColumn<String>('job_visit_id')!;

    final manager = $$JobVisitsTableTableManager(
      $_db,
      $_db.jobVisits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_jobVisitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LocationPointsTableFilterComposer
    extends Composer<_$AppDatabase, $LocationPointsTable> {
  $$LocationPointsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get accuracyMeters => $composableBuilder(
    column: $table.accuracyMeters,
    builder: (column) => ColumnFilters(column),
  );

  $$JobVisitsTableFilterComposer get jobVisitId {
    final $$JobVisitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jobVisitId,
      referencedTable: $db.jobVisits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobVisitsTableFilterComposer(
            $db: $db,
            $table: $db.jobVisits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocationPointsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocationPointsTable> {
  $$LocationPointsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get accuracyMeters => $composableBuilder(
    column: $table.accuracyMeters,
    builder: (column) => ColumnOrderings(column),
  );

  $$JobVisitsTableOrderingComposer get jobVisitId {
    final $$JobVisitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jobVisitId,
      referencedTable: $db.jobVisits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobVisitsTableOrderingComposer(
            $db: $db,
            $table: $db.jobVisits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocationPointsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocationPointsTable> {
  $$LocationPointsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<int> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get accuracyMeters => $composableBuilder(
    column: $table.accuracyMeters,
    builder: (column) => column,
  );

  $$JobVisitsTableAnnotationComposer get jobVisitId {
    final $$JobVisitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jobVisitId,
      referencedTable: $db.jobVisits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobVisitsTableAnnotationComposer(
            $db: $db,
            $table: $db.jobVisits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocationPointsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocationPointsTable,
          LocationPoint,
          $$LocationPointsTableFilterComposer,
          $$LocationPointsTableOrderingComposer,
          $$LocationPointsTableAnnotationComposer,
          $$LocationPointsTableCreateCompanionBuilder,
          $$LocationPointsTableUpdateCompanionBuilder,
          (LocationPoint, $$LocationPointsTableReferences),
          LocationPoint,
          PrefetchHooks Function({bool jobVisitId})
        > {
  $$LocationPointsTableTableManager(
    _$AppDatabase db,
    $LocationPointsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocationPointsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocationPointsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocationPointsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> jobVisitId = const Value.absent(),
                Value<double> lat = const Value.absent(),
                Value<double> lng = const Value.absent(),
                Value<int> capturedAt = const Value.absent(),
                Value<int?> accuracyMeters = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocationPointsCompanion(
                id: id,
                jobVisitId: jobVisitId,
                lat: lat,
                lng: lng,
                capturedAt: capturedAt,
                accuracyMeters: accuracyMeters,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String jobVisitId,
                required double lat,
                required double lng,
                required int capturedAt,
                Value<int?> accuracyMeters = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocationPointsCompanion.insert(
                id: id,
                jobVisitId: jobVisitId,
                lat: lat,
                lng: lng,
                capturedAt: capturedAt,
                accuracyMeters: accuracyMeters,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LocationPointsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({jobVisitId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (jobVisitId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.jobVisitId,
                                referencedTable: $$LocationPointsTableReferences
                                    ._jobVisitIdTable(db),
                                referencedColumn:
                                    $$LocationPointsTableReferences
                                        ._jobVisitIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$LocationPointsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocationPointsTable,
      LocationPoint,
      $$LocationPointsTableFilterComposer,
      $$LocationPointsTableOrderingComposer,
      $$LocationPointsTableAnnotationComposer,
      $$LocationPointsTableCreateCompanionBuilder,
      $$LocationPointsTableUpdateCompanionBuilder,
      (LocationPoint, $$LocationPointsTableReferences),
      LocationPoint,
      PrefetchHooks Function({bool jobVisitId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$JobVisitsTableTableManager get jobVisits =>
      $$JobVisitsTableTableManager(_db, _db.jobVisits);
  $$LocationPointsTableTableManager get locationPoints =>
      $$LocationPointsTableTableManager(_db, _db.locationPoints);
}
