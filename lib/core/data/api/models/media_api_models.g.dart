// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_api_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MediaUploadResponseImpl _$$MediaUploadResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$MediaUploadResponseImpl(
      id: (json['id'] as num).toInt(),
      fileName: json['fileName'] as String,
      thumbnailName: json['thumbnailName'] as String?,
      filePath: json['filePath'] as String,
      thumbnailFilePath: json['thumbnailFilePath'] as String?,
      storageFilePath: json['storageFilePath'] as String,
      storageThumbnailFilePath: json['storageThumbnailFilePath'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      deletedAt: json['deleted_at'] as String?,
      uid: json['uid'] as String?,
    );

Map<String, dynamic> _$$MediaUploadResponseImplToJson(
        _$MediaUploadResponseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fileName': instance.fileName,
      'thumbnailName': instance.thumbnailName,
      'filePath': instance.filePath,
      'thumbnailFilePath': instance.thumbnailFilePath,
      'storageFilePath': instance.storageFilePath,
      'storageThumbnailFilePath': instance.storageThumbnailFilePath,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'deleted_at': instance.deletedAt,
      'uid': instance.uid,
    };
