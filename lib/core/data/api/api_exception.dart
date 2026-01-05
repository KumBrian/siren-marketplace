/// Custom exceptions for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => message;
}

/// Exception thrown when authentication fails (401)
class UnauthorizedException extends ApiException {
  UnauthorizedException([String message = 'Unauthorized'])
    : super(message, statusCode: 401);
}

/// Exception thrown when resource is not found (404)
class NotFoundException extends ApiException {
  NotFoundException([String message = 'Resource not found'])
    : super(message, statusCode: 404);
}

/// Exception thrown when validation fails (422)
class ValidationException extends ApiException {
  final Map<String, List<String>>? errors;

  ValidationException(String message, {this.errors})
    : super(message, statusCode: 422, data: errors);

  @override
  String toString() {
    if (errors != null && errors!.isNotEmpty) {
      final errorMessages = errors!.entries
          .map((e) => '${e.key}: ${e.value.join(', ')}')
          .join('; ');
      return '$message\n$errorMessages';
    }
    return message;
  }
}

/// Exception thrown when server error occurs (500+)
class ServerException extends ApiException {
  ServerException([String message = 'Server error occurred'])
    : super(message, statusCode: 500);
}

/// Exception thrown when network connection fails
class NetworkException extends ApiException {
  NetworkException([String message = 'Network connection failed'])
    : super(message);
}

/// Exception thrown when request times out
class TimeoutException extends ApiException {
  TimeoutException([String message = 'Request timed out']) : super(message);
}
