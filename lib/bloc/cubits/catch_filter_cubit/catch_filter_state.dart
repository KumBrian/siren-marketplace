import 'package:equatable/equatable.dart';

class CatchFilterState extends Equatable {
  final Set<String> selectedStatuses;
  final String? sortBy;

  const CatchFilterState({this.selectedStatuses = const {}, this.sortBy});

  CatchFilterState copyWith({Set<String>? selectedStatuses, String? sortBy}) {
    return CatchFilterState(
      selectedStatuses: selectedStatuses ?? this.selectedStatuses,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  @override
  List<Object?> get props => [selectedStatuses, sortBy];
}
