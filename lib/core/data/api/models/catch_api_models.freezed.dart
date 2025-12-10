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

CatchApiModel _$CatchApiModelFromJson(Map<String, dynamic> json) {
  return _CatchApiModel.fromJson(json);
}

/// @nodoc
mixin _$CatchApiModel {
  dynamic get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'initial_weight_grams')
  int? get initialWeightGrams => throw _privateConstructorUsedError;
  @JsonKey(name: 'available_weight_grams')
  int? get availableWeightGrams => throw _privateConstructorUsedError;
  @JsonKey(name: 'price_per_kg_amount')
  int? get pricePerKgAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_price_amount')
  int? get totalPriceAmount => throw _privateConstructorUsedError;
  String? get size => throw _privateConstructorUsedError;
  List<String> get images => throw _privateConstructorUsedError;
  SpeciesModel? get species => throw _privateConstructorUsedError;
  AccountApiModel? get fisher => throw _privateConstructorUsedError;
  String? get market => throw _privateConstructorUsedError;
  String? get status =>
      throw _privateConstructorUsedError; // available, sold, etc.
  @JsonKey(name: 'created_at')
  String? get createdAt => throw _privateConstructorUsedError; // Location data
  @JsonKey(name: 'observation_id')
  String? get observationId => throw _privateConstructorUsedError;
  @JsonKey(name: 'location_name')
  String? get locationName => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude =>
      throw _privateConstructorUsedError; // Gear and fishing data
  @JsonKey(name: 'mesh_size')
  double? get meshSize => throw _privateConstructorUsedError;
  @JsonKey(name: 'gear_length')
  double? get gearLength => throw _privateConstructorUsedError;
  @JsonKey(name: 'gear_width')
  double? get gearWidth => throw _privateConstructorUsedError;
  @JsonKey(name: 'gear_nature')
  String? get gearNature => throw _privateConstructorUsedError;
  @JsonKey(name: 'water_depth')
  double? get waterDepth => throw _privateConstructorUsedError;
  @JsonKey(name: 'fishing_time')
  double? get fishingTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'number_of_shrimps')
  int? get numberOfShrimps => throw _privateConstructorUsedError;

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
    String? name,
    @JsonKey(name: 'initial_weight_grams') int? initialWeightGrams,
    @JsonKey(name: 'available_weight_grams') int? availableWeightGrams,
    @JsonKey(name: 'price_per_kg_amount') int? pricePerKgAmount,
    @JsonKey(name: 'total_price_amount') int? totalPriceAmount,
    String? size,
    List<String> images,
    SpeciesModel? species,
    AccountApiModel? fisher,
    String? market,
    String? status,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'observation_id') String? observationId,
    @JsonKey(name: 'location_name') String? locationName,
    double? latitude,
    double? longitude,
    @JsonKey(name: 'mesh_size') double? meshSize,
    @JsonKey(name: 'gear_length') double? gearLength,
    @JsonKey(name: 'gear_width') double? gearWidth,
    @JsonKey(name: 'gear_nature') String? gearNature,
    @JsonKey(name: 'water_depth') double? waterDepth,
    @JsonKey(name: 'fishing_time') double? fishingTime,
    @JsonKey(name: 'number_of_shrimps') int? numberOfShrimps,
  });

  $AccountApiModelCopyWith<$Res>? get fisher;
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
    Object? name = freezed,
    Object? initialWeightGrams = freezed,
    Object? availableWeightGrams = freezed,
    Object? pricePerKgAmount = freezed,
    Object? totalPriceAmount = freezed,
    Object? size = freezed,
    Object? images = null,
    Object? species = freezed,
    Object? fisher = freezed,
    Object? market = freezed,
    Object? status = freezed,
    Object? createdAt = freezed,
    Object? observationId = freezed,
    Object? locationName = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? meshSize = freezed,
    Object? gearLength = freezed,
    Object? gearWidth = freezed,
    Object? gearNature = freezed,
    Object? waterDepth = freezed,
    Object? fishingTime = freezed,
    Object? numberOfShrimps = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String?,
            initialWeightGrams: freezed == initialWeightGrams
                ? _value.initialWeightGrams
                : initialWeightGrams // ignore: cast_nullable_to_non_nullable
                      as int?,
            availableWeightGrams: freezed == availableWeightGrams
                ? _value.availableWeightGrams
                : availableWeightGrams // ignore: cast_nullable_to_non_nullable
                      as int?,
            pricePerKgAmount: freezed == pricePerKgAmount
                ? _value.pricePerKgAmount
                : pricePerKgAmount // ignore: cast_nullable_to_non_nullable
                      as int?,
            totalPriceAmount: freezed == totalPriceAmount
                ? _value.totalPriceAmount
                : totalPriceAmount // ignore: cast_nullable_to_non_nullable
                      as int?,
            size: freezed == size
                ? _value.size
                : size // ignore: cast_nullable_to_non_nullable
                      as String?,
            images: null == images
                ? _value.images
                : images // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            species: freezed == species
                ? _value.species
                : species // ignore: cast_nullable_to_non_nullable
                      as SpeciesModel?,
            fisher: freezed == fisher
                ? _value.fisher
                : fisher // ignore: cast_nullable_to_non_nullable
                      as AccountApiModel?,
            market: freezed == market
                ? _value.market
                : market // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            observationId: freezed == observationId
                ? _value.observationId
                : observationId // ignore: cast_nullable_to_non_nullable
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
            meshSize: freezed == meshSize
                ? _value.meshSize
                : meshSize // ignore: cast_nullable_to_non_nullable
                      as double?,
            gearLength: freezed == gearLength
                ? _value.gearLength
                : gearLength // ignore: cast_nullable_to_non_nullable
                      as double?,
            gearWidth: freezed == gearWidth
                ? _value.gearWidth
                : gearWidth // ignore: cast_nullable_to_non_nullable
                      as double?,
            gearNature: freezed == gearNature
                ? _value.gearNature
                : gearNature // ignore: cast_nullable_to_non_nullable
                      as String?,
            waterDepth: freezed == waterDepth
                ? _value.waterDepth
                : waterDepth // ignore: cast_nullable_to_non_nullable
                      as double?,
            fishingTime: freezed == fishingTime
                ? _value.fishingTime
                : fishingTime // ignore: cast_nullable_to_non_nullable
                      as double?,
            numberOfShrimps: freezed == numberOfShrimps
                ? _value.numberOfShrimps
                : numberOfShrimps // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }

  /// Create a copy of CatchApiModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AccountApiModelCopyWith<$Res>? get fisher {
    if (_value.fisher == null) {
      return null;
    }

    return $AccountApiModelCopyWith<$Res>(_value.fisher!, (value) {
      return _then(_value.copyWith(fisher: value) as $Val);
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
    String? name,
    @JsonKey(name: 'initial_weight_grams') int? initialWeightGrams,
    @JsonKey(name: 'available_weight_grams') int? availableWeightGrams,
    @JsonKey(name: 'price_per_kg_amount') int? pricePerKgAmount,
    @JsonKey(name: 'total_price_amount') int? totalPriceAmount,
    String? size,
    List<String> images,
    SpeciesModel? species,
    AccountApiModel? fisher,
    String? market,
    String? status,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'observation_id') String? observationId,
    @JsonKey(name: 'location_name') String? locationName,
    double? latitude,
    double? longitude,
    @JsonKey(name: 'mesh_size') double? meshSize,
    @JsonKey(name: 'gear_length') double? gearLength,
    @JsonKey(name: 'gear_width') double? gearWidth,
    @JsonKey(name: 'gear_nature') String? gearNature,
    @JsonKey(name: 'water_depth') double? waterDepth,
    @JsonKey(name: 'fishing_time') double? fishingTime,
    @JsonKey(name: 'number_of_shrimps') int? numberOfShrimps,
  });

  @override
  $AccountApiModelCopyWith<$Res>? get fisher;
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
    Object? name = freezed,
    Object? initialWeightGrams = freezed,
    Object? availableWeightGrams = freezed,
    Object? pricePerKgAmount = freezed,
    Object? totalPriceAmount = freezed,
    Object? size = freezed,
    Object? images = null,
    Object? species = freezed,
    Object? fisher = freezed,
    Object? market = freezed,
    Object? status = freezed,
    Object? createdAt = freezed,
    Object? observationId = freezed,
    Object? locationName = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? meshSize = freezed,
    Object? gearLength = freezed,
    Object? gearWidth = freezed,
    Object? gearNature = freezed,
    Object? waterDepth = freezed,
    Object? fishingTime = freezed,
    Object? numberOfShrimps = freezed,
  }) {
    return _then(
      _$CatchApiModelImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        initialWeightGrams: freezed == initialWeightGrams
            ? _value.initialWeightGrams
            : initialWeightGrams // ignore: cast_nullable_to_non_nullable
                  as int?,
        availableWeightGrams: freezed == availableWeightGrams
            ? _value.availableWeightGrams
            : availableWeightGrams // ignore: cast_nullable_to_non_nullable
                  as int?,
        pricePerKgAmount: freezed == pricePerKgAmount
            ? _value.pricePerKgAmount
            : pricePerKgAmount // ignore: cast_nullable_to_non_nullable
                  as int?,
        totalPriceAmount: freezed == totalPriceAmount
            ? _value.totalPriceAmount
            : totalPriceAmount // ignore: cast_nullable_to_non_nullable
                  as int?,
        size: freezed == size
            ? _value.size
            : size // ignore: cast_nullable_to_non_nullable
                  as String?,
        images: null == images
            ? _value._images
            : images // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        species: freezed == species
            ? _value.species
            : species // ignore: cast_nullable_to_non_nullable
                  as SpeciesModel?,
        fisher: freezed == fisher
            ? _value.fisher
            : fisher // ignore: cast_nullable_to_non_nullable
                  as AccountApiModel?,
        market: freezed == market
            ? _value.market
            : market // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        observationId: freezed == observationId
            ? _value.observationId
            : observationId // ignore: cast_nullable_to_non_nullable
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
        meshSize: freezed == meshSize
            ? _value.meshSize
            : meshSize // ignore: cast_nullable_to_non_nullable
                  as double?,
        gearLength: freezed == gearLength
            ? _value.gearLength
            : gearLength // ignore: cast_nullable_to_non_nullable
                  as double?,
        gearWidth: freezed == gearWidth
            ? _value.gearWidth
            : gearWidth // ignore: cast_nullable_to_non_nullable
                  as double?,
        gearNature: freezed == gearNature
            ? _value.gearNature
            : gearNature // ignore: cast_nullable_to_non_nullable
                  as String?,
        waterDepth: freezed == waterDepth
            ? _value.waterDepth
            : waterDepth // ignore: cast_nullable_to_non_nullable
                  as double?,
        fishingTime: freezed == fishingTime
            ? _value.fishingTime
            : fishingTime // ignore: cast_nullable_to_non_nullable
                  as double?,
        numberOfShrimps: freezed == numberOfShrimps
            ? _value.numberOfShrimps
            : numberOfShrimps // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CatchApiModelImpl implements _CatchApiModel {
  const _$CatchApiModelImpl({
    required this.id,
    this.name,
    @JsonKey(name: 'initial_weight_grams') this.initialWeightGrams,
    @JsonKey(name: 'available_weight_grams') this.availableWeightGrams,
    @JsonKey(name: 'price_per_kg_amount') this.pricePerKgAmount,
    @JsonKey(name: 'total_price_amount') this.totalPriceAmount,
    this.size,
    final List<String> images = const [],
    this.species,
    this.fisher,
    this.market,
    this.status,
    @JsonKey(name: 'created_at') this.createdAt,
    @JsonKey(name: 'observation_id') this.observationId,
    @JsonKey(name: 'location_name') this.locationName,
    this.latitude,
    this.longitude,
    @JsonKey(name: 'mesh_size') this.meshSize,
    @JsonKey(name: 'gear_length') this.gearLength,
    @JsonKey(name: 'gear_width') this.gearWidth,
    @JsonKey(name: 'gear_nature') this.gearNature,
    @JsonKey(name: 'water_depth') this.waterDepth,
    @JsonKey(name: 'fishing_time') this.fishingTime,
    @JsonKey(name: 'number_of_shrimps') this.numberOfShrimps,
  }) : _images = images;

  factory _$CatchApiModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CatchApiModelImplFromJson(json);

  @override
  final dynamic id;
  @override
  final String? name;
  @override
  @JsonKey(name: 'initial_weight_grams')
  final int? initialWeightGrams;
  @override
  @JsonKey(name: 'available_weight_grams')
  final int? availableWeightGrams;
  @override
  @JsonKey(name: 'price_per_kg_amount')
  final int? pricePerKgAmount;
  @override
  @JsonKey(name: 'total_price_amount')
  final int? totalPriceAmount;
  @override
  final String? size;
  final List<String> _images;
  @override
  @JsonKey()
  List<String> get images {
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_images);
  }

  @override
  final SpeciesModel? species;
  @override
  final AccountApiModel? fisher;
  @override
  final String? market;
  @override
  final String? status;
  // available, sold, etc.
  @override
  @JsonKey(name: 'created_at')
  final String? createdAt;
  // Location data
  @override
  @JsonKey(name: 'observation_id')
  final String? observationId;
  @override
  @JsonKey(name: 'location_name')
  final String? locationName;
  @override
  final double? latitude;
  @override
  final double? longitude;
  // Gear and fishing data
  @override
  @JsonKey(name: 'mesh_size')
  final double? meshSize;
  @override
  @JsonKey(name: 'gear_length')
  final double? gearLength;
  @override
  @JsonKey(name: 'gear_width')
  final double? gearWidth;
  @override
  @JsonKey(name: 'gear_nature')
  final String? gearNature;
  @override
  @JsonKey(name: 'water_depth')
  final double? waterDepth;
  @override
  @JsonKey(name: 'fishing_time')
  final double? fishingTime;
  @override
  @JsonKey(name: 'number_of_shrimps')
  final int? numberOfShrimps;

  @override
  String toString() {
    return 'CatchApiModel(id: $id, name: $name, initialWeightGrams: $initialWeightGrams, availableWeightGrams: $availableWeightGrams, pricePerKgAmount: $pricePerKgAmount, totalPriceAmount: $totalPriceAmount, size: $size, images: $images, species: $species, fisher: $fisher, market: $market, status: $status, createdAt: $createdAt, observationId: $observationId, locationName: $locationName, latitude: $latitude, longitude: $longitude, meshSize: $meshSize, gearLength: $gearLength, gearWidth: $gearWidth, gearNature: $gearNature, waterDepth: $waterDepth, fishingTime: $fishingTime, numberOfShrimps: $numberOfShrimps)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CatchApiModelImpl &&
            const DeepCollectionEquality().equals(other.id, id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.initialWeightGrams, initialWeightGrams) ||
                other.initialWeightGrams == initialWeightGrams) &&
            (identical(other.availableWeightGrams, availableWeightGrams) ||
                other.availableWeightGrams == availableWeightGrams) &&
            (identical(other.pricePerKgAmount, pricePerKgAmount) ||
                other.pricePerKgAmount == pricePerKgAmount) &&
            (identical(other.totalPriceAmount, totalPriceAmount) ||
                other.totalPriceAmount == totalPriceAmount) &&
            (identical(other.size, size) || other.size == size) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            (identical(other.species, species) || other.species == species) &&
            (identical(other.fisher, fisher) || other.fisher == fisher) &&
            (identical(other.market, market) || other.market == market) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.observationId, observationId) ||
                other.observationId == observationId) &&
            (identical(other.locationName, locationName) ||
                other.locationName == locationName) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.meshSize, meshSize) ||
                other.meshSize == meshSize) &&
            (identical(other.gearLength, gearLength) ||
                other.gearLength == gearLength) &&
            (identical(other.gearWidth, gearWidth) ||
                other.gearWidth == gearWidth) &&
            (identical(other.gearNature, gearNature) ||
                other.gearNature == gearNature) &&
            (identical(other.waterDepth, waterDepth) ||
                other.waterDepth == waterDepth) &&
            (identical(other.fishingTime, fishingTime) ||
                other.fishingTime == fishingTime) &&
            (identical(other.numberOfShrimps, numberOfShrimps) ||
                other.numberOfShrimps == numberOfShrimps));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    const DeepCollectionEquality().hash(id),
    name,
    initialWeightGrams,
    availableWeightGrams,
    pricePerKgAmount,
    totalPriceAmount,
    size,
    const DeepCollectionEquality().hash(_images),
    species,
    fisher,
    market,
    status,
    createdAt,
    observationId,
    locationName,
    latitude,
    longitude,
    meshSize,
    gearLength,
    gearWidth,
    gearNature,
    waterDepth,
    fishingTime,
    numberOfShrimps,
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
    final String? name,
    @JsonKey(name: 'initial_weight_grams') final int? initialWeightGrams,
    @JsonKey(name: 'available_weight_grams') final int? availableWeightGrams,
    @JsonKey(name: 'price_per_kg_amount') final int? pricePerKgAmount,
    @JsonKey(name: 'total_price_amount') final int? totalPriceAmount,
    final String? size,
    final List<String> images,
    final SpeciesModel? species,
    final AccountApiModel? fisher,
    final String? market,
    final String? status,
    @JsonKey(name: 'created_at') final String? createdAt,
    @JsonKey(name: 'observation_id') final String? observationId,
    @JsonKey(name: 'location_name') final String? locationName,
    final double? latitude,
    final double? longitude,
    @JsonKey(name: 'mesh_size') final double? meshSize,
    @JsonKey(name: 'gear_length') final double? gearLength,
    @JsonKey(name: 'gear_width') final double? gearWidth,
    @JsonKey(name: 'gear_nature') final String? gearNature,
    @JsonKey(name: 'water_depth') final double? waterDepth,
    @JsonKey(name: 'fishing_time') final double? fishingTime,
    @JsonKey(name: 'number_of_shrimps') final int? numberOfShrimps,
  }) = _$CatchApiModelImpl;

  factory _CatchApiModel.fromJson(Map<String, dynamic> json) =
      _$CatchApiModelImpl.fromJson;

  @override
  dynamic get id;
  @override
  String? get name;
  @override
  @JsonKey(name: 'initial_weight_grams')
  int? get initialWeightGrams;
  @override
  @JsonKey(name: 'available_weight_grams')
  int? get availableWeightGrams;
  @override
  @JsonKey(name: 'price_per_kg_amount')
  int? get pricePerKgAmount;
  @override
  @JsonKey(name: 'total_price_amount')
  int? get totalPriceAmount;
  @override
  String? get size;
  @override
  List<String> get images;
  @override
  SpeciesModel? get species;
  @override
  AccountApiModel? get fisher;
  @override
  String? get market;
  @override
  String? get status; // available, sold, etc.
  @override
  @JsonKey(name: 'created_at')
  String? get createdAt; // Location data
  @override
  @JsonKey(name: 'observation_id')
  String? get observationId;
  @override
  @JsonKey(name: 'location_name')
  String? get locationName;
  @override
  double? get latitude;
  @override
  double? get longitude; // Gear and fishing data
  @override
  @JsonKey(name: 'mesh_size')
  double? get meshSize;
  @override
  @JsonKey(name: 'gear_length')
  double? get gearLength;
  @override
  @JsonKey(name: 'gear_width')
  double? get gearWidth;
  @override
  @JsonKey(name: 'gear_nature')
  String? get gearNature;
  @override
  @JsonKey(name: 'water_depth')
  double? get waterDepth;
  @override
  @JsonKey(name: 'fishing_time')
  double? get fishingTime;
  @override
  @JsonKey(name: 'number_of_shrimps')
  int? get numberOfShrimps;

  /// Create a copy of CatchApiModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CatchApiModelImplCopyWith<_$CatchApiModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateCatchRequest _$CreateCatchRequestFromJson(Map<String, dynamic> json) {
  return _CreateCatchRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateCatchRequest {
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'initial_weight_grams')
  int get initialWeightGrams => throw _privateConstructorUsedError;
  @JsonKey(name: 'price_per_kg_amount')
  int get pricePerKgAmount => throw _privateConstructorUsedError;
  String get size => throw _privateConstructorUsedError;
  @JsonKey(name: 'species_id')
  String get speciesId => throw _privateConstructorUsedError;
  String get market => throw _privateConstructorUsedError;
  List<String>? get images => throw _privateConstructorUsedError;

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
    String name,
    @JsonKey(name: 'initial_weight_grams') int initialWeightGrams,
    @JsonKey(name: 'price_per_kg_amount') int pricePerKgAmount,
    String size,
    @JsonKey(name: 'species_id') String speciesId,
    String market,
    List<String>? images,
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
    Object? name = null,
    Object? initialWeightGrams = null,
    Object? pricePerKgAmount = null,
    Object? size = null,
    Object? speciesId = null,
    Object? market = null,
    Object? images = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            initialWeightGrams: null == initialWeightGrams
                ? _value.initialWeightGrams
                : initialWeightGrams // ignore: cast_nullable_to_non_nullable
                      as int,
            pricePerKgAmount: null == pricePerKgAmount
                ? _value.pricePerKgAmount
                : pricePerKgAmount // ignore: cast_nullable_to_non_nullable
                      as int,
            size: null == size
                ? _value.size
                : size // ignore: cast_nullable_to_non_nullable
                      as String,
            speciesId: null == speciesId
                ? _value.speciesId
                : speciesId // ignore: cast_nullable_to_non_nullable
                      as String,
            market: null == market
                ? _value.market
                : market // ignore: cast_nullable_to_non_nullable
                      as String,
            images: freezed == images
                ? _value.images
                : images // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
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
    String name,
    @JsonKey(name: 'initial_weight_grams') int initialWeightGrams,
    @JsonKey(name: 'price_per_kg_amount') int pricePerKgAmount,
    String size,
    @JsonKey(name: 'species_id') String speciesId,
    String market,
    List<String>? images,
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
    Object? name = null,
    Object? initialWeightGrams = null,
    Object? pricePerKgAmount = null,
    Object? size = null,
    Object? speciesId = null,
    Object? market = null,
    Object? images = freezed,
  }) {
    return _then(
      _$CreateCatchRequestImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        initialWeightGrams: null == initialWeightGrams
            ? _value.initialWeightGrams
            : initialWeightGrams // ignore: cast_nullable_to_non_nullable
                  as int,
        pricePerKgAmount: null == pricePerKgAmount
            ? _value.pricePerKgAmount
            : pricePerKgAmount // ignore: cast_nullable_to_non_nullable
                  as int,
        size: null == size
            ? _value.size
            : size // ignore: cast_nullable_to_non_nullable
                  as String,
        speciesId: null == speciesId
            ? _value.speciesId
            : speciesId // ignore: cast_nullable_to_non_nullable
                  as String,
        market: null == market
            ? _value.market
            : market // ignore: cast_nullable_to_non_nullable
                  as String,
        images: freezed == images
            ? _value._images
            : images // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateCatchRequestImpl implements _CreateCatchRequest {
  const _$CreateCatchRequestImpl({
    required this.name,
    @JsonKey(name: 'initial_weight_grams') required this.initialWeightGrams,
    @JsonKey(name: 'price_per_kg_amount') required this.pricePerKgAmount,
    required this.size,
    @JsonKey(name: 'species_id') required this.speciesId,
    required this.market,
    final List<String>? images,
  }) : _images = images;

  factory _$CreateCatchRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateCatchRequestImplFromJson(json);

  @override
  final String name;
  @override
  @JsonKey(name: 'initial_weight_grams')
  final int initialWeightGrams;
  @override
  @JsonKey(name: 'price_per_kg_amount')
  final int pricePerKgAmount;
  @override
  final String size;
  @override
  @JsonKey(name: 'species_id')
  final String speciesId;
  @override
  final String market;
  final List<String>? _images;
  @override
  List<String>? get images {
    final value = _images;
    if (value == null) return null;
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'CreateCatchRequest(name: $name, initialWeightGrams: $initialWeightGrams, pricePerKgAmount: $pricePerKgAmount, size: $size, speciesId: $speciesId, market: $market, images: $images)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateCatchRequestImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.initialWeightGrams, initialWeightGrams) ||
                other.initialWeightGrams == initialWeightGrams) &&
            (identical(other.pricePerKgAmount, pricePerKgAmount) ||
                other.pricePerKgAmount == pricePerKgAmount) &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.speciesId, speciesId) ||
                other.speciesId == speciesId) &&
            (identical(other.market, market) || other.market == market) &&
            const DeepCollectionEquality().equals(other._images, _images));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    initialWeightGrams,
    pricePerKgAmount,
    size,
    speciesId,
    market,
    const DeepCollectionEquality().hash(_images),
  );

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
    required final String name,
    @JsonKey(name: 'initial_weight_grams')
    required final int initialWeightGrams,
    @JsonKey(name: 'price_per_kg_amount') required final int pricePerKgAmount,
    required final String size,
    @JsonKey(name: 'species_id') required final String speciesId,
    required final String market,
    final List<String>? images,
  }) = _$CreateCatchRequestImpl;

  factory _CreateCatchRequest.fromJson(Map<String, dynamic> json) =
      _$CreateCatchRequestImpl.fromJson;

  @override
  String get name;
  @override
  @JsonKey(name: 'initial_weight_grams')
  int get initialWeightGrams;
  @override
  @JsonKey(name: 'price_per_kg_amount')
  int get pricePerKgAmount;
  @override
  String get size;
  @override
  @JsonKey(name: 'species_id')
  String get speciesId;
  @override
  String get market;
  @override
  List<String>? get images;

  /// Create a copy of CreateCatchRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateCatchRequestImplCopyWith<_$CreateCatchRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
