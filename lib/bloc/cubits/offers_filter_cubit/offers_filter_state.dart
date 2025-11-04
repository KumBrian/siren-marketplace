part of 'offers_filter_cubit.dart';

class OffersFilterState extends Equatable {
  final Set<String> activeStatuses;
  final SortBy? activeSortBy;

  final Set<String> pendingStatuses;
  final SortBy? pendingSortBy;

  final int totalFilters;

  const OffersFilterState({
    this.activeStatuses = const {},
    this.activeSortBy,
    this.pendingStatuses = const {},
    this.pendingSortBy,
    this.totalFilters = 0,
  });

  OffersFilterState copyWith({
    Set<String>? activeStatuses,
    SortBy? activeSortBy,
    Set<String>? pendingStatuses,
    SortBy? pendingSortBy,
    int? totalFilters,
  }) {
    return OffersFilterState(
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
