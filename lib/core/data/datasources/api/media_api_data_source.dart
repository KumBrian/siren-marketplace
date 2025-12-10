import 'dart:io';
import 'package:dio/dio.dart';
import '../api/api_config.dart';
import '../api/models/media_api_models.dart';

/// Data source for Pulsebox media upload API
class MediaApiDataSource {
  final Dio _dio;

  MediaApiDataSource({required Dio dio}) : _dio = dio;

  /// Upload multiple images to Pulsebox API
  /// Returns list of media upload responses with storageFilePath
  Future<List<MediaUploadResponse>> uploadImages(List<File> images) async {
    try {
      // Create FormData with all images
      final formData = FormData();

      for (var i = 0; i < images.length; i++) {
        final file = images[i];
        formData.files.add(
          MapEntry(
            'files[$i]', // Array field name
            await MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
            ),
          ),
        );
      }

      print('DEBUG: Uploading ${images.length} images to Pulsebox');

      // POST to Pulsebox create-collection endpoint
      final response = await _dio.post(
        '${ApiConfig.pulseboxBaseUrl}${ApiConfig.mediasCreateCollection}',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      print('DEBUG: Upload response status: ${response.statusCode}');

      // Parse response - could be array or single object
      final responseData = response.data;

      List<MediaUploadResponse> results = [];

      if (responseData is List) {
        // Array of responses
        results = responseData
            .map((json) => MediaUploadResponse.fromJson(json))
            .toList();
      } else if (responseData is Map<String, dynamic>) {
        // Single response wrapped
        if (responseData.containsKey('data')) {
          final data = responseData['data'];
          if (data is List) {
            results = data
                .map((json) => MediaUploadResponse.fromJson(json))
                .toList();
          } else {
            results = [MediaUploadResponse.fromJson(data)];
          }
        } else {
          results = [MediaUploadResponse.fromJson(responseData)];
        }
      }

      print('DEBUG: Parsed ${results.length} media upload responses');

      return results;
    } catch (e) {
      print('ERROR: Failed to upload images: $e');
      rethrow;
    }
  }
}
