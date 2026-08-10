import 'dart:convert';
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

  Future<String?> readUserId() async {
    return _decodeJwtClaim(['nameid', 'uid', 'sub', 'UserId', 'id']);
  }

  /// Reads the user's display name from the JWT access token claims.
  Future<String?> readDisplayName() async {
    return _decodeJwtClaim([
      'name',
      'given_name',
      'displayName',
      'unique_name',
      'preferred_username',
    ]);
  }

  /// Reads the user's email from the JWT access token claims.
  Future<String?> readEmail() async {
    return _decodeJwtClaim([
      'email',
      'emailaddress',
      'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress',
    ]);
  }

  /// Decodes the JWT payload and returns the first non-null claim value
  /// matching any of the given [claimKeys].
  Future<String?> _decodeJwtClaim(List<String> claimKeys) async {
    final token = await readAccessToken();
    if (token == null || token.isEmpty) return null;

    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      String payload = parts[1];
      String normalized = base64Url.normalize(payload);
      String resp = utf8.decode(base64Url.decode(normalized));

      final Map<String, dynamic> payloadMap = json.decode(resp);

      for (final key in claimKeys) {
        final value = payloadMap[key]?.toString();
        if (value != null && value.isNotEmpty) return value;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}