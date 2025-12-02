import 'dart:io';
import 'package:dio/dio.dart';
import 'api_result.dart';
import 'network_exceptions.dart';
import 'dio_client.dart';

class ApiService {
  final DioClient _dioClient;

  ApiService(this._dioClient);

  // GENERIC GET METHOD
  Future<ApiResult<T>> get<T>({
    required String endpoint,
    Map<String, dynamic>? queryParams,
    T Function(dynamic)? fromJson, // Optional mapper function
  }) async {
    try {
      final response = await _dioClient.dio.get(
        endpoint,
        queryParameters: queryParams,
      );

      // If a fromJson mapper is provided, use it. Otherwise return raw data.
      final data = fromJson != null ? fromJson(response.data) : response.data;

      return Success(data);
    } on DioException catch (e) {
      return Failure(
        NetworkExceptions.getErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return Failure(e.toString());
    }
  }

  // GENERIC POST METHOD
  Future<ApiResult<T>> post<T>({
    required String endpoint,
    required dynamic body,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dioClient.dio.post(endpoint, data: body);
      final data = fromJson != null ? fromJson(response.data) : response.data;
      return Success(data);
    } on DioException catch (e) {
      return Failure(
        NetworkExceptions.getErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return Failure(e.toString());
    }
  }

  // FILE UPLOAD METHOD
  Future<ApiResult<T>> upload<T>({
    required String endpoint,
    required File file,
    String fileKey = 'file',
    T Function(dynamic)? fromJson,
  }) async {
    try {
      String fileName = file.path.split('/').last;

      FormData formData = FormData.fromMap({
        fileKey: await MultipartFile.fromFile(file.path, filename: fileName),
      });

      final response = await _dioClient.dio.post(endpoint, data: formData);
      final data = fromJson != null ? fromJson(response.data) : response.data;
      return Success(data);
    } on DioException catch (e) {
      return Failure(
        NetworkExceptions.getErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return Failure(e.toString());
    }
  }
}
