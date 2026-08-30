import 'dart:convert';
import 'dart:io';

import '../../domain/entities/job_visit.dart';
import '../models/job_visit_json.dart';
import 'sync_backend.dart';

/// Reads the mock auth token. Secure-storage-backed in the running app; a fake
/// in tests (the platform channel can't run in pure-Dart engine tests).
typedef TokenProvider = Future<String?> Function();

/// JSON-file-backed fake backend for the mock sync service.
///
/// - Records survive app restarts: the store is read lazily from [file] on
///   first access and rewritten after every mutation.
/// - Every fake request attaches the auth token from [TokenProvider] — the
///   secure-storage requirement is real, not decorative.
/// - Failure injection: [failAfterRecords] makes the Nth record's upsert throw
///   a [SyncBackendException], which is how the "fail sync after N records"
///   debug-menu demo is triggered.
class MockSyncService implements SyncBackend {
  MockSyncService({required this._file, required this._tokenProvider});

  final File _file;
  final TokenProvider _tokenProvider;

  final Map<String, Map<String, dynamic>> _records = {};
  bool _loaded = false;

  int? _failAfterRecords;
  int _recordCount = 0;

  /// The last auth header attached to a fake request, exposed for tests to
  /// assert the token is actually being read and attached.
  Map<String, String>? lastAttachedRequestHeaders;

  Future<String?> _token() => _tokenProvider();

  Future<void> _load() async {
    if (_loaded) return;
    _loaded = true;
    if (!await _file.exists()) return;
    try {
      final raw = await _file.readAsString();
      if (raw.trim().isEmpty) return;
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      _records
        ..clear()
        ..addAll(
          decoded.map(
            (key, value) => MapEntry(key, value as Map<String, dynamic>),
          ),
        );
    } on FormatException {
      // Corrupt file (crash mid-write, hand-edited, etc.). Quarantine it and
      // start from an empty store — otherwise the next sync would silently
      // overwrite the corrupt file, and all history is gone for good.
      await _file.rename('${_file.path}.corrupt');
    } on TypeError {
      // jsonDecode succeeded but the shape is wrong (not a map) — same path.
      await _file.rename('${_file.path}.corrupt');
    }
  }

  Future<void> _persist() async {
    await _file.parent.create(recursive: true);
    // Atomic write: dump to a temp file, then rename over the real one. A
    // crash mid-write otherwise leaves a truncated file that _load quarantines
    // — losing every record written before the crash.
    final tmp = File('${_file.path}.tmp');
    await tmp.writeAsString(jsonEncode(_records));
    await tmp.rename(_file.path);
  }

  Future<void> _attachAuthHeader() async {
    final token = await _token();
    // Attach the token to every fake request. Throw if missing — the mock is
    // auth-required, which keeps the secure-storage wiring real rather than a
    // string we never look at.
    if (token == null) {
      throw const SyncBackendException('No auth token available');
    }
    lastAttachedRequestHeaders = {'authorization': 'Bearer $token'};
  }

  /// Arms the debug-menu failure injection. [failAfterRecords] null disarms it.
  /// The count resets on each call, so "fail after 2" means: the 3rd record's
  /// upsert throws this sync run if the service isn't re-armed first.
  void failAfterRecords(int? failAfterRecords) {
    _failAfterRecords = failAfterRecords;
    _recordCount = 0;
  }

  @override
  Future<JobVisit?> getVisit(String id) async {
    await _attachAuthHeader();
    await _load();
    final raw = _records[id];
    return raw == null ? null : JobVisitJson.decode(raw);
  }

  @override
  Future<List<JobVisit>> getAllVisits() async {
    await _attachAuthHeader();
    await _load();
    return _records.values.map(JobVisitJson.decode).toList();
  }

  @override
  Future<void> upsertVisit(JobVisit visit) async {
    await _attachAuthHeader();
    await _load();

    final limit = _failAfterRecords;
    if (limit != null) {
      _recordCount++;
      if (_recordCount > limit) {
        throw SyncBackendException('Injected failure after $limit records');
      }
    }

    _records[visit.id] = JobVisitJson.encode(visit);
    await _persist();
  }
}
