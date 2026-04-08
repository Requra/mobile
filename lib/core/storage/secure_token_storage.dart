import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureTokenStorage {
  const SecureTokenStorage({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  final FlutterSecureStorage _secureStorage;

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait<void>(<Future<void>>[
      _secureStorage.write(key: _accessTokenKey, value: accessToken),
      _secureStorage.write(key: _refreshTokenKey, value: refreshToken),
    ]);
  }

  Future<String?> readAccessToken() {
    return _secureStorage.read(key: _accessTokenKey);
  }

  Future<String?> readRefreshToken() {
    return _secureStorage.read(key: _refreshTokenKey);
  }

  Future<void> clearTokens() async {
    await Future.wait<void>(<Future<void>>[
      _secureStorage.delete(key: _accessTokenKey),
      _secureStorage.delete(key: _refreshTokenKey),
    ]);
  }
}