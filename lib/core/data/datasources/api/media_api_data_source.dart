import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:siren_marketplace/core/data/api/api_config.dart';
import 'package:siren_marketplace/core/data/api/models/media_api_models.dart';

/// Data source for Pulsebox media upload API
class MediaApiDataSource {
  final Dio _dio;

  MediaApiDataSource({required Dio dio}) : _dio = dio;

  /// Compress an image file to reduce size before upload
  /// Target: ~500KB per image, max dimensions 1920x1080
  Future<File> _compressImage(File imageFile) async {
    try {
      final filePath = imageFile.path;
      final fileName = filePath.split('/').last;
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/compressed_$fileName';

      print('DEBUG: Compressing image: $fileName');
      print('DEBUG: Original size: ${await imageFile.length()} bytes');

      final compressedBytes = await FlutterImageCompress.compressWithFile(
        filePath,
        minWidth: 1920,
        minHeight: 1080,
        quality: 85, // 85% quality - good balance
      );

      if (compressedBytes == null) {
        print('WARN: Compression failed, using original');
        return imageFile;
      }

      // Write compressed bytes to new file
      final compressedFile = File(targetPath);
      await compressedFile.writeAsBytes(compressedBytes);

      print('DEBUG: Compressed size: ${compressedBytes.length} bytes');
      print(
        'DEBUG: Reduction: ${((1 - (compressedBytes.length / await imageFile.length())) * 100).toStringAsFixed(1)}%',
      );

      return compressedFile;
    } catch (e) {
      print('ERROR: Image compression failed: $e');
      // Return original if compression fails
      return imageFile;
    }
  }

  /// Upload multiple images to Pulsebox API
  /// Returns list of media upload responses with storageFilePath
  /// Images are automatically compressed to reduce upload size
  Future<List<MediaUploadResponse>> uploadImages(List<File> images) async {
    try {
      // Compress all images first
      print('DEBUG: Compressing ${images.length} images before upload');
      final compressedImages = await Future.wait(
        images.map((img) => _compressImage(img)),
      );

      // Create FormData with compressed images
      final formData = FormData();

      for (var i = 0; i < compressedImages.length; i++) {
        final file = compressedImages[i];
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

      print(
        'DEBUG: Uploading ${compressedImages.length} compressed images to Pulsebox',
      );

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

      // Clean up compressed temp files
      for (var compressedFile in compressedImages) {
        try {
          if (compressedFile.path.contains('compressed_')) {
            await compressedFile.delete();
          }
        } catch (e) {
          // Ignore cleanup errors
        }
      }

      return results;
    } catch (e) {
      print('ERROR: Failed to upload images: $e');
      rethrow;
    }
  }
}
