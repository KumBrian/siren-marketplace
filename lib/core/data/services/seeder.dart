import 'dart:math';

import 'package:siren_marketplace/core/data/database/database_helper.dart';
import 'package:siren_marketplace/core/data/repositories/user_repository.dart';
import 'package:siren_marketplace/core/di/injector.dart';
import 'package:siren_marketplace/core/domain/entities/catch.dart';
import 'package:siren_marketplace/core/domain/entities/offer.dart';
import 'package:siren_marketplace/core/domain/entities/order.dart';
import 'package:siren_marketplace/core/domain/entities/species.dart';
import 'package:siren_marketplace/core/domain/enums/catch_status.dart';
import 'package:siren_marketplace/core/domain/enums/offer_status.dart';
import 'package:siren_marketplace/core/domain/enums/user_role.dart';
import 'package:siren_marketplace/core/domain/repositories/i_catch_repository.dart';
import 'package:siren_marketplace/core/domain/repositories/i_offer_repository.dart';
import 'package:siren_marketplace/core/domain/repositories/i_order_repository.dart';
import 'package:siren_marketplace/core/domain/services/negotiation_service.dart';
import 'package:siren_marketplace/core/domain/value_objects/offer_terms.dart';
import 'package:siren_marketplace/core/domain/value_objects/price.dart';
import 'package:siren_marketplace/core/domain/value_objects/price_per_kg.dart';
import 'package:siren_marketplace/core/domain/value_objects/weight.dart';
import 'package:siren_marketplace/core/models/app_user.dart';

import 'package:siren_marketplace/features/chat/data/conversation_repository.dart';
import 'package:siren_marketplace/features/chat/data/models/conversation_preview.dart';
import 'package:siren_marketplace/features/fisher/data/models/fisher.dart';
import 'package:uuid/uuid.dart';

// NOTE: This seeder assumes you updated your domain models to use grams
// for weight storage. Required model fields (examples):
// Catch: initialWeightGrams (int), availableWeightGrams (int), pricePerKg (int), total (int)
// Offer: weightGrams (int), pricePerKg (int), price (int)
// Order/fromOfferAndCatch should also expect grams-based fields or compute from the provided offer/catch.
// Keep getters on the models to expose kg values for UI (e.g. weightKg => initialWeightGrams / 1000.0)

const _uuid = Uuid();
final _rng = Random();

class CatchSeeder {
  // Dummy Avatars
  static final List<String> _avatarUrls = List.generate(
    10,
    (index) => 'https://i.pravatar.cc/150?img=${index + 1}',
  );

  // Dummy Catch Images
  static final List<String> _catchImageUrls = List.generate(
    10,
    (index) => 'https://picsum.photos/400/300?random=${500 + index}',
  );

  static final List<Species> _speciesList = [
    const Species(id: 'grey-shrimp', name: 'Grey Shrimp'),
    const Species(id: 'pink-shrimp', name: 'Pink Shrimp'),
    const Species(id: 'tiger-shrimp', name: 'Tiger Shrimp'),
    const Species(id: 'prawns', name: 'Prawns'),
  ];

  static const List<String> _markets = [
    'Yopwe',
    'Douala Port',
    'Down Beach Limbe',
    'Kribi Hub',
    'Edea Market',
  ];

  static final List<Map<String, dynamic>> _userMaps = [
    {
      'id': 'fisher_id_1',
      'name': 'Captain Jack',
      'avatar_url': _avatarUrls[0],
      'rating': 4.8,
      'review_count': 124,
      'role': UserRole.fisher.name,
    },
    {
      'id': 'fisher_id_2',
      'name': 'Ocean Master',
      'avatar_url': _avatarUrls[1],
      'rating': 4.5,
      'review_count': 90,
      'role': UserRole.fisher.name,
    },
    {
      'id': 'buyer_id_1',
      'name': 'Seafood Buyer Co',
      'avatar_url': _avatarUrls[2],
      'rating': 4.9,
      'review_count': 210,
      'role': UserRole.buyer.name,
    },
    {
      'id': 'buyer_id_2',
      'name': 'Market Pro Supply',
      'avatar_url': _avatarUrls[3],
      'rating': 4.7,
      'review_count': 150,
      'role': UserRole.buyer.name,
    },
  ];

  // -------------------------------
  // USERS
  // -------------------------------
  Future<void> seedUsers() async {
    final repository = sl<UserRepository>();
    final existingUsers = await repository.getAllUserMaps();
    if (existingUsers.isEmpty) {
      for (final map in _userMaps) {
        await repository.insertUser(AppUser.fromMap(map));
      }
      print('Users seeded.');
    } else {
      print('Users exist. Skipping.');
    }
  }

  // -------------------------------
  // WEIGHT GENERATORS (grams, 0.1kg precision)
  // -------------------------------
  /// Generates a random weight in grams with 0.1kg (100g) steps.
  /// maxKg is inclusive maximum kg (e.g. 100 -> up to 100.0 kg).
  int generateWeightGramsOneDecimal(int maxKg) {
    final steps = maxKg * 10; // number of 0.1kg steps
    final step = _rng.nextInt(steps + 1); // 0..steps
    return step * 100; // step * 0.1kg -> grams
  }

  // -------------------------------
  // CATCHES
  // -------------------------------
  Future<List<Catch>> seedCatches() async {
    final repository = sl<ICatchRepository>();
    final existing = await repository.getAvailableCatches();
    if (existing.isNotEmpty) {
      print('Catches exist. Returning existing.');
      return existing;
    }

    final List<Catch> seeded = [];
    final now = DateTime.now();

    final List<String> fisherIds = _userMaps
        .where((user) => user['role'] == UserRole.fisher.name)
        .map((user) => user['id'] as String)
        .toList();

    for (int i = 0; i < 15; i++) {
      final species = _speciesList[i % _speciesList.length];

      // Weight stored as grams (integer)
      final int initialWeightGrams = generateWeightGramsOneDecimal(100);

      // pricePerKg remains integer (e.g. 1989)
      final int pricePerKg = 500 + _rng.nextInt(2000);

      final String market = _markets[i % _markets.length];

      final fisherId = fisherIds[_rng.nextInt(fisherIds.length)];

      CatchStatus status;
      int availableWeightGrams = initialWeightGrams;
      if (i < 3) {
        status = CatchStatus.available;
      } else if (i < 5) {
        status = CatchStatus.expired;
        // half the weight (integer arithmetic) — round down to nearest 100g
        availableWeightGrams = (initialWeightGrams * 50) ~/ 100;
        // normalize to 100g steps
        availableWeightGrams = (availableWeightGrams / 100).floor() * 100;
      } else if (i == 14) {
        status = CatchStatus.soldOut;
        availableWeightGrams = 0;
      } else {
        status = CatchStatus.available;
      }

      // Generate between 1–4 random unique image URLs
      final imageCount = _rng.nextInt(4) + 1; // gives 1 to 4
      final shuffled = List.of(_catchImageUrls)..shuffle(_rng);
      final randomImages = shuffled.take(imageCount).toList();

      // total price computed in integer arithmetic: (grams * pricePerKg) / 1000
      final int totalPrice = (initialWeightGrams * pricePerKg) ~/ 1000;

      final c = Catch(
        id: _uuid.v4(),
        name: species.name,
        datePosted: now.subtract(Duration(hours: i * 5)),
        // new grams fields
        initialWeight: Weight.fromGrams(initialWeightGrams),
        availableWeight: Weight.fromGrams(availableWeightGrams),
        pricePerKg: PricePerKg.fromAmount(pricePerKg),
        totalPrice: Price.fromAmount(totalPrice),
        size: species.id != "prawns"
            ? _rng.nextInt(20).toString()
            : i < 7
            ? 'Medium'
            : 'Large',
        market: market,
        species: species,
        fisherId: fisherId,
        images: randomImages,
        status: status,
      );

      await repository.create(c);
      seeded.add(c);
    }

    print('${seeded.length} catches seeded.');
    return seeded;
  }

  // -------------------------------
  // OFFERS
  // -------------------------------
  Future<List<Offer>> seedOffers(List<Catch> seededCatches) async {
    final offerRepository = sl<IOfferRepository>();
    final existing = await offerRepository.getAllOffers();
    if (existing.isNotEmpty) {
      print('Offers exist. Returning existing.');
      return existing;
    }

    final buyer1 = AppUser.fromMap(
      _userMaps.firstWhere((m) => m['id'] == 'buyer_id_1'),
    );
    final buyer2 = AppUser.fromMap(
      _userMaps.firstWhere((m) => m['id'] == 'buyer_id_2'),
    );

    final fishers = _userMaps
        .where((m) => m['role'] == UserRole.fisher.name)
        .map((m) => AppUser.fromMap(m))
        .toList();

    final Random random = Random();
    final List<Offer> allOffers = [];
    final buyers = [buyer1, buyer2];

    for (int i = 0; i < seededCatches.length; i++) {
      final catchItem = seededCatches[i];
      final buyer = buyers[i % buyers.length];

      final fisher = fishers.firstWhere((f) => f.id == catchItem.fisherId);

      if (catchItem.status == CatchStatus.available ||
          catchItem.status == CatchStatus.expired) {
        // Pending offer — 50% of available weight
        final int pendingWeightGrams =
            ((catchItem.availableWeight.grams * 50) ~/ 100 / 100).floor() * 100;

        // discounted pricePerKg (integer) — apply 5% discount and round
        final int pendingPricePerKg =
            ((catchItem.pricePerKg.amountPerKg * 95) ~/ 100);

        final int pendingPrice =
            (pendingWeightGrams * pendingPricePerKg) ~/ 1000;

        final pendingOffer = Offer(
          id: _uuid.v4(),
          catchId: catchItem.id,
          fisherId: catchItem.fisherId,
          buyerId: buyer.id,
          currentTerms: OfferTerms.create(
            totalPrice: Price.fromAmount(pendingPrice),
            weight: Weight.fromGrams(pendingWeightGrams),
          ),
          status: OfferStatus.pending,
          dateCreated: DateTime.now(),
          previousTerms: null,
          dateUpdated: DateTime.now(),
          waitingFor: UserRole.values[random.nextInt(2)],
        );

        await offerRepository.create(pendingOffer);
        allOffers.add(pendingOffer);

        // Accepted (every 4th catch) — 20% of available weight
        if (i % 4 == 0 && catchItem.status != CatchStatus.soldOut) {
          final int acceptedWeightGrams =
              ((catchItem.availableWeight.grams * 20) ~/ 100 / 100).floor() *
              100;

          final int acceptedPrice =
              (acceptedWeightGrams * catchItem.pricePerKg.amountPerKg) ~/ 1000;

          final acceptedOffer = Offer(
            id: _uuid.v4(),
            catchId: catchItem.id,
            fisherId: catchItem.fisherId,
            buyerId: buyer.id,
            currentTerms: OfferTerms.create(
              totalPrice: Price.fromAmount(acceptedPrice),
              weight: Weight.fromGrams(acceptedWeightGrams),
            ),
            status: OfferStatus.accepted,
            dateCreated: DateTime.now().subtract(Duration(days: 1)),
            previousTerms: null,
            dateUpdated: DateTime.now(),
          );

          await offerRepository.create(acceptedOffer);
          allOffers.add(acceptedOffer);
        }
      }
    }

    print('${allOffers.length} offers seeded.');
    return allOffers;
  }

  // -------------------------------
  // ORDERS
  // -------------------------------
  Future<List<Order>> seedOrders() async {
    final orderRepository = sl<IOrderRepository>();
    final offerRepository = sl<IOfferRepository>();
    final catchRepository = sl<ICatchRepository>();
    final negotiationService = sl<NegotiationService>();
    final userRepository = sl<UserRepository>();

    final existing = await orderRepository.getAllOrders();
    if (existing.isNotEmpty) {
      print('Orders exist. Skipping.');
      return [];
    }

    final allOffers = await offerRepository.getAllOffers();
    final acceptedOffers = allOffers
        .where((o) => o.status == OfferStatus.accepted)
        .toList();

    final List<Order> orders = [];
    for (final offer in acceptedOffers) {
      final catchItem = await catchRepository.getById(offer.catchId);
      final fisherMap = await userRepository.getUserMapById(offer.fisherId);
      if (catchItem == null) continue;

      final Order newOrder = await negotiationService.acceptOffer(
        offerId: offer.id,
        userId: offer.fisherId,
      );

      await orderRepository.create(newOrder);
      orders.add(newOrder);
    }

    print('${orders.length} orders seeded.');
    return orders;
  }

  // -------------------------------
  // CONVERSATIONS
  // -------------------------------
  Future<void> seedConversations(List<Offer> allOffers) async {
    final conversationRepository = sl<ConversationRepository>();
    final catchRepository = sl<ICatchRepository>();
    final userRepository = sl<UserRepository>();

    final Map<String, Offer> uniqueConversations = {};
    for (final offer in allOffers) {
      final key = '${offer.buyerId}-${offer.fisherId}';
      if (!uniqueConversations.containsKey(key)) {
        uniqueConversations[key] = offer;
      }
    }

    final fisherName = await userRepository.getUserMapById(
      uniqueConversations.values.first.fisherId,
    );
    final buyerName = await userRepository.getUserMapById(
      uniqueConversations.values.first.buyerId,
    );
    final catchItem = await catchRepository.getById(
      uniqueConversations.values.first.catchId,
    );

    for (final offer in uniqueConversations.values) {
      final conv = ConversationPreview(
        id: _uuid.v4(),
        buyerId: offer.buyerId,
        fisherId: offer.fisherId,
        contactName: buyerName['name'],
        contactAvatarPath: buyerName['avatarUrl'],
        lastMessage: offer.status == OfferStatus.accepted
            ? 'The offer for ${catchItem?.name} was accepted. Awaiting payment.'
            : 'Is this price negotiable for a bulk order?',
        lastMessageTime: offer.dateCreated.toIso8601String(),
        unreadCount: offer.status == OfferStatus.pending ? 1 : 0,
      );

      await conversationRepository.insertOrUpdateConversation(conv);
    }

    print('${uniqueConversations.length} conversations seeded.');
  }

  // -------------------------------
  // REVIEWS & RATINGS
  // -------------------------------
  Future<void> seedReviews(List<Order> seededOrders) async {
    final userRepository = sl<UserRepository>();
    final databaseHelper = sl<DatabaseHelper>();

    final List<String> reviewMessages = [
      "Excellent quality and fast service. Highly recommended!",
      "The catch was exactly as described. Very reliable fisher.",
      "Fair price and great communication. Will buy again.",
      "Smooth transaction. Professional buyer, prompt payment.",
      "The product was fresh, but delivery was a little slow.",
      "A pleasure to deal with this user.",
      "Satisfied with the purchase, no issues.",
    ];

    int reviewCount = 0;

    for (int i = 0; i < seededOrders.length; i++) {
      if (i % 3 != 0) continue;

      final order = seededOrders[i];
      final raterBuyer = _userMaps.firstWhere((m) => m['id'] == order.buyerId);
      final ratedFisher = _userMaps.firstWhere(
        (m) => m['id'] == order.fisherId,
      );

      final fisherToBuyerRating = (_rng.nextInt(2) + 4)
          .toDouble(); // 4.0 or 5.0
      final buyerReviewMessage =
          reviewMessages[_rng.nextInt(reviewMessages.length)];

      await databaseHelper.insertRating({
        'rating_id': _uuid.v4(),
        'order_id': order.id,
        'rater_id': order.fisherId,
        'rated_user_id': order.buyerId,
        'rating_value': fisherToBuyerRating,
        'message': buyerReviewMessage,
        'timestamp': DateTime.now()
            .subtract(Duration(hours: 10 + i * 2))
            .toIso8601String(),
      });

      await databaseHelper.updateOrderRatingStatus(
        orderId: order.id,
        isRatingBuyer: true,
        ratingValue: fisherToBuyerRating,
        message: buyerReviewMessage,
      );

      await userRepository.updateUserRating(
        userId: order.buyerId,
        newRatingValue: fisherToBuyerRating,
      );

      reviewCount++;

      if (i % 6 == 0) {
        final buyerToFisherRating = (_rng.nextInt(2) + 4).toDouble();
        final fisherReviewMessage =
            reviewMessages[_rng.nextInt(reviewMessages.length)];

        await databaseHelper.insertRating({
          'rating_id': _uuid.v4(),
          'order_id': order.id,
          'rater_id': order.buyerId,
          'rated_user_id': order.fisherId,
          'rating_value': buyerToFisherRating,
          'message': fisherReviewMessage,
          'timestamp': DateTime.now()
              .subtract(Duration(hours: 5 + i * 2))
              .toIso8601String(),
        });

        await databaseHelper.updateOrderRatingStatus(
          orderId: order.id,
          isRatingBuyer: false, // Target is the Fisher
          ratingValue: buyerToFisherRating,
          message: fisherReviewMessage,
        );

        await userRepository.updateUserRating(
          userId: order.fisherId,
          newRatingValue: buyerToFisherRating,
        );

        reviewCount++;
      }
    }

    print(
      '$reviewCount total reviews seeded. User profiles and Orders updated.',
    );
  }

  // -------------------------------
  // RUN ALL
  // -------------------------------
  Future<void> seedAll() async {
    await seedUsers();
    final catches = await seedCatches();
    final offers = await seedOffers(catches);
    final orders = await seedOrders();
    await seedReviews(orders);
    await seedConversations(offers);
    print('Database seeding complete.');
  }
}
