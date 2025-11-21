import 'package:equatable/equatable.dart';

import '../../../../../new_core/domain/entities/catch.dart';
import '../../../../../new_core/domain/entities/offer.dart';
import '../../../../../new_core/domain/entities/order.dart';
import '../../../../../new_core/domain/entities/user.dart';

abstract class OrderDetailState extends Equatable {
  const OrderDetailState();

  @override
  List<Object?> get props => [];
}

class OrderDetailInitial extends OrderDetailState {
  const OrderDetailInitial();
}

class OrderDetailLoading extends OrderDetailState {
  const OrderDetailLoading();
}

class OrderDetailLoaded extends OrderDetailState {
  final Order order;
  final Catch catch_;
  final Offer offer;
  final User counterparty;
  final bool canSubmitReview;
  final bool isProcessing;

  const OrderDetailLoaded({
    required this.order,
    required this.catch_,
    required this.offer,
    required this.counterparty,
    required this.canSubmitReview,
    this.isProcessing = false,
  });

  OrderDetailLoaded copyWith({
    Order? order,
    Catch? catch_,
    Offer? offer,
    User? counterparty,
    bool? canSubmitReview,
    bool? isProcessing,
  }) {
    return OrderDetailLoaded(
      order: order ?? this.order,
      catch_: catch_ ?? this.catch_,
      offer: offer ?? this.offer,
      counterparty: counterparty ?? this.counterparty,
      canSubmitReview: canSubmitReview ?? this.canSubmitReview,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }

  @override
  List<Object?> get props => [
    order,
    catch_,
    offer,
    counterparty,
    canSubmitReview,
    isProcessing,
  ];
}

class OrderDetailError extends OrderDetailState {
  final String message;

  const OrderDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
