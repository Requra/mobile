import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:requra/core/network/api_constants.dart';
import 'package:requra/features/auth/data/models/auth_response.dart';

class AuthService {
  const AuthService();

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
      },
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
    );
  }

  Future<AuthResponse> verifyCode({
    required String code,
  }) {
    return _post(
      endpoint: ApiConstants.verifyCode,
      body: <String, dynamic>{
        'code': code,
      },
    );
  }

  Future<AuthResponse> resetPassword({
    required String password,
  }) {
    return _post(
      endpoint: ApiConstants.resetPassword,
      body: <String, dynamic>{
        'password': password,
      },
    );
  }

  Future<AuthResponse> _post({
    required String endpoint,
    required Map<String, dynamic> body,
  }) async {
    final Uri uri = endpoint.startsWith('http')
        ? Uri.parse(endpoint)
        : Uri.parse('${ApiConstants.baseUrl}$endpoint');

    try {
      final http.Response response = await http
          .post(
            uri,
            headers: <String, String>{
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 20));

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

      // Keep API-level error handling centralized for UI screens.
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
