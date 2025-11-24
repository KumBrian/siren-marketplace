import 'package:equatable/equatable.dart';

import '../../../../../new_core/domain/entities/catch.dart';
import '../../../../../new_core/domain/entities/order.dart';

abstract class FisherDashboardState extends Equatable {
  const FisherDashboardState();

  @override
  List<Object?> get props => [];
}

class FisherDashboardInitial extends FisherDashboardState {
  const FisherDashboardInitial();
}

class FisherDashboardLoading extends FisherDashboardState {
  const FisherDashboardLoading();
}

class FisherDashboardLoaded extends FisherDashboardState {
  final int totalTurnover;
  final List<Catch> availableCatches;
  final List<Catch> expiredCatches;
  final List<Order> recentOrders;
  final List<Order> completedOrders;

  const FisherDashboardLoaded({
    required this.totalTurnover,
    required this.availableCatches,
    required this.expiredCatches,
    required this.recentOrders,
    required this.completedOrders,
  });

  @override
  List<Object?> get props => [
    totalTurnover,
    availableCatches,
    expiredCatches,
    recentOrders,
    completedOrders,
  ];
}

class FisherDashboardError extends FisherDashboardState {
  final String message;

  const FisherDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
