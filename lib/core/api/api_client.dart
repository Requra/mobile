import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:requra/core/network/api_constants.dart';
import 'package:requra/core/storage/secure_token_storage.dart';
import 'package:requra/core/navigation/navigator_key.dart';
import 'package:requra/core/global_widgets/app_snackbar.dart';

class ApiClient {
  late Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final tokenStorage = const SecureTokenStorage();
          final token = await tokenStorage.readAccessToken();
          final guestToken = await tokenStorage.readGuestAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          } else if (guestToken != null && guestToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $guestToken';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          String message;

          switch (e.type) {
            case DioExceptionType.connectionTimeout:
              message = 'Connection timeout';
              break;

            case DioExceptionType.sendTimeout:
              message = 'Send timeout';
              break;

            case DioExceptionType.receiveTimeout:
              message = 'Receive timeout';
              break;

            case DioExceptionType.connectionError:
              message = 'No internet connection';
              break;

            case DioExceptionType.badResponse:
              final statusCode = e.response?.statusCode;
              if (statusCode == 401) {
                message = 'Session expired. Please log in again.';
                _handleUnauthorized();
                break;
              }

              final data = e.response?.data;
              if (data is Map<String, dynamic>) {
                if (data['errors'] != null &&
                    ((data['errors'] is List &&
                            (data['errors'] as List).isNotEmpty) ||
                        (data['errors'] is Map &&
                            (data['errors'] as Map).isNotEmpty))) {
                  message = data['errors'].toString();
                } else if (data['message'] != null &&
                    data['message'].toString().isNotEmpty) {
                  message = data['message'].toString();
                } else if (data['title'] != null &&
                    data['title'].toString().isNotEmpty) {
                  message = data['title'].toString();
                } else {
                  message = 'Server error (${statusCode})';
                }
              } else {
                message = 'Server error (${statusCode ?? 'Unknown'})';
              }
              break;

            case DioExceptionType.cancel:
              message = 'Request cancelled';
              break;

            default:
              message = 'Unexpected error';
          }

          handler.next(
            DioException(
              requestOptions: e.requestOptions,
              response: e.response,
              type: e.type,
              error: message,
              message: message,
            ),
          );
        },
      ),
    );
  }

  void _handleUnauthorized() async {
    final tokenStorage = const SecureTokenStorage();
    await tokenStorage.clearTokens();

    if (navigatorKey.currentContext != null) {
      AppSnackbar.showError(
        navigatorKey.currentContext!,
        'Session expired. Please log in again.',
      );
      Navigator.of(
        navigatorKey.currentContext!,
        rootNavigator: true,
      ).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  Dio get dio => _dio;
}
