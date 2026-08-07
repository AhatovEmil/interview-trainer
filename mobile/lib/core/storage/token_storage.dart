import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Токены лежат в Keychain (iOS) и EncryptedSharedPreferences (Android).
class TokenStorage {
  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  static const String _accessKey = 'access_token';
  static const String _refreshKey = 'refresh_token';

  final FlutterSecureStorage _storage;

  String? _cachedAccess;
  String? _cachedRefresh;

  Future<String?> readAccess() async => _cachedAccess ??= await _storage.read(key: _accessKey);

  Future<String?> readRefresh() async => _cachedRefresh ??= await _storage.read(key: _refreshKey);

  Future<void> save({required String access, required String refresh}) async {
    _cachedAccess = access;
    _cachedRefresh = refresh;
    await _storage.write(key: _accessKey, value: access);
    await _storage.write(key: _refreshKey, value: refresh);
  }

  Future<void> clear() async {
    _cachedAccess = null;
    _cachedRefresh = null;
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }

  Future<bool> get hasSession async => (await readRefresh()) != null;
}
