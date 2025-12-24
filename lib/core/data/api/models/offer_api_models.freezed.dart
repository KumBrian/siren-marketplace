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
  dynamic get id =>
      throw _privateConstructorUsedError; // API returns 'product' object which contains 'specie', 'account' etc.
  // 'product' is the new catch
  ProductApiModel? get product =>
      throw _privateConstructorUsedError; // API returns 'buyer' object
  AccountApiModel? get buyer =>
      throw _privateConstructorUsedError; // Field from API JSON "currentPriceAmount": 7000
  // Using camelCase keys as per JSON response
  int? get currentPriceAmount => throw _privateConstructorUsedError;
  int? get currentWeightGrams => throw _privateConstructorUsedError;
  int? get currentPricePerKgAmount =>
      throw _privateConstructorUsedError; // Previous values seem to use snake_case or mixed?
  // JSON: "previous_price": 90, "previousPriceAmount": 7500
  // We'll use the specific amount fields if available (camelCase ones)
  int? get previousPriceAmount => throw _privateConstructorUsedError;
  int? get previousWeightGrams => throw _privateConstructorUsedError;
  int? get previousPricePerKgAmount =>
      throw _privateConstructorUsedError; // Backend returns embedded order when offer is accepted
  @JsonKey(name: 'saleOrder')
  Map<String, dynamic>? get saleOrder => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'waiting_for')
  String? get waitingFor => throw _privateConstructorUsedError;
  @JsonKey(name: 'has_update_for_fisher')
  bool? get hasUpdateForFisher => throw _privateConstructorUsedError;
  @JsonKey(name: 'has_update_for_buyer')
  bool? get hasUpdateForBuyer => throw _privateConstructorUsedError;
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
    ProductApiModel? product,
    AccountApiModel? buyer,
    int? currentPriceAmount,
    int? currentWeightGrams,
    int? currentPricePerKgAmount,
    int? previousPriceAmount,
    int? previousWeightGrams,
    int? previousPricePerKgAmount,
    @JsonKey(name: 'saleOrder') Map<String, dynamic>? saleOrder,
    String? status,
    @JsonKey(name: 'waiting_for') String? waitingFor,
    @JsonKey(name: 'has_update_for_fisher') bool? hasUpdateForFisher,
    @JsonKey(name: 'has_update_for_buyer') bool? hasUpdateForBuyer,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  });

  $ProductApiModelCopyWith<$Res>? get product;
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
    Object? product = freezed,
    Object? buyer = freezed,
    Object? currentPriceAmount = freezed,
    Object? currentWeightGrams = freezed,
    Object? currentPricePerKgAmount = freezed,
    Object? previousPriceAmount = freezed,
    Object? previousWeightGrams = freezed,
    Object? previousPricePerKgAmount = freezed,
    Object? saleOrder = freezed,
    Object? status = freezed,
    Object? waitingFor = freezed,
    Object? hasUpdateForFisher = freezed,
    Object? hasUpdateForBuyer = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            product: freezed == product
                ? _value.product
                : product // ignore: cast_nullable_to_non_nullable
                      as ProductApiModel?,
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
            saleOrder: freezed == saleOrder
                ? _value.saleOrder
                : saleOrder // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String?,
            waitingFor: freezed == waitingFor
                ? _value.waitingFor
                : waitingFor // ignore: cast_nullable_to_non_nullable
                      as String?,
            hasUpdateForFisher: freezed == hasUpdateForFisher
                ? _value.hasUpdateForFisher
                : hasUpdateForFisher // ignore: cast_nullable_to_non_nullable
                      as bool?,
            hasUpdateForBuyer: freezed == hasUpdateForBuyer
                ? _value.hasUpdateForBuyer
                : hasUpdateForBuyer // ignore: cast_nullable_to_non_nullable
                      as bool?,
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
  $ProductApiModelCopyWith<$Res>? get product {
    if (_value.product == null) {
      return null;
    }

    return $ProductApiModelCopyWith<$Res>(_value.product!, (value) {
      return _then(_value.copyWith(product: value) as $Val);
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
    ProductApiModel? product,
    AccountApiModel? buyer,
    int? currentPriceAmount,
    int? currentWeightGrams,
    int? currentPricePerKgAmount,
    int? previousPriceAmount,
    int? previousWeightGrams,
    int? previousPricePerKgAmount,
    @JsonKey(name: 'saleOrder') Map<String, dynamic>? saleOrder,
    String? status,
    @JsonKey(name: 'waiting_for') String? waitingFor,
    @JsonKey(name: 'has_update_for_fisher') bool? hasUpdateForFisher,
    @JsonKey(name: 'has_update_for_buyer') bool? hasUpdateForBuyer,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  });

  @override
  $ProductApiModelCopyWith<$Res>? get product;
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
    Object? product = freezed,
    Object? buyer = freezed,
    Object? currentPriceAmount = freezed,
    Object? currentWeightGrams = freezed,
    Object? currentPricePerKgAmount = freezed,
    Object? previousPriceAmount = freezed,
    Object? previousWeightGrams = freezed,
    Object? previousPricePerKgAmount = freezed,
    Object? saleOrder = freezed,
    Object? status = freezed,
    Object? waitingFor = freezed,
    Object? hasUpdateForFisher = freezed,
    Object? hasUpdateForBuyer = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$OfferApiModelImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        product: freezed == product
            ? _value.product
            : product // ignore: cast_nullable_to_non_nullable
                  as ProductApiModel?,
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
        saleOrder: freezed == saleOrder
            ? _value._saleOrder
            : saleOrder // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String?,
        waitingFor: freezed == waitingFor
            ? _value.waitingFor
            : waitingFor // ignore: cast_nullable_to_non_nullable
                  as String?,
        hasUpdateForFisher: freezed == hasUpdateForFisher
            ? _value.hasUpdateForFisher
            : hasUpdateForFisher // ignore: cast_nullable_to_non_nullable
                  as bool?,
        hasUpdateForBuyer: freezed == hasUpdateForBuyer
            ? _value.hasUpdateForBuyer
            : hasUpdateForBuyer // ignore: cast_nullable_to_non_nullable
                  as bool?,
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
    this.product,
    this.buyer,
    this.currentPriceAmount,
    this.currentWeightGrams,
    this.currentPricePerKgAmount,
    this.previousPriceAmount,
    this.previousWeightGrams,
    this.previousPricePerKgAmount,
    @JsonKey(name: 'saleOrder') final Map<String, dynamic>? saleOrder,
    this.status,
    @JsonKey(name: 'waiting_for') this.waitingFor,
    @JsonKey(name: 'has_update_for_fisher') this.hasUpdateForFisher,
    @JsonKey(name: 'has_update_for_buyer') this.hasUpdateForBuyer,
    @JsonKey(name: 'created_at') this.createdAt,
    @JsonKey(name: 'updated_at') this.updatedAt,
  }) : _saleOrder = saleOrder;

  factory _$OfferApiModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$OfferApiModelImplFromJson(json);

  @override
  final dynamic id;
  // API returns 'product' object which contains 'specie', 'account' etc.
  // 'product' is the new catch
  @override
  final ProductApiModel? product;
  // API returns 'buyer' object
  @override
  final AccountApiModel? buyer;
  // Field from API JSON "currentPriceAmount": 7000
  // Using camelCase keys as per JSON response
  @override
  final int? currentPriceAmount;
  @override
  final int? currentWeightGrams;
  @override
  final int? currentPricePerKgAmount;
  // Previous values seem to use snake_case or mixed?
  // JSON: "previous_price": 90, "previousPriceAmount": 7500
  // We'll use the specific amount fields if available (camelCase ones)
  @override
  final int? previousPriceAmount;
  @override
  final int? previousWeightGrams;
  @override
  final int? previousPricePerKgAmount;
  // Backend returns embedded order when offer is accepted
  final Map<String, dynamic>? _saleOrder;
  // Backend returns embedded order when offer is accepted
  @override
  @JsonKey(name: 'saleOrder')
  Map<String, dynamic>? get saleOrder {
    final value = _saleOrder;
    if (value == null) return null;
    if (_saleOrder is EqualUnmodifiableMapView) return _saleOrder;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? status;
  @override
  @JsonKey(name: 'waiting_for')
  final String? waitingFor;
  @override
  @JsonKey(name: 'has_update_for_fisher')
  final bool? hasUpdateForFisher;
  @override
  @JsonKey(name: 'has_update_for_buyer')
  final bool? hasUpdateForBuyer;
  @override
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  @override
  String toString() {
    return 'OfferApiModel(id: $id, product: $product, buyer: $buyer, currentPriceAmount: $currentPriceAmount, currentWeightGrams: $currentWeightGrams, currentPricePerKgAmount: $currentPricePerKgAmount, previousPriceAmount: $previousPriceAmount, previousWeightGrams: $previousWeightGrams, previousPricePerKgAmount: $previousPricePerKgAmount, saleOrder: $saleOrder, status: $status, waitingFor: $waitingFor, hasUpdateForFisher: $hasUpdateForFisher, hasUpdateForBuyer: $hasUpdateForBuyer, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OfferApiModelImpl &&
            const DeepCollectionEquality().equals(other.id, id) &&
            (identical(other.product, product) || other.product == product) &&
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
            const DeepCollectionEquality().equals(
              other._saleOrder,
              _saleOrder,
            ) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.waitingFor, waitingFor) ||
                other.waitingFor == waitingFor) &&
            (identical(other.hasUpdateForFisher, hasUpdateForFisher) ||
                other.hasUpdateForFisher == hasUpdateForFisher) &&
            (identical(other.hasUpdateForBuyer, hasUpdateForBuyer) ||
                other.hasUpdateForBuyer == hasUpdateForBuyer) &&
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
    product,
    buyer,
    currentPriceAmount,
    currentWeightGrams,
    currentPricePerKgAmount,
    previousPriceAmount,
    previousWeightGrams,
    previousPricePerKgAmount,
    const DeepCollectionEquality().hash(_saleOrder),
    status,
    waitingFor,
    hasUpdateForFisher,
    hasUpdateForBuyer,
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
    final ProductApiModel? product,
    final AccountApiModel? buyer,
    final int? currentPriceAmount,
    final int? currentWeightGrams,
    final int? currentPricePerKgAmount,
    final int? previousPriceAmount,
    final int? previousWeightGrams,
    final int? previousPricePerKgAmount,
    @JsonKey(name: 'saleOrder') final Map<String, dynamic>? saleOrder,
    final String? status,
    @JsonKey(name: 'waiting_for') final String? waitingFor,
    @JsonKey(name: 'has_update_for_fisher') final bool? hasUpdateForFisher,
    @JsonKey(name: 'has_update_for_buyer') final bool? hasUpdateForBuyer,
    @JsonKey(name: 'created_at') final String? createdAt,
    @JsonKey(name: 'updated_at') final String? updatedAt,
  }) = _$OfferApiModelImpl;

  factory _OfferApiModel.fromJson(Map<String, dynamic> json) =
      _$OfferApiModelImpl.fromJson;

  @override
  dynamic get id; // API returns 'product' object which contains 'specie', 'account' etc.
  // 'product' is the new catch
  @override
  ProductApiModel? get product; // API returns 'buyer' object
  @override
  AccountApiModel? get buyer; // Field from API JSON "currentPriceAmount": 7000
  // Using camelCase keys as per JSON response
  @override
  int? get currentPriceAmount;
  @override
  int? get currentWeightGrams;
  @override
  int? get currentPricePerKgAmount; // Previous values seem to use snake_case or mixed?
  // JSON: "previous_price": 90, "previousPriceAmount": 7500
  // We'll use the specific amount fields if available (camelCase ones)
  @override
  int? get previousPriceAmount;
  @override
  int? get previousWeightGrams;
  @override
  int? get previousPricePerKgAmount; // Backend returns embedded order when offer is accepted
  @override
  @JsonKey(name: 'saleOrder')
  Map<String, dynamic>? get saleOrder;
  @override
  String? get status;
  @override
  @JsonKey(name: 'waiting_for')
  String? get waitingFor;
  @override
  @JsonKey(name: 'has_update_for_fisher')
  bool? get hasUpdateForFisher;
  @override
  @JsonKey(name: 'has_update_for_buyer')
  bool? get hasUpdateForBuyer;
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
  // Request: "product": 1
  dynamic get product =>
      throw _privateConstructorUsedError; // Request: "weight_in_grams": 10.5
  @JsonKey(name: 'weight_in_grams')
  double get weightInGrams => throw _privateConstructorUsedError; // Request: "price": 100
  double get price =>
      throw _privateConstructorUsedError; // Request: "price_per_kg": 9.52
  @JsonKey(name: 'price_per_kg')
  double get pricePerKg => throw _privateConstructorUsedError;

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
    dynamic product,
    @JsonKey(name: 'weight_in_grams') double weightInGrams,
    double price,
    @JsonKey(name: 'price_per_kg') double pricePerKg,
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
    Object? product = freezed,
    Object? weightInGrams = null,
    Object? price = null,
    Object? pricePerKg = null,
  }) {
    return _then(
      _value.copyWith(
            product: freezed == product
                ? _value.product
                : product // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            weightInGrams: null == weightInGrams
                ? _value.weightInGrams
                : weightInGrams // ignore: cast_nullable_to_non_nullable
                      as double,
            price: null == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                      as double,
            pricePerKg: null == pricePerKg
                ? _value.pricePerKg
                : pricePerKg // ignore: cast_nullable_to_non_nullable
                      as double,
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
    dynamic product,
    @JsonKey(name: 'weight_in_grams') double weightInGrams,
    double price,
    @JsonKey(name: 'price_per_kg') double pricePerKg,
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
    Object? product = freezed,
    Object? weightInGrams = null,
    Object? price = null,
    Object? pricePerKg = null,
  }) {
    return _then(
      _$CreateOfferRequestImpl(
        product: freezed == product
            ? _value.product
            : product // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        weightInGrams: null == weightInGrams
            ? _value.weightInGrams
            : weightInGrams // ignore: cast_nullable_to_non_nullable
                  as double,
        price: null == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                  as double,
        pricePerKg: null == pricePerKg
            ? _value.pricePerKg
            : pricePerKg // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateOfferRequestImpl implements _CreateOfferRequest {
  const _$CreateOfferRequestImpl({
    required this.product,
    @JsonKey(name: 'weight_in_grams') required this.weightInGrams,
    required this.price,
    @JsonKey(name: 'price_per_kg') required this.pricePerKg,
  });

  factory _$CreateOfferRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateOfferRequestImplFromJson(json);

  // Request: "product": 1
  @override
  final dynamic product;
  // Request: "weight_in_grams": 10.5
  @override
  @JsonKey(name: 'weight_in_grams')
  final double weightInGrams;
  // Request: "price": 100
  @override
  final double price;
  // Request: "price_per_kg": 9.52
  @override
  @JsonKey(name: 'price_per_kg')
  final double pricePerKg;

  @override
  String toString() {
    return 'CreateOfferRequest(product: $product, weightInGrams: $weightInGrams, price: $price, pricePerKg: $pricePerKg)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateOfferRequestImpl &&
            const DeepCollectionEquality().equals(other.product, product) &&
            (identical(other.weightInGrams, weightInGrams) ||
                other.weightInGrams == weightInGrams) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.pricePerKg, pricePerKg) ||
                other.pricePerKg == pricePerKg));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(product),
    weightInGrams,
    price,
    pricePerKg,
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
    required final dynamic product,
    @JsonKey(name: 'weight_in_grams') required final double weightInGrams,
    required final double price,
    @JsonKey(name: 'price_per_kg') required final double pricePerKg,
  }) = _$CreateOfferRequestImpl;

  factory _CreateOfferRequest.fromJson(Map<String, dynamic> json) =
      _$CreateOfferRequestImpl.fromJson;

  // Request: "product": 1
  @override
  dynamic get product; // Request: "weight_in_grams": 10.5
  @override
  @JsonKey(name: 'weight_in_grams')
  double get weightInGrams; // Request: "price": 100
  @override
  double get price; // Request: "price_per_kg": 9.52
  @override
  @JsonKey(name: 'price_per_kg')
  double get pricePerKg;

  /// Create a copy of CreateOfferRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateOfferRequestImplCopyWith<_$CreateOfferRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CounterOfferRequest _$CounterOfferRequestFromJson(Map<String, dynamic> json) {
  return _CounterOfferRequest.fromJson(json);
}

/// @nodoc
mixin _$CounterOfferRequest {
  @JsonKey(name: 'weight_in_grams')
  double get weightInGrams => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  @JsonKey(name: 'price_per_kg')
  double get pricePerKg => throw _privateConstructorUsedError;

  /// Serializes this CounterOfferRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CounterOfferRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CounterOfferRequestCopyWith<CounterOfferRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CounterOfferRequestCopyWith<$Res> {
  factory $CounterOfferRequestCopyWith(
    CounterOfferRequest value,
    $Res Function(CounterOfferRequest) then,
  ) = _$CounterOfferRequestCopyWithImpl<$Res, CounterOfferRequest>;
  @useResult
  $Res call({
    @JsonKey(name: 'weight_in_grams') double weightInGrams,
    double price,
    @JsonKey(name: 'price_per_kg') double pricePerKg,
  });
}

/// @nodoc
class _$CounterOfferRequestCopyWithImpl<$Res, $Val extends CounterOfferRequest>
    implements $CounterOfferRequestCopyWith<$Res> {
  _$CounterOfferRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CounterOfferRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? weightInGrams = null,
    Object? price = null,
    Object? pricePerKg = null,
  }) {
    return _then(
      _value.copyWith(
            weightInGrams: null == weightInGrams
                ? _value.weightInGrams
                : weightInGrams // ignore: cast_nullable_to_non_nullable
                      as double,
            price: null == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                      as double,
            pricePerKg: null == pricePerKg
                ? _value.pricePerKg
                : pricePerKg // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CounterOfferRequestImplCopyWith<$Res>
    implements $CounterOfferRequestCopyWith<$Res> {
  factory _$$CounterOfferRequestImplCopyWith(
    _$CounterOfferRequestImpl value,
    $Res Function(_$CounterOfferRequestImpl) then,
  ) = __$$CounterOfferRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'weight_in_grams') double weightInGrams,
    double price,
    @JsonKey(name: 'price_per_kg') double pricePerKg,
  });
}

/// @nodoc
class __$$CounterOfferRequestImplCopyWithImpl<$Res>
    extends _$CounterOfferRequestCopyWithImpl<$Res, _$CounterOfferRequestImpl>
    implements _$$CounterOfferRequestImplCopyWith<$Res> {
  __$$CounterOfferRequestImplCopyWithImpl(
    _$CounterOfferRequestImpl _value,
    $Res Function(_$CounterOfferRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CounterOfferRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? weightInGrams = null,
    Object? price = null,
    Object? pricePerKg = null,
  }) {
    return _then(
      _$CounterOfferRequestImpl(
        weightInGrams: null == weightInGrams
            ? _value.weightInGrams
            : weightInGrams // ignore: cast_nullable_to_non_nullable
                  as double,
        price: null == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                  as double,
        pricePerKg: null == pricePerKg
            ? _value.pricePerKg
            : pricePerKg // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CounterOfferRequestImpl implements _CounterOfferRequest {
  const _$CounterOfferRequestImpl({
    @JsonKey(name: 'weight_in_grams') required this.weightInGrams,
    required this.price,
    @JsonKey(name: 'price_per_kg') required this.pricePerKg,
  });

  factory _$CounterOfferRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CounterOfferRequestImplFromJson(json);

  @override
  @JsonKey(name: 'weight_in_grams')
  final double weightInGrams;
  @override
  final double price;
  @override
  @JsonKey(name: 'price_per_kg')
  final double pricePerKg;

  @override
  String toString() {
    return 'CounterOfferRequest(weightInGrams: $weightInGrams, price: $price, pricePerKg: $pricePerKg)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CounterOfferRequestImpl &&
            (identical(other.weightInGrams, weightInGrams) ||
                other.weightInGrams == weightInGrams) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.pricePerKg, pricePerKg) ||
                other.pricePerKg == pricePerKg));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, weightInGrams, price, pricePerKg);

  /// Create a copy of CounterOfferRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CounterOfferRequestImplCopyWith<_$CounterOfferRequestImpl> get copyWith =>
      __$$CounterOfferRequestImplCopyWithImpl<_$CounterOfferRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CounterOfferRequestImplToJson(this);
  }
}

abstract class _CounterOfferRequest implements CounterOfferRequest {
  const factory _CounterOfferRequest({
    @JsonKey(name: 'weight_in_grams') required final double weightInGrams,
    required final double price,
    @JsonKey(name: 'price_per_kg') required final double pricePerKg,
  }) = _$CounterOfferRequestImpl;

  factory _CounterOfferRequest.fromJson(Map<String, dynamic> json) =
      _$CounterOfferRequestImpl.fromJson;

  @override
  @JsonKey(name: 'weight_in_grams')
  double get weightInGrams;
  @override
  double get price;
  @override
  @JsonKey(name: 'price_per_kg')
  double get pricePerKg;

  /// Create a copy of CounterOfferRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CounterOfferRequestImplCopyWith<_$CounterOfferRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OfferResponseRequest _$OfferResponseRequestFromJson(Map<String, dynamic> json) {
  return _OfferResponseRequest.fromJson(json);
}

/// @nodoc
mixin _$OfferResponseRequest {
  String get action => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;

  /// Serializes this OfferResponseRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OfferResponseRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OfferResponseRequestCopyWith<OfferResponseRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OfferResponseRequestCopyWith<$Res> {
  factory $OfferResponseRequestCopyWith(
    OfferResponseRequest value,
    $Res Function(OfferResponseRequest) then,
  ) = _$OfferResponseRequestCopyWithImpl<$Res, OfferResponseRequest>;
  @useResult
  $Res call({String action, String message});
}

/// @nodoc
class _$OfferResponseRequestCopyWithImpl<
  $Res,
  $Val extends OfferResponseRequest
>
    implements $OfferResponseRequestCopyWith<$Res> {
  _$OfferResponseRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OfferResponseRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? action = null, Object? message = null}) {
    return _then(
      _value.copyWith(
            action: null == action
                ? _value.action
                : action // ignore: cast_nullable_to_non_nullable
                      as String,
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OfferResponseRequestImplCopyWith<$Res>
    implements $OfferResponseRequestCopyWith<$Res> {
  factory _$$OfferResponseRequestImplCopyWith(
    _$OfferResponseRequestImpl value,
    $Res Function(_$OfferResponseRequestImpl) then,
  ) = __$$OfferResponseRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String action, String message});
}

/// @nodoc
class __$$OfferResponseRequestImplCopyWithImpl<$Res>
    extends _$OfferResponseRequestCopyWithImpl<$Res, _$OfferResponseRequestImpl>
    implements _$$OfferResponseRequestImplCopyWith<$Res> {
  __$$OfferResponseRequestImplCopyWithImpl(
    _$OfferResponseRequestImpl _value,
    $Res Function(_$OfferResponseRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OfferResponseRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? action = null, Object? message = null}) {
    return _then(
      _$OfferResponseRequestImpl(
        action: null == action
            ? _value.action
            : action // ignore: cast_nullable_to_non_nullable
                  as String,
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OfferResponseRequestImpl implements _OfferResponseRequest {
  const _$OfferResponseRequestImpl({
    required this.action,
    required this.message,
  });

  factory _$OfferResponseRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$OfferResponseRequestImplFromJson(json);

  @override
  final String action;
  @override
  final String message;

  @override
  String toString() {
    return 'OfferResponseRequest(action: $action, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OfferResponseRequestImpl &&
            (identical(other.action, action) || other.action == action) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, action, message);

  /// Create a copy of OfferResponseRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OfferResponseRequestImplCopyWith<_$OfferResponseRequestImpl>
  get copyWith =>
      __$$OfferResponseRequestImplCopyWithImpl<_$OfferResponseRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$OfferResponseRequestImplToJson(this);
  }
}

abstract class _OfferResponseRequest implements OfferResponseRequest {
  const factory _OfferResponseRequest({
    required final String action,
    required final String message,
  }) = _$OfferResponseRequestImpl;

  factory _OfferResponseRequest.fromJson(Map<String, dynamic> json) =
      _$OfferResponseRequestImpl.fromJson;

  @override
  String get action;
  @override
  String get message;

  /// Create a copy of OfferResponseRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OfferResponseRequestImplCopyWith<_$OfferResponseRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}
