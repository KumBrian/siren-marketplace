// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_api_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

OrderApiModel _$OrderApiModelFromJson(Map<String, dynamic> json) {
  return _OrderApiModel.fromJson(json);
}

/// @nodoc
mixin _$OrderApiModel {
  dynamic get id => throw _privateConstructorUsedError; // ID can be int in JSON
  @JsonKey(name: 'orderNumber')
  String? get orderNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'cancellationReason')
  String? get cancellationReason => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;
  bool? get completed => throw _privateConstructorUsedError; // Order terms
  @JsonKey(name: 'terms_price')
  int? get termsPrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'terms_weight')
  int? get termsWeight => throw _privateConstructorUsedError;
  @JsonKey(name: 'terms_price_per_kg')
  int? get termsPricePerKg =>
      throw _privateConstructorUsedError; // Review objects
  @JsonKey(name: 'buyerReview')
  ReviewApiResponse? get buyerReview => throw _privateConstructorUsedError;
  @JsonKey(name: 'fisherReview')
  ReviewApiResponse? get fisherReview =>
      throw _privateConstructorUsedError; // Embedded product data
  ProductApiModel? get product =>
      throw _privateConstructorUsedError; // Embedded buyer data (will be mapped manually in mapper)
  dynamic get buyer => throw _privateConstructorUsedError; // Timestamps
  @JsonKey(name: 'created_at')
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  String? get updatedAt => throw _privateConstructorUsedError;
  String? get uid => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $OrderApiModelCopyWith<OrderApiModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderApiModelCopyWith<$Res> {
  factory $OrderApiModelCopyWith(
          OrderApiModel value, $Res Function(OrderApiModel) then) =
      _$OrderApiModelCopyWithImpl<$Res, OrderApiModel>;
  @useResult
  $Res call(
      {dynamic id,
      @JsonKey(name: 'orderNumber') String? orderNumber,
      @JsonKey(name: 'cancellationReason') String? cancellationReason,
      String? status,
      bool? completed,
      @JsonKey(name: 'terms_price') int? termsPrice,
      @JsonKey(name: 'terms_weight') int? termsWeight,
      @JsonKey(name: 'terms_price_per_kg') int? termsPricePerKg,
      @JsonKey(name: 'buyerReview') ReviewApiResponse? buyerReview,
      @JsonKey(name: 'fisherReview') ReviewApiResponse? fisherReview,
      ProductApiModel? product,
      dynamic buyer,
      @JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(name: 'updated_at') String? updatedAt,
      String? uid});

  $ReviewApiResponseCopyWith<$Res>? get buyerReview;
  $ReviewApiResponseCopyWith<$Res>? get fisherReview;
  $ProductApiModelCopyWith<$Res>? get product;
}

/// @nodoc
class _$OrderApiModelCopyWithImpl<$Res, $Val extends OrderApiModel>
    implements $OrderApiModelCopyWith<$Res> {
  _$OrderApiModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? orderNumber = freezed,
    Object? cancellationReason = freezed,
    Object? status = freezed,
    Object? completed = freezed,
    Object? termsPrice = freezed,
    Object? termsWeight = freezed,
    Object? termsPricePerKg = freezed,
    Object? buyerReview = freezed,
    Object? fisherReview = freezed,
    Object? product = freezed,
    Object? buyer = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? uid = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as dynamic,
      orderNumber: freezed == orderNumber
          ? _value.orderNumber
          : orderNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      cancellationReason: freezed == cancellationReason
          ? _value.cancellationReason
          : cancellationReason // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      completed: freezed == completed
          ? _value.completed
          : completed // ignore: cast_nullable_to_non_nullable
              as bool?,
      termsPrice: freezed == termsPrice
          ? _value.termsPrice
          : termsPrice // ignore: cast_nullable_to_non_nullable
              as int?,
      termsWeight: freezed == termsWeight
          ? _value.termsWeight
          : termsWeight // ignore: cast_nullable_to_non_nullable
              as int?,
      termsPricePerKg: freezed == termsPricePerKg
          ? _value.termsPricePerKg
          : termsPricePerKg // ignore: cast_nullable_to_non_nullable
              as int?,
      buyerReview: freezed == buyerReview
          ? _value.buyerReview
          : buyerReview // ignore: cast_nullable_to_non_nullable
              as ReviewApiResponse?,
      fisherReview: freezed == fisherReview
          ? _value.fisherReview
          : fisherReview // ignore: cast_nullable_to_non_nullable
              as ReviewApiResponse?,
      product: freezed == product
          ? _value.product
          : product // ignore: cast_nullable_to_non_nullable
              as ProductApiModel?,
      buyer: freezed == buyer
          ? _value.buyer
          : buyer // ignore: cast_nullable_to_non_nullable
              as dynamic,
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
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ReviewApiResponseCopyWith<$Res>? get buyerReview {
    if (_value.buyerReview == null) {
      return null;
    }

    return $ReviewApiResponseCopyWith<$Res>(_value.buyerReview!, (value) {
      return _then(_value.copyWith(buyerReview: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $ReviewApiResponseCopyWith<$Res>? get fisherReview {
    if (_value.fisherReview == null) {
      return null;
    }

    return $ReviewApiResponseCopyWith<$Res>(_value.fisherReview!, (value) {
      return _then(_value.copyWith(fisherReview: value) as $Val);
    });
  }

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
}

/// @nodoc
abstract class _$$OrderApiModelImplCopyWith<$Res>
    implements $OrderApiModelCopyWith<$Res> {
  factory _$$OrderApiModelImplCopyWith(
          _$OrderApiModelImpl value, $Res Function(_$OrderApiModelImpl) then) =
      __$$OrderApiModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {dynamic id,
      @JsonKey(name: 'orderNumber') String? orderNumber,
      @JsonKey(name: 'cancellationReason') String? cancellationReason,
      String? status,
      bool? completed,
      @JsonKey(name: 'terms_price') int? termsPrice,
      @JsonKey(name: 'terms_weight') int? termsWeight,
      @JsonKey(name: 'terms_price_per_kg') int? termsPricePerKg,
      @JsonKey(name: 'buyerReview') ReviewApiResponse? buyerReview,
      @JsonKey(name: 'fisherReview') ReviewApiResponse? fisherReview,
      ProductApiModel? product,
      dynamic buyer,
      @JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(name: 'updated_at') String? updatedAt,
      String? uid});

  @override
  $ReviewApiResponseCopyWith<$Res>? get buyerReview;
  @override
  $ReviewApiResponseCopyWith<$Res>? get fisherReview;
  @override
  $ProductApiModelCopyWith<$Res>? get product;
}

/// @nodoc
class __$$OrderApiModelImplCopyWithImpl<$Res>
    extends _$OrderApiModelCopyWithImpl<$Res, _$OrderApiModelImpl>
    implements _$$OrderApiModelImplCopyWith<$Res> {
  __$$OrderApiModelImplCopyWithImpl(
      _$OrderApiModelImpl _value, $Res Function(_$OrderApiModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? orderNumber = freezed,
    Object? cancellationReason = freezed,
    Object? status = freezed,
    Object? completed = freezed,
    Object? termsPrice = freezed,
    Object? termsWeight = freezed,
    Object? termsPricePerKg = freezed,
    Object? buyerReview = freezed,
    Object? fisherReview = freezed,
    Object? product = freezed,
    Object? buyer = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? uid = freezed,
  }) {
    return _then(_$OrderApiModelImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as dynamic,
      orderNumber: freezed == orderNumber
          ? _value.orderNumber
          : orderNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      cancellationReason: freezed == cancellationReason
          ? _value.cancellationReason
          : cancellationReason // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      completed: freezed == completed
          ? _value.completed
          : completed // ignore: cast_nullable_to_non_nullable
              as bool?,
      termsPrice: freezed == termsPrice
          ? _value.termsPrice
          : termsPrice // ignore: cast_nullable_to_non_nullable
              as int?,
      termsWeight: freezed == termsWeight
          ? _value.termsWeight
          : termsWeight // ignore: cast_nullable_to_non_nullable
              as int?,
      termsPricePerKg: freezed == termsPricePerKg
          ? _value.termsPricePerKg
          : termsPricePerKg // ignore: cast_nullable_to_non_nullable
              as int?,
      buyerReview: freezed == buyerReview
          ? _value.buyerReview
          : buyerReview // ignore: cast_nullable_to_non_nullable
              as ReviewApiResponse?,
      fisherReview: freezed == fisherReview
          ? _value.fisherReview
          : fisherReview // ignore: cast_nullable_to_non_nullable
              as ReviewApiResponse?,
      product: freezed == product
          ? _value.product
          : product // ignore: cast_nullable_to_non_nullable
              as ProductApiModel?,
      buyer: freezed == buyer
          ? _value.buyer
          : buyer // ignore: cast_nullable_to_non_nullable
              as dynamic,
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
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderApiModelImpl implements _OrderApiModel {
  const _$OrderApiModelImpl(
      {required this.id,
      @JsonKey(name: 'orderNumber') this.orderNumber,
      @JsonKey(name: 'cancellationReason') this.cancellationReason,
      this.status,
      this.completed,
      @JsonKey(name: 'terms_price') this.termsPrice,
      @JsonKey(name: 'terms_weight') this.termsWeight,
      @JsonKey(name: 'terms_price_per_kg') this.termsPricePerKg,
      @JsonKey(name: 'buyerReview') this.buyerReview,
      @JsonKey(name: 'fisherReview') this.fisherReview,
      this.product,
      this.buyer,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt,
      this.uid});

  factory _$OrderApiModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderApiModelImplFromJson(json);

  @override
  final dynamic id;
// ID can be int in JSON
  @override
  @JsonKey(name: 'orderNumber')
  final String? orderNumber;
  @override
  @JsonKey(name: 'cancellationReason')
  final String? cancellationReason;
  @override
  final String? status;
  @override
  final bool? completed;
// Order terms
  @override
  @JsonKey(name: 'terms_price')
  final int? termsPrice;
  @override
  @JsonKey(name: 'terms_weight')
  final int? termsWeight;
  @override
  @JsonKey(name: 'terms_price_per_kg')
  final int? termsPricePerKg;
// Review objects
  @override
  @JsonKey(name: 'buyerReview')
  final ReviewApiResponse? buyerReview;
  @override
  @JsonKey(name: 'fisherReview')
  final ReviewApiResponse? fisherReview;
// Embedded product data
  @override
  final ProductApiModel? product;
// Embedded buyer data (will be mapped manually in mapper)
  @override
  final dynamic buyer;
// Timestamps
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
    return 'OrderApiModel(id: $id, orderNumber: $orderNumber, cancellationReason: $cancellationReason, status: $status, completed: $completed, termsPrice: $termsPrice, termsWeight: $termsWeight, termsPricePerKg: $termsPricePerKg, buyerReview: $buyerReview, fisherReview: $fisherReview, product: $product, buyer: $buyer, createdAt: $createdAt, updatedAt: $updatedAt, uid: $uid)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderApiModelImpl &&
            const DeepCollectionEquality().equals(other.id, id) &&
            (identical(other.orderNumber, orderNumber) ||
                other.orderNumber == orderNumber) &&
            (identical(other.cancellationReason, cancellationReason) ||
                other.cancellationReason == cancellationReason) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.completed, completed) ||
                other.completed == completed) &&
            (identical(other.termsPrice, termsPrice) ||
                other.termsPrice == termsPrice) &&
            (identical(other.termsWeight, termsWeight) ||
                other.termsWeight == termsWeight) &&
            (identical(other.termsPricePerKg, termsPricePerKg) ||
                other.termsPricePerKg == termsPricePerKg) &&
            (identical(other.buyerReview, buyerReview) ||
                other.buyerReview == buyerReview) &&
            (identical(other.fisherReview, fisherReview) ||
                other.fisherReview == fisherReview) &&
            (identical(other.product, product) || other.product == product) &&
            const DeepCollectionEquality().equals(other.buyer, buyer) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.uid, uid) || other.uid == uid));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(id),
      orderNumber,
      cancellationReason,
      status,
      completed,
      termsPrice,
      termsWeight,
      termsPricePerKg,
      buyerReview,
      fisherReview,
      product,
      const DeepCollectionEquality().hash(buyer),
      createdAt,
      updatedAt,
      uid);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderApiModelImplCopyWith<_$OrderApiModelImpl> get copyWith =>
      __$$OrderApiModelImplCopyWithImpl<_$OrderApiModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderApiModelImplToJson(
      this,
    );
  }
}

abstract class _OrderApiModel implements OrderApiModel {
  const factory _OrderApiModel(
      {required final dynamic id,
      @JsonKey(name: 'orderNumber') final String? orderNumber,
      @JsonKey(name: 'cancellationReason') final String? cancellationReason,
      final String? status,
      final bool? completed,
      @JsonKey(name: 'terms_price') final int? termsPrice,
      @JsonKey(name: 'terms_weight') final int? termsWeight,
      @JsonKey(name: 'terms_price_per_kg') final int? termsPricePerKg,
      @JsonKey(name: 'buyerReview') final ReviewApiResponse? buyerReview,
      @JsonKey(name: 'fisherReview') final ReviewApiResponse? fisherReview,
      final ProductApiModel? product,
      final dynamic buyer,
      @JsonKey(name: 'created_at') final String? createdAt,
      @JsonKey(name: 'updated_at') final String? updatedAt,
      final String? uid}) = _$OrderApiModelImpl;

  factory _OrderApiModel.fromJson(Map<String, dynamic> json) =
      _$OrderApiModelImpl.fromJson;

  @override
  dynamic get id;
  @override // ID can be int in JSON
  @JsonKey(name: 'orderNumber')
  String? get orderNumber;
  @override
  @JsonKey(name: 'cancellationReason')
  String? get cancellationReason;
  @override
  String? get status;
  @override
  bool? get completed;
  @override // Order terms
  @JsonKey(name: 'terms_price')
  int? get termsPrice;
  @override
  @JsonKey(name: 'terms_weight')
  int? get termsWeight;
  @override
  @JsonKey(name: 'terms_price_per_kg')
  int? get termsPricePerKg;
  @override // Review objects
  @JsonKey(name: 'buyerReview')
  ReviewApiResponse? get buyerReview;
  @override
  @JsonKey(name: 'fisherReview')
  ReviewApiResponse? get fisherReview;
  @override // Embedded product data
  ProductApiModel? get product;
  @override // Embedded buyer data (will be mapped manually in mapper)
  dynamic get buyer;
  @override // Timestamps
  @JsonKey(name: 'created_at')
  String? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  String? get updatedAt;
  @override
  String? get uid;
  @override
  @JsonKey(ignore: true)
  _$$OrderApiModelImplCopyWith<_$OrderApiModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
