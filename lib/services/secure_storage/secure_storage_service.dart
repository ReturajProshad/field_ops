import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wraps `flutter_secure_storage` for the mock auth token.
///
/// Bootstrap happens on first run ([ensureToken] is called at app startup);
/// the backend reads the token back out and attaches it to each fake request.
class SecureStorageService {
  static const _tokenKey = 'fieldops_mock_auth_token';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  /// Bootstraps a fake auth token on first run. Idempotent — if one already
  /// exists it is returned unchanged.
  Future<String> ensureToken() async {
    final existing = await readToken();
    if (existing != null && existing.isNotEmpty) return existing;
    final token = 'mock-token-${DateTime.now().millisecondsSinceEpoch}';
    await _storage.write(key: _tokenKey, value: token);
    return token;
  }
}