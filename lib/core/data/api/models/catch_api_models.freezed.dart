// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'catch_api_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GearApiModel _$GearApiModelFromJson(Map<String, dynamic> json) {
  return _GearApiModel.fromJson(json);
}

/// @nodoc
mixin _$GearApiModel {
  dynamic get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'gear_mesh_size_in_finger')
  double? get gearMeshSizeInFinger => throw _privateConstructorUsedError;
  @JsonKey(name: 'gear_length_in_meter')
  double? get gearLengthInMeter => throw _privateConstructorUsedError;
  @JsonKey(name: 'gear_nature')
  String? get gearNature => throw _privateConstructorUsedError;
  AccountApiModel? get account => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  String? get updatedAt => throw _privateConstructorUsedError;
  String? get uid => throw _privateConstructorUsedError;

  /// Serializes this GearApiModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GearApiModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GearApiModelCopyWith<GearApiModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GearApiModelCopyWith<$Res> {
  factory $GearApiModelCopyWith(
    GearApiModel value,
    $Res Function(GearApiModel) then,
  ) = _$GearApiModelCopyWithImpl<$Res, GearApiModel>;
  @useResult
  $Res call({
    dynamic id,
    @JsonKey(name: 'gear_mesh_size_in_finger') double? gearMeshSizeInFinger,
    @JsonKey(name: 'gear_length_in_meter') double? gearLengthInMeter,
    @JsonKey(name: 'gear_nature') String? gearNature,
    AccountApiModel? account,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    String? uid,
  });

  $AccountApiModelCopyWith<$Res>? get account;
}

/// @nodoc
class _$GearApiModelCopyWithImpl<$Res, $Val extends GearApiModel>
    implements $GearApiModelCopyWith<$Res> {
  _$GearApiModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GearApiModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? gearMeshSizeInFinger = freezed,
    Object? gearLengthInMeter = freezed,
    Object? gearNature = freezed,
    Object? account = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? uid = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            gearMeshSizeInFinger: freezed == gearMeshSizeInFinger
                ? _value.gearMeshSizeInFinger
                : gearMeshSizeInFinger // ignore: cast_nullable_to_non_nullable
                      as double?,
            gearLengthInMeter: freezed == gearLengthInMeter
                ? _value.gearLengthInMeter
                : gearLengthInMeter // ignore: cast_nullable_to_non_nullable
                      as double?,
            gearNature: freezed == gearNature
                ? _value.gearNature
                : gearNature // ignore: cast_nullable_to_non_nullable
                      as String?,
            account: freezed == account
                ? _value.account
                : account // ignore: cast_nullable_to_non_nullable
                      as AccountApiModel?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            uid: freezed == uid
                ? _value.uid
                : uid // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of GearApiModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AccountApiModelCopyWith<$Res>? get account {
    if (_value.account == null) {
      return null;
    }

    return $AccountApiModelCopyWith<$Res>(_value.account!, (value) {
      return _then(_value.copyWith(account: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GearApiModelImplCopyWith<$Res>
    implements $GearApiModelCopyWith<$Res> {
  factory _$$GearApiModelImplCopyWith(
    _$GearApiModelImpl value,
    $Res Function(_$GearApiModelImpl) then,
  ) = __$$GearApiModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    dynamic id,
    @JsonKey(name: 'gear_mesh_size_in_finger') double? gearMeshSizeInFinger,
    @JsonKey(name: 'gear_length_in_meter') double? gearLengthInMeter,
    @JsonKey(name: 'gear_nature') String? gearNature,
    AccountApiModel? account,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    String? uid,
  });

  @override
  $AccountApiModelCopyWith<$Res>? get account;
}

/// @nodoc
class __$$GearApiModelImplCopyWithImpl<$Res>
    extends _$GearApiModelCopyWithImpl<$Res, _$GearApiModelImpl>
    implements _$$GearApiModelImplCopyWith<$Res> {
  __$$GearApiModelImplCopyWithImpl(
    _$GearApiModelImpl _value,
    $Res Function(_$GearApiModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GearApiModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? gearMeshSizeInFinger = freezed,
    Object? gearLengthInMeter = freezed,
    Object? gearNature = freezed,
    Object? account = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? uid = freezed,
  }) {
    return _then(
      _$GearApiModelImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        gearMeshSizeInFinger: freezed == gearMeshSizeInFinger
            ? _value.gearMeshSizeInFinger
            : gearMeshSizeInFinger // ignore: cast_nullable_to_non_nullable
                  as double?,
        gearLengthInMeter: freezed == gearLengthInMeter
            ? _value.gearLengthInMeter
            : gearLengthInMeter // ignore: cast_nullable_to_non_nullable
                  as double?,
        gearNature: freezed == gearNature
            ? _value.gearNature
            : gearNature // ignore: cast_nullable_to_non_nullable
                  as String?,
        account: freezed == account
            ? _value.account
            : account // ignore: cast_nullable_to_non_nullable
                  as AccountApiModel?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
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
class _$GearApiModelImpl implements _GearApiModel {
  const _$GearApiModelImpl({
    required this.id,
    @JsonKey(name: 'gear_mesh_size_in_finger') this.gearMeshSizeInFinger,
    @JsonKey(name: 'gear_length_in_meter') this.gearLengthInMeter,
    @JsonKey(name: 'gear_nature') this.gearNature,
    this.account,
    @JsonKey(name: 'created_at') this.createdAt,
    @JsonKey(name: 'updated_at') this.updatedAt,
    this.uid,
  });

  factory _$GearApiModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$GearApiModelImplFromJson(json);

  @override
  final dynamic id;
  @override
  @JsonKey(name: 'gear_mesh_size_in_finger')
  final double? gearMeshSizeInFinger;
  @override
  @JsonKey(name: 'gear_length_in_meter')
  final double? gearLengthInMeter;
  @override
  @JsonKey(name: 'gear_nature')
  final String? gearNature;
  @override
  final AccountApiModel? account;
  @override
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final String? updatedAt;
  @override
  final String? uid;

  @override
  String toString() {
    return 'GearApiModel(id: $id, gearMeshSizeInFinger: $gearMeshSizeInFinger, gearLengthInMeter: $gearLengthInMeter, gearNature: $gearNature, account: $account, createdAt: $createdAt, updatedAt: $updatedAt, uid: $uid)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GearApiModelImpl &&
            const DeepCollectionEquality().equals(other.id, id) &&
            (identical(other.gearMeshSizeInFinger, gearMeshSizeInFinger) ||
                other.gearMeshSizeInFinger == gearMeshSizeInFinger) &&
            (identical(other.gearLengthInMeter, gearLengthInMeter) ||
                other.gearLengthInMeter == gearLengthInMeter) &&
            (identical(other.gearNature, gearNature) ||
                other.gearNature == gearNature) &&
            (identical(other.account, account) || other.account == account) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.uid, uid) || other.uid == uid));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(id),
    gearMeshSizeInFinger,
    gearLengthInMeter,
    gearNature,
    account,
    createdAt,
    updatedAt,
    uid,
  );

  /// Create a copy of GearApiModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GearApiModelImplCopyWith<_$GearApiModelImpl> get copyWith =>
      __$$GearApiModelImplCopyWithImpl<_$GearApiModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GearApiModelImplToJson(this);
  }
}

abstract class _GearApiModel implements GearApiModel {
  const factory _GearApiModel({
    required final dynamic id,
    @JsonKey(name: 'gear_mesh_size_in_finger')
    final double? gearMeshSizeInFinger,
    @JsonKey(name: 'gear_length_in_meter') final double? gearLengthInMeter,
    @JsonKey(name: 'gear_nature') final String? gearNature,
    final AccountApiModel? account,
    @JsonKey(name: 'created_at') final String? createdAt,
    @JsonKey(name: 'updated_at') final String? updatedAt,
    final String? uid,
  }) = _$GearApiModelImpl;

  factory _GearApiModel.fromJson(Map<String, dynamic> json) =
      _$GearApiModelImpl.fromJson;

  @override
  dynamic get id;
  @override
  @JsonKey(name: 'gear_mesh_size_in_finger')
  double? get gearMeshSizeInFinger;
  @override
  @JsonKey(name: 'gear_length_in_meter')
  double? get gearLengthInMeter;
  @override
  @JsonKey(name: 'gear_nature')
  String? get gearNature;
  @override
  AccountApiModel? get account;
  @override
  @JsonKey(name: 'created_at')
  String? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  String? get updatedAt;
  @override
  String? get uid;

  /// Create a copy of GearApiModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GearApiModelImplCopyWith<_$GearApiModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FishCatchImageApiModel _$FishCatchImageApiModelFromJson(
  Map<String, dynamic> json,
) {
  return _FishCatchImageApiModel.fromJson(json);
}

/// @nodoc
mixin _$FishCatchImageApiModel {
  dynamic get id => throw _privateConstructorUsedError;
  String? get fishCatch => throw _privateConstructorUsedError;
  @JsonKey(name: 'imageUrl')
  String? get imageUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  String? get updatedAt => throw _privateConstructorUsedError;
  String? get uid => throw _privateConstructorUsedError;

  /// Serializes this FishCatchImageApiModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FishCatchImageApiModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FishCatchImageApiModelCopyWith<FishCatchImageApiModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FishCatchImageApiModelCopyWith<$Res> {
  factory $FishCatchImageApiModelCopyWith(
    FishCatchImageApiModel value,
    $Res Function(FishCatchImageApiModel) then,
  ) = _$FishCatchImageApiModelCopyWithImpl<$Res, FishCatchImageApiModel>;
  @useResult
  $Res call({
    dynamic id,
    String? fishCatch,
    @JsonKey(name: 'imageUrl') String? imageUrl,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    String? uid,
  });
}

/// @nodoc
class _$FishCatchImageApiModelCopyWithImpl<
  $Res,
  $Val extends FishCatchImageApiModel
>
    implements $FishCatchImageApiModelCopyWith<$Res> {
  _$FishCatchImageApiModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FishCatchImageApiModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? fishCatch = freezed,
    Object? imageUrl = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? uid = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            fishCatch: freezed == fishCatch
                ? _value.fishCatch
                : fishCatch // ignore: cast_nullable_to_non_nullable
                      as String?,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
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
abstract class _$$FishCatchImageApiModelImplCopyWith<$Res>
    implements $FishCatchImageApiModelCopyWith<$Res> {
  factory _$$FishCatchImageApiModelImplCopyWith(
    _$FishCatchImageApiModelImpl value,
    $Res Function(_$FishCatchImageApiModelImpl) then,
  ) = __$$FishCatchImageApiModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    dynamic id,
    String? fishCatch,
    @JsonKey(name: 'imageUrl') String? imageUrl,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    String? uid,
  });
}

/// @nodoc
class __$$FishCatchImageApiModelImplCopyWithImpl<$Res>
    extends
        _$FishCatchImageApiModelCopyWithImpl<$Res, _$FishCatchImageApiModelImpl>
    implements _$$FishCatchImageApiModelImplCopyWith<$Res> {
  __$$FishCatchImageApiModelImplCopyWithImpl(
    _$FishCatchImageApiModelImpl _value,
    $Res Function(_$FishCatchImageApiModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FishCatchImageApiModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? fishCatch = freezed,
    Object? imageUrl = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? uid = freezed,
  }) {
    return _then(
      _$FishCatchImageApiModelImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        fishCatch: freezed == fishCatch
            ? _value.fishCatch
            : fishCatch // ignore: cast_nullable_to_non_nullable
                  as String?,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
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
class _$FishCatchImageApiModelImpl implements _FishCatchImageApiModel {
  const _$FishCatchImageApiModelImpl({
    required this.id,
    this.fishCatch,
    @JsonKey(name: 'imageUrl') this.imageUrl,
    @JsonKey(name: 'created_at') this.createdAt,
    @JsonKey(name: 'updated_at') this.updatedAt,
    this.uid,
  });

  factory _$FishCatchImageApiModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$FishCatchImageApiModelImplFromJson(json);

  @override
  final dynamic id;
  @override
  final String? fishCatch;
  @override
  @JsonKey(name: 'imageUrl')
  final String? imageUrl;
  @override
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final String? updatedAt;
  @override
  final String? uid;

  @override
  String toString() {
    return 'FishCatchImageApiModel(id: $id, fishCatch: $fishCatch, imageUrl: $imageUrl, createdAt: $createdAt, updatedAt: $updatedAt, uid: $uid)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FishCatchImageApiModelImpl &&
            const DeepCollectionEquality().equals(other.id, id) &&
            (identical(other.fishCatch, fishCatch) ||
                other.fishCatch == fishCatch) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.uid, uid) || other.uid == uid));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(id),
    fishCatch,
    imageUrl,
    createdAt,
    updatedAt,
    uid,
  );

  /// Create a copy of FishCatchImageApiModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FishCatchImageApiModelImplCopyWith<_$FishCatchImageApiModelImpl>
  get copyWith =>
      __$$FishCatchImageApiModelImplCopyWithImpl<_$FishCatchImageApiModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$FishCatchImageApiModelImplToJson(this);
  }
}

abstract class _FishCatchImageApiModel implements FishCatchImageApiModel {
  const factory _FishCatchImageApiModel({
    required final dynamic id,
    final String? fishCatch,
    @JsonKey(name: 'imageUrl') final String? imageUrl,
    @JsonKey(name: 'created_at') final String? createdAt,
    @JsonKey(name: 'updated_at') final String? updatedAt,
    final String? uid,
  }) = _$FishCatchImageApiModelImpl;

  factory _FishCatchImageApiModel.fromJson(Map<String, dynamic> json) =
      _$FishCatchImageApiModelImpl.fromJson;

  @override
  dynamic get id;
  @override
  String? get fishCatch;
  @override
  @JsonKey(name: 'imageUrl')
  String? get imageUrl;
  @override
  @JsonKey(name: 'created_at')
  String? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  String? get updatedAt;
  @override
  String? get uid;

  /// Create a copy of FishCatchImageApiModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FishCatchImageApiModelImplCopyWith<_$FishCatchImageApiModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}

CatchApiModel _$CatchApiModelFromJson(Map<String, dynamic> json) {
  return _CatchApiModel.fromJson(json);
}

/// @nodoc
mixin _$CatchApiModel {
  dynamic get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'water_depth_in_meter')
  double? get waterDepthInMeter => throw _privateConstructorUsedError;
  @JsonKey(name: 'fishing_time_in_hour')
  double? get fishingTimeInHour => throw _privateConstructorUsedError;
  @JsonKey(name: 'estimated_weight_in_kg')
  double? get estimatedWeightInKg => throw _privateConstructorUsedError;
  @JsonKey(name: 'average_size_in_cm')
  double? get averageSizeInCm => throw _privateConstructorUsedError;
  @JsonKey(name: 'estimated_size')
  int? get estimatedSize => throw _privateConstructorUsedError;
  @JsonKey(name: 'published_weight_in_kg')
  double? get publishedWeightInKg => throw _privateConstructorUsedError;
  @JsonKey(name: 'price_per_kg')
  double? get pricePerKg => throw _privateConstructorUsedError;
  @JsonKey(name: 'final_price')
  double? get finalPrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'published_in_market_place')
  bool? get publishedInMarketPlace => throw _privateConstructorUsedError;
  @JsonKey(name: 'fishCatchImages')
  List<FishCatchImageApiModel> get fishCatchImages =>
      throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;
  GearApiModel? get gear => throw _privateConstructorUsedError;
  AccountApiModel? get account =>
      throw _privateConstructorUsedError; // The fisher
  @JsonKey(name: 'obs_synced')
  bool? get obsSynced => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  String? get updatedAt => throw _privateConstructorUsedError;
  String? get uid =>
      throw _privateConstructorUsedError; // Legacy fields for compatibility
  String? get name => throw _privateConstructorUsedError;
  SpeciesModel? get species => throw _privateConstructorUsedError;
  String? get market => throw _privateConstructorUsedError;

  /// Serializes this CatchApiModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CatchApiModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CatchApiModelCopyWith<CatchApiModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CatchApiModelCopyWith<$Res> {
  factory $CatchApiModelCopyWith(
    CatchApiModel value,
    $Res Function(CatchApiModel) then,
  ) = _$CatchApiModelCopyWithImpl<$Res, CatchApiModel>;
  @useResult
  $Res call({
    dynamic id,
    @JsonKey(name: 'water_depth_in_meter') double? waterDepthInMeter,
    @JsonKey(name: 'fishing_time_in_hour') double? fishingTimeInHour,
    @JsonKey(name: 'estimated_weight_in_kg') double? estimatedWeightInKg,
    @JsonKey(name: 'average_size_in_cm') double? averageSizeInCm,
    @JsonKey(name: 'estimated_size') int? estimatedSize,
    @JsonKey(name: 'published_weight_in_kg') double? publishedWeightInKg,
    @JsonKey(name: 'price_per_kg') double? pricePerKg,
    @JsonKey(name: 'final_price') double? finalPrice,
    @JsonKey(name: 'published_in_market_place') bool? publishedInMarketPlace,
    @JsonKey(name: 'fishCatchImages')
    List<FishCatchImageApiModel> fishCatchImages,
    String? note,
    String? status,
    GearApiModel? gear,
    AccountApiModel? account,
    @JsonKey(name: 'obs_synced') bool? obsSynced,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    String? uid,
    String? name,
    SpeciesModel? species,
    String? market,
  });

  $GearApiModelCopyWith<$Res>? get gear;
  $AccountApiModelCopyWith<$Res>? get account;
}

/// @nodoc
class _$CatchApiModelCopyWithImpl<$Res, $Val extends CatchApiModel>
    implements $CatchApiModelCopyWith<$Res> {
  _$CatchApiModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CatchApiModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? waterDepthInMeter = freezed,
    Object? fishingTimeInHour = freezed,
    Object? estimatedWeightInKg = freezed,
    Object? averageSizeInCm = freezed,
    Object? estimatedSize = freezed,
    Object? publishedWeightInKg = freezed,
    Object? pricePerKg = freezed,
    Object? finalPrice = freezed,
    Object? publishedInMarketPlace = freezed,
    Object? fishCatchImages = null,
    Object? note = freezed,
    Object? status = freezed,
    Object? gear = freezed,
    Object? account = freezed,
    Object? obsSynced = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? uid = freezed,
    Object? name = freezed,
    Object? species = freezed,
    Object? market = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            waterDepthInMeter: freezed == waterDepthInMeter
                ? _value.waterDepthInMeter
                : waterDepthInMeter // ignore: cast_nullable_to_non_nullable
                      as double?,
            fishingTimeInHour: freezed == fishingTimeInHour
                ? _value.fishingTimeInHour
                : fishingTimeInHour // ignore: cast_nullable_to_non_nullable
                      as double?,
            estimatedWeightInKg: freezed == estimatedWeightInKg
                ? _value.estimatedWeightInKg
                : estimatedWeightInKg // ignore: cast_nullable_to_non_nullable
                      as double?,
            averageSizeInCm: freezed == averageSizeInCm
                ? _value.averageSizeInCm
                : averageSizeInCm // ignore: cast_nullable_to_non_nullable
                      as double?,
            estimatedSize: freezed == estimatedSize
                ? _value.estimatedSize
                : estimatedSize // ignore: cast_nullable_to_non_nullable
                      as int?,
            publishedWeightInKg: freezed == publishedWeightInKg
                ? _value.publishedWeightInKg
                : publishedWeightInKg // ignore: cast_nullable_to_non_nullable
                      as double?,
            pricePerKg: freezed == pricePerKg
                ? _value.pricePerKg
                : pricePerKg // ignore: cast_nullable_to_non_nullable
                      as double?,
            finalPrice: freezed == finalPrice
                ? _value.finalPrice
                : finalPrice // ignore: cast_nullable_to_non_nullable
                      as double?,
            publishedInMarketPlace: freezed == publishedInMarketPlace
                ? _value.publishedInMarketPlace
                : publishedInMarketPlace // ignore: cast_nullable_to_non_nullable
                      as bool?,
            fishCatchImages: null == fishCatchImages
                ? _value.fishCatchImages
                : fishCatchImages // ignore: cast_nullable_to_non_nullable
                      as List<FishCatchImageApiModel>,
            note: freezed == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String?,
            gear: freezed == gear
                ? _value.gear
                : gear // ignore: cast_nullable_to_non_nullable
                      as GearApiModel?,
            account: freezed == account
                ? _value.account
                : account // ignore: cast_nullable_to_non_nullable
                      as AccountApiModel?,
            obsSynced: freezed == obsSynced
                ? _value.obsSynced
                : obsSynced // ignore: cast_nullable_to_non_nullable
                      as bool?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            uid: freezed == uid
                ? _value.uid
                : uid // ignore: cast_nullable_to_non_nullable
                      as String?,
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String?,
            species: freezed == species
                ? _value.species
                : species // ignore: cast_nullable_to_non_nullable
                      as SpeciesModel?,
            market: freezed == market
                ? _value.market
                : market // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of CatchApiModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GearApiModelCopyWith<$Res>? get gear {
    if (_value.gear == null) {
      return null;
    }

    return $GearApiModelCopyWith<$Res>(_value.gear!, (value) {
      return _then(_value.copyWith(gear: value) as $Val);
    });
  }

  /// Create a copy of CatchApiModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AccountApiModelCopyWith<$Res>? get account {
    if (_value.account == null) {
      return null;
    }

    return $AccountApiModelCopyWith<$Res>(_value.account!, (value) {
      return _then(_value.copyWith(account: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CatchApiModelImplCopyWith<$Res>
    implements $CatchApiModelCopyWith<$Res> {
  factory _$$CatchApiModelImplCopyWith(
    _$CatchApiModelImpl value,
    $Res Function(_$CatchApiModelImpl) then,
  ) = __$$CatchApiModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    dynamic id,
    @JsonKey(name: 'water_depth_in_meter') double? waterDepthInMeter,
    @JsonKey(name: 'fishing_time_in_hour') double? fishingTimeInHour,
    @JsonKey(name: 'estimated_weight_in_kg') double? estimatedWeightInKg,
    @JsonKey(name: 'average_size_in_cm') double? averageSizeInCm,
    @JsonKey(name: 'estimated_size') int? estimatedSize,
    @JsonKey(name: 'published_weight_in_kg') double? publishedWeightInKg,
    @JsonKey(name: 'price_per_kg') double? pricePerKg,
    @JsonKey(name: 'final_price') double? finalPrice,
    @JsonKey(name: 'published_in_market_place') bool? publishedInMarketPlace,
    @JsonKey(name: 'fishCatchImages')
    List<FishCatchImageApiModel> fishCatchImages,
    String? note,
    String? status,
    GearApiModel? gear,
    AccountApiModel? account,
    @JsonKey(name: 'obs_synced') bool? obsSynced,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    String? uid,
    String? name,
    SpeciesModel? species,
    String? market,
  });

  @override
  $GearApiModelCopyWith<$Res>? get gear;
  @override
  $AccountApiModelCopyWith<$Res>? get account;
}

/// @nodoc
class __$$CatchApiModelImplCopyWithImpl<$Res>
    extends _$CatchApiModelCopyWithImpl<$Res, _$CatchApiModelImpl>
    implements _$$CatchApiModelImplCopyWith<$Res> {
  __$$CatchApiModelImplCopyWithImpl(
    _$CatchApiModelImpl _value,
    $Res Function(_$CatchApiModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CatchApiModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? waterDepthInMeter = freezed,
    Object? fishingTimeInHour = freezed,
    Object? estimatedWeightInKg = freezed,
    Object? averageSizeInCm = freezed,
    Object? estimatedSize = freezed,
    Object? publishedWeightInKg = freezed,
    Object? pricePerKg = freezed,
    Object? finalPrice = freezed,
    Object? publishedInMarketPlace = freezed,
    Object? fishCatchImages = null,
    Object? note = freezed,
    Object? status = freezed,
    Object? gear = freezed,
    Object? account = freezed,
    Object? obsSynced = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? uid = freezed,
    Object? name = freezed,
    Object? species = freezed,
    Object? market = freezed,
  }) {
    return _then(
      _$CatchApiModelImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        waterDepthInMeter: freezed == waterDepthInMeter
            ? _value.waterDepthInMeter
            : waterDepthInMeter // ignore: cast_nullable_to_non_nullable
                  as double?,
        fishingTimeInHour: freezed == fishingTimeInHour
            ? _value.fishingTimeInHour
            : fishingTimeInHour // ignore: cast_nullable_to_non_nullable
                  as double?,
        estimatedWeightInKg: freezed == estimatedWeightInKg
            ? _value.estimatedWeightInKg
            : estimatedWeightInKg // ignore: cast_nullable_to_non_nullable
                  as double?,
        averageSizeInCm: freezed == averageSizeInCm
            ? _value.averageSizeInCm
            : averageSizeInCm // ignore: cast_nullable_to_non_nullable
                  as double?,
        estimatedSize: freezed == estimatedSize
            ? _value.estimatedSize
            : estimatedSize // ignore: cast_nullable_to_non_nullable
                  as int?,
        publishedWeightInKg: freezed == publishedWeightInKg
            ? _value.publishedWeightInKg
            : publishedWeightInKg // ignore: cast_nullable_to_non_nullable
                  as double?,
        pricePerKg: freezed == pricePerKg
            ? _value.pricePerKg
            : pricePerKg // ignore: cast_nullable_to_non_nullable
                  as double?,
        finalPrice: freezed == finalPrice
            ? _value.finalPrice
            : finalPrice // ignore: cast_nullable_to_non_nullable
                  as double?,
        publishedInMarketPlace: freezed == publishedInMarketPlace
            ? _value.publishedInMarketPlace
            : publishedInMarketPlace // ignore: cast_nullable_to_non_nullable
                  as bool?,
        fishCatchImages: null == fishCatchImages
            ? _value._fishCatchImages
            : fishCatchImages // ignore: cast_nullable_to_non_nullable
                  as List<FishCatchImageApiModel>,
        note: freezed == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String?,
        gear: freezed == gear
            ? _value.gear
            : gear // ignore: cast_nullable_to_non_nullable
                  as GearApiModel?,
        account: freezed == account
            ? _value.account
            : account // ignore: cast_nullable_to_non_nullable
                  as AccountApiModel?,
        obsSynced: freezed == obsSynced
            ? _value.obsSynced
            : obsSynced // ignore: cast_nullable_to_non_nullable
                  as bool?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        uid: freezed == uid
            ? _value.uid
            : uid // ignore: cast_nullable_to_non_nullable
                  as String?,
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        species: freezed == species
            ? _value.species
            : species // ignore: cast_nullable_to_non_nullable
                  as SpeciesModel?,
        market: freezed == market
            ? _value.market
            : market // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CatchApiModelImpl implements _CatchApiModel {
  const _$CatchApiModelImpl({
    required this.id,
    @JsonKey(name: 'water_depth_in_meter') this.waterDepthInMeter,
    @JsonKey(name: 'fishing_time_in_hour') this.fishingTimeInHour,
    @JsonKey(name: 'estimated_weight_in_kg') this.estimatedWeightInKg,
    @JsonKey(name: 'average_size_in_cm') this.averageSizeInCm,
    @JsonKey(name: 'estimated_size') this.estimatedSize,
    @JsonKey(name: 'published_weight_in_kg') this.publishedWeightInKg,
    @JsonKey(name: 'price_per_kg') this.pricePerKg,
    @JsonKey(name: 'final_price') this.finalPrice,
    @JsonKey(name: 'published_in_market_place') this.publishedInMarketPlace,
    @JsonKey(name: 'fishCatchImages')
    final List<FishCatchImageApiModel> fishCatchImages =
        const <FishCatchImageApiModel>[],
    this.note,
    this.status,
    this.gear,
    this.account,
    @JsonKey(name: 'obs_synced') this.obsSynced,
    @JsonKey(name: 'created_at') this.createdAt,
    @JsonKey(name: 'updated_at') this.updatedAt,
    this.uid,
    this.name,
    this.species,
    this.market,
  }) : _fishCatchImages = fishCatchImages;

  factory _$CatchApiModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CatchApiModelImplFromJson(json);

  @override
  final dynamic id;
  @override
  @JsonKey(name: 'water_depth_in_meter')
  final double? waterDepthInMeter;
  @override
  @JsonKey(name: 'fishing_time_in_hour')
  final double? fishingTimeInHour;
  @override
  @JsonKey(name: 'estimated_weight_in_kg')
  final double? estimatedWeightInKg;
  @override
  @JsonKey(name: 'average_size_in_cm')
  final double? averageSizeInCm;
  @override
  @JsonKey(name: 'estimated_size')
  final int? estimatedSize;
  @override
  @JsonKey(name: 'published_weight_in_kg')
  final double? publishedWeightInKg;
  @override
  @JsonKey(name: 'price_per_kg')
  final double? pricePerKg;
  @override
  @JsonKey(name: 'final_price')
  final double? finalPrice;
  @override
  @JsonKey(name: 'published_in_market_place')
  final bool? publishedInMarketPlace;
  final List<FishCatchImageApiModel> _fishCatchImages;
  @override
  @JsonKey(name: 'fishCatchImages')
  List<FishCatchImageApiModel> get fishCatchImages {
    if (_fishCatchImages is EqualUnmodifiableListView) return _fishCatchImages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_fishCatchImages);
  }

  @override
  final String? note;
  @override
  final String? status;
  @override
  final GearApiModel? gear;
  @override
  final AccountApiModel? account;
  // The fisher
  @override
  @JsonKey(name: 'obs_synced')
  final bool? obsSynced;
  @override
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final String? updatedAt;
  @override
  final String? uid;
  // Legacy fields for compatibility
  @override
  final String? name;
  @override
  final SpeciesModel? species;
  @override
  final String? market;

  @override
  String toString() {
    return 'CatchApiModel(id: $id, waterDepthInMeter: $waterDepthInMeter, fishingTimeInHour: $fishingTimeInHour, estimatedWeightInKg: $estimatedWeightInKg, averageSizeInCm: $averageSizeInCm, estimatedSize: $estimatedSize, publishedWeightInKg: $publishedWeightInKg, pricePerKg: $pricePerKg, finalPrice: $finalPrice, publishedInMarketPlace: $publishedInMarketPlace, fishCatchImages: $fishCatchImages, note: $note, status: $status, gear: $gear, account: $account, obsSynced: $obsSynced, createdAt: $createdAt, updatedAt: $updatedAt, uid: $uid, name: $name, species: $species, market: $market)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CatchApiModelImpl &&
            const DeepCollectionEquality().equals(other.id, id) &&
            (identical(other.waterDepthInMeter, waterDepthInMeter) ||
                other.waterDepthInMeter == waterDepthInMeter) &&
            (identical(other.fishingTimeInHour, fishingTimeInHour) ||
                other.fishingTimeInHour == fishingTimeInHour) &&
            (identical(other.estimatedWeightInKg, estimatedWeightInKg) ||
                other.estimatedWeightInKg == estimatedWeightInKg) &&
            (identical(other.averageSizeInCm, averageSizeInCm) ||
                other.averageSizeInCm == averageSizeInCm) &&
            (identical(other.estimatedSize, estimatedSize) ||
                other.estimatedSize == estimatedSize) &&
            (identical(other.publishedWeightInKg, publishedWeightInKg) ||
                other.publishedWeightInKg == publishedWeightInKg) &&
            (identical(other.pricePerKg, pricePerKg) ||
                other.pricePerKg == pricePerKg) &&
            (identical(other.finalPrice, finalPrice) ||
                other.finalPrice == finalPrice) &&
            (identical(other.publishedInMarketPlace, publishedInMarketPlace) ||
                other.publishedInMarketPlace == publishedInMarketPlace) &&
            const DeepCollectionEquality().equals(
              other._fishCatchImages,
              _fishCatchImages,
            ) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.gear, gear) || other.gear == gear) &&
            (identical(other.account, account) || other.account == account) &&
            (identical(other.obsSynced, obsSynced) ||
                other.obsSynced == obsSynced) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.species, species) || other.species == species) &&
            (identical(other.market, market) || other.market == market));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    const DeepCollectionEquality().hash(id),
    waterDepthInMeter,
    fishingTimeInHour,
    estimatedWeightInKg,
    averageSizeInCm,
    estimatedSize,
    publishedWeightInKg,
    pricePerKg,
    finalPrice,
    publishedInMarketPlace,
    const DeepCollectionEquality().hash(_fishCatchImages),
    note,
    status,
    gear,
    account,
    obsSynced,
    createdAt,
    updatedAt,
    uid,
    name,
    species,
    market,
  ]);

  /// Create a copy of CatchApiModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CatchApiModelImplCopyWith<_$CatchApiModelImpl> get copyWith =>
      __$$CatchApiModelImplCopyWithImpl<_$CatchApiModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CatchApiModelImplToJson(this);
  }
}

abstract class _CatchApiModel implements CatchApiModel {
  const factory _CatchApiModel({
    required final dynamic id,
    @JsonKey(name: 'water_depth_in_meter') final double? waterDepthInMeter,
    @JsonKey(name: 'fishing_time_in_hour') final double? fishingTimeInHour,
    @JsonKey(name: 'estimated_weight_in_kg') final double? estimatedWeightInKg,
    @JsonKey(name: 'average_size_in_cm') final double? averageSizeInCm,
    @JsonKey(name: 'estimated_size') final int? estimatedSize,
    @JsonKey(name: 'published_weight_in_kg') final double? publishedWeightInKg,
    @JsonKey(name: 'price_per_kg') final double? pricePerKg,
    @JsonKey(name: 'final_price') final double? finalPrice,
    @JsonKey(name: 'published_in_market_place')
    final bool? publishedInMarketPlace,
    @JsonKey(name: 'fishCatchImages')
    final List<FishCatchImageApiModel> fishCatchImages,
    final String? note,
    final String? status,
    final GearApiModel? gear,
    final AccountApiModel? account,
    @JsonKey(name: 'obs_synced') final bool? obsSynced,
    @JsonKey(name: 'created_at') final String? createdAt,
    @JsonKey(name: 'updated_at') final String? updatedAt,
    final String? uid,
    final String? name,
    final SpeciesModel? species,
    final String? market,
  }) = _$CatchApiModelImpl;

  factory _CatchApiModel.fromJson(Map<String, dynamic> json) =
      _$CatchApiModelImpl.fromJson;

  @override
  dynamic get id;
  @override
  @JsonKey(name: 'water_depth_in_meter')
  double? get waterDepthInMeter;
  @override
  @JsonKey(name: 'fishing_time_in_hour')
  double? get fishingTimeInHour;
  @override
  @JsonKey(name: 'estimated_weight_in_kg')
  double? get estimatedWeightInKg;
  @override
  @JsonKey(name: 'average_size_in_cm')
  double? get averageSizeInCm;
  @override
  @JsonKey(name: 'estimated_size')
  int? get estimatedSize;
  @override
  @JsonKey(name: 'published_weight_in_kg')
  double? get publishedWeightInKg;
  @override
  @JsonKey(name: 'price_per_kg')
  double? get pricePerKg;
  @override
  @JsonKey(name: 'final_price')
  double? get finalPrice;
  @override
  @JsonKey(name: 'published_in_market_place')
  bool? get publishedInMarketPlace;
  @override
  @JsonKey(name: 'fishCatchImages')
  List<FishCatchImageApiModel> get fishCatchImages;
  @override
  String? get note;
  @override
  String? get status;
  @override
  GearApiModel? get gear;
  @override
  AccountApiModel? get account; // The fisher
  @override
  @JsonKey(name: 'obs_synced')
  bool? get obsSynced;
  @override
  @JsonKey(name: 'created_at')
  String? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  String? get updatedAt;
  @override
  String? get uid; // Legacy fields for compatibility
  @override
  String? get name;
  @override
  SpeciesModel? get species;
  @override
  String? get market;

  /// Create a copy of CatchApiModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CatchApiModelImplCopyWith<_$CatchApiModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CatchImageRequest _$CatchImageRequestFromJson(Map<String, dynamic> json) {
  return _CatchImageRequest.fromJson(json);
}

/// @nodoc
mixin _$CatchImageRequest {
  String get mediaUrl => throw _privateConstructorUsedError;

  /// Serializes this CatchImageRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CatchImageRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CatchImageRequestCopyWith<CatchImageRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CatchImageRequestCopyWith<$Res> {
  factory $CatchImageRequestCopyWith(
    CatchImageRequest value,
    $Res Function(CatchImageRequest) then,
  ) = _$CatchImageRequestCopyWithImpl<$Res, CatchImageRequest>;
  @useResult
  $Res call({String mediaUrl});
}

/// @nodoc
class _$CatchImageRequestCopyWithImpl<$Res, $Val extends CatchImageRequest>
    implements $CatchImageRequestCopyWith<$Res> {
  _$CatchImageRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CatchImageRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? mediaUrl = null}) {
    return _then(
      _value.copyWith(
            mediaUrl: null == mediaUrl
                ? _value.mediaUrl
                : mediaUrl // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CatchImageRequestImplCopyWith<$Res>
    implements $CatchImageRequestCopyWith<$Res> {
  factory _$$CatchImageRequestImplCopyWith(
    _$CatchImageRequestImpl value,
    $Res Function(_$CatchImageRequestImpl) then,
  ) = __$$CatchImageRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String mediaUrl});
}

/// @nodoc
class __$$CatchImageRequestImplCopyWithImpl<$Res>
    extends _$CatchImageRequestCopyWithImpl<$Res, _$CatchImageRequestImpl>
    implements _$$CatchImageRequestImplCopyWith<$Res> {
  __$$CatchImageRequestImplCopyWithImpl(
    _$CatchImageRequestImpl _value,
    $Res Function(_$CatchImageRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CatchImageRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? mediaUrl = null}) {
    return _then(
      _$CatchImageRequestImpl(
        mediaUrl: null == mediaUrl
            ? _value.mediaUrl
            : mediaUrl // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CatchImageRequestImpl implements _CatchImageRequest {
  const _$CatchImageRequestImpl({required this.mediaUrl});

  factory _$CatchImageRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CatchImageRequestImplFromJson(json);

  @override
  final String mediaUrl;

  @override
  String toString() {
    return 'CatchImageRequest(mediaUrl: $mediaUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CatchImageRequestImpl &&
            (identical(other.mediaUrl, mediaUrl) ||
                other.mediaUrl == mediaUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, mediaUrl);

  /// Create a copy of CatchImageRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CatchImageRequestImplCopyWith<_$CatchImageRequestImpl> get copyWith =>
      __$$CatchImageRequestImplCopyWithImpl<_$CatchImageRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CatchImageRequestImplToJson(this);
  }
}

abstract class _CatchImageRequest implements CatchImageRequest {
  const factory _CatchImageRequest({required final String mediaUrl}) =
      _$CatchImageRequestImpl;

  factory _CatchImageRequest.fromJson(Map<String, dynamic> json) =
      _$CatchImageRequestImpl.fromJson;

  @override
  String get mediaUrl;

  /// Create a copy of CatchImageRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CatchImageRequestImplCopyWith<_$CatchImageRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateCatchRequest _$CreateCatchRequestFromJson(Map<String, dynamic> json) {
  return _CreateCatchRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateCatchRequest {
  String get specie => throw _privateConstructorUsedError;
  String get subgroup => throw _privateConstructorUsedError;
  @JsonKey(name: 'gear_mesh_size_in_finger')
  double get gearMeshSizeInFinger => throw _privateConstructorUsedError;
  @JsonKey(name: 'gear_length_in_meter')
  double get gearLengthInMeter => throw _privateConstructorUsedError;
  @JsonKey(name: 'gear_nature')
  String get gearNature => throw _privateConstructorUsedError;
  @JsonKey(name: 'water_depth_in_meter')
  double get waterDepthInMeter => throw _privateConstructorUsedError;
  @JsonKey(name: 'fishing_time_in_hour')
  double get fishingTimeInHour => throw _privateConstructorUsedError;
  @JsonKey(name: 'estimated_weight_in_kg')
  double get estimatedWeightInKg => throw _privateConstructorUsedError;
  @JsonKey(name: 'average_size_in_cm')
  double get averageSizeInCm => throw _privateConstructorUsedError;
  @JsonKey(name: 'estimated_size')
  int get estimatedSize => throw _privateConstructorUsedError;
  @JsonKey(name: 'published_weight_in_kg')
  double get publishedWeightInKg => throw _privateConstructorUsedError;
  @JsonKey(name: 'price_per_kg')
  double get pricePerKg => throw _privateConstructorUsedError;
  @JsonKey(name: 'final_price')
  double get finalPrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'published_in_market_place')
  bool get publishedInMarketPlace => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  List<CatchImageRequest> get images => throw _privateConstructorUsedError;
  String? get alpha => throw _privateConstructorUsedError;
  bool get dead => throw _privateConstructorUsedError;
  double get coordX => throw _privateConstructorUsedError;
  double get coordY => throw _privateConstructorUsedError;
  String get date => throw _privateConstructorUsedError;
  int get market => throw _privateConstructorUsedError;
  String? get observationType => throw _privateConstructorUsedError;
  String? get patrol => throw _privateConstructorUsedError;
  String? get segment => throw _privateConstructorUsedError;

  /// Serializes this CreateCatchRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateCatchRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateCatchRequestCopyWith<CreateCatchRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateCatchRequestCopyWith<$Res> {
  factory $CreateCatchRequestCopyWith(
    CreateCatchRequest value,
    $Res Function(CreateCatchRequest) then,
  ) = _$CreateCatchRequestCopyWithImpl<$Res, CreateCatchRequest>;
  @useResult
  $Res call({
    String specie,
    String subgroup,
    @JsonKey(name: 'gear_mesh_size_in_finger') double gearMeshSizeInFinger,
    @JsonKey(name: 'gear_length_in_meter') double gearLengthInMeter,
    @JsonKey(name: 'gear_nature') String gearNature,
    @JsonKey(name: 'water_depth_in_meter') double waterDepthInMeter,
    @JsonKey(name: 'fishing_time_in_hour') double fishingTimeInHour,
    @JsonKey(name: 'estimated_weight_in_kg') double estimatedWeightInKg,
    @JsonKey(name: 'average_size_in_cm') double averageSizeInCm,
    @JsonKey(name: 'estimated_size') int estimatedSize,
    @JsonKey(name: 'published_weight_in_kg') double publishedWeightInKg,
    @JsonKey(name: 'price_per_kg') double pricePerKg,
    @JsonKey(name: 'final_price') double finalPrice,
    @JsonKey(name: 'published_in_market_place') bool publishedInMarketPlace,
    String? note,
    List<CatchImageRequest> images,
    String? alpha,
    bool dead,
    double coordX,
    double coordY,
    String date,
    int market,
    String? observationType,
    String? patrol,
    String? segment,
  });
}

/// @nodoc
class _$CreateCatchRequestCopyWithImpl<$Res, $Val extends CreateCatchRequest>
    implements $CreateCatchRequestCopyWith<$Res> {
  _$CreateCatchRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateCatchRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? specie = null,
    Object? subgroup = null,
    Object? gearMeshSizeInFinger = null,
    Object? gearLengthInMeter = null,
    Object? gearNature = null,
    Object? waterDepthInMeter = null,
    Object? fishingTimeInHour = null,
    Object? estimatedWeightInKg = null,
    Object? averageSizeInCm = null,
    Object? estimatedSize = null,
    Object? publishedWeightInKg = null,
    Object? pricePerKg = null,
    Object? finalPrice = null,
    Object? publishedInMarketPlace = null,
    Object? note = freezed,
    Object? images = null,
    Object? alpha = freezed,
    Object? dead = null,
    Object? coordX = null,
    Object? coordY = null,
    Object? date = null,
    Object? market = null,
    Object? observationType = freezed,
    Object? patrol = freezed,
    Object? segment = freezed,
  }) {
    return _then(
      _value.copyWith(
            specie: null == specie
                ? _value.specie
                : specie // ignore: cast_nullable_to_non_nullable
                      as String,
            subgroup: null == subgroup
                ? _value.subgroup
                : subgroup // ignore: cast_nullable_to_non_nullable
                      as String,
            gearMeshSizeInFinger: null == gearMeshSizeInFinger
                ? _value.gearMeshSizeInFinger
                : gearMeshSizeInFinger // ignore: cast_nullable_to_non_nullable
                      as double,
            gearLengthInMeter: null == gearLengthInMeter
                ? _value.gearLengthInMeter
                : gearLengthInMeter // ignore: cast_nullable_to_non_nullable
                      as double,
            gearNature: null == gearNature
                ? _value.gearNature
                : gearNature // ignore: cast_nullable_to_non_nullable
                      as String,
            waterDepthInMeter: null == waterDepthInMeter
                ? _value.waterDepthInMeter
                : waterDepthInMeter // ignore: cast_nullable_to_non_nullable
                      as double,
            fishingTimeInHour: null == fishingTimeInHour
                ? _value.fishingTimeInHour
                : fishingTimeInHour // ignore: cast_nullable_to_non_nullable
                      as double,
            estimatedWeightInKg: null == estimatedWeightInKg
                ? _value.estimatedWeightInKg
                : estimatedWeightInKg // ignore: cast_nullable_to_non_nullable
                      as double,
            averageSizeInCm: null == averageSizeInCm
                ? _value.averageSizeInCm
                : averageSizeInCm // ignore: cast_nullable_to_non_nullable
                      as double,
            estimatedSize: null == estimatedSize
                ? _value.estimatedSize
                : estimatedSize // ignore: cast_nullable_to_non_nullable
                      as int,
            publishedWeightInKg: null == publishedWeightInKg
                ? _value.publishedWeightInKg
                : publishedWeightInKg // ignore: cast_nullable_to_non_nullable
                      as double,
            pricePerKg: null == pricePerKg
                ? _value.pricePerKg
                : pricePerKg // ignore: cast_nullable_to_non_nullable
                      as double,
            finalPrice: null == finalPrice
                ? _value.finalPrice
                : finalPrice // ignore: cast_nullable_to_non_nullable
                      as double,
            publishedInMarketPlace: null == publishedInMarketPlace
                ? _value.publishedInMarketPlace
                : publishedInMarketPlace // ignore: cast_nullable_to_non_nullable
                      as bool,
            note: freezed == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as String?,
            images: null == images
                ? _value.images
                : images // ignore: cast_nullable_to_non_nullable
                      as List<CatchImageRequest>,
            alpha: freezed == alpha
                ? _value.alpha
                : alpha // ignore: cast_nullable_to_non_nullable
                      as String?,
            dead: null == dead
                ? _value.dead
                : dead // ignore: cast_nullable_to_non_nullable
                      as bool,
            coordX: null == coordX
                ? _value.coordX
                : coordX // ignore: cast_nullable_to_non_nullable
                      as double,
            coordY: null == coordY
                ? _value.coordY
                : coordY // ignore: cast_nullable_to_non_nullable
                      as double,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as String,
            market: null == market
                ? _value.market
                : market // ignore: cast_nullable_to_non_nullable
                      as int,
            observationType: freezed == observationType
                ? _value.observationType
                : observationType // ignore: cast_nullable_to_non_nullable
                      as String?,
            patrol: freezed == patrol
                ? _value.patrol
                : patrol // ignore: cast_nullable_to_non_nullable
                      as String?,
            segment: freezed == segment
                ? _value.segment
                : segment // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreateCatchRequestImplCopyWith<$Res>
    implements $CreateCatchRequestCopyWith<$Res> {
  factory _$$CreateCatchRequestImplCopyWith(
    _$CreateCatchRequestImpl value,
    $Res Function(_$CreateCatchRequestImpl) then,
  ) = __$$CreateCatchRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String specie,
    String subgroup,
    @JsonKey(name: 'gear_mesh_size_in_finger') double gearMeshSizeInFinger,
    @JsonKey(name: 'gear_length_in_meter') double gearLengthInMeter,
    @JsonKey(name: 'gear_nature') String gearNature,
    @JsonKey(name: 'water_depth_in_meter') double waterDepthInMeter,
    @JsonKey(name: 'fishing_time_in_hour') double fishingTimeInHour,
    @JsonKey(name: 'estimated_weight_in_kg') double estimatedWeightInKg,
    @JsonKey(name: 'average_size_in_cm') double averageSizeInCm,
    @JsonKey(name: 'estimated_size') int estimatedSize,
    @JsonKey(name: 'published_weight_in_kg') double publishedWeightInKg,
    @JsonKey(name: 'price_per_kg') double pricePerKg,
    @JsonKey(name: 'final_price') double finalPrice,
    @JsonKey(name: 'published_in_market_place') bool publishedInMarketPlace,
    String? note,
    List<CatchImageRequest> images,
    String? alpha,
    bool dead,
    double coordX,
    double coordY,
    String date,
    int market,
    String? observationType,
    String? patrol,
    String? segment,
  });
}

/// @nodoc
class __$$CreateCatchRequestImplCopyWithImpl<$Res>
    extends _$CreateCatchRequestCopyWithImpl<$Res, _$CreateCatchRequestImpl>
    implements _$$CreateCatchRequestImplCopyWith<$Res> {
  __$$CreateCatchRequestImplCopyWithImpl(
    _$CreateCatchRequestImpl _value,
    $Res Function(_$CreateCatchRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreateCatchRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? specie = null,
    Object? subgroup = null,
    Object? gearMeshSizeInFinger = null,
    Object? gearLengthInMeter = null,
    Object? gearNature = null,
    Object? waterDepthInMeter = null,
    Object? fishingTimeInHour = null,
    Object? estimatedWeightInKg = null,
    Object? averageSizeInCm = null,
    Object? estimatedSize = null,
    Object? publishedWeightInKg = null,
    Object? pricePerKg = null,
    Object? finalPrice = null,
    Object? publishedInMarketPlace = null,
    Object? note = freezed,
    Object? images = null,
    Object? alpha = freezed,
    Object? dead = null,
    Object? coordX = null,
    Object? coordY = null,
    Object? date = null,
    Object? market = null,
    Object? observationType = freezed,
    Object? patrol = freezed,
    Object? segment = freezed,
  }) {
    return _then(
      _$CreateCatchRequestImpl(
        specie: null == specie
            ? _value.specie
            : specie // ignore: cast_nullable_to_non_nullable
                  as String,
        subgroup: null == subgroup
            ? _value.subgroup
            : subgroup // ignore: cast_nullable_to_non_nullable
                  as String,
        gearMeshSizeInFinger: null == gearMeshSizeInFinger
            ? _value.gearMeshSizeInFinger
            : gearMeshSizeInFinger // ignore: cast_nullable_to_non_nullable
                  as double,
        gearLengthInMeter: null == gearLengthInMeter
            ? _value.gearLengthInMeter
            : gearLengthInMeter // ignore: cast_nullable_to_non_nullable
                  as double,
        gearNature: null == gearNature
            ? _value.gearNature
            : gearNature // ignore: cast_nullable_to_non_nullable
                  as String,
        waterDepthInMeter: null == waterDepthInMeter
            ? _value.waterDepthInMeter
            : waterDepthInMeter // ignore: cast_nullable_to_non_nullable
                  as double,
        fishingTimeInHour: null == fishingTimeInHour
            ? _value.fishingTimeInHour
            : fishingTimeInHour // ignore: cast_nullable_to_non_nullable
                  as double,
        estimatedWeightInKg: null == estimatedWeightInKg
            ? _value.estimatedWeightInKg
            : estimatedWeightInKg // ignore: cast_nullable_to_non_nullable
                  as double,
        averageSizeInCm: null == averageSizeInCm
            ? _value.averageSizeInCm
            : averageSizeInCm // ignore: cast_nullable_to_non_nullable
                  as double,
        estimatedSize: null == estimatedSize
            ? _value.estimatedSize
            : estimatedSize // ignore: cast_nullable_to_non_nullable
                  as int,
        publishedWeightInKg: null == publishedWeightInKg
            ? _value.publishedWeightInKg
            : publishedWeightInKg // ignore: cast_nullable_to_non_nullable
                  as double,
        pricePerKg: null == pricePerKg
            ? _value.pricePerKg
            : pricePerKg // ignore: cast_nullable_to_non_nullable
                  as double,
        finalPrice: null == finalPrice
            ? _value.finalPrice
            : finalPrice // ignore: cast_nullable_to_non_nullable
                  as double,
        publishedInMarketPlace: null == publishedInMarketPlace
            ? _value.publishedInMarketPlace
            : publishedInMarketPlace // ignore: cast_nullable_to_non_nullable
                  as bool,
        note: freezed == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String?,
        images: null == images
            ? _value.images
            : images // ignore: cast_nullable_to_non_nullable
                  as List<CatchImageRequest>,
        alpha: freezed == alpha
            ? _value.alpha
            : alpha // ignore: cast_nullable_to_non_nullable
                  as String?,
        dead: null == dead
            ? _value.dead
            : dead // ignore: cast_nullable_to_non_nullable
                  as bool,
        coordX: null == coordX
            ? _value.coordX
            : coordX // ignore: cast_nullable_to_non_nullable
                  as double,
        coordY: null == coordY
            ? _value.coordY
            : coordY // ignore: cast_nullable_to_non_nullable
                  as double,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as String,
        market: null == market
            ? _value.market
            : market // ignore: cast_nullable_to_non_nullable
                  as int,
        observationType: freezed == observationType
            ? _value.observationType
            : observationType // ignore: cast_nullable_to_non_nullable
                  as String?,
        patrol: freezed == patrol
            ? _value.patrol
            : patrol // ignore: cast_nullable_to_non_nullable
                  as String?,
        segment: freezed == segment
            ? _value.segment
            : segment // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateCatchRequestImpl implements _CreateCatchRequest {
  const _$CreateCatchRequestImpl({
    required this.specie,
    required this.subgroup,
    @JsonKey(name: 'gear_mesh_size_in_finger')
    required this.gearMeshSizeInFinger,
    @JsonKey(name: 'gear_length_in_meter') required this.gearLengthInMeter,
    @JsonKey(name: 'gear_nature') required this.gearNature,
    @JsonKey(name: 'water_depth_in_meter') required this.waterDepthInMeter,
    @JsonKey(name: 'fishing_time_in_hour') required this.fishingTimeInHour,
    @JsonKey(name: 'estimated_weight_in_kg') required this.estimatedWeightInKg,
    @JsonKey(name: 'average_size_in_cm') required this.averageSizeInCm,
    @JsonKey(name: 'estimated_size') required this.estimatedSize,
    @JsonKey(name: 'published_weight_in_kg') required this.publishedWeightInKg,
    @JsonKey(name: 'price_per_kg') required this.pricePerKg,
    @JsonKey(name: 'final_price') required this.finalPrice,
    @JsonKey(name: 'published_in_market_place')
    required this.publishedInMarketPlace,
    this.note,
    required this.images,
    this.alpha,
    required this.dead,
    required this.coordX,
    required this.coordY,
    required this.date,
    required this.market,
    this.observationType,
    this.patrol,
    this.segment,
  });

  factory _$CreateCatchRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateCatchRequestImplFromJson(json);

  @override
  final String specie;
  @override
  final String subgroup;
  @override
  @JsonKey(name: 'gear_mesh_size_in_finger')
  final double gearMeshSizeInFinger;
  @override
  @JsonKey(name: 'gear_length_in_meter')
  final double gearLengthInMeter;
  @override
  @JsonKey(name: 'gear_nature')
  final String gearNature;
  @override
  @JsonKey(name: 'water_depth_in_meter')
  final double waterDepthInMeter;
  @override
  @JsonKey(name: 'fishing_time_in_hour')
  final double fishingTimeInHour;
  @override
  @JsonKey(name: 'estimated_weight_in_kg')
  final double estimatedWeightInKg;
  @override
  @JsonKey(name: 'average_size_in_cm')
  final double averageSizeInCm;
  @override
  @JsonKey(name: 'estimated_size')
  final int estimatedSize;
  @override
  @JsonKey(name: 'published_weight_in_kg')
  final double publishedWeightInKg;
  @override
  @JsonKey(name: 'price_per_kg')
  final double pricePerKg;
  @override
  @JsonKey(name: 'final_price')
  final double finalPrice;
  @override
  @JsonKey(name: 'published_in_market_place')
  final bool publishedInMarketPlace;
  @override
  final String? note;
  @override
  final List<CatchImageRequest> images;
  @override
  final String? alpha;
  @override
  final bool dead;
  @override
  final double coordX;
  @override
  final double coordY;
  @override
  final String date;
  @override
  final int market;
  @override
  final String? observationType;
  @override
  final String? patrol;
  @override
  final String? segment;

  @override
  String toString() {
    return 'CreateCatchRequest(specie: $specie, subgroup: $subgroup, gearMeshSizeInFinger: $gearMeshSizeInFinger, gearLengthInMeter: $gearLengthInMeter, gearNature: $gearNature, waterDepthInMeter: $waterDepthInMeter, fishingTimeInHour: $fishingTimeInHour, estimatedWeightInKg: $estimatedWeightInKg, averageSizeInCm: $averageSizeInCm, estimatedSize: $estimatedSize, publishedWeightInKg: $publishedWeightInKg, pricePerKg: $pricePerKg, finalPrice: $finalPrice, publishedInMarketPlace: $publishedInMarketPlace, note: $note, images: $images, alpha: $alpha, dead: $dead, coordX: $coordX, coordY: $coordY, date: $date, market: $market, observationType: $observationType, patrol: $patrol, segment: $segment)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateCatchRequestImpl &&
            (identical(other.specie, specie) || other.specie == specie) &&
            (identical(other.subgroup, subgroup) ||
                other.subgroup == subgroup) &&
            (identical(other.gearMeshSizeInFinger, gearMeshSizeInFinger) ||
                other.gearMeshSizeInFinger == gearMeshSizeInFinger) &&
            (identical(other.gearLengthInMeter, gearLengthInMeter) ||
                other.gearLengthInMeter == gearLengthInMeter) &&
            (identical(other.gearNature, gearNature) ||
                other.gearNature == gearNature) &&
            (identical(other.waterDepthInMeter, waterDepthInMeter) ||
                other.waterDepthInMeter == waterDepthInMeter) &&
            (identical(other.fishingTimeInHour, fishingTimeInHour) ||
                other.fishingTimeInHour == fishingTimeInHour) &&
            (identical(other.estimatedWeightInKg, estimatedWeightInKg) ||
                other.estimatedWeightInKg == estimatedWeightInKg) &&
            (identical(other.averageSizeInCm, averageSizeInCm) ||
                other.averageSizeInCm == averageSizeInCm) &&
            (identical(other.estimatedSize, estimatedSize) ||
                other.estimatedSize == estimatedSize) &&
            (identical(other.publishedWeightInKg, publishedWeightInKg) ||
                other.publishedWeightInKg == publishedWeightInKg) &&
            (identical(other.pricePerKg, pricePerKg) ||
                other.pricePerKg == pricePerKg) &&
            (identical(other.finalPrice, finalPrice) ||
                other.finalPrice == finalPrice) &&
            (identical(other.publishedInMarketPlace, publishedInMarketPlace) ||
                other.publishedInMarketPlace == publishedInMarketPlace) &&
            (identical(other.note, note) || other.note == note) &&
            const DeepCollectionEquality().equals(other.images, images) &&
            (identical(other.alpha, alpha) || other.alpha == alpha) &&
            (identical(other.dead, dead) || other.dead == dead) &&
            (identical(other.coordX, coordX) || other.coordX == coordX) &&
            (identical(other.coordY, coordY) || other.coordY == coordY) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.market, market) || other.market == market) &&
            (identical(other.observationType, observationType) ||
                other.observationType == observationType) &&
            (identical(other.patrol, patrol) || other.patrol == patrol) &&
            (identical(other.segment, segment) || other.segment == segment));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    specie,
    subgroup,
    gearMeshSizeInFinger,
    gearLengthInMeter,
    gearNature,
    waterDepthInMeter,
    fishingTimeInHour,
    estimatedWeightInKg,
    averageSizeInCm,
    estimatedSize,
    publishedWeightInKg,
    pricePerKg,
    finalPrice,
    publishedInMarketPlace,
    note,
    const DeepCollectionEquality().hash(images),
    alpha,
    dead,
    coordX,
    coordY,
    date,
    market,
    observationType,
    patrol,
    segment,
  ]);

  /// Create a copy of CreateCatchRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateCatchRequestImplCopyWith<_$CreateCatchRequestImpl> get copyWith =>
      __$$CreateCatchRequestImplCopyWithImpl<_$CreateCatchRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateCatchRequestImplToJson(this);
  }
}

abstract class _CreateCatchRequest implements CreateCatchRequest {
  const factory _CreateCatchRequest({
    required final String specie,
    required final String subgroup,
    @JsonKey(name: 'gear_mesh_size_in_finger')
    required final double gearMeshSizeInFinger,
    @JsonKey(name: 'gear_length_in_meter')
    required final double gearLengthInMeter,
    @JsonKey(name: 'gear_nature') required final String gearNature,
    @JsonKey(name: 'water_depth_in_meter')
    required final double waterDepthInMeter,
    @JsonKey(name: 'fishing_time_in_hour')
    required final double fishingTimeInHour,
    @JsonKey(name: 'estimated_weight_in_kg')
    required final double estimatedWeightInKg,
    @JsonKey(name: 'average_size_in_cm') required final double averageSizeInCm,
    @JsonKey(name: 'estimated_size') required final int estimatedSize,
    @JsonKey(name: 'published_weight_in_kg')
    required final double publishedWeightInKg,
    @JsonKey(name: 'price_per_kg') required final double pricePerKg,
    @JsonKey(name: 'final_price') required final double finalPrice,
    @JsonKey(name: 'published_in_market_place')
    required final bool publishedInMarketPlace,
    final String? note,
    required final List<CatchImageRequest> images,
    final String? alpha,
    required final bool dead,
    required final double coordX,
    required final double coordY,
    required final String date,
    required final int market,
    final String? observationType,
    final String? patrol,
    final String? segment,
  }) = _$CreateCatchRequestImpl;

  factory _CreateCatchRequest.fromJson(Map<String, dynamic> json) =
      _$CreateCatchRequestImpl.fromJson;

  @override
  String get specie;
  @override
  String get subgroup;
  @override
  @JsonKey(name: 'gear_mesh_size_in_finger')
  double get gearMeshSizeInFinger;
  @override
  @JsonKey(name: 'gear_length_in_meter')
  double get gearLengthInMeter;
  @override
  @JsonKey(name: 'gear_nature')
  String get gearNature;
  @override
  @JsonKey(name: 'water_depth_in_meter')
  double get waterDepthInMeter;
  @override
  @JsonKey(name: 'fishing_time_in_hour')
  double get fishingTimeInHour;
  @override
  @JsonKey(name: 'estimated_weight_in_kg')
  double get estimatedWeightInKg;
  @override
  @JsonKey(name: 'average_size_in_cm')
  double get averageSizeInCm;
  @override
  @JsonKey(name: 'estimated_size')
  int get estimatedSize;
  @override
  @JsonKey(name: 'published_weight_in_kg')
  double get publishedWeightInKg;
  @override
  @JsonKey(name: 'price_per_kg')
  double get pricePerKg;
  @override
  @JsonKey(name: 'final_price')
  double get finalPrice;
  @override
  @JsonKey(name: 'published_in_market_place')
  bool get publishedInMarketPlace;
  @override
  String? get note;
  @override
  List<CatchImageRequest> get images;
  @override
  String? get alpha;
  @override
  bool get dead;
  @override
  double get coordX;
  @override
  double get coordY;
  @override
  String get date;
  @override
  int get market;
  @override
  String? get observationType;
  @override
  String? get patrol;
  @override
  String? get segment;

  /// Create a copy of CreateCatchRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateCatchRequestImplCopyWith<_$CreateCatchRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
