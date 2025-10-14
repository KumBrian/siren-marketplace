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

  // ⚠️ Removed hardcoded mock ID, now accepts the ID via loadBuyerData.

  BuyerCubit(this._userRepository, this._orderRepository, this._offerRepository)
    : super(BuyerInitial());

  // --- Helper function to assemble the full Offer model ---
  Future<Offer?> _assembleOffer(String offerId) async {
    final offerMap = await _offerRepository.getOfferMapById(offerId);
    if (offerMap == null) return null;
    // Assuming Offer.fromMap is sufficient to build the Offer model.
    return Offer.fromMap(offerMap);
  }

  // 🆕 loadBuyerData now requires the buyerId
  Future<void> loadBuyerData({required String buyerId}) async {
    if (state is BuyerLoading) return;

    emit(BuyerLoading());
    try {
      // 1. Fetch the Buyer profile data (raw map) using the provided ID.
      final buyerMap = await _userRepository.getUserMapById(buyerId);

      if (buyerMap == null) {
        // This is the source of your "Buyer ID not found" error.
        emit(const BuyerError('Buyer profile not found or ID is incorrect.'));
        return;
      }

      // 2. Fetch all raw Order maps linked to this buyer
      final rawOrderMaps = await _orderRepository.getOrderMapsByUserId(buyerId);

      // 3. Assemble the full Order objects (now includes fetching Offer and Fisher)
      final List<Order> assembledOrders = [];
      for (final orderMap in rawOrderMaps) {
        final offerId = orderMap['offer_id'] as String;
        final fisherId = orderMap['fisher_id'] as String;

        // A. Fetch the linked Offer model using the dedicated helper
        final Offer? linkedOffer = await _assembleOffer(offerId);

        // B. Fetch the linked Fisher data (raw map)
        final Map<String, dynamic>? fisherMap = await _userRepository
            .getUserMapById(fisherId);

        if (linkedOffer != null && fisherMap != null) {
          // C. Assemble the Fisher model
          final Fisher linkedFisher = Fisher.fromMap(fisherMap);

          // D. Assemble the Order, passing both the Offer and Fisher
          final order = Order.fromMap(
            m: orderMap,
            linkedOffer: linkedOffer,
            linkedFisher: linkedFisher,
          );
          assembledOrders.add(order);
        }
      }

      // 4. Create the Buyer object from the raw map.
      final buyerProfile = Buyer.fromMap(buyerMap);

      // 5. Emit the loaded state with the profile and assembled orders.
      emit(BuyerLoaded(buyer: buyerProfile, orders: assembledOrders));
    } catch (e) {
      // Catch exceptions from repository calls or assembly steps
      emit(BuyerError('Failed to load buyer data or orders: ${e.toString()}'));
    }
  }
}
