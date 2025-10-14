part of 'buyer_orders_bloc.dart';

abstract class BuyerOrdersEvent {}

class LoadBuyerOrders extends BuyerOrdersEvent {
  final String buyerId;

  LoadBuyerOrders(this.buyerId);
}
