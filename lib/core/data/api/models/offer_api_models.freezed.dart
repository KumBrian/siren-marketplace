// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'offer_api_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

OfferApiModel _$OfferApiModelFromJson(Map<String, dynamic> json) {
  return _OfferApiModel.fromJson(json);
}

/// @nodoc
mixin _$OfferApiModel {
  dynamic get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'catch_id')
  dynamic get catchId => throw _privateConstructorUsedError; // ID or object? Assume object if expanded
  @JsonKey(name: 'fisher_id')
  dynamic get fisherId => throw _privateConstructorUsedError;
  @JsonKey(name: 'buyer_id')
  dynamic get buyerId => throw _privateConstructorUsedError; // Or full objects if API returns them
  CatchApiModel? get catchDetails => throw _privateConstructorUsedError;
  AccountApiModel? get fisher => throw _privateConstructorUsedError;
  AccountApiModel? get buyer => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_price_amount')
  int? get currentPriceAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_weight_grams')
  int? get currentWeightGrams => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_price_per_kg_amount')
  int? get currentPricePerKgAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'previous_price_amount')
  int? get previousPriceAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'previous_weight_grams')
  int? get previousWeightGrams => throw _privateConstructorUsedError;
  @JsonKey(name: 'previous_price_per_kg_amount')
  int? get previousPricePerKgAmount => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  String? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this OfferApiModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OfferApiModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OfferApiModelCopyWith<OfferApiModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OfferApiModelCopyWith<$Res> {
  factory $OfferApiModelCopyWith(
    OfferApiModel value,
    $Res Function(OfferApiModel) then,
  ) = _$OfferApiModelCopyWithImpl<$Res, OfferApiModel>;
  @useResult
  $Res call({
    dynamic id,
    @JsonKey(name: 'catch_id') dynamic catchId,
    @JsonKey(name: 'fisher_id') dynamic fisherId,
    @JsonKey(name: 'buyer_id') dynamic buyerId,
    CatchApiModel? catchDetails,
    AccountApiModel? fisher,
    AccountApiModel? buyer,
    @JsonKey(name: 'current_price_amount') int? currentPriceAmount,
    @JsonKey(name: 'current_weight_grams') int? currentWeightGrams,
    @JsonKey(name: 'current_price_per_kg_amount') int? currentPricePerKgAmount,
    @JsonKey(name: 'previous_price_amount') int? previousPriceAmount,
    @JsonKey(name: 'previous_weight_grams') int? previousWeightGrams,
    @JsonKey(name: 'previous_price_per_kg_amount')
    int? previousPricePerKgAmount,
    String? status,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  });

  $CatchApiModelCopyWith<$Res>? get catchDetails;
  $AccountApiModelCopyWith<$Res>? get fisher;
  $AccountApiModelCopyWith<$Res>? get buyer;
}

/// @nodoc
class _$OfferApiModelCopyWithImpl<$Res, $Val extends OfferApiModel>
    implements $OfferApiModelCopyWith<$Res> {
  _$OfferApiModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OfferApiModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? catchId = freezed,
    Object? fisherId = freezed,
    Object? buyerId = freezed,
    Object? catchDetails = freezed,
    Object? fisher = freezed,
    Object? buyer = freezed,
    Object? currentPriceAmount = freezed,
    Object? currentWeightGrams = freezed,
    Object? currentPricePerKgAmount = freezed,
    Object? previousPriceAmount = freezed,
    Object? previousWeightGrams = freezed,
    Object? previousPricePerKgAmount = freezed,
    Object? status = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            catchId: freezed == catchId
                ? _value.catchId
                : catchId // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            fisherId: freezed == fisherId
                ? _value.fisherId
                : fisherId // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            buyerId: freezed == buyerId
                ? _value.buyerId
                : buyerId // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            catchDetails: freezed == catchDetails
                ? _value.catchDetails
                : catchDetails // ignore: cast_nullable_to_non_nullable
                      as CatchApiModel?,
            fisher: freezed == fisher
                ? _value.fisher
                : fisher // ignore: cast_nullable_to_non_nullable
                      as AccountApiModel?,
            buyer: freezed == buyer
                ? _value.buyer
                : buyer // ignore: cast_nullable_to_non_nullable
                      as AccountApiModel?,
            currentPriceAmount: freezed == currentPriceAmount
                ? _value.currentPriceAmount
                : currentPriceAmount // ignore: cast_nullable_to_non_nullable
                      as int?,
            currentWeightGrams: freezed == currentWeightGrams
                ? _value.currentWeightGrams
                : currentWeightGrams // ignore: cast_nullable_to_non_nullable
                      as int?,
            currentPricePerKgAmount: freezed == currentPricePerKgAmount
                ? _value.currentPricePerKgAmount
                : currentPricePerKgAmount // ignore: cast_nullable_to_non_nullable
                      as int?,
            previousPriceAmount: freezed == previousPriceAmount
                ? _value.previousPriceAmount
                : previousPriceAmount // ignore: cast_nullable_to_non_nullable
                      as int?,
            previousWeightGrams: freezed == previousWeightGrams
                ? _value.previousWeightGrams
                : previousWeightGrams // ignore: cast_nullable_to_non_nullable
                      as int?,
            previousPricePerKgAmount: freezed == previousPricePerKgAmount
                ? _value.previousPricePerKgAmount
                : previousPricePerKgAmount // ignore: cast_nullable_to_non_nullable
                      as int?,
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of OfferApiModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CatchApiModelCopyWith<$Res>? get catchDetails {
    if (_value.catchDetails == null) {
      return null;
    }

    return $CatchApiModelCopyWith<$Res>(_value.catchDetails!, (value) {
      return _then(_value.copyWith(catchDetails: value) as $Val);
    });
  }

  /// Create a copy of OfferApiModel
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

  /// Create a copy of OfferApiModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AccountApiModelCopyWith<$Res>? get buyer {
    if (_value.buyer == null) {
      return null;
    }

    return $AccountApiModelCopyWith<$Res>(_value.buyer!, (value) {
      return _then(_value.copyWith(buyer: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$OfferApiModelImplCopyWith<$Res>
    implements $OfferApiModelCopyWith<$Res> {
  factory _$$OfferApiModelImplCopyWith(
    _$OfferApiModelImpl value,
    $Res Function(_$OfferApiModelImpl) then,
  ) = __$$OfferApiModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    dynamic id,
    @JsonKey(name: 'catch_id') dynamic catchId,
    @JsonKey(name: 'fisher_id') dynamic fisherId,
    @JsonKey(name: 'buyer_id') dynamic buyerId,
    CatchApiModel? catchDetails,
    AccountApiModel? fisher,
    AccountApiModel? buyer,
    @JsonKey(name: 'current_price_amount') int? currentPriceAmount,
    @JsonKey(name: 'current_weight_grams') int? currentWeightGrams,
    @JsonKey(name: 'current_price_per_kg_amount') int? currentPricePerKgAmount,
    @JsonKey(name: 'previous_price_amount') int? previousPriceAmount,
    @JsonKey(name: 'previous_weight_grams') int? previousWeightGrams,
    @JsonKey(name: 'previous_price_per_kg_amount')
    int? previousPricePerKgAmount,
    String? status,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  });

  @override
  $CatchApiModelCopyWith<$Res>? get catchDetails;
  @override
  $AccountApiModelCopyWith<$Res>? get fisher;
  @override
  $AccountApiModelCopyWith<$Res>? get buyer;
}

/// @nodoc
class __$$OfferApiModelImplCopyWithImpl<$Res>
    extends _$OfferApiModelCopyWithImpl<$Res, _$OfferApiModelImpl>
    implements _$$OfferApiModelImplCopyWith<$Res> {
  __$$OfferApiModelImplCopyWithImpl(
    _$OfferApiModelImpl _value,
    $Res Function(_$OfferApiModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OfferApiModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? catchId = freezed,
    Object? fisherId = freezed,
    Object? buyerId = freezed,
    Object? catchDetails = freezed,
    Object? fisher = freezed,
    Object? buyer = freezed,
    Object? currentPriceAmount = freezed,
    Object? currentWeightGrams = freezed,
    Object? currentPricePerKgAmount = freezed,
    Object? previousPriceAmount = freezed,
    Object? previousWeightGrams = freezed,
    Object? previousPricePerKgAmount = freezed,
    Object? status = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$OfferApiModelImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        catchId: freezed == catchId
            ? _value.catchId
            : catchId // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        fisherId: freezed == fisherId
            ? _value.fisherId
            : fisherId // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        buyerId: freezed == buyerId
            ? _value.buyerId
            : buyerId // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        catchDetails: freezed == catchDetails
            ? _value.catchDetails
            : catchDetails // ignore: cast_nullable_to_non_nullable
                  as CatchApiModel?,
        fisher: freezed == fisher
            ? _value.fisher
            : fisher // ignore: cast_nullable_to_non_nullable
                  as AccountApiModel?,
        buyer: freezed == buyer
            ? _value.buyer
            : buyer // ignore: cast_nullable_to_non_nullable
                  as AccountApiModel?,
        currentPriceAmount: freezed == currentPriceAmount
            ? _value.currentPriceAmount
            : currentPriceAmount // ignore: cast_nullable_to_non_nullable
                  as int?,
        currentWeightGrams: freezed == currentWeightGrams
            ? _value.currentWeightGrams
            : currentWeightGrams // ignore: cast_nullable_to_non_nullable
                  as int?,
        currentPricePerKgAmount: freezed == currentPricePerKgAmount
            ? _value.currentPricePerKgAmount
            : currentPricePerKgAmount // ignore: cast_nullable_to_non_nullable
                  as int?,
        previousPriceAmount: freezed == previousPriceAmount
            ? _value.previousPriceAmount
            : previousPriceAmount // ignore: cast_nullable_to_non_nullable
                  as int?,
        previousWeightGrams: freezed == previousWeightGrams
            ? _value.previousWeightGrams
            : previousWeightGrams // ignore: cast_nullable_to_non_nullable
                  as int?,
        previousPricePerKgAmount: freezed == previousPricePerKgAmount
            ? _value.previousPricePerKgAmount
            : previousPricePerKgAmount // ignore: cast_nullable_to_non_nullable
                  as int?,
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OfferApiModelImpl implements _OfferApiModel {
  const _$OfferApiModelImpl({
    required this.id,
    @JsonKey(name: 'catch_id') this.catchId,
    @JsonKey(name: 'fisher_id') this.fisherId,
    @JsonKey(name: 'buyer_id') this.buyerId,
    this.catchDetails,
    this.fisher,
    this.buyer,
    @JsonKey(name: 'current_price_amount') this.currentPriceAmount,
    @JsonKey(name: 'current_weight_grams') this.currentWeightGrams,
    @JsonKey(name: 'current_price_per_kg_amount') this.currentPricePerKgAmount,
    @JsonKey(name: 'previous_price_amount') this.previousPriceAmount,
    @JsonKey(name: 'previous_weight_grams') this.previousWeightGrams,
    @JsonKey(name: 'previous_price_per_kg_amount')
    this.previousPricePerKgAmount,
    this.status,
    @JsonKey(name: 'created_at') this.createdAt,
    @JsonKey(name: 'updated_at') this.updatedAt,
  });

  factory _$OfferApiModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$OfferApiModelImplFromJson(json);

  @override
  final dynamic id;
  @override
  @JsonKey(name: 'catch_id')
  final dynamic catchId;
  // ID or object? Assume object if expanded
  @override
  @JsonKey(name: 'fisher_id')
  final dynamic fisherId;
  @override
  @JsonKey(name: 'buyer_id')
  final dynamic buyerId;
  // Or full objects if API returns them
  @override
  final CatchApiModel? catchDetails;
  @override
  final AccountApiModel? fisher;
  @override
  final AccountApiModel? buyer;
  @override
  @JsonKey(name: 'current_price_amount')
  final int? currentPriceAmount;
  @override
  @JsonKey(name: 'current_weight_grams')
  final int? currentWeightGrams;
  @override
  @JsonKey(name: 'current_price_per_kg_amount')
  final int? currentPricePerKgAmount;
  @override
  @JsonKey(name: 'previous_price_amount')
  final int? previousPriceAmount;
  @override
  @JsonKey(name: 'previous_weight_grams')
  final int? previousWeightGrams;
  @override
  @JsonKey(name: 'previous_price_per_kg_amount')
  final int? previousPricePerKgAmount;
  @override
  final String? status;
  @override
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  @override
  String toString() {
    return 'OfferApiModel(id: $id, catchId: $catchId, fisherId: $fisherId, buyerId: $buyerId, catchDetails: $catchDetails, fisher: $fisher, buyer: $buyer, currentPriceAmount: $currentPriceAmount, currentWeightGrams: $currentWeightGrams, currentPricePerKgAmount: $currentPricePerKgAmount, previousPriceAmount: $previousPriceAmount, previousWeightGrams: $previousWeightGrams, previousPricePerKgAmount: $previousPricePerKgAmount, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OfferApiModelImpl &&
            const DeepCollectionEquality().equals(other.id, id) &&
            const DeepCollectionEquality().equals(other.catchId, catchId) &&
            const DeepCollectionEquality().equals(other.fisherId, fisherId) &&
            const DeepCollectionEquality().equals(other.buyerId, buyerId) &&
            (identical(other.catchDetails, catchDetails) ||
                other.catchDetails == catchDetails) &&
            (identical(other.fisher, fisher) || other.fisher == fisher) &&
            (identical(other.buyer, buyer) || other.buyer == buyer) &&
            (identical(other.currentPriceAmount, currentPriceAmount) ||
                other.currentPriceAmount == currentPriceAmount) &&
            (identical(other.currentWeightGrams, currentWeightGrams) ||
                other.currentWeightGrams == currentWeightGrams) &&
            (identical(
                  other.currentPricePerKgAmount,
                  currentPricePerKgAmount,
                ) ||
                other.currentPricePerKgAmount == currentPricePerKgAmount) &&
            (identical(other.previousPriceAmount, previousPriceAmount) ||
                other.previousPriceAmount == previousPriceAmount) &&
            (identical(other.previousWeightGrams, previousWeightGrams) ||
                other.previousWeightGrams == previousWeightGrams) &&
            (identical(
                  other.previousPricePerKgAmount,
                  previousPricePerKgAmount,
                ) ||
                other.previousPricePerKgAmount == previousPricePerKgAmount) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(id),
    const DeepCollectionEquality().hash(catchId),
    const DeepCollectionEquality().hash(fisherId),
    const DeepCollectionEquality().hash(buyerId),
    catchDetails,
    fisher,
    buyer,
    currentPriceAmount,
    currentWeightGrams,
    currentPricePerKgAmount,
    previousPriceAmount,
    previousWeightGrams,
    previousPricePerKgAmount,
    status,
    createdAt,
    updatedAt,
  );

  /// Create a copy of OfferApiModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OfferApiModelImplCopyWith<_$OfferApiModelImpl> get copyWith =>
      __$$OfferApiModelImplCopyWithImpl<_$OfferApiModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OfferApiModelImplToJson(this);
  }
}

abstract class _OfferApiModel implements OfferApiModel {
  const factory _OfferApiModel({
    required final dynamic id,
    @JsonKey(name: 'catch_id') final dynamic catchId,
    @JsonKey(name: 'fisher_id') final dynamic fisherId,
    @JsonKey(name: 'buyer_id') final dynamic buyerId,
    final CatchApiModel? catchDetails,
    final AccountApiModel? fisher,
    final AccountApiModel? buyer,
    @JsonKey(name: 'current_price_amount') final int? currentPriceAmount,
    @JsonKey(name: 'current_weight_grams') final int? currentWeightGrams,
    @JsonKey(name: 'current_price_per_kg_amount')
    final int? currentPricePerKgAmount,
    @JsonKey(name: 'previous_price_amount') final int? previousPriceAmount,
    @JsonKey(name: 'previous_weight_grams') final int? previousWeightGrams,
    @JsonKey(name: 'previous_price_per_kg_amount')
    final int? previousPricePerKgAmount,
    final String? status,
    @JsonKey(name: 'created_at') final String? createdAt,
    @JsonKey(name: 'updated_at') final String? updatedAt,
  }) = _$OfferApiModelImpl;

  factory _OfferApiModel.fromJson(Map<String, dynamic> json) =
      _$OfferApiModelImpl.fromJson;

  @override
  dynamic get id;
  @override
  @JsonKey(name: 'catch_id')
  dynamic get catchId; // ID or object? Assume object if expanded
  @override
  @JsonKey(name: 'fisher_id')
  dynamic get fisherId;
  @override
  @JsonKey(name: 'buyer_id')
  dynamic get buyerId; // Or full objects if API returns them
  @override
  CatchApiModel? get catchDetails;
  @override
  AccountApiModel? get fisher;
  @override
  AccountApiModel? get buyer;
  @override
  @JsonKey(name: 'current_price_amount')
  int? get currentPriceAmount;
  @override
  @JsonKey(name: 'current_weight_grams')
  int? get currentWeightGrams;
  @override
  @JsonKey(name: 'current_price_per_kg_amount')
  int? get currentPricePerKgAmount;
  @override
  @JsonKey(name: 'previous_price_amount')
  int? get previousPriceAmount;
  @override
  @JsonKey(name: 'previous_weight_grams')
  int? get previousWeightGrams;
  @override
  @JsonKey(name: 'previous_price_per_kg_amount')
  int? get previousPricePerKgAmount;
  @override
  String? get status;
  @override
  @JsonKey(name: 'created_at')
  String? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  String? get updatedAt;

  /// Create a copy of OfferApiModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OfferApiModelImplCopyWith<_$OfferApiModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateOfferRequest _$CreateOfferRequestFromJson(Map<String, dynamic> json) {
  return _CreateOfferRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateOfferRequest {
  @JsonKey(name: 'catch_id')
  String get catchId => throw _privateConstructorUsedError;
  @JsonKey(name: 'price_amount')
  int get priceAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'weight_grams')
  int get weightGrams => throw _privateConstructorUsedError;
  @JsonKey(name: 'price_per_kg_amount')
  int get pricePerKgAmount => throw _privateConstructorUsedError;

  /// Serializes this CreateOfferRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateOfferRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateOfferRequestCopyWith<CreateOfferRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateOfferRequestCopyWith<$Res> {
  factory $CreateOfferRequestCopyWith(
    CreateOfferRequest value,
    $Res Function(CreateOfferRequest) then,
  ) = _$CreateOfferRequestCopyWithImpl<$Res, CreateOfferRequest>;
  @useResult
  $Res call({
    @JsonKey(name: 'catch_id') String catchId,
    @JsonKey(name: 'price_amount') int priceAmount,
    @JsonKey(name: 'weight_grams') int weightGrams,
    @JsonKey(name: 'price_per_kg_amount') int pricePerKgAmount,
  });
}

/// @nodoc
class _$CreateOfferRequestCopyWithImpl<$Res, $Val extends CreateOfferRequest>
    implements $CreateOfferRequestCopyWith<$Res> {
  _$CreateOfferRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateOfferRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? catchId = null,
    Object? priceAmount = null,
    Object? weightGrams = null,
    Object? pricePerKgAmount = null,
  }) {
    return _then(
      _value.copyWith(
            catchId: null == catchId
                ? _value.catchId
                : catchId // ignore: cast_nullable_to_non_nullable
                      as String,
            priceAmount: null == priceAmount
                ? _value.priceAmount
                : priceAmount // ignore: cast_nullable_to_non_nullable
                      as int,
            weightGrams: null == weightGrams
                ? _value.weightGrams
                : weightGrams // ignore: cast_nullable_to_non_nullable
                      as int,
            pricePerKgAmount: null == pricePerKgAmount
                ? _value.pricePerKgAmount
                : pricePerKgAmount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreateOfferRequestImplCopyWith<$Res>
    implements $CreateOfferRequestCopyWith<$Res> {
  factory _$$CreateOfferRequestImplCopyWith(
    _$CreateOfferRequestImpl value,
    $Res Function(_$CreateOfferRequestImpl) then,
  ) = __$$CreateOfferRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'catch_id') String catchId,
    @JsonKey(name: 'price_amount') int priceAmount,
    @JsonKey(name: 'weight_grams') int weightGrams,
    @JsonKey(name: 'price_per_kg_amount') int pricePerKgAmount,
  });
}

/// @nodoc
class __$$CreateOfferRequestImplCopyWithImpl<$Res>
    extends _$CreateOfferRequestCopyWithImpl<$Res, _$CreateOfferRequestImpl>
    implements _$$CreateOfferRequestImplCopyWith<$Res> {
  __$$CreateOfferRequestImplCopyWithImpl(
    _$CreateOfferRequestImpl _value,
    $Res Function(_$CreateOfferRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreateOfferRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? catchId = null,
    Object? priceAmount = null,
    Object? weightGrams = null,
    Object? pricePerKgAmount = null,
  }) {
    return _then(
      _$CreateOfferRequestImpl(
        catchId: null == catchId
            ? _value.catchId
            : catchId // ignore: cast_nullable_to_non_nullable
                  as String,
        priceAmount: null == priceAmount
            ? _value.priceAmount
            : priceAmount // ignore: cast_nullable_to_non_nullable
                  as int,
        weightGrams: null == weightGrams
            ? _value.weightGrams
            : weightGrams // ignore: cast_nullable_to_non_nullable
                  as int,
        pricePerKgAmount: null == pricePerKgAmount
            ? _value.pricePerKgAmount
            : pricePerKgAmount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateOfferRequestImpl implements _CreateOfferRequest {
  const _$CreateOfferRequestImpl({
    @JsonKey(name: 'catch_id') required this.catchId,
    @JsonKey(name: 'price_amount') required this.priceAmount,
    @JsonKey(name: 'weight_grams') required this.weightGrams,
    @JsonKey(name: 'price_per_kg_amount') required this.pricePerKgAmount,
  });

  factory _$CreateOfferRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateOfferRequestImplFromJson(json);

  @override
  @JsonKey(name: 'catch_id')
  final String catchId;
  @override
  @JsonKey(name: 'price_amount')
  final int priceAmount;
  @override
  @JsonKey(name: 'weight_grams')
  final int weightGrams;
  @override
  @JsonKey(name: 'price_per_kg_amount')
  final int pricePerKgAmount;

  @override
  String toString() {
    return 'CreateOfferRequest(catchId: $catchId, priceAmount: $priceAmount, weightGrams: $weightGrams, pricePerKgAmount: $pricePerKgAmount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateOfferRequestImpl &&
            (identical(other.catchId, catchId) || other.catchId == catchId) &&
            (identical(other.priceAmount, priceAmount) ||
                other.priceAmount == priceAmount) &&
            (identical(other.weightGrams, weightGrams) ||
                other.weightGrams == weightGrams) &&
            (identical(other.pricePerKgAmount, pricePerKgAmount) ||
                other.pricePerKgAmount == pricePerKgAmount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    catchId,
    priceAmount,
    weightGrams,
    pricePerKgAmount,
  );

  /// Create a copy of CreateOfferRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateOfferRequestImplCopyWith<_$CreateOfferRequestImpl> get copyWith =>
      __$$CreateOfferRequestImplCopyWithImpl<_$CreateOfferRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateOfferRequestImplToJson(this);
  }
}

abstract class _CreateOfferRequest implements CreateOfferRequest {
  const factory _CreateOfferRequest({
    @JsonKey(name: 'catch_id') required final String catchId,
    @JsonKey(name: 'price_amount') required final int priceAmount,
    @JsonKey(name: 'weight_grams') required final int weightGrams,
    @JsonKey(name: 'price_per_kg_amount') required final int pricePerKgAmount,
  }) = _$CreateOfferRequestImpl;

  factory _CreateOfferRequest.fromJson(Map<String, dynamic> json) =
      _$CreateOfferRequestImpl.fromJson;

  @override
  @JsonKey(name: 'catch_id')
  String get catchId;
  @override
  @JsonKey(name: 'price_amount')
  int get priceAmount;
  @override
  @JsonKey(name: 'weight_grams')
  int get weightGrams;
  @override
  @JsonKey(name: 'price_per_kg_amount')
  int get pricePerKgAmount;

  /// Create a copy of CreateOfferRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateOfferRequestImplCopyWith<_$CreateOfferRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
