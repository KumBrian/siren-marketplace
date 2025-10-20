import 'dart:math';

import 'package:siren_marketplace/core/data/repositories/user_repository.dart';
import 'package:siren_marketplace/core/di/injector.dart';
import 'package:siren_marketplace/core/models/app_user.dart';
import 'package:siren_marketplace/core/models/catch.dart';
import 'package:siren_marketplace/core/models/offer.dart';
import 'package:siren_marketplace/core/models/order.dart';
import 'package:siren_marketplace/core/models/species.dart';
import 'package:siren_marketplace/core/types/enum.dart';
import 'package:siren_marketplace/features/chat/data/conversation_repository.dart';
import 'package:siren_marketplace/features/chat/data/models/conversation_preview.dart';
import 'package:siren_marketplace/features/fisher/data/catch_repository.dart';
import 'package:siren_marketplace/features/fisher/data/models/fisher.dart';
import 'package:siren_marketplace/features/fisher/data/offer_repositories.dart';
import 'package:siren_marketplace/features/fisher/data/order_repository.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();
final _rng = Random();

class CatchSeeder {
  // Dummy Avatars
  // (index) => 'https://i.pravatar.cc/150?img=${index + 1}',
  static final List<String> _avatarUrls = List.generate(
    10,
    (index) => 'https://i.pravatar.cc/150?img=${index + 1}',
  );

  // Dummy Catch Images
  // (index) => 'https://picsum.photos/400/300?random=${500 + index}',
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
      'role': Role.fisher.name,
    },
    {
      'id': 'fisher_id_2',
      'name': 'Ocean Master',
      'avatar_url': _avatarUrls[1],
      'rating': 4.5,
      'review_count': 90,
      'role': Role.fisher.name,
    },
    {
      'id': 'buyer_id_1',
      'name': 'Seafood Buyer Co',
      'avatar_url': _avatarUrls[2],
      'rating': 4.9,
      'review_count': 210,
      'role': Role.buyer.name,
    },
    {
      'id': 'buyer_id_2',
      'name': 'Market Pro Supply',
      'avatar_url': _avatarUrls[3],
      'rating': 4.7,
      'review_count': 150,
      'role': Role.buyer.name,
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
  // CATCHES
  // -------------------------------
  Future<List<Catch>> seedCatches() async {
    final repository = sl<CatchRepository>();
    final existing = await repository.getAllCatchMaps();
    if (existing.isNotEmpty) {
      print('Catches exist. Returning existing.');
      return existing.map((m) => Catch.fromMap(m)).toList();
    }

    final List<Catch> seeded = [];
    final now = DateTime.now();
    const fisherId = 'fisher_id_1';

    for (int i = 0; i < 15; i++) {
      final species = _speciesList[i % _speciesList.length];
      final weight = 50 + _rng.nextDouble() * 50;
      final pricePerKg = 4 + _rng.nextDouble() * 2;
      final market = _markets[i % _markets.length];

      CatchStatus status;
      double availableWeight = weight;
      if (i < 3) {
        status = CatchStatus.available;
      } else if (i < 5) {
        status = CatchStatus.processing;
        availableWeight = weight * 0.5;
      } else if (i == 14) {
        status = CatchStatus.sold;
        availableWeight = 0;
      } else {
        status = CatchStatus.available;
      }

      final c = Catch(
        id: _uuid.v4(),
        name: '${species.name} Catch ${_rng.nextInt(100)}',
        datePosted: now.subtract(Duration(hours: i * 5)).toIso8601String(),
        initialWeight: weight,
        availableWeight: availableWeight,
        pricePerKg: double.parse(pricePerKg.toStringAsFixed(2)),
        total: double.parse((weight * pricePerKg).toStringAsFixed(2)),
        size: i < 7 ? 'Medium' : 'Large',
        market: market,
        species: species,
        fisherId: fisherId,
        images: [_catchImageUrls[_rng.nextInt(_catchImageUrls.length)]],
        status: status,
      );

      await repository.insertCatch(c);
      seeded.add(c);
    }

    print('${seeded.length} catches seeded.');
    return seeded;
  }

  // -------------------------------
  // OFFERS
  // -------------------------------
  Future<List<Offer>> seedOffers(List<Catch> seededCatches) async {
    final offerRepository = sl<OfferRepository>();
    final existing = await offerRepository.getAllOfferMaps();
    if (existing.isNotEmpty) {
      print('Offers exist. Returning existing.');
      return existing.map((m) => Offer.fromMap(m)).toList();
    }

    final buyer1 = AppUser.fromMap(
      _userMaps.firstWhere((m) => m['id'] == 'buyer_id_1'),
    );
    final buyer2 = AppUser.fromMap(
      _userMaps.firstWhere((m) => m['id'] == 'buyer_id_2'),
    );
    final fisher1 = AppUser.fromMap(
      _userMaps.firstWhere((m) => m['id'] == 'fisher_id_1'),
    );
    final List<Offer> allOffers = [];
    final buyers = [buyer1, buyer2];

    for (int i = 0; i < seededCatches.length; i++) {
      final catchItem = seededCatches[i];
      final buyer = buyers[i % buyers.length];

      if (catchItem.status == CatchStatus.available ||
          catchItem.status == CatchStatus.processing) {
        // Pending
        final pendingOffer = Offer(
          id: _uuid.v4(),
          catchId: catchItem.id,
          fisherId: catchItem.fisherId,
          buyerId: buyer.id,
          pricePerKg: double.parse(
            (catchItem.pricePerKg * 0.95).toStringAsFixed(2),
          ),
          weight: double.parse(
            (catchItem.availableWeight * 0.5).toStringAsFixed(2),
          ),
          price: double.parse(
            (catchItem.pricePerKg * 0.95 * catchItem.availableWeight * 0.5)
                .toStringAsFixed(2),
          ),
          status: OfferStatus.pending,
          dateCreated: DateTime.now().toIso8601String(),
          previousPrice: null,
          previousPricePerKg: null,
          previousWeight: null,
          catchName: catchItem.name,
          catchImageUrl: catchItem.images.first,
          fisherName: fisher1.name,
          fisherRating: fisher1.rating,
          fisherAvatarUrl: fisher1.avatarUrl,
          buyerName: buyer.name,
          buyerRating: buyer.rating,
          buyerAvatarUrl: buyer.avatarUrl,
        );
        await offerRepository.insertOffer(pendingOffer);
        allOffers.add(pendingOffer);

        // Accepted (every 4th catch)
        if (i % 4 == 0 && catchItem.status != CatchStatus.sold) {
          final acceptedOffer = Offer(
            id: _uuid.v4(),
            catchId: catchItem.id,
            fisherId: catchItem.fisherId,
            buyerId: buyer.id,
            pricePerKg: catchItem.pricePerKg,
            weight: double.parse(
              (catchItem.availableWeight * 0.2).toStringAsFixed(2),
            ),
            price: double.parse(
              (catchItem.pricePerKg * catchItem.availableWeight * 0.2)
                  .toStringAsFixed(2),
            ),
            status: OfferStatus.accepted,
            dateCreated: DateTime.now()
                .subtract(Duration(days: 1))
                .toIso8601String(),
            previousPrice: null,
            previousPricePerKg: null,
            previousWeight: null,
            catchName: catchItem.name,
            catchImageUrl: catchItem.images.first,
            fisherName: fisher1.name,
            fisherRating: fisher1.rating,
            fisherAvatarUrl: fisher1.avatarUrl,
            buyerName: buyer.name,
            buyerRating: buyer.rating,
            buyerAvatarUrl: buyer.avatarUrl,
          );
          await offerRepository.insertOffer(acceptedOffer);
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
    final orderRepository = sl<OrderRepository>();
    final offerRepository = sl<OfferRepository>();
    final catchRepository = sl<CatchRepository>();
    final userRepository = sl<UserRepository>();

    final existing = await orderRepository.getAllOrderMaps();
    if (existing.isNotEmpty) {
      print('Orders exist. Skipping.');
      return [];
    }

    final allOfferMaps = await offerRepository.getAllOfferMaps();
    final acceptedOffers = allOfferMaps
        .map((m) => Offer.fromMap(m))
        .where((o) => o.status == OfferStatus.accepted)
        .toList();

    final List<Order> orders = [];
    for (final offer in acceptedOffers) {
      final catchMap = await catchRepository.getCatchMapById(offer.catchId);
      final fisherMap = await userRepository.getUserMapById(offer.fisherId);
      if (catchMap == null || fisherMap == null) continue;

      final newOrder = Order.fromOfferAndCatch(
        offer: offer,
        catchItem: Catch.fromMap(catchMap),
        fisher: Fisher.fromMap(fisherMap),
      );

      await orderRepository.insertOrder(newOrder);
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

    final Map<String, Offer> uniqueConversations = {};
    for (final offer in allOffers) {
      final key = '${offer.buyerId}-${offer.fisherId}';
      if (!uniqueConversations.containsKey(key)) {
        uniqueConversations[key] = offer;
      }
    }

    for (final offer in uniqueConversations.values) {
      final conv = ConversationPreview(
        id: _uuid.v4(),
        buyerId: offer.buyerId,
        fisherId: offer.fisherId,
        contactName: offer.fisherName,
        contactAvatarPath: offer.fisherAvatarUrl,
        lastMessage: offer.status == OfferStatus.accepted
            ? 'The offer for ${offer.catchName} was accepted. Awaiting payment.'
            : 'Is this price negotiable for a bulk order?',
        lastMessageTime: offer.dateCreated,
        unreadCount: offer.status == OfferStatus.pending ? 1 : 0,
      );

      await conversationRepository.insertOrUpdateConversation(conv);
    }

    print('${uniqueConversations.length} conversations seeded.');
  }

  // -------------------------------
  // RUN ALL
  // -------------------------------
  Future<void> seedAll() async {
    await seedUsers();
    final catches = await seedCatches();
    final offers = await seedOffers(catches);
    await seedOrders();
    await seedConversations(offers);
    print('Database seeding complete.');
  }
}
