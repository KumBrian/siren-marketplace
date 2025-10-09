import 'dart:math';

import 'package:siren_marketplace/constants/types.dart';

import 'mock_repo.dart';

class MockRepository {
  static final _random = Random();

  // ---------------------------------------------------------------------------
  // NETWORK IMAGE HELPERS
  // ---------------------------------------------------------------------------
  static String _randomFishImage(int i) =>
      "https://picsum.photos/seed/fish$i/400/300";

  static String _randomUserAvatar(int i) =>
      "https://i.pravatar.cc/150?img=${i + 1}";

  // ---------------------------------------------------------------------------
  // USER ROLE
  // ---------------------------------------------------------------------------
  static Future<Role> getUserRole() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Role.fisher; // default role
  }

  // ---------------------------------------------------------------------------
  // FISHER DATA
  // ---------------------------------------------------------------------------
  static Future<Fisher> getFisher() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final fisher = Fisher(
      id: "f-1",
      name: "John Fisher",
      avatarUrl: _randomUserAvatar(1),
      rating: (_random.nextDouble() * 5).clamp(0, 5),
      reviewCount: 25,
      catches: [],
      orders: [],
      messages: [],
      receivedOffers: [], // Initialize new field
    );

    final List<Offer> allOffers = []; // Collect all offers here

    final catches = List.generate(5, (i) {
      final initialWeight = 10.0 + _random.nextInt(20);
      final availableWeight = max(
        0.0,
        initialWeight - _random.nextDouble() * initialWeight,
      );

      // Create the catch *before* the offers
      final catchItem = Catch(
        catchId: "c-$i",
        name: "Catch #$i",
        datePosted: DateTime.now()
            .subtract(Duration(days: i))
            .toIso8601String(),
        size: "${10 + i} cm",
        initialWeight: initialWeight,
        availableWeight: availableWeight,
        pricePerKg: 2000 + _random.nextInt(500).toDouble(),
        total: availableWeight * (2000 + _random.nextInt(500)),
        images: [_randomFishImage(i)],
        species: Species(id: "s-$i", name: "Species $i"),
        market: "Market ${i + 1}",
        offers: [],
        // Will be populated below
        messages: [],
        fisher: fisher,
      );

      final offers = List.generate(3, (j) {
        final buyer = Buyer(
          id: "b-$j",
          name: "Buyer #$j",
          avatarUrl: _randomUserAvatar(j + 10),
          rating: (_random.nextDouble() * 5).clamp(0, 5),
          reviewCount: _random.nextInt(50),
          orders: [],
          madeOffers: [],
          messages: [],
        );

        final offer = Offer(
          // Use unified Offer class
          offerId: "o-${i}_$j",
          catchId: catchItem.catchId,
          fisherId: fisher.id,
          buyerId: buyer.id,

          // ✨ UPDATE: Fisher/Seller details for the Offer
          fisherName: fisher.name,
          fisherAvatar: fisher.avatarUrl,
          fisherRating: fisher.rating,
          fisherReviewCount: fisher.reviewCount,

          // Client details are the Buyer's details
          clientName: buyer.name,
          clientAvatar: buyer.avatarUrl,
          clientRating: buyer.rating,
          clientReviewCount: buyer.reviewCount,

          catchName: catchItem.name,
          catchImages: catchItem.images,

          dateCreated: DateTime.now()
              .subtract(Duration(days: j))
              .toIso8601String(),
          status: OfferStatus.values[j % OfferStatus.values.length],
          pricePerKg: 2000 + _random.nextInt(500).toDouble(),
          price: 5000 + _random.nextInt(2000).toDouble(),
          weight: 5.0 + _random.nextDouble() * 5,
          previousCounterOffer: null,
        );
        allOffers.add(offer);
        return offer;
      });

      final messages = List.generate(2, (j) => _mockConversationPreview(j));
      return catchItem.copyWith(offers: offers, messages: messages);
    });

    fisher.catches.addAll(catches);
    fisher.receivedOffers.addAll(allOffers); // Populate the new field

    // Update Order creation to use the new simplified Order structure
    fisher.orders.addAll(
      allOffers
          .where(
            (o) =>
                o.status == OfferStatus.accepted ||
                o.status == OfferStatus.completed,
          )
          .map((offer) {
            // Find the original Catch to create the Product
            final catchItem = catches.firstWhere(
              (c) => c.catchId == offer.catchId,
            );

            final product = Product(
              id: catchItem.catchId,
              name: catchItem.name,
              totalPrice: (offer.weight * offer.pricePerKg).toInt(),
              species: catchItem.species,
              market: catchItem.market,
              averageSize: catchItem.size,
              availableWeight: catchItem.availableWeight,
              pricePerKg: catchItem.pricePerKg,
              datePosted: catchItem.datePosted,
              seller: Seller(
                id: fisher.id,
                name: fisher.name,
                avatarUrl: fisher.avatarUrl,
                rating: fisher.rating,
                reviewCount: fisher.reviewCount,
              ),
              images: catchItem.images,
            );

            // Create dummy Buyer for the order
            final buyer = Buyer(
              id: offer.buyerId,
              name: offer.clientName,
              avatarUrl: offer.clientAvatar,
              rating: offer.clientRating,
              reviewCount: offer.clientReviewCount,
              orders: [],
              madeOffers: [],
              messages: [],
            );

            return Order(
              orderId: "order-${offer.offerId}",
              offer: offer,
              // Use the Offer
              product: product,
              fisher: fisher,
              buyer: buyer,
              dateUpdated: DateTime.now().toIso8601String(),
            );
          }),
    );

    fisher.messages.addAll(
      List.generate(5, (i) => _mockConversationPreview(i)),
    );

    return fisher;
  }

  // ---------------------------------------------------------------------------
  // BUYER DATA
  // ---------------------------------------------------------------------------
  static Future<Buyer> getBuyer() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final buyer = Buyer(
      id: "b-1",
      name: "Alice Buyer",
      avatarUrl: _randomUserAvatar(20),
      rating: (_random.nextDouble() * 5).clamp(0, 5),
      reviewCount: 10,
      orders: [],
      madeOffers: [],
      // Initialize the new field
      messages: [],
    );

    final List<Catch> mockCatches = [];
    final List<Offer> madeOffers = [];

    // Create catches and the offers made on them
    for (int i = 0; i < 5; i++) {
      final fisher = Fisher(
        id: "f-$i",
        name: "Fisher $i",
        avatarUrl: _randomUserAvatar(i + 30),
        rating: (_random.nextDouble() * 5).clamp(0, 5),
        reviewCount: _random.nextInt(50),
        catches: [],
        orders: [],
        messages: [],
        receivedOffers: [],
      );

      final catchItem = Catch(
        catchId: "c-b-$i",
        name: "Catch #$i",
        datePosted: DateTime.now()
            .subtract(Duration(days: i))
            .toIso8601String(),
        size: "${10 + i} cm",
        initialWeight: 10.0 + _random.nextInt(20),
        availableWeight: 5.0 + _random.nextDouble() * 5,
        pricePerKg: 2000 + _random.nextInt(500).toDouble(),
        total: 5000 + _random.nextInt(2000).toDouble(),
        images: [_randomFishImage(i)],
        species: Species(id: "s-$i", name: "Species $i"),
        market: "Market ${i + 1}",
        offers: [],
        messages: [],
        fisher: fisher,
      );
      mockCatches.add(catchItem);

      final offer = Offer(
        // Use unified Offer class
        offerId: "o-b-$i",
        catchId: catchItem.catchId,
        fisherId: fisher.id,
        buyerId: buyer.id,

        // ✨ UPDATE: Fisher/Seller details for the Offer
        fisherName: fisher.name,
        fisherAvatar: fisher.avatarUrl,
        fisherRating: fisher.rating,
        fisherReviewCount: fisher.reviewCount,

        // Client details are the Fisher's details when viewed by the Buyer
        // This is now redundant with the dedicated fields above, but kept for consistency
        clientName: fisher.name,
        clientAvatar: fisher.avatarUrl,
        clientRating: fisher.rating,
        clientReviewCount: fisher.reviewCount,

        catchName: catchItem.name,
        catchImages: catchItem.images,

        dateCreated: DateTime.now()
            .subtract(Duration(days: i))
            .toIso8601String(),
        status: OfferStatus.values[i % OfferStatus.values.length],
        pricePerKg: catchItem.pricePerKg,
        price: catchItem.pricePerKg * (catchItem.availableWeight / 2),
        weight: catchItem.availableWeight / 2,
        previousCounterOffer: null,
      );
      madeOffers.add(offer);
    }

    buyer.madeOffers.addAll(madeOffers); // Populate the new field

    // Update Order creation to use the new simplified Order structure
    buyer.orders.addAll(
      madeOffers
          .where(
            (o) =>
                o.status == OfferStatus.accepted ||
                o.status == OfferStatus.completed,
          )
          .map((offer) {
            final catchItem = mockCatches.firstWhere(
              (c) => c.catchId == offer.catchId,
            );
            final fisher = catchItem.fisher;

            final product = Product(
              id: catchItem.catchId,
              name: catchItem.name,
              totalPrice: (offer.weight * offer.pricePerKg).toInt(),
              species: catchItem.species,
              market: catchItem.market,
              averageSize: catchItem.size,
              availableWeight: catchItem.availableWeight,
              pricePerKg: catchItem.pricePerKg,
              datePosted: catchItem.datePosted,
              seller: Seller(
                id: fisher.id,
                name: fisher.name,
                avatarUrl: fisher.avatarUrl,
                rating: fisher.rating,
                reviewCount: fisher.reviewCount,
              ),
              images: catchItem.images,
            );

            return Order(
              orderId: "order-b-${offer.offerId}",
              offer: offer,
              // Use the Offer
              product: product,
              fisher: fisher,
              buyer: buyer,
              dateUpdated: DateTime.now().toIso8601String(),
            );
          }),
    );

    buyer.messages.addAll(List.generate(3, (i) => _mockConversationPreview(i)));

    return buyer;
  }

  // ---------------------------------------------------------------------------
  // AVAILABLE PRODUCTS
  // ---------------------------------------------------------------------------
  static Future<List<Product>> getAvailableProducts() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return List.generate(5, (i) {
      final fisher = Fisher(
        id: "f-$i",
        name: "Fisher $i",
        avatarUrl: _randomUserAvatar(i + 40),
        rating: (_random.nextDouble() * 5).clamp(0, 5),
        reviewCount: _random.nextInt(50),
        catches: [],
        orders: [],
        messages: [],
        receivedOffers: [],
      );

      final catchItem = Catch(
        catchId: "c-p-$i",
        name: "Catch #$i",
        datePosted: DateTime.now()
            .subtract(Duration(days: i))
            .toIso8601String(),
        size: "${10 + i} cm",
        initialWeight: 10.0 + _random.nextInt(20),
        availableWeight: 5.0 + _random.nextDouble() * 5,
        pricePerKg: 2000 + _random.nextInt(500).toDouble(),
        total: 5000 + _random.nextInt(2000).toDouble(),
        images: [_randomFishImage(i)],
        species: Species(id: "s-$i", name: "Species $i"),
        market: "Market ${i + 1}",
        offers: [],
        messages: [],
        fisher: fisher,
      );

      return Product(
        id: catchItem.catchId,
        name: catchItem.name,
        totalPrice: (catchItem.availableWeight * catchItem.pricePerKg).toInt(),
        species: catchItem.species,
        market: catchItem.market,
        averageSize: catchItem.size,
        availableWeight: catchItem.availableWeight,
        pricePerKg: catchItem.pricePerKg,
        datePosted: catchItem.datePosted,
        seller: Seller(
          id: fisher.id,
          name: fisher.name,
          avatarUrl: fisher.avatarUrl,
          rating: fisher.rating,
          reviewCount: fisher.reviewCount,
        ),
        images: catchItem.images,
      );
    });
  }

  // ---------------------------------------------------------------------------
  // HELPER
  // ---------------------------------------------------------------------------
  static ConversationPreview _mockConversationPreview(int index) {
    return ConversationPreview(
      messageId: "m-$index",
      clientName: "Client $index",
      lastMessageTime: DateTime.now()
          .subtract(Duration(minutes: index * 5))
          .toIso8601String(),
      lastMessage: "Message content $index",
      unreadCount: _random.nextInt(3),
      avatarPath: _randomUserAvatar(index),
    );
  }
}

// ---------------------------------------------------------------------------
// EXTENSION (No longer needed, copyWith is now a method on Catch)
// ---------------------------------------------------------------------------
// The MockRepositoryImpl class remains the same, assuming it uses the new
// MockRepository static methods.
class MockRepositoryImpl implements Repository {
  final Role _role;

  // The constructor accepts an optional role for role-based mocking
  MockRepositoryImpl({Role role = Role.fisher}) : _role = role;

  @override
  Role get role => _role;

  @override
  Future<Role> getUserRole() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    return _role;
  }

  @override
  Future<Fisher> getFisher() => MockRepository.getFisher();

  @override
  Future<Buyer> getBuyer() => MockRepository.getBuyer();

  @override
  Future<List<Product>> getAvailableProducts() =>
      MockRepository.getAvailableProducts();
}
