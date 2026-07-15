import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
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
      body: <String, dynamic>{'email': email, 'otpCode': otpCode},
      includeAuthHeader: false,
    );
  }

  Future<AuthResponse> resendOtp({
    required String email,
    required int otpType,
  }) {
    return _post(
      endpoint: ApiConstants.resendOtp,
      body: <String, dynamic>{'email': email, 'otpType': otpType},
      includeAuthHeader: false,
    );
  }

  Future<AuthResponse> googleLogin({required String idToken}) {
    final String platform = _resolvePlatformParam();
    final Uri uri = _resolveUri(
      ApiConstants.googleLogin,
      queryParameters: <String, String>{
        'idToken': idToken,
        'platform': platform,
      },
    );

    if (kDebugMode) {
      final Uri safeUri = uri.replace(
        queryParameters: <String, String>{
          'idToken': '***',
          'platform': platform,
        },
      );
      debugPrint(
        'Google login request: $safeUri (idTokenLength=${idToken.length})',
      );
    }

    return _get(
      endpoint: uri.toString(),
      includeAuthHeader: false,
      allowRefreshRetry: false,
      debugLabel: 'googleLogin',
    );
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) {
    return _post(
      endpoint: ApiConstants.login,
      body: <String, dynamic>{'email': email, 'password': password},
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
        'role': 1,
      },
      includeAuthHeader: false,
    );
  }

  Future<AuthResponse> forgotPassword({required String email}) {
    return _post(
      endpoint: ApiConstants.forgotPassword,
      body: <String, dynamic>{'email': email},
      includeAuthHeader: false,
    );
  }

  Future<AuthResponse> verifyOtp({required String otp}) {
    return _post(
      endpoint: ApiConstants.verifyOtp,
      body: <String, dynamic>{'otp': otp},
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

  Future<AuthResponse> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return _put(
      endpoint: ApiConstants.changePassword,
      body: <String, dynamic>{
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }

  Future<AuthResponse> updateProfile({required String name}) {
    return _put(
      endpoint: ApiConstants.updateProfile,
      body: <String, dynamic>{'name': name},
    );
  }

  Future<AuthResponse> getProfile() {
    return _get(endpoint: ApiConstants.updateProfile);
  }

  Future<AuthResponse> logout() async {
    final AuthResponse response = await _post(
      endpoint: ApiConstants.logout,
      body: <String, dynamic>{},
    );
    if (response.isSuccess) {
      await _tokenStorage.clearTokens();
    }
    return response;
  }

  Future<AuthResponse> deleteAccount() {
    return _deleteAccountWithFallback();
  }

  Future<AuthResponse> _deleteAccountWithFallback() async {
    AuthResponse response = await _delete(endpoint: ApiConstants.deleteAccount);
    if (response.statusCode == 404 || response.statusCode == 405) {
      response = await _post(
        endpoint: ApiConstants.deleteAccount,
        body: <String, dynamic>{},
      );
    }
    return response;
  }

  Future<AuthResponse> uploadAvatar({required File file}) async {
    try {
      http.Response response = await _sendAvatarRequest(
        file: file,
        includeAuthHeader: true,
      );
      AuthResponse parsedResponse = _buildResponse(response);

      final bool shouldRefreshAndRetry = _isUnauthorized(
        response.statusCode,
        parsedResponse.statusCode,
      );

      if (shouldRefreshAndRetry) {
        final bool refreshSucceeded = await _tryRefreshAndPersistTokens();
        if (refreshSucceeded) {
          response = await _sendAvatarRequest(
            file: file,
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
      body: <String, dynamic>{'refreshToken': storedRefreshToken!.trim()},
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

  Future<AuthResponse> getAuthorized({required String endpoint}) {
    return _get(endpoint: endpoint);
  }

  Future<AuthResponse> putAuthorized({
    required String endpoint,
    required Map<String, dynamic> body,
  }) {
    return _put(endpoint: endpoint, body: body);
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
    Map<String, String>? queryParameters,
    String? debugLabel,
  }) async {
    final Uri uri = _resolveUri(endpoint, queryParameters: queryParameters);

    try {
      http.Response response = await _sendGetRequest(
        uri: uri,
        includeAuthHeader: includeAuthHeader,
      );
      if (kDebugMode && debugLabel != null) {
        debugPrint('[$debugLabel] status=${response.statusCode}');
        debugPrint('[$debugLabel] body=${response.body}');
      }
      AuthResponse parsedResponse = _buildResponse(response);

      final bool shouldRefreshAndRetry =
          includeAuthHeader &&
          allowRefreshRetry &&
          _isUnauthorized(response.statusCode, parsedResponse.statusCode);

      if (shouldRefreshAndRetry) {
        final bool refreshSucceeded = await _tryRefreshAndPersistTokens();
        if (refreshSucceeded) {
          response = await _sendGetRequest(uri: uri, includeAuthHeader: true);
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

  Future<AuthResponse> _put({
    required String endpoint,
    required Map<String, dynamic> body,
    bool includeAuthHeader = true,
    bool allowRefreshRetry = true,
  }) async {
    final Uri uri = _resolveUri(endpoint);

    try {
      http.Response response = await _sendPutRequest(
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
          response = await _sendPutRequest(
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

  Future<AuthResponse> _delete({
    required String endpoint,
    bool includeAuthHeader = true,
    bool allowRefreshRetry = true,
  }) async {
    final Uri uri = _resolveUri(endpoint);

    try {
      http.Response response = await _sendDeleteRequest(
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
          response = await _sendDeleteRequest(
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

  Uri _resolveUri(String endpoint, {Map<String, String>? queryParameters}) {
    return _resolveUriWithQuery(endpoint, queryParameters: queryParameters);
  }

  Uri _resolveUriWithQuery(
    String endpoint, {
    Map<String, String>? queryParameters,
  }) {
    final Uri baseUri = endpoint.startsWith('http')
        ? Uri.parse(endpoint)
        : Uri.parse('${ApiConstants.baseUrl}$endpoint');
    if (kDebugMode) {
      final Uri logUri = baseUri.queryParameters.containsKey('idToken')
          ? baseUri.replace(
              queryParameters: <String, String>{
                ...baseUri.queryParameters,
                'idToken': '***',
              },
            )
          : baseUri;
      debugPrint('REQUEST URL: $logUri');
    }
    if (queryParameters == null || queryParameters.isEmpty) {
      return baseUri;
    }

    return baseUri.replace(
      queryParameters: <String, String>{
        ...baseUri.queryParameters,
        ...queryParameters,
      },
    );
  }

  Future<http.Response> _sendPostRequest({
    required Uri uri,
    required Map<String, dynamic> body,
    required bool includeAuthHeader,
  }) async {
    final Map<String, String> headers = await _buildHeaders(
      includeAuthHeader: includeAuthHeader,
    );

    return http
        .post(uri, headers: headers, body: jsonEncode(body))
        .timeout(const Duration(seconds: 20));
  }

  Future<http.Response> _sendGetRequest({
    required Uri uri,
    required bool includeAuthHeader,
  }) async {
    final Map<String, String> headers = await _buildHeaders(
      includeAuthHeader: includeAuthHeader,
    );

    return http.get(uri, headers: headers).timeout(const Duration(seconds: 20));
  }

  Future<http.Response> _sendPutRequest({
    required Uri uri,
    required Map<String, dynamic> body,
    required bool includeAuthHeader,
  }) async {
    final Map<String, String> headers = await _buildHeaders(
      includeAuthHeader: includeAuthHeader,
    );

    return http
        .put(uri, headers: headers, body: jsonEncode(body))
        .timeout(const Duration(seconds: 20));
  }

  Future<http.Response> _sendDeleteRequest({
    required Uri uri,
    required bool includeAuthHeader,
  }) async {
    final Map<String, String> headers = await _buildHeaders(
      includeAuthHeader: includeAuthHeader,
    );

    return http
        .delete(uri, headers: headers)
        .timeout(const Duration(seconds: 20));
  }

  Future<http.Response> _sendAvatarRequest({
    required File file,
    required bool includeAuthHeader,
  }) async {
    final Uri uri = _resolveUri(ApiConstants.uploadAvatar);
    final Map<String, String> headers = await _buildMultipartHeaders(
      includeAuthHeader: includeAuthHeader,
    );

    final http.MultipartRequest request = http.MultipartRequest('POST', uri)
      ..headers.addAll(headers)
      ..files.add(await http.MultipartFile.fromPath('avatar', file.path));

    final http.StreamedResponse streamedResponse = await request.send();
    return http.Response.fromStream(streamedResponse);
  }

  Future<Map<String, String>> _buildHeaders({
    required bool includeAuthHeader,
  }) async {
    final Map<String, String> headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuthHeader) {
      final String? accessToken = await _tokenStorage.readAccessToken().timeout(
        const Duration(seconds: 3),
        onTimeout: () => null,
      );
      if (_hasValue(accessToken)) {
        headers['Authorization'] = 'Bearer ${accessToken!.trim()}';
      }
    }

    return headers;
  }

  Future<Map<String, String>> _buildMultipartHeaders({
    required bool includeAuthHeader,
  }) async {
    final Map<String, String> headers = <String, String>{
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

  String _resolvePlatformParam() {
    if (kIsWeb) {
      return 'web';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.android:
        return 'android';
      default:
        return 'android';
    }
  }

  bool _isUnauthorized(int httpStatusCode, int apiStatusCode) {
    return httpStatusCode == 401 || apiStatusCode == 401;
  }

  AuthResponse _buildResponse(http.Response response) {
    final String rawBody = response.body;
    final Map<String, dynamic> decoded = _decodeBody(rawBody);

    final int resolvedStatusCode = _resolveStatusCode(
      decoded['statusCode'],
      response.statusCode,
    );
    List<dynamic> resolvedErrors = _resolveErrors(decoded['errors']);

    if (_hasFormatError(resolvedErrors) &&
        response.statusCode >= 200 &&
        response.statusCode < 300) {
      resolvedErrors = <dynamic>[];
      if (decoded['message'] == null ||
          decoded['message'].toString().trim().isEmpty) {
        decoded['message'] = rawBody.trim().isNotEmpty
            ? rawBody.trim()
            : 'Request completed';
      }
    }

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

  bool _hasFormatError(List<dynamic> errors) {
    for (final dynamic error in errors) {
      final String text = error.toString();
      if (text.contains('Response is not a JSON object') ||
          text.contains('Response is not valid JSON')) {
        return true;
      }
    }
    return false;
  }

  Map<String, dynamic> _decodeBody(String body) {
    if (body.trim().isEmpty) {
      return <String, dynamic>{};
    }

    try {
      final dynamic parsed = jsonDecode(body);
      if (parsed is Map<String, dynamic>) {
        return parsed;
      }

      return <String, dynamic>{
        'message': 'Unexpected response format',
        'errors': <dynamic>['Response is not a JSON object'],
      };
    } catch (_) {
      return <String, dynamic>{
        'message': 'Unexpected response format',
        'errors': <dynamic>['Response is not valid JSON'],
      };
    }
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
