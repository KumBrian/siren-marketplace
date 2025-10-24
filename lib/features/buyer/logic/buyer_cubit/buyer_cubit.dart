import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:siren_marketplace/core/data/repositories/user_repository.dart';
import 'package:siren_marketplace/core/models/offer.dart';
import 'package:siren_marketplace/core/models/order.dart';
import 'package:siren_marketplace/features/buyer/data/models/buyer.dart';
import 'package:siren_marketplace/features/fisher/data/models/fisher.dart';
import 'package:siren_marketplace/features/fisher/data/offer_repositories.dart';
import 'package:siren_marketplace/features/fisher/data/order_repository.dart';

part 'buyer_state.dart';

class BuyerCubit extends Cubit<BuyerState> {
  final UserRepository _userRepository;
  final OrderRepository _orderRepository;
  final OfferRepository _offerRepository;

  BuyerCubit(this._userRepository, this._orderRepository, this._offerRepository)
    : super(BuyerInitial());

  Future<Offer?> _assembleOffer(String offerId) async {
    final offerMap = await _offerRepository.getOfferMapById(offerId);
    if (offerMap == null) return null;
    return Offer.fromMap(offerMap);
  }

  Future<List<Offer>> _loadMadeOffers(String buyerId) async {
    final rawOfferMaps = await _offerRepository.getOfferMapsByBuyerId(buyerId);
    return rawOfferMaps.map((map) => Offer.fromMap(map)).toList();
  }

  Future<void> loadBuyerData({required String buyerId}) async {
    if (state is BuyerLoading) return;

    emit(BuyerLoading());
    try {
      final buyerMap = await _userRepository.getUserMapById(buyerId);
      if (buyerMap == null) {
        emit(const BuyerError('Buyer profile not found or ID is incorrect.'));
        return;
      }

      final List<Order> assembledOrders = [];
      final rawOrderMaps = await _orderRepository.getOrderMapsByUserId(buyerId);
      for (final orderMap in rawOrderMaps) {
        final offerId = orderMap['offer_id'] as String;
        final fisherId = orderMap['fisher_id'] as String;

        final Offer? linkedOffer = await _assembleOffer(offerId);
        final Map<String, dynamic>? fisherMap = await _userRepository
            .getUserMapById(fisherId);

        if (linkedOffer != null && fisherMap != null) {
          final Fisher linkedFisher = Fisher.fromMap(fisherMap);
          final order = Order.fromMap(
            m: orderMap,
            linkedOffer: linkedOffer,
            linkedFisher: linkedFisher,
          );
          assembledOrders.add(order);
        }
      }

      final List<Offer> assembledOffers = await _loadMadeOffers(buyerId);

      final buyerProfile = Buyer.fromMap(buyerMap);
      emit(
        BuyerLoaded(
          buyer: buyerProfile,
          orders: assembledOrders,
          madeOffers: assembledOffers,
        ),
      );
    } catch (e) {
      emit(BuyerError('Failed to load buyer data or lists: ${e.toString()}'));
    }
  }
}
