class AuthResponse {
  const AuthResponse({
    required this.isSuccess,
    this.data,
    required this.message,
    required this.statusCode,
    required this.errors,
  });

  final bool isSuccess;
  final dynamic data;
  final String message;
  final int statusCode;
  final List<dynamic> errors;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final dynamic rawIsSuccess = json['isSuccess'];

    return AuthResponse(
      isSuccess: _parseBool(rawIsSuccess),
      data: json['data'],
      message: (json['message'] ?? 'Unknown response').toString(),
      statusCode: json['statusCode'] is int
          ? json['statusCode'] as int
          : int.tryParse((json['statusCode'] ?? 0).toString()) ?? 0,
      errors: json['errors'] is List ? json['errors'] as List<dynamic> : const <dynamic>[],
    );
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    if (value is String) {
      final String normalized = value.trim().toLowerCase();
      return normalized == 'true' || normalized == '1' || normalized == 'yes';
    }

    return false;
  }

  String get firstError {
    if (errors.isEmpty) {
      return message;
    }
    return errors.first.toString();
  }
}
