import 'dart:convert';
import '../../domain/entities/product.dart';
import '../../domain/entities/species.dart';
import '../../domain/entities/user.dart';
import '../../domain/value_objects/price.dart';
import '../../domain/value_objects/price_per_kg.dart';
import '../../domain/value_objects/weight.dart';
import '../../domain/value_objects/rating.dart';
import '../../domain/enums/user_role.dart';

class ProductModel {
  final String id;
  final String name;
  final String marketName;
  final String status;
  final double pricePerKg;
  final double totalPrice;
  final double initialWeight;
  final double availableWeight;
  final String size;
  final String datePosted;
  final String locationName;
  final double latitude;
  final double longitude;
  final String? soldAt;
  final bool isSold;
  final String? gearNature;
  // Species (flattened)
  final String speciesId;
  final String speciesName;
  final String speciesImage;
  final int offersCount;
  final List<String> images;
  // Fisher (flattened)
  final String fisherId;
  final String fisherName;
  final String fisherAvatar;
  final double fisherRating;
  final int fisherReviewCount;

  ProductModel({
    required this.id,
    required this.name,
    required this.marketName,
    required this.status,
    required this.pricePerKg,
    required this.totalPrice,
    required this.initialWeight,
    required this.availableWeight,
    required this.size,
    required this.datePosted,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    this.soldAt,
    required this.isSold,
    this.gearNature,
    required this.speciesId,
    required this.speciesName,
    required this.speciesImage,
    required this.offersCount,
    required this.images,
    required this.fisherId,
    required this.fisherName,
    required this.fisherAvatar,
    required this.fisherRating,
    required this.fisherReviewCount,
  });

  factory ProductModel.fromDomain(Product product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      marketName: product.marketName,
      status: product.status,
      pricePerKg: product.pricePerKg.amountPerKg.toDouble(),
      totalPrice: product.totalPrice.amount.toDouble(),
      initialWeight: product.initialWeight.grams.toDouble(),
      availableWeight: product.availableWeight.grams.toDouble(),
      size: product.size,
      datePosted: product.datePosted.toIso8601String(),
      locationName: product.locationName,
      latitude: product.latitude,
      longitude: product.longitude,
      soldAt: product.soldAt?.toIso8601String(),
      isSold: product.isSold,
      gearNature: product.gearNature,
      speciesId: product.species.id,
      speciesName: product.species.name,
      speciesImage: product.species.image,
      offersCount: product.offersCount,
      images: product.images,
      fisherId: product.fisherId,
      fisherName: product.fisher?.name ?? 'Unknown',
      fisherAvatar: product.fisher?.avatarUrl ?? '',
      fisherRating: product.fisher?.rating.value ?? 0.0,
      fisherReviewCount: product.fisher?.reviewCount ?? 0,
    );
  }

  Product toDomain() {
    return Product(
      id: id,
      name: name,
      marketName: marketName,
      status: status,
      pricePerKg: PricePerKg.fromAmount(pricePerKg.toInt()),
      totalPrice: Price.fromAmount(totalPrice.toInt()),
      initialWeight: Weight.fromGrams(initialWeight.toInt()),
      availableWeight: Weight.fromGrams(availableWeight.toInt()),
      size: size,
      datePosted: DateTime.parse(datePosted),
      locationName: locationName,
      latitude: latitude,
      longitude: longitude,
      soldAt: soldAt != null ? DateTime.parse(soldAt!) : null,
      isSold: isSold,
      gearNature: gearNature,
      species: Species(
        id: speciesId,
        name: speciesName,
        image: speciesImage,
        uid: speciesId, // Assuming ID is valid UID
      ),
      offersCount: offersCount,
      images: images,
      fisherId: fisherId,
      fisher: User(
        id: fisherId,
        name: fisherName,
        rating: Rating.fromValue(fisherRating),
        reviewCount: fisherReviewCount,
        avatarUrl: fisherAvatar,
        currentRole: UserRole.fisher, // Always fisher for product owner
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'market_name': marketName,
      'status': status,
      'price_per_kg': pricePerKg,
      'final_price': totalPrice,
      'initial_weight': initialWeight,
      'available_weight': availableWeight,
      'size': size,
      'date_posted': datePosted,
      'location_name': locationName,
      'latitude': latitude,
      'longitude': longitude,
      'sold_at': soldAt,
      'is_sold': isSold ? 1 : 0,
      'gear_nature': gearNature,
      'species_id': speciesId,
      'species_name': speciesName,
      'species_image': speciesImage,
      'offers_count': offersCount,
      'images': jsonEncode(images),
      'fisher_id': fisherId,
      'fisher_name': fisherName,
      'fisher_avatar': fisherAvatar,
      'fisher_rating': fisherRating,
      'fisher_review_count': fisherReviewCount,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'],
      name: map['name'],
      marketName: map['market_name'],
      status: map['status'],
      pricePerKg: map['price_per_kg'],
      totalPrice: map['final_price'],
      initialWeight: map['initial_weight'],
      availableWeight: map['available_weight'],
      size: map['size'],
      datePosted: map['date_posted'],
      locationName: map['location_name'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      soldAt: map['sold_at'],
      isSold: map['is_sold'] == 1,
      gearNature: map['gear_nature'],
      speciesId: map['species_id'],
      speciesName: map['species_name'],
      speciesImage: map['species_image'],
      offersCount: map['offers_count'],
      images: map['images'] == null || map['images'].toString().isEmpty
          ? []
          : List<String>.from(jsonDecode(map['images'])),
      fisherId: map['fisher_id'],
      fisherName: map['fisher_name'],
      fisherAvatar: map['fisher_avatar'] ?? '',
      fisherRating: map['fisher_rating'],
      fisherReviewCount: map['fisher_review_count'],
    );
  }
}
