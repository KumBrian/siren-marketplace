import 'package:dio/dio.dart';

class NetworkExceptions {
  static String getErrorMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return "Connection timed out";
      case DioExceptionType.sendTimeout:
        return "Send timed out";
      case DioExceptionType.receiveTimeout:
        return "Receive timed out";
      case DioExceptionType.badResponse:
        return _handleStatusCode(error.response?.statusCode);
      case DioExceptionType.cancel:
        return "Request cancelled";
      case DioExceptionType.connectionError:
        return "No internet connection";
      default:
        return "Something went wrong";
    }
  }

  static String _handleStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return "Bad request.";
      case 401:
        return "Authentication failed.";
      case 403:
        return "The authenticated user is not allowed to access the specified API endpoint.";
      case 404:
        return "The requested resource does not exist.";
      case 500:
        return "Internal server error.";
      default:
        return "Received invalid status code: $statusCode";
    }
  }
}
