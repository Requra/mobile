import 'package:dio/dio.dart';
import 'package:requra/core/network/api_constants.dart';
import 'package:requra/core/storage/secure_token_storage.dart';

class ApiClient {
  late Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final tokenStorage = const SecureTokenStorage();
          final token = await tokenStorage.readAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
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
              final data = e.response?.data;
              if (data is Map<String, dynamic>) {
                if (data['errors'] != null && 
                    ((data['errors'] is List && (data['errors'] as List).isNotEmpty) || 
                     (data['errors'] is Map && (data['errors'] as Map).isNotEmpty))) {
                  message = data['errors'].toString();
                } else if (data['message'] != null && data['message'].toString().isNotEmpty) {
                  message = data['message'].toString();
                } else if (data['title'] != null && data['title'].toString().isNotEmpty) {
                  message = data['title'].toString();
                } else {
                  message = 'Server error (${e.response?.statusCode})';
                }
              } else {
                message = 'Server error (${e.response?.statusCode ?? 'Unknown'})';
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

  Dio get dio => _dio;
}
