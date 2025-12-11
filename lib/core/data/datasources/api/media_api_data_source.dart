import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:siren_marketplace/core/data/api/api_config.dart';
import 'package:siren_marketplace/core/data/api/models/media_api_models.dart';
import 'package:siren_marketplace/core/data/storage/token_storage.dart';

/// Data source for Pulsebox media upload API
class MediaApiDataSource {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  // Cache Pulsebox access token to avoid repeated API calls
  String? _cachedPulseboxToken;
  DateTime? _pulseboxTokenExpiry;

  MediaApiDataSource({required Dio dio, required TokenStorage tokenStorage})
    : _dio = dio,
      _tokenStorage = tokenStorage;

  /// Get Pulsebox access token by exchanging JWT
  /// Returns cached token if still valid
  Future<String> _getPulseboxAccessToken() async {
    // Check if we have a valid cached token
    if (_cachedPulseboxToken != null &&
        _pulseboxTokenExpiry != null &&
        DateTime.now().isBefore(_pulseboxTokenExpiry!)) {
      print('DEBUG: Using cached Pulsebox token');
      return _cachedPulseboxToken!;
    }

    // Get JWT from storage
    final jwt = await _tokenStorage.getAccessToken();
    if (jwt == null) {
      throw Exception('No JWT available to exchange for Pulsebox token');
    }

    print('DEBUG: Exchanging JWT for Pulsebox access token');

    try {
      // Call Pulsebox to create access token
      final response = await _dio.post(
        '${ApiConfig.pulseboxBaseUrl}/access-token/create',
        data: {'jwtToken': jwt},
      );

      final data = response.data;
      final pulseboxToken = data['token'] as String?;
      final expireAt = data['expireAt'] as String?;

      if (pulseboxToken == null) {
        throw Exception('No token in Pulsebox response');
      }

      // Parse expiry time from response
      DateTime? expiryTime;
      if (expireAt != null) {
        try {
          expiryTime = DateTime.parse(expireAt);
          // Use token until 5 minutes before expiry for safety
          expiryTime = expiryTime.subtract(const Duration(minutes: 5));
        } catch (e) {
          print('WARN: Could not parse expireAt, using default 55 minutes');
          expiryTime = DateTime.now().add(const Duration(minutes: 55));
        }
      } else {
        expiryTime = DateTime.now().add(const Duration(minutes: 55));
      }

      // Cache the token
      _cachedPulseboxToken = pulseboxToken;
      _pulseboxTokenExpiry = expiryTime;

      print(
        'DEBUG: Got Pulsebox access token, valid until ${_pulseboxTokenExpiry}',
      );

      return pulseboxToken;
    } catch (e) {
      print('ERROR: Failed to get Pulsebox access token: $e');
      rethrow;
    }
  }

  /// Extract pulseBoxAccessToken from JWT
  String? _extractPulseBoxToken(String jwt) {
    try {
      // JWT format: header.payload.signature
      final parts = jwt.split('.');
      if (parts.length != 3) return null;

      // Decode payload (base64url)
      final payload = parts[1];
      // Add padding if needed
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final json = jsonDecode(decoded) as Map<String, dynamic>;

      return json['pulseBoxAccessToken'] as String?;
    } catch (e) {
      print('ERROR: Failed to extract pulseBoxAccessToken: $e');
      return null;
    }
  }

  /// Compress an image file to reduce size before upload
  /// Target: ~500KB per image with quality compression
  Future<File> _compressImage(File imageFile) async {
    try {
      final filePath = imageFile.path;
      final fileName = filePath.split('/').last;
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/compressed_$fileName';

      final originalSize = await imageFile.length();
      print('DEBUG: Compressing image: $fileName');
      print('DEBUG: Original size: $originalSize bytes');

      // Compress with quality only (no resizing)
      // This prevents upscaling small images
      final compressedBytes = await FlutterImageCompress.compressWithFile(
        filePath,
        quality:
            60, // 60% quality - good compression while maintaining decent quality
      );

      if (compressedBytes == null) {
        print('WARN: Compression failed, using original');
        return imageFile;
      }

      final compressedSize = compressedBytes.length;

      // Only use compressed version if it's actually smaller
      if (compressedSize >= originalSize) {
        print('WARN: Compressed file is larger, using original');
        return imageFile;
      }

      // Write compressed bytes to new file
      final compressedFile = File(targetPath);
      await compressedFile.writeAsBytes(compressedBytes);

      print('DEBUG: Compressed size: $compressedSize bytes');
      print(
        'DEBUG: Reduction: ${((1 - (compressedSize / originalSize)) * 100).toStringAsFixed(1)}%',
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

      // Get Pulsebox access token (exchanges JWT if needed)
      final pulseboxToken = await _getPulseboxAccessToken();

      // POST to Pulsebox create-collection endpoint with AccessToken only
      final response = await _dio.post(
        '${ApiConfig.pulseboxBaseUrl}${ApiConfig.mediasCreateCollection}',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
            'AccessToken': pulseboxToken,
          },
        ),
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
