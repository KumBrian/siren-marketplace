import 'package:siren_marketplace/core/domain/entities/catch.dart';
import 'package:siren_marketplace/core/domain/entities/offer.dart';
import 'package:siren_marketplace/core/domain/entities/order.dart';
import 'package:siren_marketplace/core/domain/entities/review.dart';
import 'package:siren_marketplace/core/domain/entities/species.dart';
import 'package:siren_marketplace/core/domain/entities/user.dart';
import 'package:siren_marketplace/core/domain/enums/catch_status.dart';
import 'package:siren_marketplace/core/domain/enums/offer_status.dart';
import 'package:siren_marketplace/core/domain/enums/order_status.dart';
import 'package:siren_marketplace/core/domain/enums/user_role.dart';
import 'package:siren_marketplace/core/domain/value_objects/offer_terms.dart';
import 'package:siren_marketplace/core/domain/value_objects/price.dart';
import 'package:siren_marketplace/core/domain/value_objects/price_per_kg.dart';
import 'package:siren_marketplace/core/domain/value_objects/rating.dart';
import 'package:siren_marketplace/core/domain/value_objects/weight.dart';

/// Factory class for creating test data
///
/// This class provides factory methods to create domain entities and value objects
/// with sensible defaults for testing purposes. All methods accept optional parameters
/// to customize the created objects as needed for specific test scenarios.
class TestData {
  // ============================================================================
  // ENTITIES
  // ============================================================================

  /// Creates a test Catch entity with sensible defaults
  static Catch createCatch({
    String? id,
    String? name,
    DateTime? datePosted,
    Weight? initialWeight,
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
  }) {
    final defaultInitialWeight = Weight.fromKg(10);
    return Catch(
      id: id ?? 'test-catch-1',
      name: name ?? 'Fresh Tuna',
      datePosted: datePosted ?? DateTime.now(),
      initialWeight: initialWeight ?? defaultInitialWeight,
      availableWeight: availableWeight ?? defaultInitialWeight,
      pricePerKg: pricePerKg ?? PricePerKg.fromAmount(5000),
      totalPrice: totalPrice ?? Price.fromAmount(50000),
      size: size ?? 'Large',
      market: market ?? 'Test Market',
      images: images ?? [],
      species: species ?? createSpecies(),
      fisherId: fisherId ?? 'fisher-1',
      status: status ?? CatchStatus.available,
      observationId: observationId ?? 'Obs-001',
      locationName: locationName ?? 'Test Location',
      latitude: latitude ?? 4.0511,
      longitude: longitude ?? 9.7679,
    );
  }

  /// Creates a test Offer entity with sensible defaults
  static Offer createOffer({
    String? id,
    String? productId,
    String? fisherId,
    String? buyerId,
    DateTime? dateCreated,
    DateTime? dateUpdated,
    OfferStatus? status,
    OfferTerms? currentTerms,
    OfferTerms? previousTerms,
    UserRole? waitingFor,
    bool? hasUpdateForFisher,
    bool? hasUpdateForBuyer,
  }) {
    final defaultTerms = createOfferTerms();
    final now = DateTime.now();
    return Offer(
      id: id ?? 'test-offer-1',
      productId:
          productId ??
          'test-catch-1', // Assuming catchId was functioning as productId
      fisherId: fisherId ?? 'fisher-1',
      buyerId: buyerId ?? 'buyer-1',
      dateCreated: dateCreated ?? now,
      dateUpdated: dateUpdated ?? now,
      status: status ?? OfferStatus.pending,
      currentTerms: currentTerms ?? defaultTerms,
      previousTerms: previousTerms,
      waitingFor: waitingFor ?? UserRole.fisher,
      hasUpdateForFisher: hasUpdateForFisher ?? true,
      hasUpdateForBuyer: hasUpdateForBuyer ?? true,
    );
  }

  /// Creates a test Order entity with sensible defaults
  static Order createOrder({
    String? id,
    String? offerId,
    String? catchId,
    String? fisherId,
    String? buyerId,
    DateTime? dateCreated,
    DateTime? dateUpdated,
    OrderStatus? status,
    OfferTerms? terms,
    bool? hasReviewFromFisher,
    bool? hasReviewFromBuyer,
    String? cancellationReason,
  }) {
    final now = DateTime.now();
    return Order(
      id: id ?? 'test-order-1',
      offerId: offerId ?? 'test-offer-1',
      catchId: catchId ?? 'test-catch-1',
      fisherId: fisherId ?? 'fisher-1',
      buyerId: buyerId ?? 'buyer-1',
      dateCreated: dateCreated ?? now,
      dateUpdated: dateUpdated ?? now,
      status: status ?? OrderStatus.accepted,
      terms: terms ?? createOfferTerms(),
      hasReviewFromFisher: hasReviewFromFisher ?? false,
      hasReviewFromBuyer: hasReviewFromBuyer ?? false,
      cancellationReason: cancellationReason,
    );
  }

  /// Creates a test User entity with sensible defaults
  static User createUser({
    String? id,
    String? name,
    String? avatarUrl,
    UserRole? currentRole,
    Rating? rating,
    int? reviewCount,
  }) {
    return User(
      id: id ?? 'test-user-1',
      name: name ?? 'Test User',
      avatarUrl: avatarUrl,
      currentRole: currentRole ?? UserRole.fisher,
      rating: rating ?? Rating.fromValue(4.5),
      reviewCount: reviewCount ?? 10,
    );
  }

  /// Creates a test Review entity with sensible defaults
  static Review createReview({
    String? id,
    String? orderId,
    String? reviewerId,
    String? reviewedUserId,
    Rating? rating,
    String? comment,
    DateTime? timestamp,
  }) {
    return Review(
      id: id ?? 'test-review-1',
      orderId: orderId ?? 'test-order-1',
      reviewerId: reviewerId ?? 'reviewer-1',
      reviewedUserId: reviewedUserId ?? 'reviewee-1',
      rating: rating ?? Rating.fromValue(4.5),
      comment: comment,
      timestamp: timestamp ?? DateTime.now(),
    );
  }

  /// Creates a test Species entity with sensible defaults
  static Species createSpecies({
    String? id,
    String? name,
    String? image,
    String? uid,
  }) {
    return Species(
      id: id ?? 'species-1',
      name: name ?? 'Tuna',
      image: image ?? '',
      uid: uid ?? 'species-1',
    );
  }

  // ============================================================================
  // VALUE OBJECTS
  // ============================================================================

  /// Creates a test Weight value object
  static Weight createWeight({double? kilograms, int? grams}) {
    if (grams != null) {
      return Weight.fromGrams(grams);
    }
    return Weight.fromKg(kilograms ?? 10.0);
  }

  /// Creates a test Price value object
  static Price createPrice({int? amount}) {
    return Price.fromAmount(amount ?? 50000);
  }

  /// Creates a test PricePerKg value object
  static PricePerKg createPricePerKg({int? amount}) {
    return PricePerKg.fromAmount(amount ?? 5000);
  }

  /// Creates a test Rating value object
  static Rating createRating({double? value}) {
    return Rating.fromValue(value ?? 4.5);
  }

  /// Creates a test OfferTerms value object
  static OfferTerms createOfferTerms({Weight? weight, Price? totalPrice}) {
    return OfferTerms.create(
      weight: weight ?? Weight.fromKg(5),
      totalPrice: totalPrice ?? Price.fromAmount(25000),
    );
  }

  // ============================================================================
  // LISTS FOR BULK TESTING
  // ============================================================================

  /// Creates a list of test catches
  static List<Catch> createCatchList({int count = 3}) {
    return List.generate(
      count,
      (index) => createCatch(id: 'catch-$index', name: 'Catch $index'),
    );
  }

  /// Creates a list of test offers
  static List<Offer> createOfferList({int count = 3}) {
    return List.generate(count, (index) => createOffer(id: 'offer-$index'));
  }

  /// Creates a list of test users
  static List<User> createUserList({int count = 3}) {
    return List.generate(
      count,
      (index) => createUser(id: 'user-$index', name: 'User $index'),
    );
  }
}
