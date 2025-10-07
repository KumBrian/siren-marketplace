import 'package:equatable/equatable.dart';
import 'package:siren_marketplace/constants/types.dart';

class OrdersFilterState extends Equatable {
  final Set<OfferStatus> selectedStatuses;

  const OrdersFilterState({this.selectedStatuses = const {}});

  OrdersFilterState copyWith({Set<OfferStatus>? selectedStatuses}) {
    return OrdersFilterState(
      selectedStatuses: selectedStatuses ?? this.selectedStatuses,
    );
  }

  @override
  List<Object?> get props => [selectedStatuses];
}
