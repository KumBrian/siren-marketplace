import 'package:equatable/equatable.dart';

import '../enums/catch_status.dart';
import '../value_objects/price.dart';
import '../value_objects/price_per_kg.dart';
import '../value_objects/weight.dart';
import 'species.dart';

class Catch extends Equatable {
  final String id;
  final String name;
  final DateTime datePosted;
  final Weight initialWeight;
  final Weight availableWeight;
  final PricePerKg pricePerKg;
  final Price totalPrice;
  final String size;
  final String market;
  final List<String> images;
  final Species species;
  final String fisherId;
  final CatchStatus status;
  // Geolocation & Observation
  final String observationId;
  final String locationName;
  final double latitude;
  final double longitude;

  // Gearw Fields
  final double? meshSize; // Fingers
  final double? gearLength; // meters
  final double? gearWidth; // meters
  final String? gearNature; // Cotton, Monofilament, Multifilament
  final double? waterDepth; // meters
  final double? fishingTime; // hours
  final int? numberOfShrimps;

  const Catch({
    required this.id,
    required this.name,
    required this.datePosted,
    required this.initialWeight,
    required this.availableWeight,
    required this.pricePerKg,
    required this.totalPrice,
    required this.size,
    required this.market,
    required this.images,
    required this.species,
    required this.fisherId,
    required this.status,
    required this.observationId,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    // Gear params.meshSize,
    this.meshSize,
    this.gearLength,
    this.gearWidth,
    this.gearNature,
    this.waterDepth,
    this.fishingTime,
    this.numberOfShrimps,
  });

  // Business Logic
  static const Duration expirationDuration = Duration(days: 7);
  static const Duration deletionGracePeriod = Duration(days: 1);

  DateTime get expirationDate => datePosted.add(expirationDuration);
  DateTime get deletionDate => expirationDate.add(deletionGracePeriod);

  bool get isExpired {
    if (status != CatchStatus.available) return false;
    return DateTime.now().isAfter(expirationDate);
  }

  bool get shouldBeDeleted {
    if (status != CatchStatus.expired) return false;
    return DateTime.now().isAfter(deletionDate);
  }

  int get daysLeft {
    if (status != CatchStatus.available) return 0;
    final diff = expirationDate.difference(DateTime.now()).inDays;
    return diff > 0 ? diff : 0;
  }

  String get daysLeftLabel {
    final left = daysLeft;
    if (left == 0) return "Expired";
    if (left == 1) return "1 day left";
    return "$left days left";
  }

  bool get hasImages => images.isNotEmpty;
  String? get primaryImage => hasImages ? images.first : null;

  bool get isSoldOut => status == CatchStatus.soldOut;
  bool get isAvailable => status == CatchStatus.available;
  bool get canReceiveOffers => status.canReceiveOffers && !isExpired;

  // Domain Actions
  Catch markAsExpired() {
    if (status != CatchStatus.available) {
      throw StateError('Can only expire available catches');
    }
    return copyWith(status: CatchStatus.expired);
  }

  Catch markAsSoldOut() {
    if (status != CatchStatus.available) {
      throw StateError('Can only mark available catches as sold out');
    }
    return copyWith(status: CatchStatus.soldOut);
  }

  Catch markAsRemoved() {
    return copyWith(status: CatchStatus.removed);
  }

  Catch reduceAvailableWeight(Weight soldWeight) {
    if (soldWeight > availableWeight) {
      throw ArgumentError('Cannot reduce by more than available weight');
    }

    final newAvailable = availableWeight - soldWeight;
    final newStatus = newAvailable.isZero ? CatchStatus.soldOut : status;

    return copyWith(availableWeight: newAvailable, status: newStatus);
  }

  Catch copyWith({
    String? name,
    DateTime? datePosted,
    Weight? availableWeight,
    PricePerKg? pricePerKg,
    Price? totalPrice,
    String? size,
    String? market,
    List<String>? images,
    Species? species,
    String? fisherId,
    CatchStatus? status,
    String? observationId,
    String? locationName,
    double? latitude,
    double? longitude,
    double? meshSize,
    double? gearLength,
    double? gearWidth,
    String? gearNature,
    double? waterDepth,
    double? fishingTime,
    int? numberOfShrimps,
  }) {
    return Catch(
      id: id,
      name: name ?? this.name,
      datePosted: datePosted ?? this.datePosted,
      initialWeight: initialWeight,
      availableWeight: availableWeight ?? this.availableWeight,
      pricePerKg: pricePerKg ?? this.pricePerKg,
      totalPrice: totalPrice ?? this.totalPrice,
      size: size ?? this.size,
      market: market ?? this.market,
      images: images ?? this.images,
      species: species ?? this.species,
      fisherId: fisherId ?? this.fisherId,
      status: status ?? this.status,
      observationId: observationId ?? this.observationId,
      locationName: locationName ?? this.locationName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      meshSize: meshSize ?? this.meshSize,
      gearLength: gearLength ?? this.gearLength,
      gearWidth: gearWidth ?? this.gearWidth,
      gearNature: gearNature ?? this.gearNature,
      waterDepth: waterDepth ?? this.waterDepth,
      fishingTime: fishingTime ?? this.fishingTime,
      numberOfShrimps: numberOfShrimps ?? this.numberOfShrimps,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    datePosted,
    initialWeight,
    availableWeight,
    pricePerKg,
    totalPrice,
    size,
    market,
    images,
    species,
    fisherId,
    status,
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
  ];
}
