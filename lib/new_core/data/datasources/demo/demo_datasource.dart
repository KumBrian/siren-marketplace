// lib/core/data/datasources/demo/demo_datasource.dart

import '../../../domain/enums/catch_status.dart';
import '../../../domain/enums/offer_status.dart';
import '../../../domain/enums/order_status.dart';
import '../../models/catch_model.dart';
import '../../models/offer_model.dart';
import '../../models/order_model.dart';
import '../../models/review_model.dart';
import '../../models/species_model.dart';
import '../../models/user_model.dart';
import '../interfaces/i_catch_datasource.dart';
import '../interfaces/i_offer_datasource.dart';
import '../interfaces/i_order_datasource.dart';
import '../interfaces/i_review_datasource.dart';
import '../interfaces/i_session_datasource.dart';
import '../interfaces/i_user_datasource.dart';

// ============================================================================
// SEPARATE DATA SOURCE CLASSES (No conflicting overrides)
// ============================================================================

class DemoUserDataSource implements IUserDataSource {
  final Map<String, UserModel> _users;

  DemoUserDataSource(this._users);

  @override
  Future<UserModel?> getById(String userId) async {
    await Future.delayed(Duration(milliseconds: 100));
    return _users[userId];
  }

  @override
  Future<List<UserModel>> getByIds(List<String> userIds) async {
    await Future.delayed(Duration(milliseconds: 100));
    return userIds.map((id) => _users[id]).whereType<UserModel>().toList();
  }

  @override
  Future<void> create(UserModel user) async {
    await Future.delayed(Duration(milliseconds: 50));
    _users[user.id] = user;
  }

  @override
  Future<void> update(UserModel user) async {
    await Future.delayed(Duration(milliseconds: 50));
    _users[user.id] = user;
  }

  @override
  Future<void> updateRating({
    required String userId,
    required double rating,
    required int reviewCount,
  }) async {
    await Future.delayed(Duration(milliseconds: 50));
    final user = _users[userId];
    if (user != null) {
      _users[userId] = UserModel(
        id: user.id,
        name: user.name,
        avatarUrl: user.avatarUrl,
        rating: rating,
        reviewCount: reviewCount,
        currentRole: user.currentRole,
      );
    }
  }

  @override
  Future<bool> exists(String userId) async {
    await Future.delayed(Duration(milliseconds: 50));
    return _users.containsKey(userId);
  }
}

class DemoCatchDataSource implements ICatchDataSource {
  final Map<String, CatchModel> _catches;

  DemoCatchDataSource(this._catches);

  @override
  Future<String> create(CatchModel catch_) async {
    await Future.delayed(Duration(milliseconds: 100));
    _catches[catch_.id] = catch_;
    return catch_.id;
  }

  @override
  Future<CatchModel?> getById(String catchId) async {
    await Future.delayed(Duration(milliseconds: 100));
    return _catches[catchId];
  }

  @override
  Future<List<CatchModel>> getByFisherId(String fisherId) async {
    await Future.delayed(Duration(milliseconds: 100));
    return _catches.values.where((c) => c.fisherId == fisherId).toList();
  }

  @override
  Future<List<CatchModel>> getByStatus(CatchStatus status) async {
    await Future.delayed(Duration(milliseconds: 100));
    return _catches.values.where((c) => c.status == status.name).toList();
  }

  @override
  Future<List<CatchModel>> getAll() async {
    await Future.delayed(Duration(milliseconds: 100));
    return _catches.values.toList();
  }

  @override
  Future<void> update(CatchModel catch_) async {
    await Future.delayed(Duration(milliseconds: 50));
    _catches[catch_.id] = catch_;
  }

  @override
  Future<void> delete(String catchId) async {
    await Future.delayed(Duration(milliseconds: 50));
    _catches.remove(catchId);
  }

  @override
  Future<void> updateBatch(List<CatchModel> catches) async {
    await Future.delayed(Duration(milliseconds: 100));
    for (final catch_ in catches) {
      _catches[catch_.id] = catch_;
    }
  }

  @override
  Future<void> deleteBatch(List<String> catchIds) async {
    await Future.delayed(Duration(milliseconds: 100));
    for (final id in catchIds) {
      _catches.remove(id);
    }
  }
}

class DemoOfferDataSource implements IOfferDataSource {
  final Map<String, OfferModel> _offers;

  DemoOfferDataSource(this._offers);

  @override
  Future<String> create(OfferModel offer) async {
    await Future.delayed(Duration(milliseconds: 100));
    _offers[offer.id] = offer;
    return offer.id;
  }

  @override
  Future<OfferModel?> getById(String offerId) async {
    await Future.delayed(Duration(milliseconds: 100));
    return _offers[offerId];
  }

  @override
  Future<List<OfferModel>> getByCatchId(String catchId) async {
    await Future.delayed(Duration(milliseconds: 100));
    return _offers.values.where((o) => o.catchId == catchId).toList();
  }

  @override
  Future<List<OfferModel>> getByBuyerId(String buyerId) async {
    await Future.delayed(Duration(milliseconds: 100));
    return _offers.values.where((o) => o.buyerId == buyerId).toList();
  }

  @override
  Future<List<OfferModel>> getByFisherId(String fisherId) async {
    await Future.delayed(Duration(milliseconds: 100));
    return _offers.values.where((o) => o.fisherId == fisherId).toList();
  }

  @override
  Future<List<OfferModel>> getByCatchIds(List<String> catchIds) async {
    await Future.delayed(Duration(milliseconds: 100));
    return _offers.values.where((o) => catchIds.contains(o.catchId)).toList();
  }

  @override
  Future<List<OfferModel>> getByStatus(OfferStatus status) async {
    await Future.delayed(Duration(milliseconds: 100));
    return _offers.values.where((o) => o.status == status.name).toList();
  }

  @override
  Future<void> update(OfferModel offer) async {
    await Future.delayed(Duration(milliseconds: 50));
    _offers[offer.id] = offer;
  }

  @override
  Future<void> delete(String offerId) async {
    await Future.delayed(Duration(milliseconds: 50));
    _offers.remove(offerId);
  }

  @override
  Future<T> transaction<T>(Future<T> Function() action) async {
    return await action();
  }
}

class DemoOrderDataSource implements IOrderDataSource {
  final Map<String, OrderModel> _orders;

  DemoOrderDataSource(this._orders);

  @override
  Future<String> create(OrderModel order) async {
    await Future.delayed(Duration(milliseconds: 100));
    _orders[order.id] = order;
    return order.id;
  }

  @override
  Future<OrderModel?> getById(String orderId) async {
    await Future.delayed(Duration(milliseconds: 100));
    return _orders[orderId];
  }

  @override
  Future<OrderModel?> getByOfferId(String offerId) async {
    await Future.delayed(Duration(milliseconds: 100));
    try {
      return _orders.values.firstWhere((o) => o.offerId == offerId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<OrderModel>> getByUserId(String userId) async {
    await Future.delayed(Duration(milliseconds: 100));
    return _orders.values
        .where((o) => o.fisherId == userId || o.buyerId == userId)
        .toList();
  }

  @override
  Future<List<OrderModel>> getByFisherId(String fisherId) async {
    await Future.delayed(Duration(milliseconds: 100));
    return _orders.values.where((o) => o.fisherId == fisherId).toList();
  }

  @override
  Future<List<OrderModel>> getByBuyerId(String buyerId) async {
    await Future.delayed(Duration(milliseconds: 100));
    return _orders.values.where((o) => o.buyerId == buyerId).toList();
  }

  @override
  Future<List<OrderModel>> getByStatus(OrderStatus status) async {
    await Future.delayed(Duration(milliseconds: 100));
    return _orders.values.where((o) => o.status == status.name).toList();
  }

  @override
  Future<void> update(OrderModel order) async {
    await Future.delayed(Duration(milliseconds: 50));
    _orders[order.id] = order;
  }

  @override
  Future<void> delete(String orderId) async {
    await Future.delayed(Duration(milliseconds: 50));
    _orders.remove(orderId);
  }

  @override
  Future<T> transaction<T>(Future<T> Function() action) async {
    return await action();
  }
}

class DemoReviewDataSource implements IReviewDataSource {
  final Map<String, ReviewModel> _reviews;

  DemoReviewDataSource(this._reviews);

  @override
  Future<String> create(ReviewModel review) async {
    await Future.delayed(Duration(milliseconds: 100));
    _reviews[review.id] = review;
    return review.id;
  }

  @override
  Future<ReviewModel?> getById(String reviewId) async {
    await Future.delayed(Duration(milliseconds: 100));
    return _reviews[reviewId];
  }

  @override
  Future<List<ReviewModel>> getReviewsForUser(String userId) async {
    await Future.delayed(Duration(milliseconds: 100));
    return _reviews.values.where((r) => r.reviewedUserId == userId).toList();
  }

  @override
  Future<List<ReviewModel>> getReviewsByUser(String userId) async {
    await Future.delayed(Duration(milliseconds: 100));
    return _reviews.values.where((r) => r.reviewerId == userId).toList();
  }

  @override
  Future<List<ReviewModel>> getReviewsForOrder(String orderId) async {
    await Future.delayed(Duration(milliseconds: 100));
    return _reviews.values.where((r) => r.orderId == orderId).toList();
  }

  @override
  Future<bool> hasReview({
    required String orderId,
    required String reviewerId,
    required String reviewedUserId,
  }) async {
    await Future.delayed(Duration(milliseconds: 50));
    return _reviews.values.any(
      (r) =>
          r.orderId == orderId &&
          r.reviewerId == reviewerId &&
          r.reviewedUserId == reviewedUserId,
    );
  }

  @override
  Future<void> delete(String reviewId) async {
    await Future.delayed(Duration(milliseconds: 50));
    _reviews.remove(reviewId);
  }

  @override
  Future<T> transaction<T>(Future<T> Function() action) async {
    return await action();
  }
}

class DemoSessionDataSource implements ISessionDataSource {
  UserModel? _currentUser;
  String? _currentRole;

  DemoSessionDataSource({UserModel? initialUser, String? initialRole}) {
    _currentUser = initialUser;
    _currentRole = initialRole;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    await Future.delayed(Duration(milliseconds: 50));
    return _currentUser;
  }

  @override
  Future<String?> getCurrentRole() async {
    await Future.delayed(Duration(milliseconds: 50));
    return _currentRole;
  }

  @override
  Future<void> saveCurrentUser(UserModel user) async {
    await Future.delayed(Duration(milliseconds: 50));
    _currentUser = user;
  }

  @override
  Future<void> saveCurrentRole(String role) async {
    await Future.delayed(Duration(milliseconds: 50));
    _currentRole = role;
  }

  @override
  Future<void> clearSession() async {
    await Future.delayed(Duration(milliseconds: 50));
    _currentUser = null;
    _currentRole = null;
  }

  @override
  Future<bool> isLoggedIn() async {
    await Future.delayed(Duration(milliseconds: 50));
    return _currentUser != null;
  }
}

// ============================================================================
// DATA SOURCE FACTORY & SEEDER
// ============================================================================

class DemoDataSourceFactory {
  static final Map<String, UserModel> _users = {};
  static final Map<String, CatchModel> _catches = {};
  static final Map<String, OfferModel> _offers = {};
  static final Map<String, OrderModel> _orders = {};
  static final Map<String, ReviewModel> _reviews = {};
  static bool _initialized = false;

  /// Seed demo data (call once)
  static void seedData() {
    if (_initialized) return;
    _initialized = true;

    // Seed Users
    final fisher1 = UserModel(
      id: 'fisher-1',
      name: 'John Fisher',
      avatarUrl: 'https://i.pravatar.cc/150?u=fisher1',
      rating: 4.5,
      reviewCount: 12,
      currentRole: 'fisher',
    );

    final fisher2 = UserModel(
      id: 'fisher-2',
      name: 'Maria Ocean',
      avatarUrl: 'https://i.pravatar.cc/150?u=fisher2',
      rating: 4.8,
      reviewCount: 24,
      currentRole: 'fisher',
    );

    final buyer1 = UserModel(
      id: 'buyer-1',
      name: 'Alice Buyer',
      avatarUrl: 'https://i.pravatar.cc/150?u=buyer1',
      rating: 4.2,
      reviewCount: 8,
      currentRole: 'buyer',
    );

    final buyer2 = UserModel(
      id: 'buyer-2',
      name: 'Bob Market',
      avatarUrl: 'https://i.pravatar.cc/150?u=buyer2',
      rating: 4.6,
      reviewCount: 15,
      currentRole: 'buyer',
    );

    _users[fisher1.id] = fisher1;
    _users[fisher2.id] = fisher2;
    _users[buyer1.id] = buyer1;
    _users[buyer2.id] = buyer2;

    // Seed Species
    final species1 = SpeciesModel(
      id: 'species-1',
      name: 'Tuna',
      scientificName: 'Thunnus',
    );

    final species2 = SpeciesModel(
      id: 'species-2',
      name: 'Salmon',
      scientificName: 'Salmo salar',
    );

    final species3 = SpeciesModel(
      id: 'species-3',
      name: 'Mackerel',
      scientificName: 'Scomber',
    );

    // Seed Catches
    final now = DateTime.now();

    final catch1 = CatchModel(
      id: 'catch-1',
      name: 'Fresh Tuna',
      datePosted: now.subtract(Duration(days: 2)).toIso8601String(),
      initialWeightGrams: 5000,
      // 5kg
      availableWeightGrams: 5000,
      pricePerKgAmount: 1500,
      // $15/kg
      totalPriceAmount: 7500,
      // $75 total
      size: 'Large',
      market: 'Port Market',
      images: [
        'https://images.unsplash.com/photo-1544943910-4c1dc44aab44?w=400',
        'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=400',
      ],
      species: species1,
      fisherId: fisher1.id,
      status: CatchStatus.available.name,
    );

    final catch2 = CatchModel(
      id: 'catch-2',
      name: 'Wild Salmon',
      datePosted: now.subtract(Duration(days: 1)).toIso8601String(),
      initialWeightGrams: 3000,
      // 3kg
      availableWeightGrams: 3000,
      pricePerKgAmount: 2000,
      // $20/kg
      totalPriceAmount: 6000,
      // $60 total
      size: 'Medium',
      market: 'Coastal Market',
      images: [
        'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=400',
      ],
      species: species2,
      fisherId: fisher2.id,
      status: CatchStatus.available.name,
    );

    final catch3 = CatchModel(
      id: 'catch-3',
      name: 'Mackerel Batch',
      datePosted: now.subtract(Duration(days: 5)).toIso8601String(),
      initialWeightGrams: 10000,
      // 10kg
      availableWeightGrams: 7000,
      // 7kg remaining (3kg sold)
      pricePerKgAmount: 800,
      // $8/kg
      totalPriceAmount: 5600,
      // $56 for remaining
      size: 'Bulk',
      market: 'Port Market',
      images: [
        'https://images.unsplash.com/photo-1534043464124-3be32fe000c9?w=400',
      ],
      species: species3,
      fisherId: fisher1.id,
      status: CatchStatus.available.name,
    );

    final catch4 = CatchModel(
      id: 'catch-4',
      name: 'Premium Tuna',
      datePosted: now.subtract(Duration(days: 8)).toIso8601String(),
      initialWeightGrams: 4000,
      availableWeightGrams: 4000,
      pricePerKgAmount: 1800,
      totalPriceAmount: 7200,
      size: 'Large',
      market: 'Port Market',
      images: [
        'https://images.unsplash.com/photo-1544943910-4c1dc44aab44?w=400',
      ],
      species: species1,
      fisherId: fisher2.id,
      status: CatchStatus.expired.name, // Expired for testing
    );

    _catches[catch1.id] = catch1;
    _catches[catch2.id] = catch2;
    _catches[catch3.id] = catch3;
    _catches[catch4.id] = catch4;

    // Seed Offers
    final offer1 = OfferModel(
      id: 'offer-1',
      catchId: catch1.id,
      fisherId: fisher1.id,
      buyerId: buyer1.id,
      currentPriceAmount: 7000,
      // $70 (countered from $75)
      currentWeightGrams: 5000,
      currentPricePerKgAmount: 1400,
      // $14/kg
      previousPriceAmount: 7500,
      previousWeightGrams: 5000,
      previousPricePerKgAmount: 1500,
      status: OfferStatus.pending.name,
      dateCreated: now.subtract(Duration(hours: 3)).toIso8601String(),
      dateUpdated: now.subtract(Duration(hours: 1)).toIso8601String(),
      waitingFor: 'fisher', // Fisher's turn to respond
    );

    final offer2 = OfferModel(
      id: 'offer-2',
      catchId: catch2.id,
      fisherId: fisher2.id,
      buyerId: buyer2.id,
      currentPriceAmount: 5500,
      // $55 (countered from $60)
      currentWeightGrams: 3000,
      currentPricePerKgAmount: 1833,
      // ~$18.33/kg
      previousPriceAmount: null,
      previousWeightGrams: null,
      previousPricePerKgAmount: null,
      status: OfferStatus.pending.name,
      dateCreated: now.subtract(Duration(hours: 2)).toIso8601String(),
      dateUpdated: now.subtract(Duration(hours: 2)).toIso8601String(),
      waitingFor: 'fisher',
    );

    final offer3 = OfferModel(
      id: 'offer-3',
      catchId: catch3.id,
      fisherId: fisher1.id,
      buyerId: buyer1.id,
      currentPriceAmount: 2400,
      // $24 for 3kg
      currentWeightGrams: 3000,
      currentPricePerKgAmount: 800,
      previousPriceAmount: null,
      previousWeightGrams: null,
      previousPricePerKgAmount: null,
      status: OfferStatus.accepted.name,
      dateCreated: now.subtract(Duration(days: 4)).toIso8601String(),
      dateUpdated: now.subtract(Duration(days: 4)).toIso8601String(),
      waitingFor: null,
    );

    _offers[offer1.id] = offer1;
    _offers[offer2.id] = offer2;
    _offers[offer3.id] = offer3;

    // Seed Orders (from accepted offer3)
    final order1 = OrderModel(
      id: 'order-1',
      offerId: offer3.id,
      catchId: catch3.id,
      fisherId: fisher1.id,
      buyerId: buyer1.id,
      termsPrice: 2400,
      termsWeight: 3000,
      termsPricePerKg: 800,
      status: OrderStatus.completed.name,
      dateCreated: now.subtract(Duration(days: 4)).toIso8601String(),
      dateUpdated: now.subtract(Duration(days: 3)).toIso8601String(),
      hasReviewFromFisher: false,
      hasReviewFromBuyer: false,
    );

    _orders[order1.id] = order1;

    // Seed Reviews
    final review1 = ReviewModel(
      id: 'review-1',
      orderId: 'order-old',
      // Simulating old order
      reviewerId: buyer2.id,
      reviewedUserId: fisher2.id,
      ratingValue: 5.0,
      comment: 'Excellent quality fish!',
      timestamp: now.subtract(Duration(days: 10)).toIso8601String(),
    );

    final review2 = ReviewModel(
      id: 'review-2',
      orderId: 'order-old-2',
      reviewerId: buyer1.id,
      reviewedUserId: fisher1.id,
      ratingValue: 4.5,
      comment: 'Good catch, fast delivery',
      timestamp: now.subtract(Duration(days: 15)).toIso8601String(),
    );

    _reviews[review1.id] = review1;
    _reviews[review2.id] = review2;
  }

  /// Create all data sources with shared storage
  static DemoDataSources create() {
    seedData();

    return DemoDataSources(
      userDataSource: DemoUserDataSource(_users),
      catchDataSource: DemoCatchDataSource(_catches),
      offerDataSource: DemoOfferDataSource(_offers),
      orderDataSource: DemoOrderDataSource(_orders),
      reviewDataSource: DemoReviewDataSource(_reviews),
      sessionDataSource: DemoSessionDataSource(
        initialUser: null,
        initialRole: null,
      ),
    );
  }

  /// Get a specific user for auto-login
  static UserModel? getUserById(String id) {
    seedData();
    return _users[id];
  }
}

/// Container for all demo data sources
class DemoDataSources {
  final DemoUserDataSource userDataSource;
  final DemoCatchDataSource catchDataSource;
  final DemoOfferDataSource offerDataSource;
  final DemoOrderDataSource orderDataSource;
  final DemoReviewDataSource reviewDataSource;
  final DemoSessionDataSource sessionDataSource;

  DemoDataSources({
    required this.userDataSource,
    required this.catchDataSource,
    required this.offerDataSource,
    required this.orderDataSource,
    required this.reviewDataSource,
    required this.sessionDataSource,
  });
}
