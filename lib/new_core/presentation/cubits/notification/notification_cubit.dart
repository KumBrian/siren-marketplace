import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../di/injection.dart';
import '../../../domain/enums/offer_status.dart';
import '../../../domain/repositories/i_offer_repository.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final IOfferRepository _offerRepository;

  NotificationCubit({IOfferRepository? offerRepository})
    : _offerRepository = offerRepository ?? DI().offerRepository,
      super(const NotificationState());

  /// Load unread offers count for a user
  Future<void> loadUnreadCount(String userId, bool isFisher) async {
    try {
      final offers = isFisher
          ? await _offerRepository.getByFisherId(userId)
          : await _offerRepository.getByBuyerId(userId);

      // Count pending offers where it's the user's turn
      final unreadCount = offers.where((offer) {
        return offer.status == OfferStatus.pending && offer.isUsersTurn(userId);
      }).length;

      emit(
        NotificationState(
          unreadOffersCount: unreadCount,
          lastUpdated: DateTime.now(),
        ),
      );
    } catch (e) {
      // Keep current state on error
    }
  }

  /// Mark an offer as read (decrement count)
  void markOfferAsRead() {
    final currentCount = state.unreadOffersCount;
    if (currentCount > 0) {
      emit(
        state.copyWith(
          unreadOffersCount: currentCount - 1,
          lastUpdated: DateTime.now(),
        ),
      );
    }
  }

  /// Increment when new offer arrives or is updated
  void incrementUnreadCount() {
    emit(
      state.copyWith(
        unreadOffersCount: state.unreadOffersCount + 1,
        lastUpdated: DateTime.now(),
      ),
    );
  }

  /// Reset count
  void reset() {
    emit(const NotificationState());
  }
}
