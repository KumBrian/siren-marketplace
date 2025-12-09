import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/domain/entities/catch.dart';
import 'package:siren_marketplace/core/domain/enums/catch_status.dart';
import 'package:siren_marketplace/core/providers/catch_providers.dart';
import 'package:siren_marketplace/core/providers/offer_providers.dart';
import 'package:siren_marketplace/core/utils/custom_icons.dart';
import 'package:siren_marketplace/core/widgets/custom_button.dart';
import 'package:siren_marketplace/core/widgets/filter_button.dart';
import 'package:siren_marketplace/core/widgets/section_header.dart';
import 'package:siren_marketplace/features/fisher/presentation/widgets/catch_card.dart';

class CatchesScreen extends ConsumerStatefulWidget {
  const CatchesScreen({super.key});

  @override
  ConsumerState<CatchesScreen> createState() => _CatchesScreenState();
}

class _CatchesScreenState extends ConsumerState<CatchesScreen> {
  String _searchQuery = '';
  List<CatchStatus> _selectedStatuses = [];

  @override
  Widget build(BuildContext context) {
    final notificationCount = ref.watch(fisherPendingOffersCountProvider);
    final catchesAsync = ref.watch(fisherCatchesProvider);

    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.white100,
        actions: [
          IconButton(
            onPressed: () {
              context.go("/fisher/notifications");
            },
            icon: Badge(
              label: Text("$notificationCount"),
              isLabelVisible: notificationCount > 0,
              child: const Icon(
                Icons.notifications_none,
                color: AppColors.textBlue,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24.0),
          child: Column(
            spacing: 16,
            children: [
              const SectionHeader("Catch", fontSize: 16),
              Container(color: AppColors.textBlue, height: 2.0),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(fisherCatchesProvider);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 56, child: _buildSearchAndFilterRow()),
              const SizedBox(height: 16),
              Expanded(
                child: catchesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: Text(
                      'Error loading catches: $error',
                      style: const TextStyle(color: AppColors.fail500),
                    ),
                  ),
                  data: (catches) {
                    final filteredCatches = _filterCatches(catches);

                    if (filteredCatches.isEmpty) {
                      return const Center(
                        child: Text(
                          "No catches found.",
                          style: TextStyle(color: AppColors.textGray),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: filteredCatches.length,
                      padding: const EdgeInsets.only(bottom: 80),
                      itemBuilder: (context, index) {
                        return CatchCard(
                          catchItem: filteredCatches[index],
                          onTap: () {
                            context.push(
                              "/fisher/catch-report/${filteredCatches[index].id}",
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilterRow() {
    return Row(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 4,
          child: SearchBar(
            hintText: "Search...",
            textStyle: WidgetStateProperty.all(
              const TextStyle(fontSize: 16, color: AppColors.textBlue),
            ),
            backgroundColor: WidgetStateProperty.all(AppColors.white100),
            shape: WidgetStateProperty.all(
              const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
            trailing: const [
              Icon(CustomIcons.search, color: AppColors.textBlue),
            ],
            elevation: WidgetStateProperty.all(0),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        Expanded(
          flex: 1,
          child: Badge(
            isLabelVisible: _selectedStatuses.isNotEmpty,
            label: Text("${_selectedStatuses.length}"),
            alignment: Alignment.topRight,
            backgroundColor: AppColors.blue800,
            child: SizedBox(
              width: double.infinity,
              child: Material(
                color: AppColors.white100,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  splashColor: AppColors.blue700.withAlpha(25),
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _showFilterModal(),
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Icon(CustomIcons.filter, color: AppColors.textBlue),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => _FilterModalContent(
        selectedStatuses: _selectedStatuses,
        onApply: (statuses) {
          setState(() {
            _selectedStatuses = statuses;
          });
        },
      ),
    );
  }

  List<Catch> _filterCatches(List<Catch> catches) {
    return catches.where((catchItem) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesName = catchItem.species.name.toLowerCase().contains(
          query,
        );
        final matchesScientific =
            catchItem.species.scientificName?.toLowerCase().contains(query) ??
            false;
        final matchesObs = catchItem.observationId.toLowerCase().contains(
          query,
        );
        final matchesLoc = catchItem.locationName.toLowerCase().contains(query);

        if (!matchesName && !matchesScientific && !matchesObs && !matchesLoc) {
          return false;
        }
      }

      if (_selectedStatuses.isNotEmpty) {
        if (!_selectedStatuses.contains(catchItem.status)) {
          return false;
        }
      }

      return true;
    }).toList();
  }
}

class _FilterModalContent extends StatefulWidget {
  final List<CatchStatus> selectedStatuses;
  final Function(List<CatchStatus>) onApply;

  const _FilterModalContent({
    required this.selectedStatuses,
    required this.onApply,
  });

  @override
  State<_FilterModalContent> createState() => _FilterModalContentState();
}

class _FilterModalContentState extends State<_FilterModalContent> {
  late List<CatchStatus> _tempSelectedStatuses;

  @override
  void initState() {
    super.initState();
    _tempSelectedStatuses = List.from(widget.selectedStatuses);
  }

  void _toggleStatus(CatchStatus status) {
    setState(() {
      if (_tempSelectedStatuses.contains(status)) {
        _tempSelectedStatuses.remove(status);
      } else {
        _tempSelectedStatuses.add(status);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.35;

    return Container(
      height: height,
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          const Text(
            "Filter by:",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const Text("Status", style: TextStyle(fontSize: 12)),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: CatchStatus.values.map((status) {
              final title =
                  status.name.substring(0, 1).toUpperCase() +
                  status.name.substring(1);
              return FilterButton(
                title: title,
                color: _getStatusColor(status),
                isSelected: _tempSelectedStatuses.contains(status),
                onPressed: () => _toggleStatus(status),
              );
            }).toList(),
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _tempSelectedStatuses = [];
                  });
                },
                child: const Text(
                  "Reset All",
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              ),
              CustomButton(
                title: "Apply Filters",
                onPressed: () {
                  widget.onApply(_tempSelectedStatuses);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(CatchStatus status) {
    switch (status) {
      case CatchStatus.available:
        return AppColors.success500;
      case CatchStatus.soldOut:
        return AppColors.blue500;
      case CatchStatus.expired:
        return AppColors.fail500;
      case CatchStatus.removed:
      case CatchStatus.draft:
        return AppColors.gray500;
    }
  }
}
