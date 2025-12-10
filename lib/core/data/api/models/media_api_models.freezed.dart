// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'media_api_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MediaUploadResponse _$MediaUploadResponseFromJson(Map<String, dynamic> json) {
  return _MediaUploadResponse.fromJson(json);
}

/// @nodoc
mixin _$MediaUploadResponse {
  int get id => throw _privateConstructorUsedError;
  String get fileName => throw _privateConstructorUsedError;
  String? get thumbnailName => throw _privateConstructorUsedError;
  String get filePath => throw _privateConstructorUsedError;
  String? get thumbnailFilePath => throw _privateConstructorUsedError;
  String get storageFilePath =>
      throw _privateConstructorUsedError; // This is what we need for catch creation
  String? get storageThumbnailFilePath => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  String? get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'deleted_at')
  String? get deletedAt => throw _privateConstructorUsedError;
  String? get uid => throw _privateConstructorUsedError;

  /// Serializes this MediaUploadResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MediaUploadResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MediaUploadResponseCopyWith<MediaUploadResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MediaUploadResponseCopyWith<$Res> {
  factory $MediaUploadResponseCopyWith(
    MediaUploadResponse value,
    $Res Function(MediaUploadResponse) then,
  ) = _$MediaUploadResponseCopyWithImpl<$Res, MediaUploadResponse>;
  @useResult
  $Res call({
    int id,
    String fileName,
    String? thumbnailName,
    String filePath,
    String? thumbnailFilePath,
    String storageFilePath,
    String? storageThumbnailFilePath,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    @JsonKey(name: 'deleted_at') String? deletedAt,
    String? uid,
  });
}

/// @nodoc
class _$MediaUploadResponseCopyWithImpl<$Res, $Val extends MediaUploadResponse>
    implements $MediaUploadResponseCopyWith<$Res> {
  _$MediaUploadResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MediaUploadResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fileName = null,
    Object? thumbnailName = freezed,
    Object? filePath = null,
    Object? thumbnailFilePath = freezed,
    Object? storageFilePath = null,
    Object? storageThumbnailFilePath = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? deletedAt = freezed,
    Object? uid = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            fileName: null == fileName
                ? _value.fileName
                : fileName // ignore: cast_nullable_to_non_nullable
                      as String,
            thumbnailName: freezed == thumbnailName
                ? _value.thumbnailName
                : thumbnailName // ignore: cast_nullable_to_non_nullable
                      as String?,
            filePath: null == filePath
                ? _value.filePath
                : filePath // ignore: cast_nullable_to_non_nullable
                      as String,
            thumbnailFilePath: freezed == thumbnailFilePath
                ? _value.thumbnailFilePath
                : thumbnailFilePath // ignore: cast_nullable_to_non_nullable
                      as String?,
            storageFilePath: null == storageFilePath
                ? _value.storageFilePath
                : storageFilePath // ignore: cast_nullable_to_non_nullable
                      as String,
            storageThumbnailFilePath: freezed == storageThumbnailFilePath
                ? _value.storageThumbnailFilePath
                : storageThumbnailFilePath // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            deletedAt: freezed == deletedAt
                ? _value.deletedAt
                : deletedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            uid: freezed == uid
                ? _value.uid
                : uid // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MediaUploadResponseImplCopyWith<$Res>
    implements $MediaUploadResponseCopyWith<$Res> {
  factory _$$MediaUploadResponseImplCopyWith(
    _$MediaUploadResponseImpl value,
    $Res Function(_$MediaUploadResponseImpl) then,
  ) = __$$MediaUploadResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String fileName,
    String? thumbnailName,
    String filePath,
    String? thumbnailFilePath,
    String storageFilePath,
    String? storageThumbnailFilePath,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    @JsonKey(name: 'deleted_at') String? deletedAt,
    String? uid,
  });
}

/// @nodoc
class __$$MediaUploadResponseImplCopyWithImpl<$Res>
    extends _$MediaUploadResponseCopyWithImpl<$Res, _$MediaUploadResponseImpl>
    implements _$$MediaUploadResponseImplCopyWith<$Res> {
  __$$MediaUploadResponseImplCopyWithImpl(
    _$MediaUploadResponseImpl _value,
    $Res Function(_$MediaUploadResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MediaUploadResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fileName = null,
    Object? thumbnailName = freezed,
    Object? filePath = null,
    Object? thumbnailFilePath = freezed,
    Object? storageFilePath = null,
    Object? storageThumbnailFilePath = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? deletedAt = freezed,
    Object? uid = freezed,
  }) {
    return _then(
      _$MediaUploadResponseImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        fileName: null == fileName
            ? _value.fileName
            : fileName // ignore: cast_nullable_to_non_nullable
                  as String,
        thumbnailName: freezed == thumbnailName
            ? _value.thumbnailName
            : thumbnailName // ignore: cast_nullable_to_non_nullable
                  as String?,
        filePath: null == filePath
            ? _value.filePath
            : filePath // ignore: cast_nullable_to_non_nullable
                  as String,
        thumbnailFilePath: freezed == thumbnailFilePath
            ? _value.thumbnailFilePath
            : thumbnailFilePath // ignore: cast_nullable_to_non_nullable
                  as String?,
        storageFilePath: null == storageFilePath
            ? _value.storageFilePath
            : storageFilePath // ignore: cast_nullable_to_non_nullable
                  as String,
        storageThumbnailFilePath: freezed == storageThumbnailFilePath
            ? _value.storageThumbnailFilePath
            : storageThumbnailFilePath // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        deletedAt: freezed == deletedAt
            ? _value.deletedAt
            : deletedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        uid: freezed == uid
            ? _value.uid
            : uid // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MediaUploadResponseImpl implements _MediaUploadResponse {
  const _$MediaUploadResponseImpl({
    required this.id,
    required this.fileName,
    this.thumbnailName,
    required this.filePath,
    this.thumbnailFilePath,
    required this.storageFilePath,
    this.storageThumbnailFilePath,
    @JsonKey(name: 'created_at') this.createdAt,
    @JsonKey(name: 'updated_at') this.updatedAt,
    @JsonKey(name: 'deleted_at') this.deletedAt,
    this.uid,
  });

  factory _$MediaUploadResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$MediaUploadResponseImplFromJson(json);

  @override
  final int id;
  @override
  final String fileName;
  @override
  final String? thumbnailName;
  @override
  final String filePath;
  @override
  final String? thumbnailFilePath;
  @override
  final String storageFilePath;
  // This is what we need for catch creation
  @override
  final String? storageThumbnailFilePath;
  @override
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final String? updatedAt;
  @override
  @JsonKey(name: 'deleted_at')
  final String? deletedAt;
  @override
  final String? uid;

  @override
  String toString() {
    return 'MediaUploadResponse(id: $id, fileName: $fileName, thumbnailName: $thumbnailName, filePath: $filePath, thumbnailFilePath: $thumbnailFilePath, storageFilePath: $storageFilePath, storageThumbnailFilePath: $storageThumbnailFilePath, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, uid: $uid)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MediaUploadResponseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.thumbnailName, thumbnailName) ||
                other.thumbnailName == thumbnailName) &&
            (identical(other.filePath, filePath) ||
                other.filePath == filePath) &&
            (identical(other.thumbnailFilePath, thumbnailFilePath) ||
                other.thumbnailFilePath == thumbnailFilePath) &&
            (identical(other.storageFilePath, storageFilePath) ||
                other.storageFilePath == storageFilePath) &&
            (identical(
                  other.storageThumbnailFilePath,
                  storageThumbnailFilePath,
                ) ||
                other.storageThumbnailFilePath == storageThumbnailFilePath) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.uid, uid) || other.uid == uid));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    fileName,
    thumbnailName,
    filePath,
    thumbnailFilePath,
    storageFilePath,
    storageThumbnailFilePath,
    createdAt,
    updatedAt,
    deletedAt,
    uid,
  );

  /// Create a copy of MediaUploadResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MediaUploadResponseImplCopyWith<_$MediaUploadResponseImpl> get copyWith =>
      __$$MediaUploadResponseImplCopyWithImpl<_$MediaUploadResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MediaUploadResponseImplToJson(this);
  }
}

abstract class _MediaUploadResponse implements MediaUploadResponse {
  const factory _MediaUploadResponse({
    required final int id,
    required final String fileName,
    final String? thumbnailName,
    required final String filePath,
    final String? thumbnailFilePath,
    required final String storageFilePath,
    final String? storageThumbnailFilePath,
    @JsonKey(name: 'created_at') final String? createdAt,
    @JsonKey(name: 'updated_at') final String? updatedAt,
    @JsonKey(name: 'deleted_at') final String? deletedAt,
    final String? uid,
  }) = _$MediaUploadResponseImpl;

  factory _MediaUploadResponse.fromJson(Map<String, dynamic> json) =
      _$MediaUploadResponseImpl.fromJson;

  @override
  int get id;
  @override
  String get fileName;
  @override
  String? get thumbnailName;
  @override
  String get filePath;
  @override
  String? get thumbnailFilePath;
  @override
  String get storageFilePath; // This is what we need for catch creation
  @override
  String? get storageThumbnailFilePath;
  @override
  @JsonKey(name: 'created_at')
  String? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  String? get updatedAt;
  @override
  @JsonKey(name: 'deleted_at')
  String? get deletedAt;
  @override
  String? get uid;

  /// Create a copy of MediaUploadResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MediaUploadResponseImplCopyWith<_$MediaUploadResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
