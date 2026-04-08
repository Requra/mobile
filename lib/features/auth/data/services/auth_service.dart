import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:requra/core/network/api_constants.dart';
import 'package:requra/core/storage/secure_token_storage.dart';
import 'package:requra/features/auth/data/models/auth_response.dart';

class AuthService {
  const AuthService();

  static const SecureTokenStorage _tokenStorage = SecureTokenStorage();

  Future<AuthResponse> confirmAccount({
    required String email,
    required String otpCode,
  }) {
    return _post(
      endpoint: ApiConstants.confirmAccount,
      body: <String, dynamic>{
        'email': email,
        'otpCode': otpCode,
      },
      includeAuthHeader: false,
    );
  }

  Future<AuthResponse> resendOtp({
    required String email,
    required int otpType,
  }) {
    return _post(
      endpoint: ApiConstants.resendOtp,
      body: <String, dynamic>{
        'email': email,
        'otpType': otpType,
      },
      includeAuthHeader: false,
    );
  }

  Future<AuthResponse> googleLogin({
    required String idToken,
  }) {
    return _post(
      endpoint: ApiConstants.googleLogin,
      body: <String, dynamic>{
        'idToken': idToken,
      },
      includeAuthHeader: false,
    );
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) {
    return _post(
      endpoint: ApiConstants.login,
      body: <String, dynamic>{
        'email': email,
        'password': password,
      },
      includeAuthHeader: false,
    );
  }

  Future<AuthResponse> signup({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    return _post(
      endpoint: ApiConstants.signup,
      body: <String, dynamic>{
        'fullName': fullName,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
        'role': 0,
      },
      includeAuthHeader: false,
    );
  }

  Future<AuthResponse> forgotPassword({
    required String email,
  }) {
    return _post(
      endpoint: ApiConstants.forgotPassword,
      body: <String, dynamic>{
        'email': email,
      },
      includeAuthHeader: false,
    );
  }

  Future<AuthResponse> verifyOtp({
    required String otp,
  }) {
    return _post(
      endpoint: ApiConstants.verifyOtp,
      body: <String, dynamic>{
        'otp': otp,
      },
      includeAuthHeader: false,
    );
  }

  Future<AuthResponse> resetPassword({
    required String newPassword,
    required String confirmPassword,
  }) {
    return _post(
      endpoint: ApiConstants.resetPassword,
      body: <String, dynamic>{
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
      includeAuthHeader: false,
    );
  }

  Future<AuthResponse> refreshAuthToken() async {
    final String? storedRefreshToken = await _tokenStorage.readRefreshToken();
    if (!_hasValue(storedRefreshToken)) {
      return const AuthResponse(
        isSuccess: false,
        data: null,
        message: 'Refresh token not found. Please sign in again.',
        statusCode: 401,
        errors: <dynamic>['Refresh token not found'],
      );
    }

    return _post(
      endpoint: ApiConstants.refreshToken,
      body: <String, dynamic>{
        'refreshToken': storedRefreshToken!.trim(),
      },
      includeAuthHeader: false,
      allowRefreshRetry: false,
    );
  }

  Future<AuthResponse> postAuthorized({
    required String endpoint,
    required Map<String, dynamic> body,
  }) {
    return _post(endpoint: endpoint, body: body);
  }

  Future<AuthResponse> getAuthorized({
    required String endpoint,
  }) {
    return _get(endpoint: endpoint);
  }

  Future<String?> readAccessToken() {
    return _tokenStorage.readAccessToken();
  }

  Future<String?> readRefreshToken() {
    return _tokenStorage.readRefreshToken();
  }

  Future<void> clearSessionTokens() {
    return _tokenStorage.clearTokens();
  }

  Future<AuthResponse> _post({
    required String endpoint,
    required Map<String, dynamic> body,
    bool includeAuthHeader = true,
    bool allowRefreshRetry = true,
  }) async {
    final Uri uri = _resolveUri(endpoint);

    try {
      http.Response response = await _sendPostRequest(
        uri: uri,
        body: body,
        includeAuthHeader: includeAuthHeader,
      );
      AuthResponse parsedResponse = _buildResponse(response);

      final bool shouldRefreshAndRetry =
          includeAuthHeader &&
          allowRefreshRetry &&
          _isUnauthorized(response.statusCode, parsedResponse.statusCode);

      if (shouldRefreshAndRetry) {
        final bool refreshSucceeded = await _tryRefreshAndPersistTokens();
        if (refreshSucceeded) {
          response = await _sendPostRequest(
            uri: uri,
            body: body,
            includeAuthHeader: true,
          );
          parsedResponse = _buildResponse(response);
        }
      }

      await _saveTokensFromData(parsedResponse.data);
      return parsedResponse;
    } on TimeoutException {
      return const AuthResponse(
        isSuccess: false,
        data: null,
        message: 'Request timed out. Please try again.',
        statusCode: 408,
        errors: <dynamic>['Request timed out'],
      );
    } catch (e) {
      return AuthResponse(
        isSuccess: false,
        data: null,
        message: 'Something went wrong. Please try again.',
        statusCode: 500,
        errors: <dynamic>[e.toString()],
      );
    }
  }

  Future<AuthResponse> _get({
    required String endpoint,
    bool includeAuthHeader = true,
    bool allowRefreshRetry = true,
  }) async {
    final Uri uri = _resolveUri(endpoint);

    try {
      http.Response response = await _sendGetRequest(
        uri: uri,
        includeAuthHeader: includeAuthHeader,
      );
      AuthResponse parsedResponse = _buildResponse(response);

      final bool shouldRefreshAndRetry =
          includeAuthHeader &&
          allowRefreshRetry &&
          _isUnauthorized(response.statusCode, parsedResponse.statusCode);

      if (shouldRefreshAndRetry) {
        final bool refreshSucceeded = await _tryRefreshAndPersistTokens();
        if (refreshSucceeded) {
          response = await _sendGetRequest(
            uri: uri,
            includeAuthHeader: true,
          );
          parsedResponse = _buildResponse(response);
        }
      }

      await _saveTokensFromData(parsedResponse.data);
      return parsedResponse;
    } on TimeoutException {
      return const AuthResponse(
        isSuccess: false,
        data: null,
        message: 'Request timed out. Please try again.',
        statusCode: 408,
        errors: <dynamic>['Request timed out'],
      );
    } catch (e) {
      return AuthResponse(
        isSuccess: false,
        data: null,
        message: 'Something went wrong. Please try again.',
        statusCode: 500,
        errors: <dynamic>[e.toString()],
      );
    }
  }

  Uri _resolveUri(String endpoint) {
    if (endpoint.startsWith('http')) {
      return Uri.parse(endpoint);
    }

    return Uri.parse('${ApiConstants.baseUrl}$endpoint');
  }

  Future<http.Response> _sendPostRequest({
    required Uri uri,
    required Map<String, dynamic> body,
    required bool includeAuthHeader,
  }) async {
    final Map<String, String> headers =
        await _buildHeaders(includeAuthHeader: includeAuthHeader);

    return http
        .post(
          uri,
          headers: headers,
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 20));
  }

  Future<http.Response> _sendGetRequest({
    required Uri uri,
    required bool includeAuthHeader,
  }) async {
    final Map<String, String> headers =
        await _buildHeaders(includeAuthHeader: includeAuthHeader);

    return http
        .get(
          uri,
          headers: headers,
        )
        .timeout(const Duration(seconds: 20));
  }

  Future<Map<String, String>> _buildHeaders({
    required bool includeAuthHeader,
  }) async {
    final Map<String, String> headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuthHeader) {
      final String? accessToken = await _tokenStorage.readAccessToken();
      if (_hasValue(accessToken)) {
        headers['Authorization'] = 'Bearer ${accessToken!.trim()}';
      }
    }

    return headers;
  }

  Future<bool> _tryRefreshAndPersistTokens() async {
    final AuthResponse refreshResponse = await refreshAuthToken();
    if (!refreshResponse.isSuccess) {
      await _tokenStorage.clearTokens();
      return false;
    }

    final bool hasTokens = _hasTokensInData(refreshResponse.data);
    if (!hasTokens) {
      await _tokenStorage.clearTokens();
      return false;
    }

    return true;
  }

  bool _hasTokensInData(dynamic data) {
    if (data is! Map<String, dynamic>) {
      return false;
    }

    final String accessToken = (data['token'] ?? '').toString().trim();
    final String refreshToken = (data['refreshToken'] ?? '').toString().trim();
    return accessToken.isNotEmpty && refreshToken.isNotEmpty;
  }

  Future<bool> _saveTokensFromData(dynamic data) async {
    if (data is! Map<String, dynamic>) {
      return false;
    }

    final String accessToken = (data['token'] ?? '').toString().trim();
    final String refreshToken = (data['refreshToken'] ?? '').toString().trim();

    if (accessToken.isEmpty || refreshToken.isEmpty) {
      return false;
    }

    await _tokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    return true;
  }

  bool _hasValue(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  bool _isUnauthorized(int httpStatusCode, int apiStatusCode) {
    return httpStatusCode == 401 || apiStatusCode == 401;
  }

  AuthResponse _buildResponse(http.Response response) {
    final Map<String, dynamic> decoded = _decodeBody(response.body);

    final int resolvedStatusCode = _resolveStatusCode(
      decoded['statusCode'],
      response.statusCode,
    );
    final List<dynamic> resolvedErrors = _resolveErrors(decoded['errors']);
    final bool resolvedIsSuccess = _resolveIsSuccess(
      decoded,
      statusCode: resolvedStatusCode,
      errors: resolvedErrors,
    );

    return AuthResponse.fromJson(<String, dynamic>{
      'isSuccess': resolvedIsSuccess,
      'data': decoded['data'],
      'message': _resolveMessage(
        decoded['message'],
        statusCode: resolvedStatusCode,
        isSuccess: resolvedIsSuccess,
      ),
      'statusCode': resolvedStatusCode,
      'errors': resolvedErrors,
    });
  }

  Map<String, dynamic> _decodeBody(String body) {
    if (body.trim().isEmpty) {
      return <String, dynamic>{};
    }

    final dynamic parsed = jsonDecode(body);
    if (parsed is Map<String, dynamic>) {
      return parsed;
    }

    return <String, dynamic>{
      'message': 'Unexpected response format',
      'errors': <dynamic>['Response is not a JSON object'],
    };
  }

  int _resolveStatusCode(dynamic rawStatusCode, int fallback) {
    if (rawStatusCode is int) {
      return rawStatusCode;
    }

    if (rawStatusCode is String) {
      return int.tryParse(rawStatusCode) ?? fallback;
    }

    return fallback;
  }

  List<dynamic> _resolveErrors(dynamic rawErrors) {
    if (rawErrors is List<dynamic>) {
      return rawErrors;
    }

    if (rawErrors == null) {
      return <dynamic>[];
    }

    return <dynamic>[rawErrors.toString()];
  }

  bool _resolveIsSuccess(
    Map<String, dynamic> decoded, {
    required int statusCode,
    required List<dynamic> errors,
  }) {
    final bool? explicitSuccess = _readSuccessFromMap(decoded);
    if (explicitSuccess != null) {
      return explicitSuccess;
    }

    // Fallback for mock APIs that omit success flag.
    return statusCode >= 200 && statusCode < 300 && errors.isEmpty;
  }

  bool? _readSuccessFromMap(Map<String, dynamic> map) {
    const List<String> keys = <String>[
      'isSuccess',
      'success',
      'is_success',
      'isSucceeded',
      'ok',
      'status',
    ];

    for (final String key in keys) {
      if (!map.containsKey(key)) {
        continue;
      }

      final bool? parsed = _parseBoolNullable(map[key]);
      if (parsed != null) {
        return parsed;
      }
    }

    final dynamic nestedData = map['data'];
    if (nestedData is Map<String, dynamic>) {
      return _readSuccessFromMap(nestedData);
    }

    return null;
  }

  bool? _parseBoolNullable(dynamic value) {
    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    if (value is String) {
      final String normalized = value.trim().toLowerCase();

      if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
        return true;
      }

      if (normalized == 'false' || normalized == '0' || normalized == 'no') {
        return false;
      }
    }

    return null;
  }

  String _resolveMessage(
    dynamic rawMessage, {
    required int statusCode,
    required bool isSuccess,
  }) {
    final String message = (rawMessage ?? '').toString().trim();
    if (message.isNotEmpty) {
      return message;
    }

    if (isSuccess) {
      return 'Request completed';
    }

    return 'Request failed (HTTP $statusCode)';
  }
}
