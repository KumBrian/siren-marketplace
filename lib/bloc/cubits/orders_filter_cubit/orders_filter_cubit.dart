import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:siren_marketplace/new_core/domain/enums/offer_status.dart';

part 'orders_filter_state.dart';

class OrdersFilterCubit extends Cubit<OrdersFilterState> {
  OrdersFilterCubit() : super(const OrdersFilterState());

  void toggleStatus(OfferStatus status) {
    final current = Set<OfferStatus>.from(state.selectedStatuses);
    if (current.contains(status)) {
      current.remove(status);
    } else {
      current.add(status);
    }
    emit(state.copyWith(selectedStatuses: current));
  }

  void clear() {
    emit(const OrdersFilterState());
  }
}
