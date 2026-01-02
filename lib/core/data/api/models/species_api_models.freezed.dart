// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'species_api_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SpeciesApiModel _$SpeciesApiModelFromJson(Map<String, dynamic> json) {
  return _SpeciesApiModel.fromJson(json);
}

/// @nodoc
mixin _$SpeciesApiModel {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'mediaReference')
  String? get mediaReference => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  String? get updatedAt => throw _privateConstructorUsedError;
  String get uid => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SpeciesApiModelCopyWith<SpeciesApiModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SpeciesApiModelCopyWith<$Res> {
  factory $SpeciesApiModelCopyWith(
          SpeciesApiModel value, $Res Function(SpeciesApiModel) then) =
      _$SpeciesApiModelCopyWithImpl<$Res, SpeciesApiModel>;
  @useResult
  $Res call(
      {int id,
      String name,
      @JsonKey(name: 'mediaReference') String? mediaReference,
      @JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(name: 'updated_at') String? updatedAt,
      String uid});
}

/// @nodoc
class _$SpeciesApiModelCopyWithImpl<$Res, $Val extends SpeciesApiModel>
    implements $SpeciesApiModelCopyWith<$Res> {
  _$SpeciesApiModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? mediaReference = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? uid = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      mediaReference: freezed == mediaReference
          ? _value.mediaReference
          : mediaReference // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SpeciesApiModelImplCopyWith<$Res>
    implements $SpeciesApiModelCopyWith<$Res> {
  factory _$$SpeciesApiModelImplCopyWith(_$SpeciesApiModelImpl value,
          $Res Function(_$SpeciesApiModelImpl) then) =
      __$$SpeciesApiModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String name,
      @JsonKey(name: 'mediaReference') String? mediaReference,
      @JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(name: 'updated_at') String? updatedAt,
      String uid});
}

/// @nodoc
class __$$SpeciesApiModelImplCopyWithImpl<$Res>
    extends _$SpeciesApiModelCopyWithImpl<$Res, _$SpeciesApiModelImpl>
    implements _$$SpeciesApiModelImplCopyWith<$Res> {
  __$$SpeciesApiModelImplCopyWithImpl(
      _$SpeciesApiModelImpl _value, $Res Function(_$SpeciesApiModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? mediaReference = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? uid = null,
  }) {
    return _then(_$SpeciesApiModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      mediaReference: freezed == mediaReference
          ? _value.mediaReference
          : mediaReference // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SpeciesApiModelImpl implements _SpeciesApiModel {
  const _$SpeciesApiModelImpl(
      {required this.id,
      required this.name,
      @JsonKey(name: 'mediaReference') this.mediaReference,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt,
      required this.uid});

  factory _$SpeciesApiModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SpeciesApiModelImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  @JsonKey(name: 'mediaReference')
  final String? mediaReference;
  @override
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final String? updatedAt;
  @override
  final String uid;

  @override
  String toString() {
    return 'SpeciesApiModel(id: $id, name: $name, mediaReference: $mediaReference, createdAt: $createdAt, updatedAt: $updatedAt, uid: $uid)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SpeciesApiModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.mediaReference, mediaReference) ||
                other.mediaReference == mediaReference) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.uid, uid) || other.uid == uid));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, name, mediaReference, createdAt, updatedAt, uid);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SpeciesApiModelImplCopyWith<_$SpeciesApiModelImpl> get copyWith =>
      __$$SpeciesApiModelImplCopyWithImpl<_$SpeciesApiModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SpeciesApiModelImplToJson(
      this,
    );
  }
}

abstract class _SpeciesApiModel implements SpeciesApiModel {
  const factory _SpeciesApiModel(
      {required final int id,
      required final String name,
      @JsonKey(name: 'mediaReference') final String? mediaReference,
      @JsonKey(name: 'created_at') final String? createdAt,
      @JsonKey(name: 'updated_at') final String? updatedAt,
      required final String uid}) = _$SpeciesApiModelImpl;

  factory _SpeciesApiModel.fromJson(Map<String, dynamic> json) =
      _$SpeciesApiModelImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  @JsonKey(name: 'mediaReference')
  String? get mediaReference;
  @override
  @JsonKey(name: 'created_at')
  String? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  String? get updatedAt;
  @override
  String get uid;
  @override
  @JsonKey(ignore: true)
  _$$SpeciesApiModelImplCopyWith<_$SpeciesApiModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SpeciesListResponse _$SpeciesListResponseFromJson(Map<String, dynamic> json) {
  return _SpeciesListResponse.fromJson(json);
}

/// @nodoc
mixin _$SpeciesListResponse {
  SpeciesListData get data => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SpeciesListResponseCopyWith<SpeciesListResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SpeciesListResponseCopyWith<$Res> {
  factory $SpeciesListResponseCopyWith(
          SpeciesListResponse value, $Res Function(SpeciesListResponse) then) =
      _$SpeciesListResponseCopyWithImpl<$Res, SpeciesListResponse>;
  @useResult
  $Res call({SpeciesListData data});

  $SpeciesListDataCopyWith<$Res> get data;
}

/// @nodoc
class _$SpeciesListResponseCopyWithImpl<$Res, $Val extends SpeciesListResponse>
    implements $SpeciesListResponseCopyWith<$Res> {
  _$SpeciesListResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
  }) {
    return _then(_value.copyWith(
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as SpeciesListData,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $SpeciesListDataCopyWith<$Res> get data {
    return $SpeciesListDataCopyWith<$Res>(_value.data, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SpeciesListResponseImplCopyWith<$Res>
    implements $SpeciesListResponseCopyWith<$Res> {
  factory _$$SpeciesListResponseImplCopyWith(_$SpeciesListResponseImpl value,
          $Res Function(_$SpeciesListResponseImpl) then) =
      __$$SpeciesListResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({SpeciesListData data});

  @override
  $SpeciesListDataCopyWith<$Res> get data;
}

/// @nodoc
class __$$SpeciesListResponseImplCopyWithImpl<$Res>
    extends _$SpeciesListResponseCopyWithImpl<$Res, _$SpeciesListResponseImpl>
    implements _$$SpeciesListResponseImplCopyWith<$Res> {
  __$$SpeciesListResponseImplCopyWithImpl(_$SpeciesListResponseImpl _value,
      $Res Function(_$SpeciesListResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
  }) {
    return _then(_$SpeciesListResponseImpl(
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as SpeciesListData,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SpeciesListResponseImpl implements _SpeciesListResponse {
  const _$SpeciesListResponseImpl({required this.data});

  factory _$SpeciesListResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$SpeciesListResponseImplFromJson(json);

  @override
  final SpeciesListData data;

  @override
  String toString() {
    return 'SpeciesListResponse(data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SpeciesListResponseImpl &&
            (identical(other.data, data) || other.data == data));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, data);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SpeciesListResponseImplCopyWith<_$SpeciesListResponseImpl> get copyWith =>
      __$$SpeciesListResponseImplCopyWithImpl<_$SpeciesListResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SpeciesListResponseImplToJson(
      this,
    );
  }
}

abstract class _SpeciesListResponse implements SpeciesListResponse {
  const factory _SpeciesListResponse({required final SpeciesListData data}) =
      _$SpeciesListResponseImpl;

  factory _SpeciesListResponse.fromJson(Map<String, dynamic> json) =
      _$SpeciesListResponseImpl.fromJson;

  @override
  SpeciesListData get data;
  @override
  @JsonKey(ignore: true)
  _$$SpeciesListResponseImplCopyWith<_$SpeciesListResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SpeciesListData _$SpeciesListDataFromJson(Map<String, dynamic> json) {
  return _SpeciesListData.fromJson(json);
}

/// @nodoc
mixin _$SpeciesListData {
  int get totalItems => throw _privateConstructorUsedError;
  List<SpeciesApiModel> get member => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SpeciesListDataCopyWith<SpeciesListData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SpeciesListDataCopyWith<$Res> {
  factory $SpeciesListDataCopyWith(
          SpeciesListData value, $Res Function(SpeciesListData) then) =
      _$SpeciesListDataCopyWithImpl<$Res, SpeciesListData>;
  @useResult
  $Res call({int totalItems, List<SpeciesApiModel> member});
}

/// @nodoc
class _$SpeciesListDataCopyWithImpl<$Res, $Val extends SpeciesListData>
    implements $SpeciesListDataCopyWith<$Res> {
  _$SpeciesListDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalItems = null,
    Object? member = null,
  }) {
    return _then(_value.copyWith(
      totalItems: null == totalItems
          ? _value.totalItems
          : totalItems // ignore: cast_nullable_to_non_nullable
              as int,
      member: null == member
          ? _value.member
          : member // ignore: cast_nullable_to_non_nullable
              as List<SpeciesApiModel>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SpeciesListDataImplCopyWith<$Res>
    implements $SpeciesListDataCopyWith<$Res> {
  factory _$$SpeciesListDataImplCopyWith(_$SpeciesListDataImpl value,
          $Res Function(_$SpeciesListDataImpl) then) =
      __$$SpeciesListDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int totalItems, List<SpeciesApiModel> member});
}

/// @nodoc
class __$$SpeciesListDataImplCopyWithImpl<$Res>
    extends _$SpeciesListDataCopyWithImpl<$Res, _$SpeciesListDataImpl>
    implements _$$SpeciesListDataImplCopyWith<$Res> {
  __$$SpeciesListDataImplCopyWithImpl(
      _$SpeciesListDataImpl _value, $Res Function(_$SpeciesListDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalItems = null,
    Object? member = null,
  }) {
    return _then(_$SpeciesListDataImpl(
      totalItems: null == totalItems
          ? _value.totalItems
          : totalItems // ignore: cast_nullable_to_non_nullable
              as int,
      member: null == member
          ? _value._member
          : member // ignore: cast_nullable_to_non_nullable
              as List<SpeciesApiModel>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SpeciesListDataImpl implements _SpeciesListData {
  const _$SpeciesListDataImpl(
      {required this.totalItems, required final List<SpeciesApiModel> member})
      : _member = member;

  factory _$SpeciesListDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$SpeciesListDataImplFromJson(json);

  @override
  final int totalItems;
  final List<SpeciesApiModel> _member;
  @override
  List<SpeciesApiModel> get member {
    if (_member is EqualUnmodifiableListView) return _member;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_member);
  }

  @override
  String toString() {
    return 'SpeciesListData(totalItems: $totalItems, member: $member)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SpeciesListDataImpl &&
            (identical(other.totalItems, totalItems) ||
                other.totalItems == totalItems) &&
            const DeepCollectionEquality().equals(other._member, _member));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, totalItems, const DeepCollectionEquality().hash(_member));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SpeciesListDataImplCopyWith<_$SpeciesListDataImpl> get copyWith =>
      __$$SpeciesListDataImplCopyWithImpl<_$SpeciesListDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SpeciesListDataImplToJson(
      this,
    );
  }
}

abstract class _SpeciesListData implements SpeciesListData {
  const factory _SpeciesListData(
      {required final int totalItems,
      required final List<SpeciesApiModel> member}) = _$SpeciesListDataImpl;

  factory _SpeciesListData.fromJson(Map<String, dynamic> json) =
      _$SpeciesListDataImpl.fromJson;

  @override
  int get totalItems;
  @override
  List<SpeciesApiModel> get member;
  @override
  @JsonKey(ignore: true)
  _$$SpeciesListDataImplCopyWith<_$SpeciesListDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
