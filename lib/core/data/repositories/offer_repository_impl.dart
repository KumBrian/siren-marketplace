import '../../di/injector.dart';
import '../../domain/entities/offer.dart';
import '../../domain/entities/order.dart';
import '../../domain/enums/offer_status.dart';
import '../../domain/enums/order_status.dart';
import '../../domain/enums/user_role.dart';
import '../../domain/value_objects/offer_terms.dart';
import '../../domain/repositories/i_offer_repository.dart';
import '../../domain/repositories/i_order_repository.dart';
import '../datasources/interfaces/i_offer_datasource.dart';
import '../mappers/offer_mapper.dart';

class OfferRepositoryImpl implements IOfferRepository {
  final IOfferDataSource dataSource;

  OfferRepositoryImpl({required this.dataSource});

  @override
  Future<String> create(Offer offer) async {
    final model = OfferMapper.toModel(offer);
    return await dataSource.create(model);
  }

  @override
  Future<List<Offer>> getAllOffers() async {
    final models = await dataSource.getAllOffers();
    return models.map((m) => OfferMapper.toEntity(m)).toList();
  }

  @override
  Future<Offer?> getById(String offerId) async {
    final model = await dataSource.getById(offerId);
    return model != null ? OfferMapper.toEntity(model) : null;
  }

  @override
  Future<List<Offer>> getByCatchId(String catchId) async {
    final models = await dataSource.getByCatchId(catchId);
    return models.map((m) => OfferMapper.toEntity(m)).toList();
  }

  @override
  Future<List<Offer>> getByBuyerId(String buyerId) async {
    final models = await dataSource.getByBuyerId(buyerId);
    return models.map((m) => OfferMapper.toEntity(m)).toList();
  }

  @override
  Future<List<Offer>> getByFisherId(String fisherId) async {
    final models = await dataSource.getByFisherId(fisherId);
    return models.map((m) => OfferMapper.toEntity(m)).toList();
  }

  @override
  Future<List<Offer>> getByCatchIds(List<String> catchIds) async {
    final models = await dataSource.getByCatchIds(catchIds);
    return models.map((m) => OfferMapper.toEntity(m)).toList();
  }

  @override
  Future<List<Offer>> getByStatus(OfferStatus status) async {
    final models = await dataSource.getByStatus(status);
    return models.map((m) => OfferMapper.toEntity(m)).toList();
  }

  @override
  Future<List<Offer>> getPendingForUser(String userId) async {
    final pending = await getByStatus(OfferStatus.pending);
    return pending.where((o) => o.isUsersTurn(userId)).toList();
  }

  @override
  Future<void> update(Offer offer) async {
    final model = OfferMapper.toModel(offer);
    await dataSource.update(model);
  }

  @override
  Future<void> delete(String offerId) async {
    await dataSource.delete(offerId);
  }

  @override
  Future<T> transaction<T>(Future<T> Function() action) async {
    return await dataSource.transaction(action);
  }

  @override
  Future<void> acceptOffer(String offerId, UserRole role) async {
    final offerModel = await dataSource.getById(offerId);
    if (offerModel == null) throw Exception('Offer not found');

    final offer = OfferMapper.toEntity(offerModel);
    final updatedOffer = offer.accept();

    await update(updatedOffer);

    // Create an order from the accepted offer
    final orderRepository = sl<IOrderRepository>();
    final now = DateTime.now();

    // Generate order ID (format: ODD + 8 random chars)
    final orderId =
        'ODD${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    final order = Order(
      id: orderId,
      offerId: offer.id,
      catchId: offer.catchId,
      fisherId: offer.fisherId,
      buyerId: offer.buyerId,
      terms: offer.currentTerms,
      status: OrderStatus.accepted,
      dateCreated: now,
      dateUpdated: now,
    );

    await orderRepository.create(order);
  }

  @override
  Future<void> rejectOffer(String offerId, UserRole role) async {
    final offerModel = await dataSource.getById(offerId);
    if (offerModel == null) throw Exception('Offer not found');

    final offer = OfferMapper.toEntity(offerModel);
    final updatedOffer = offer.reject();

    await update(updatedOffer);
  }

  @override
  Future<void> counterOffer(
    String offerId,
    UserRole role,
    OfferTerms terms,
  ) async {
    final offerModel = await dataSource.getById(offerId);
    if (offerModel == null) throw Exception('Offer not found');

    final offer = OfferMapper.toEntity(offerModel);
    // Assuming the role passed is the one countering.
    // We need the userId to verify turn, but the interface only passes role.
    // However, the Offer.counter method requires userId.
    // We might need to fetch the user ID from the offer based on the role.

    String userId;
    if (role == UserRole.fisher) {
      userId = offer.fisherId;
    } else {
      userId = offer.buyerId;
    }

    final updatedOffer = offer.counter(newTerms: terms, byUserId: userId);

    await update(updatedOffer);
  }

  @override
  Future<void> markAsViewed(String offerId, UserRole role) async {
    final offerModel = await dataSource.getById(offerId);
    if (offerModel == null) return;

    final offer = OfferMapper.toEntity(offerModel);
    Offer updatedOffer;

    if (role == UserRole.fisher) {
      updatedOffer = offer.copyWith(hasUpdateForFisher: false);
    } else {
      updatedOffer = offer.copyWith(hasUpdateForBuyer: false);
    }

    await update(updatedOffer);
  }
}
