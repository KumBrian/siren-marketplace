// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_api_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ProductSpeciesApiModel _$ProductSpeciesApiModelFromJson(
    Map<String, dynamic> json) {
  return _ProductSpeciesApiModel.fromJson(json);
}

/// @nodoc
mixin _$ProductSpeciesApiModel {
  @JsonKey(name: 'created_at')
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  String? get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'deleted_at')
  String? get deletedAt => throw _privateConstructorUsedError;
  String? get uid => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get image => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ProductSpeciesApiModelCopyWith<ProductSpeciesApiModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductSpeciesApiModelCopyWith<$Res> {
  factory $ProductSpeciesApiModelCopyWith(ProductSpeciesApiModel value,
          $Res Function(ProductSpeciesApiModel) then) =
      _$ProductSpeciesApiModelCopyWithImpl<$Res, ProductSpeciesApiModel>;
  @useResult
  $Res call(
      {@JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(name: 'updated_at') String? updatedAt,
      @JsonKey(name: 'deleted_at') String? deletedAt,
      String? uid,
      String? name,
      String? image});
}

/// @nodoc
class _$ProductSpeciesApiModelCopyWithImpl<$Res,
        $Val extends ProductSpeciesApiModel>
    implements $ProductSpeciesApiModelCopyWith<$Res> {
  _$ProductSpeciesApiModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? deletedAt = freezed,
    Object? uid = freezed,
    Object? name = freezed,
    Object? image = freezed,
  }) {
    return _then(_value.copyWith(
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
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      image: freezed == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProductSpeciesApiModelImplCopyWith<$Res>
    implements $ProductSpeciesApiModelCopyWith<$Res> {
  factory _$$ProductSpeciesApiModelImplCopyWith(
          _$ProductSpeciesApiModelImpl value,
          $Res Function(_$ProductSpeciesApiModelImpl) then) =
      __$$ProductSpeciesApiModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(name: 'updated_at') String? updatedAt,
      @JsonKey(name: 'deleted_at') String? deletedAt,
      String? uid,
      String? name,
      String? image});
}

/// @nodoc
class __$$ProductSpeciesApiModelImplCopyWithImpl<$Res>
    extends _$ProductSpeciesApiModelCopyWithImpl<$Res,
        _$ProductSpeciesApiModelImpl>
    implements _$$ProductSpeciesApiModelImplCopyWith<$Res> {
  __$$ProductSpeciesApiModelImplCopyWithImpl(
      _$ProductSpeciesApiModelImpl _value,
      $Res Function(_$ProductSpeciesApiModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? deletedAt = freezed,
    Object? uid = freezed,
    Object? name = freezed,
    Object? image = freezed,
  }) {
    return _then(_$ProductSpeciesApiModelImpl(
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
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      image: freezed == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductSpeciesApiModelImpl implements _ProductSpeciesApiModel {
  const _$ProductSpeciesApiModelImpl(
      {@JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt,
      @JsonKey(name: 'deleted_at') this.deletedAt,
      this.uid,
      this.name,
      this.image});

  factory _$ProductSpeciesApiModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductSpeciesApiModelImplFromJson(json);

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
  final String? name;
  @override
  final String? image;

  @override
  String toString() {
    return 'ProductSpeciesApiModel(createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, uid: $uid, name: $name, image: $image)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductSpeciesApiModelImpl &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.image, image) || other.image == image));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, createdAt, updatedAt, deletedAt, uid, name, image);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductSpeciesApiModelImplCopyWith<_$ProductSpeciesApiModelImpl>
      get copyWith => __$$ProductSpeciesApiModelImplCopyWithImpl<
          _$ProductSpeciesApiModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductSpeciesApiModelImplToJson(
      this,
    );
  }
}

abstract class _ProductSpeciesApiModel implements ProductSpeciesApiModel {
  const factory _ProductSpeciesApiModel(
      {@JsonKey(name: 'created_at') final String? createdAt,
      @JsonKey(name: 'updated_at') final String? updatedAt,
      @JsonKey(name: 'deleted_at') final String? deletedAt,
      final String? uid,
      final String? name,
      final String? image}) = _$ProductSpeciesApiModelImpl;

  factory _ProductSpeciesApiModel.fromJson(Map<String, dynamic> json) =
      _$ProductSpeciesApiModelImpl.fromJson;

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
  @override
  String? get name;
  @override
  String? get image;
  @override
  @JsonKey(ignore: true)
  _$$ProductSpeciesApiModelImplCopyWith<_$ProductSpeciesApiModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

ProductMarketApiModel _$ProductMarketApiModelFromJson(
    Map<String, dynamic> json) {
  return _ProductMarketApiModel.fromJson(json);
}

/// @nodoc
mixin _$ProductMarketApiModel {
  @JsonKey(name: 'created_at')
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  String? get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'deleted_at')
  String? get deletedAt => throw _privateConstructorUsedError;
  String? get uid => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ProductMarketApiModelCopyWith<ProductMarketApiModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductMarketApiModelCopyWith<$Res> {
  factory $ProductMarketApiModelCopyWith(ProductMarketApiModel value,
          $Res Function(ProductMarketApiModel) then) =
      _$ProductMarketApiModelCopyWithImpl<$Res, ProductMarketApiModel>;
  @useResult
  $Res call(
      {@JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(name: 'updated_at') String? updatedAt,
      @JsonKey(name: 'deleted_at') String? deletedAt,
      String? uid});
}

/// @nodoc
class _$ProductMarketApiModelCopyWithImpl<$Res,
        $Val extends ProductMarketApiModel>
    implements $ProductMarketApiModelCopyWith<$Res> {
  _$ProductMarketApiModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? deletedAt = freezed,
    Object? uid = freezed,
  }) {
    return _then(_value.copyWith(
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
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProductMarketApiModelImplCopyWith<$Res>
    implements $ProductMarketApiModelCopyWith<$Res> {
  factory _$$ProductMarketApiModelImplCopyWith(
          _$ProductMarketApiModelImpl value,
          $Res Function(_$ProductMarketApiModelImpl) then) =
      __$$ProductMarketApiModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(name: 'updated_at') String? updatedAt,
      @JsonKey(name: 'deleted_at') String? deletedAt,
      String? uid});
}

/// @nodoc
class __$$ProductMarketApiModelImplCopyWithImpl<$Res>
    extends _$ProductMarketApiModelCopyWithImpl<$Res,
        _$ProductMarketApiModelImpl>
    implements _$$ProductMarketApiModelImplCopyWith<$Res> {
  __$$ProductMarketApiModelImplCopyWithImpl(_$ProductMarketApiModelImpl _value,
      $Res Function(_$ProductMarketApiModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? deletedAt = freezed,
    Object? uid = freezed,
  }) {
    return _then(_$ProductMarketApiModelImpl(
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
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductMarketApiModelImpl implements _ProductMarketApiModel {
  const _$ProductMarketApiModelImpl(
      {@JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt,
      @JsonKey(name: 'deleted_at') this.deletedAt,
      this.uid});

  factory _$ProductMarketApiModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductMarketApiModelImplFromJson(json);

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
    return 'ProductMarketApiModel(createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, uid: $uid)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductMarketApiModelImpl &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.uid, uid) || other.uid == uid));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, createdAt, updatedAt, deletedAt, uid);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductMarketApiModelImplCopyWith<_$ProductMarketApiModelImpl>
      get copyWith => __$$ProductMarketApiModelImplCopyWithImpl<
          _$ProductMarketApiModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductMarketApiModelImplToJson(
      this,
    );
  }
}

abstract class _ProductMarketApiModel implements ProductMarketApiModel {
  const factory _ProductMarketApiModel(
      {@JsonKey(name: 'created_at') final String? createdAt,
      @JsonKey(name: 'updated_at') final String? updatedAt,
      @JsonKey(name: 'deleted_at') final String? deletedAt,
      final String? uid}) = _$ProductMarketApiModelImpl;

  factory _ProductMarketApiModel.fromJson(Map<String, dynamic> json) =
      _$ProductMarketApiModelImpl.fromJson;

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
  @override
  @JsonKey(ignore: true)
  _$$ProductMarketApiModelImplCopyWith<_$ProductMarketApiModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

ProductAccountApiModel _$ProductAccountApiModelFromJson(
    Map<String, dynamic> json) {
  return _ProductAccountApiModel.fromJson(json);
}

/// @nodoc
mixin _$ProductAccountApiModel {
  int? get id =>
      throw _privateConstructorUsedError; // Integer ID for comparisons
  @JsonKey(name: 'created_at')
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  String? get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'deleted_at')
  String? get deletedAt => throw _privateConstructorUsedError;
  String? get uid => throw _privateConstructorUsedError;
  String? get firstName => throw _privateConstructorUsedError;
  String? get lastName => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get phoneNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'totalReviews')
  int? get totalReviews => throw _privateConstructorUsedError;
  @JsonKey(name: 'ratingDistribution')
  List<dynamic>? get ratingDistribution => throw _privateConstructorUsedError;
  @JsonKey(name: 'averageRating')
  double? get rating => throw _privateConstructorUsedError;
  String? get avatar => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ProductAccountApiModelCopyWith<ProductAccountApiModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductAccountApiModelCopyWith<$Res> {
  factory $ProductAccountApiModelCopyWith(ProductAccountApiModel value,
          $Res Function(ProductAccountApiModel) then) =
      _$ProductAccountApiModelCopyWithImpl<$Res, ProductAccountApiModel>;
  @useResult
  $Res call(
      {int? id,
      @JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(name: 'updated_at') String? updatedAt,
      @JsonKey(name: 'deleted_at') String? deletedAt,
      String? uid,
      String? firstName,
      String? lastName,
      String? email,
      String? phoneNumber,
      @JsonKey(name: 'totalReviews') int? totalReviews,
      @JsonKey(name: 'ratingDistribution') List<dynamic>? ratingDistribution,
      @JsonKey(name: 'averageRating') double? rating,
      String? avatar});
}

/// @nodoc
class _$ProductAccountApiModelCopyWithImpl<$Res,
        $Val extends ProductAccountApiModel>
    implements $ProductAccountApiModelCopyWith<$Res> {
  _$ProductAccountApiModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? deletedAt = freezed,
    Object? uid = freezed,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? email = freezed,
    Object? phoneNumber = freezed,
    Object? totalReviews = freezed,
    Object? ratingDistribution = freezed,
    Object? rating = freezed,
    Object? avatar = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
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
      firstName: freezed == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastName: freezed == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      totalReviews: freezed == totalReviews
          ? _value.totalReviews
          : totalReviews // ignore: cast_nullable_to_non_nullable
              as int?,
      ratingDistribution: freezed == ratingDistribution
          ? _value.ratingDistribution
          : ratingDistribution // ignore: cast_nullable_to_non_nullable
              as List<dynamic>?,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double?,
      avatar: freezed == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProductAccountApiModelImplCopyWith<$Res>
    implements $ProductAccountApiModelCopyWith<$Res> {
  factory _$$ProductAccountApiModelImplCopyWith(
          _$ProductAccountApiModelImpl value,
          $Res Function(_$ProductAccountApiModelImpl) then) =
      __$$ProductAccountApiModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      @JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(name: 'updated_at') String? updatedAt,
      @JsonKey(name: 'deleted_at') String? deletedAt,
      String? uid,
      String? firstName,
      String? lastName,
      String? email,
      String? phoneNumber,
      @JsonKey(name: 'totalReviews') int? totalReviews,
      @JsonKey(name: 'ratingDistribution') List<dynamic>? ratingDistribution,
      @JsonKey(name: 'averageRating') double? rating,
      String? avatar});
}

/// @nodoc
class __$$ProductAccountApiModelImplCopyWithImpl<$Res>
    extends _$ProductAccountApiModelCopyWithImpl<$Res,
        _$ProductAccountApiModelImpl>
    implements _$$ProductAccountApiModelImplCopyWith<$Res> {
  __$$ProductAccountApiModelImplCopyWithImpl(
      _$ProductAccountApiModelImpl _value,
      $Res Function(_$ProductAccountApiModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? deletedAt = freezed,
    Object? uid = freezed,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? email = freezed,
    Object? phoneNumber = freezed,
    Object? totalReviews = freezed,
    Object? ratingDistribution = freezed,
    Object? rating = freezed,
    Object? avatar = freezed,
  }) {
    return _then(_$ProductAccountApiModelImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
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
      firstName: freezed == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastName: freezed == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      totalReviews: freezed == totalReviews
          ? _value.totalReviews
          : totalReviews // ignore: cast_nullable_to_non_nullable
              as int?,
      ratingDistribution: freezed == ratingDistribution
          ? _value._ratingDistribution
          : ratingDistribution // ignore: cast_nullable_to_non_nullable
              as List<dynamic>?,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double?,
      avatar: freezed == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductAccountApiModelImpl implements _ProductAccountApiModel {
  const _$ProductAccountApiModelImpl(
      {this.id,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt,
      @JsonKey(name: 'deleted_at') this.deletedAt,
      this.uid,
      this.firstName,
      this.lastName,
      this.email,
      this.phoneNumber,
      @JsonKey(name: 'totalReviews') this.totalReviews,
      @JsonKey(name: 'ratingDistribution')
      final List<dynamic>? ratingDistribution,
      @JsonKey(name: 'averageRating') this.rating,
      this.avatar})
      : _ratingDistribution = ratingDistribution;

  factory _$ProductAccountApiModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductAccountApiModelImplFromJson(json);

  @override
  final int? id;
// Integer ID for comparisons
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
  final String? firstName;
  @override
  final String? lastName;
  @override
  final String? email;
  @override
  final String? phoneNumber;
  @override
  @JsonKey(name: 'totalReviews')
  final int? totalReviews;
  final List<dynamic>? _ratingDistribution;
  @override
  @JsonKey(name: 'ratingDistribution')
  List<dynamic>? get ratingDistribution {
    final value = _ratingDistribution;
    if (value == null) return null;
    if (_ratingDistribution is EqualUnmodifiableListView)
      return _ratingDistribution;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'averageRating')
  final double? rating;
  @override
  final String? avatar;

  @override
  String toString() {
    return 'ProductAccountApiModel(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, uid: $uid, firstName: $firstName, lastName: $lastName, email: $email, phoneNumber: $phoneNumber, totalReviews: $totalReviews, ratingDistribution: $ratingDistribution, rating: $rating, avatar: $avatar)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductAccountApiModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.totalReviews, totalReviews) ||
                other.totalReviews == totalReviews) &&
            const DeepCollectionEquality()
                .equals(other._ratingDistribution, _ratingDistribution) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.avatar, avatar) || other.avatar == avatar));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      createdAt,
      updatedAt,
      deletedAt,
      uid,
      firstName,
      lastName,
      email,
      phoneNumber,
      totalReviews,
      const DeepCollectionEquality().hash(_ratingDistribution),
      rating,
      avatar);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductAccountApiModelImplCopyWith<_$ProductAccountApiModelImpl>
      get copyWith => __$$ProductAccountApiModelImplCopyWithImpl<
          _$ProductAccountApiModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductAccountApiModelImplToJson(
      this,
    );
  }
}

abstract class _ProductAccountApiModel implements ProductAccountApiModel {
  const factory _ProductAccountApiModel(
      {final int? id,
      @JsonKey(name: 'created_at') final String? createdAt,
      @JsonKey(name: 'updated_at') final String? updatedAt,
      @JsonKey(name: 'deleted_at') final String? deletedAt,
      final String? uid,
      final String? firstName,
      final String? lastName,
      final String? email,
      final String? phoneNumber,
      @JsonKey(name: 'totalReviews') final int? totalReviews,
      @JsonKey(name: 'ratingDistribution')
      final List<dynamic>? ratingDistribution,
      @JsonKey(name: 'averageRating') final double? rating,
      final String? avatar}) = _$ProductAccountApiModelImpl;

  factory _ProductAccountApiModel.fromJson(Map<String, dynamic> json) =
      _$ProductAccountApiModelImpl.fromJson;

  @override
  int? get id;
  @override // Integer ID for comparisons
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
  @override
  String? get firstName;
  @override
  String? get lastName;
  @override
  String? get email;
  @override
  String? get phoneNumber;
  @override
  @JsonKey(name: 'totalReviews')
  int? get totalReviews;
  @override
  @JsonKey(name: 'ratingDistribution')
  List<dynamic>? get ratingDistribution;
  @override
  @JsonKey(name: 'averageRating')
  double? get rating;
  @override
  String? get avatar;
  @override
  @JsonKey(ignore: true)
  _$$ProductAccountApiModelImplCopyWith<_$ProductAccountApiModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

ProductApiModel _$ProductApiModelFromJson(Map<String, dynamic> json) {
  return _ProductApiModel.fromJson(json);
}

/// @nodoc
mixin _$ProductApiModel {
  dynamic get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  ProductMarketApiModel? get market => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;
  String? get rejectReason => throw _privateConstructorUsedError;
  @JsonKey(name: 'price_per_kg')
  double? get pricePerKg => throw _privateConstructorUsedError;
  @JsonKey(name: 'final_price')
  double? get finalPrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'published_weight_in_grams')
  double? get publishedWeightInGrams => throw _privateConstructorUsedError;
  @JsonKey(name: 'expire_at')
  String? get expireAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'location_name')
  String? get locationName => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  String? get size => throw _privateConstructorUsedError;
  @JsonKey(name: 'date_posted')
  String? get datePosted => throw _privateConstructorUsedError;
  bool? get isSold => throw _privateConstructorUsedError;
  String? get soldAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'initial_weight')
  double? get initialWeight => throw _privateConstructorUsedError;
  @JsonKey(name: 'available_weight')
  double? get availableWeight => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  String? get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'deleted_at')
  String? get deletedAt => throw _privateConstructorUsedError;
  String? get uid => throw _privateConstructorUsedError;
  double? get gearMeshSizeInFinger => throw _privateConstructorUsedError;
  double? get gearLengthInMeter => throw _privateConstructorUsedError;
  double? get gearWidthInMeter => throw _privateConstructorUsedError;
  String? get gearNature => throw _privateConstructorUsedError;
  ProductSpeciesApiModel? get specie => throw _privateConstructorUsedError;
  ProductAccountApiModel? get account => throw _privateConstructorUsedError;
  @JsonKey(name: 'offersCount')
  int get offersCount => throw _privateConstructorUsedError;
  List<String> get images => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ProductApiModelCopyWith<ProductApiModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductApiModelCopyWith<$Res> {
  factory $ProductApiModelCopyWith(
          ProductApiModel value, $Res Function(ProductApiModel) then) =
      _$ProductApiModelCopyWithImpl<$Res, ProductApiModel>;
  @useResult
  $Res call(
      {dynamic id,
      String? name,
      ProductMarketApiModel? market,
      String? status,
      String? rejectReason,
      @JsonKey(name: 'price_per_kg') double? pricePerKg,
      @JsonKey(name: 'final_price') double? finalPrice,
      @JsonKey(name: 'published_weight_in_grams')
      double? publishedWeightInGrams,
      @JsonKey(name: 'expire_at') String? expireAt,
      @JsonKey(name: 'location_name') String? locationName,
      double? latitude,
      double? longitude,
      String? size,
      @JsonKey(name: 'date_posted') String? datePosted,
      bool? isSold,
      String? soldAt,
      @JsonKey(name: 'initial_weight') double? initialWeight,
      @JsonKey(name: 'available_weight') double? availableWeight,
      @JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(name: 'updated_at') String? updatedAt,
      @JsonKey(name: 'deleted_at') String? deletedAt,
      String? uid,
      double? gearMeshSizeInFinger,
      double? gearLengthInMeter,
      double? gearWidthInMeter,
      String? gearNature,
      ProductSpeciesApiModel? specie,
      ProductAccountApiModel? account,
      @JsonKey(name: 'offersCount') int offersCount,
      List<String> images});

  $ProductMarketApiModelCopyWith<$Res>? get market;
  $ProductSpeciesApiModelCopyWith<$Res>? get specie;
  $ProductAccountApiModelCopyWith<$Res>? get account;
}

/// @nodoc
class _$ProductApiModelCopyWithImpl<$Res, $Val extends ProductApiModel>
    implements $ProductApiModelCopyWith<$Res> {
  _$ProductApiModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? market = freezed,
    Object? status = freezed,
    Object? rejectReason = freezed,
    Object? pricePerKg = freezed,
    Object? finalPrice = freezed,
    Object? publishedWeightInGrams = freezed,
    Object? expireAt = freezed,
    Object? locationName = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? size = freezed,
    Object? datePosted = freezed,
    Object? isSold = freezed,
    Object? soldAt = freezed,
    Object? initialWeight = freezed,
    Object? availableWeight = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? deletedAt = freezed,
    Object? uid = freezed,
    Object? gearMeshSizeInFinger = freezed,
    Object? gearLengthInMeter = freezed,
    Object? gearWidthInMeter = freezed,
    Object? gearNature = freezed,
    Object? specie = freezed,
    Object? account = freezed,
    Object? offersCount = null,
    Object? images = null,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as dynamic,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      market: freezed == market
          ? _value.market
          : market // ignore: cast_nullable_to_non_nullable
              as ProductMarketApiModel?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      rejectReason: freezed == rejectReason
          ? _value.rejectReason
          : rejectReason // ignore: cast_nullable_to_non_nullable
              as String?,
      pricePerKg: freezed == pricePerKg
          ? _value.pricePerKg
          : pricePerKg // ignore: cast_nullable_to_non_nullable
              as double?,
      finalPrice: freezed == finalPrice
          ? _value.finalPrice
          : finalPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      publishedWeightInGrams: freezed == publishedWeightInGrams
          ? _value.publishedWeightInGrams
          : publishedWeightInGrams // ignore: cast_nullable_to_non_nullable
              as double?,
      expireAt: freezed == expireAt
          ? _value.expireAt
          : expireAt // ignore: cast_nullable_to_non_nullable
              as String?,
      locationName: freezed == locationName
          ? _value.locationName
          : locationName // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      size: freezed == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as String?,
      datePosted: freezed == datePosted
          ? _value.datePosted
          : datePosted // ignore: cast_nullable_to_non_nullable
              as String?,
      isSold: freezed == isSold
          ? _value.isSold
          : isSold // ignore: cast_nullable_to_non_nullable
              as bool?,
      soldAt: freezed == soldAt
          ? _value.soldAt
          : soldAt // ignore: cast_nullable_to_non_nullable
              as String?,
      initialWeight: freezed == initialWeight
          ? _value.initialWeight
          : initialWeight // ignore: cast_nullable_to_non_nullable
              as double?,
      availableWeight: freezed == availableWeight
          ? _value.availableWeight
          : availableWeight // ignore: cast_nullable_to_non_nullable
              as double?,
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
      gearMeshSizeInFinger: freezed == gearMeshSizeInFinger
          ? _value.gearMeshSizeInFinger
          : gearMeshSizeInFinger // ignore: cast_nullable_to_non_nullable
              as double?,
      gearLengthInMeter: freezed == gearLengthInMeter
          ? _value.gearLengthInMeter
          : gearLengthInMeter // ignore: cast_nullable_to_non_nullable
              as double?,
      gearWidthInMeter: freezed == gearWidthInMeter
          ? _value.gearWidthInMeter
          : gearWidthInMeter // ignore: cast_nullable_to_non_nullable
              as double?,
      gearNature: freezed == gearNature
          ? _value.gearNature
          : gearNature // ignore: cast_nullable_to_non_nullable
              as String?,
      specie: freezed == specie
          ? _value.specie
          : specie // ignore: cast_nullable_to_non_nullable
              as ProductSpeciesApiModel?,
      account: freezed == account
          ? _value.account
          : account // ignore: cast_nullable_to_non_nullable
              as ProductAccountApiModel?,
      offersCount: null == offersCount
          ? _value.offersCount
          : offersCount // ignore: cast_nullable_to_non_nullable
              as int,
      images: null == images
          ? _value.images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ProductMarketApiModelCopyWith<$Res>? get market {
    if (_value.market == null) {
      return null;
    }

    return $ProductMarketApiModelCopyWith<$Res>(_value.market!, (value) {
      return _then(_value.copyWith(market: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $ProductSpeciesApiModelCopyWith<$Res>? get specie {
    if (_value.specie == null) {
      return null;
    }

    return $ProductSpeciesApiModelCopyWith<$Res>(_value.specie!, (value) {
      return _then(_value.copyWith(specie: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $ProductAccountApiModelCopyWith<$Res>? get account {
    if (_value.account == null) {
      return null;
    }

    return $ProductAccountApiModelCopyWith<$Res>(_value.account!, (value) {
      return _then(_value.copyWith(account: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ProductApiModelImplCopyWith<$Res>
    implements $ProductApiModelCopyWith<$Res> {
  factory _$$ProductApiModelImplCopyWith(_$ProductApiModelImpl value,
          $Res Function(_$ProductApiModelImpl) then) =
      __$$ProductApiModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {dynamic id,
      String? name,
      ProductMarketApiModel? market,
      String? status,
      String? rejectReason,
      @JsonKey(name: 'price_per_kg') double? pricePerKg,
      @JsonKey(name: 'final_price') double? finalPrice,
      @JsonKey(name: 'published_weight_in_grams')
      double? publishedWeightInGrams,
      @JsonKey(name: 'expire_at') String? expireAt,
      @JsonKey(name: 'location_name') String? locationName,
      double? latitude,
      double? longitude,
      String? size,
      @JsonKey(name: 'date_posted') String? datePosted,
      bool? isSold,
      String? soldAt,
      @JsonKey(name: 'initial_weight') double? initialWeight,
      @JsonKey(name: 'available_weight') double? availableWeight,
      @JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(name: 'updated_at') String? updatedAt,
      @JsonKey(name: 'deleted_at') String? deletedAt,
      String? uid,
      double? gearMeshSizeInFinger,
      double? gearLengthInMeter,
      double? gearWidthInMeter,
      String? gearNature,
      ProductSpeciesApiModel? specie,
      ProductAccountApiModel? account,
      @JsonKey(name: 'offersCount') int offersCount,
      List<String> images});

  @override
  $ProductMarketApiModelCopyWith<$Res>? get market;
  @override
  $ProductSpeciesApiModelCopyWith<$Res>? get specie;
  @override
  $ProductAccountApiModelCopyWith<$Res>? get account;
}

/// @nodoc
class __$$ProductApiModelImplCopyWithImpl<$Res>
    extends _$ProductApiModelCopyWithImpl<$Res, _$ProductApiModelImpl>
    implements _$$ProductApiModelImplCopyWith<$Res> {
  __$$ProductApiModelImplCopyWithImpl(
      _$ProductApiModelImpl _value, $Res Function(_$ProductApiModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? market = freezed,
    Object? status = freezed,
    Object? rejectReason = freezed,
    Object? pricePerKg = freezed,
    Object? finalPrice = freezed,
    Object? publishedWeightInGrams = freezed,
    Object? expireAt = freezed,
    Object? locationName = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? size = freezed,
    Object? datePosted = freezed,
    Object? isSold = freezed,
    Object? soldAt = freezed,
    Object? initialWeight = freezed,
    Object? availableWeight = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? deletedAt = freezed,
    Object? uid = freezed,
    Object? gearMeshSizeInFinger = freezed,
    Object? gearLengthInMeter = freezed,
    Object? gearWidthInMeter = freezed,
    Object? gearNature = freezed,
    Object? specie = freezed,
    Object? account = freezed,
    Object? offersCount = null,
    Object? images = null,
  }) {
    return _then(_$ProductApiModelImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as dynamic,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      market: freezed == market
          ? _value.market
          : market // ignore: cast_nullable_to_non_nullable
              as ProductMarketApiModel?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      rejectReason: freezed == rejectReason
          ? _value.rejectReason
          : rejectReason // ignore: cast_nullable_to_non_nullable
              as String?,
      pricePerKg: freezed == pricePerKg
          ? _value.pricePerKg
          : pricePerKg // ignore: cast_nullable_to_non_nullable
              as double?,
      finalPrice: freezed == finalPrice
          ? _value.finalPrice
          : finalPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      publishedWeightInGrams: freezed == publishedWeightInGrams
          ? _value.publishedWeightInGrams
          : publishedWeightInGrams // ignore: cast_nullable_to_non_nullable
              as double?,
      expireAt: freezed == expireAt
          ? _value.expireAt
          : expireAt // ignore: cast_nullable_to_non_nullable
              as String?,
      locationName: freezed == locationName
          ? _value.locationName
          : locationName // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      size: freezed == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as String?,
      datePosted: freezed == datePosted
          ? _value.datePosted
          : datePosted // ignore: cast_nullable_to_non_nullable
              as String?,
      isSold: freezed == isSold
          ? _value.isSold
          : isSold // ignore: cast_nullable_to_non_nullable
              as bool?,
      soldAt: freezed == soldAt
          ? _value.soldAt
          : soldAt // ignore: cast_nullable_to_non_nullable
              as String?,
      initialWeight: freezed == initialWeight
          ? _value.initialWeight
          : initialWeight // ignore: cast_nullable_to_non_nullable
              as double?,
      availableWeight: freezed == availableWeight
          ? _value.availableWeight
          : availableWeight // ignore: cast_nullable_to_non_nullable
              as double?,
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
      gearMeshSizeInFinger: freezed == gearMeshSizeInFinger
          ? _value.gearMeshSizeInFinger
          : gearMeshSizeInFinger // ignore: cast_nullable_to_non_nullable
              as double?,
      gearLengthInMeter: freezed == gearLengthInMeter
          ? _value.gearLengthInMeter
          : gearLengthInMeter // ignore: cast_nullable_to_non_nullable
              as double?,
      gearWidthInMeter: freezed == gearWidthInMeter
          ? _value.gearWidthInMeter
          : gearWidthInMeter // ignore: cast_nullable_to_non_nullable
              as double?,
      gearNature: freezed == gearNature
          ? _value.gearNature
          : gearNature // ignore: cast_nullable_to_non_nullable
              as String?,
      specie: freezed == specie
          ? _value.specie
          : specie // ignore: cast_nullable_to_non_nullable
              as ProductSpeciesApiModel?,
      account: freezed == account
          ? _value.account
          : account // ignore: cast_nullable_to_non_nullable
              as ProductAccountApiModel?,
      offersCount: null == offersCount
          ? _value.offersCount
          : offersCount // ignore: cast_nullable_to_non_nullable
              as int,
      images: null == images
          ? _value._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductApiModelImpl implements _ProductApiModel {
  const _$ProductApiModelImpl(
      {required this.id,
      this.name,
      this.market,
      this.status,
      this.rejectReason,
      @JsonKey(name: 'price_per_kg') this.pricePerKg,
      @JsonKey(name: 'final_price') this.finalPrice,
      @JsonKey(name: 'published_weight_in_grams') this.publishedWeightInGrams,
      @JsonKey(name: 'expire_at') this.expireAt,
      @JsonKey(name: 'location_name') this.locationName,
      this.latitude,
      this.longitude,
      this.size,
      @JsonKey(name: 'date_posted') this.datePosted,
      this.isSold,
      this.soldAt,
      @JsonKey(name: 'initial_weight') this.initialWeight,
      @JsonKey(name: 'available_weight') this.availableWeight,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt,
      @JsonKey(name: 'deleted_at') this.deletedAt,
      this.uid,
      this.gearMeshSizeInFinger,
      this.gearLengthInMeter,
      this.gearWidthInMeter,
      this.gearNature,
      this.specie,
      this.account,
      @JsonKey(name: 'offersCount') this.offersCount = 0,
      final List<String> images = const []})
      : _images = images;

  factory _$ProductApiModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductApiModelImplFromJson(json);

  @override
  final dynamic id;
  @override
  final String? name;
  @override
  final ProductMarketApiModel? market;
  @override
  final String? status;
  @override
  final String? rejectReason;
  @override
  @JsonKey(name: 'price_per_kg')
  final double? pricePerKg;
  @override
  @JsonKey(name: 'final_price')
  final double? finalPrice;
  @override
  @JsonKey(name: 'published_weight_in_grams')
  final double? publishedWeightInGrams;
  @override
  @JsonKey(name: 'expire_at')
  final String? expireAt;
  @override
  @JsonKey(name: 'location_name')
  final String? locationName;
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  final String? size;
  @override
  @JsonKey(name: 'date_posted')
  final String? datePosted;
  @override
  final bool? isSold;
  @override
  final String? soldAt;
  @override
  @JsonKey(name: 'initial_weight')
  final double? initialWeight;
  @override
  @JsonKey(name: 'available_weight')
  final double? availableWeight;
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
  final double? gearMeshSizeInFinger;
  @override
  final double? gearLengthInMeter;
  @override
  final double? gearWidthInMeter;
  @override
  final String? gearNature;
  @override
  final ProductSpeciesApiModel? specie;
  @override
  final ProductAccountApiModel? account;
  @override
  @JsonKey(name: 'offersCount')
  final int offersCount;
  final List<String> _images;
  @override
  @JsonKey()
  List<String> get images {
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_images);
  }

  @override
  String toString() {
    return 'ProductApiModel(id: $id, name: $name, market: $market, status: $status, rejectReason: $rejectReason, pricePerKg: $pricePerKg, finalPrice: $finalPrice, publishedWeightInGrams: $publishedWeightInGrams, expireAt: $expireAt, locationName: $locationName, latitude: $latitude, longitude: $longitude, size: $size, datePosted: $datePosted, isSold: $isSold, soldAt: $soldAt, initialWeight: $initialWeight, availableWeight: $availableWeight, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, uid: $uid, gearMeshSizeInFinger: $gearMeshSizeInFinger, gearLengthInMeter: $gearLengthInMeter, gearWidthInMeter: $gearWidthInMeter, gearNature: $gearNature, specie: $specie, account: $account, offersCount: $offersCount, images: $images)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductApiModelImpl &&
            const DeepCollectionEquality().equals(other.id, id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.market, market) || other.market == market) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.rejectReason, rejectReason) ||
                other.rejectReason == rejectReason) &&
            (identical(other.pricePerKg, pricePerKg) ||
                other.pricePerKg == pricePerKg) &&
            (identical(other.finalPrice, finalPrice) ||
                other.finalPrice == finalPrice) &&
            (identical(other.publishedWeightInGrams, publishedWeightInGrams) ||
                other.publishedWeightInGrams == publishedWeightInGrams) &&
            (identical(other.expireAt, expireAt) ||
                other.expireAt == expireAt) &&
            (identical(other.locationName, locationName) ||
                other.locationName == locationName) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.datePosted, datePosted) ||
                other.datePosted == datePosted) &&
            (identical(other.isSold, isSold) || other.isSold == isSold) &&
            (identical(other.soldAt, soldAt) || other.soldAt == soldAt) &&
            (identical(other.initialWeight, initialWeight) ||
                other.initialWeight == initialWeight) &&
            (identical(other.availableWeight, availableWeight) ||
                other.availableWeight == availableWeight) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.gearMeshSizeInFinger, gearMeshSizeInFinger) ||
                other.gearMeshSizeInFinger == gearMeshSizeInFinger) &&
            (identical(other.gearLengthInMeter, gearLengthInMeter) ||
                other.gearLengthInMeter == gearLengthInMeter) &&
            (identical(other.gearWidthInMeter, gearWidthInMeter) ||
                other.gearWidthInMeter == gearWidthInMeter) &&
            (identical(other.gearNature, gearNature) ||
                other.gearNature == gearNature) &&
            (identical(other.specie, specie) || other.specie == specie) &&
            (identical(other.account, account) || other.account == account) &&
            (identical(other.offersCount, offersCount) ||
                other.offersCount == offersCount) &&
            const DeepCollectionEquality().equals(other._images, _images));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        const DeepCollectionEquality().hash(id),
        name,
        market,
        status,
        rejectReason,
        pricePerKg,
        finalPrice,
        publishedWeightInGrams,
        expireAt,
        locationName,
        latitude,
        longitude,
        size,
        datePosted,
        isSold,
        soldAt,
        initialWeight,
        availableWeight,
        createdAt,
        updatedAt,
        deletedAt,
        uid,
        gearMeshSizeInFinger,
        gearLengthInMeter,
        gearWidthInMeter,
        gearNature,
        specie,
        account,
        offersCount,
        const DeepCollectionEquality().hash(_images)
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductApiModelImplCopyWith<_$ProductApiModelImpl> get copyWith =>
      __$$ProductApiModelImplCopyWithImpl<_$ProductApiModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductApiModelImplToJson(
      this,
    );
  }
}

abstract class _ProductApiModel implements ProductApiModel {
  const factory _ProductApiModel(
      {required final dynamic id,
      final String? name,
      final ProductMarketApiModel? market,
      final String? status,
      final String? rejectReason,
      @JsonKey(name: 'price_per_kg') final double? pricePerKg,
      @JsonKey(name: 'final_price') final double? finalPrice,
      @JsonKey(name: 'published_weight_in_grams')
      final double? publishedWeightInGrams,
      @JsonKey(name: 'expire_at') final String? expireAt,
      @JsonKey(name: 'location_name') final String? locationName,
      final double? latitude,
      final double? longitude,
      final String? size,
      @JsonKey(name: 'date_posted') final String? datePosted,
      final bool? isSold,
      final String? soldAt,
      @JsonKey(name: 'initial_weight') final double? initialWeight,
      @JsonKey(name: 'available_weight') final double? availableWeight,
      @JsonKey(name: 'created_at') final String? createdAt,
      @JsonKey(name: 'updated_at') final String? updatedAt,
      @JsonKey(name: 'deleted_at') final String? deletedAt,
      final String? uid,
      final double? gearMeshSizeInFinger,
      final double? gearLengthInMeter,
      final double? gearWidthInMeter,
      final String? gearNature,
      final ProductSpeciesApiModel? specie,
      final ProductAccountApiModel? account,
      @JsonKey(name: 'offersCount') final int offersCount,
      final List<String> images}) = _$ProductApiModelImpl;

  factory _ProductApiModel.fromJson(Map<String, dynamic> json) =
      _$ProductApiModelImpl.fromJson;

  @override
  dynamic get id;
  @override
  String? get name;
  @override
  ProductMarketApiModel? get market;
  @override
  String? get status;
  @override
  String? get rejectReason;
  @override
  @JsonKey(name: 'price_per_kg')
  double? get pricePerKg;
  @override
  @JsonKey(name: 'final_price')
  double? get finalPrice;
  @override
  @JsonKey(name: 'published_weight_in_grams')
  double? get publishedWeightInGrams;
  @override
  @JsonKey(name: 'expire_at')
  String? get expireAt;
  @override
  @JsonKey(name: 'location_name')
  String? get locationName;
  @override
  double? get latitude;
  @override
  double? get longitude;
  @override
  String? get size;
  @override
  @JsonKey(name: 'date_posted')
  String? get datePosted;
  @override
  bool? get isSold;
  @override
  String? get soldAt;
  @override
  @JsonKey(name: 'initial_weight')
  double? get initialWeight;
  @override
  @JsonKey(name: 'available_weight')
  double? get availableWeight;
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
  @override
  double? get gearMeshSizeInFinger;
  @override
  double? get gearLengthInMeter;
  @override
  double? get gearWidthInMeter;
  @override
  String? get gearNature;
  @override
  ProductSpeciesApiModel? get specie;
  @override
  ProductAccountApiModel? get account;
  @override
  @JsonKey(name: 'offersCount')
  int get offersCount;
  @override
  List<String> get images;
  @override
  @JsonKey(ignore: true)
  _$$ProductApiModelImplCopyWith<_$ProductApiModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
