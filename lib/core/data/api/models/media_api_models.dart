import 'package:freezed_annotation/freezed_annotation.dart';

part 'media_api_models.freezed.dart';
part 'media_api_models.g.dart';

/// Media upload response from Pulsebox API
@freezed
class MediaUploadResponse with _$MediaUploadResponse {
  const factory MediaUploadResponse({
    required int id,
    required String fileName,
    String? thumbnailName,
    required String filePath,
    String? thumbnailFilePath,
    required String storageFilePath,
    String? storageThumbnailFilePath,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    @JsonKey(name: 'deleted_at') String? deletedAt,
    String? uid,
  }) = _MediaUploadResponse;

  factory MediaUploadResponse.fromJson(Map<String, dynamic> json) =>
      _$MediaUploadResponseFromJson(json);
}
