import 'package:equatable/equatable.dart';

class CatchFilterState extends Equatable {
  final Set<String> activeStatuses;
  final String? activeSortBy;

  final Set<String> pendingStatuses;
  final String? pendingSortBy;

  final int totalFilters;

  const CatchFilterState({
    this.activeStatuses = const {},
    this.activeSortBy,
    this.pendingStatuses = const {},
    this.pendingSortBy,
    this.totalFilters = 0,
  });

  CatchFilterState copyWith({
    Set<String>? activeStatuses,
    String? activeSortBy,
    Set<String>? pendingStatuses,
    String? pendingSortBy,
    int? totalFilters,
  }) {
    return CatchFilterState(
      activeStatuses: activeStatuses ?? this.activeStatuses,
      activeSortBy: activeSortBy ?? this.activeSortBy,
      pendingStatuses: pendingStatuses ?? this.pendingStatuses,
      pendingSortBy: pendingSortBy ?? this.pendingSortBy,
      totalFilters: totalFilters ?? this.totalFilters,
    );
  }

  @override
  List<Object?> get props => [
    activeStatuses,
    activeSortBy,
    pendingStatuses,
    pendingSortBy,
    totalFilters,
  ];
}
