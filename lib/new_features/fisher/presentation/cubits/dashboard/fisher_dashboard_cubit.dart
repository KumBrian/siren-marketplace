import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../new_core/di/injection.dart';
import '../../../../../new_core/domain/enums/catch_status.dart';
import '../../../../../new_core/domain/enums/order_status.dart';
import '../../../../../new_core/domain/repositories/i_catch_repository.dart';
import '../../../../../new_core/domain/repositories/i_order_repository.dart';
import 'fisher_dashboard_state.dart';

class FisherDashboardCubit extends Cubit<FisherDashboardState> {
  final ICatchRepository _catchRepository;
  final IOrderRepository _orderRepository;

  FisherDashboardCubit({
    ICatchRepository? catchRepository,
    IOrderRepository? orderRepository,
  }) : _catchRepository = catchRepository ?? DI().catchRepository,
       _orderRepository = orderRepository ?? DI().orderRepository,
       super(const FisherDashboardInitial());

  Future<void> loadDashboard(String fisherId) async {
    emit(const FisherDashboardLoading());

    try {
      // Load catches
      final allCatches = await _catchRepository.getByFisherId(fisherId);
      final availableCatches = allCatches
          .where((c) => c.status == CatchStatus.available)
          .toList();
      final expiredCatches = allCatches
          .where((c) => c.status == CatchStatus.expired)
          .toList();

      // Load orders
      final allOrders = await _orderRepository.getByFisherId(fisherId);
      final recentOrders = allOrders.take(5).toList();

      // Calculate turnover (sum of completed orders)
      final completedOrders = allOrders
          .where((o) => o.status == OrderStatus.completed)
          .toList();
      final totalTurnover = completedOrders.fold<int>(
        0,
        (sum, order) => sum + order.terms.totalPrice.amount,
      );

      emit(
        FisherDashboardLoaded(
          totalTurnover: totalTurnover,
          availableCatches: availableCatches,
          expiredCatches: expiredCatches,
          recentOrders: recentOrders,
        ),
      );
    } catch (e) {
      emit(FisherDashboardError('Failed to load dashboard: $e'));
    }
  }

  Future<void> refresh(String fisherId) async {
    await loadDashboard(fisherId);
  }
}
