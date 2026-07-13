import 'package:dio/dio.dart';
import 'package:requra/core/network/api_constants.dart';

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
          // Mock token since ApiDog endpoints seem to expect some Authorization header
          options.headers['Authorization'] = 'Bearer ANY_TOKEN';
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
              message =
              'Server error (${e.response?.statusCode ?? 'Unknown'})';
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
            ),
          );
        },
      ),
    );
  }

  Dio get dio => _dio;
}
