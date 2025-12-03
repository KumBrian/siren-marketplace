import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/domain/entities/catch.dart';
import 'package:siren_marketplace/core/domain/entities/species.dart';
import 'package:siren_marketplace/core/domain/value_objects/weight.dart';
import 'package:siren_marketplace/core/providers/catch_providers.dart';
import 'package:siren_marketplace/core/providers/offer_providers.dart';
import 'package:siren_marketplace/core/providers/product_filter_providers.dart';
import 'package:siren_marketplace/core/types/enum.dart';
import 'package:siren_marketplace/core/types/extensions.dart';
import 'package:siren_marketplace/core/utils/custom_icons.dart';
import 'package:siren_marketplace/core/widgets/custom_button.dart';
import 'package:siren_marketplace/core/widgets/multi_select_dropdown.dart';
import 'package:siren_marketplace/core/widgets/number_input_field.dart';
import 'package:siren_marketplace/features/buyer/presentation/widgets/product_card.dart';

class BuyerHome extends ConsumerStatefulWidget {
  const BuyerHome({super.key});

  @override
  ConsumerState<BuyerHome> createState() => _BuyerHomeState();
}

class _BuyerHomeState extends ConsumerState<BuyerHome> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref
          .read(productsFilterProvider.notifier)
          .update((state) => state.copyWith(searchQuery: query));
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredCatchesAsync = ref.watch(filteredCatchesProvider);
    final notificationCount = ref.watch(buyerNotificationCountProvider);

    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        title: Image.asset(
          "assets/icons/siren_logo.png",
          width: 100,
          errorBuilder: (context, error, stackTrace) {
            return const Text("SIREN");
          },
        ),
        actions: [
          IconButton(
            onPressed: () => context.go("/buyer/notifications"),
            icon: Badge(
              label: Text("$notificationCount"),
              isLabelVisible: notificationCount > 0,
              child: const Icon(
                CustomIcons.notificationbell,
                color: AppColors.textBlue,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(availableCatchesProvider);
          await ref.read(availableCatchesProvider.future);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              SizedBox(height: 56, child: _buildSearchAndFilterRow(context)),
              const SizedBox(height: 8),
              Expanded(
                child: filteredCatchesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: Text(
                      'Error loading products: $error',
                      style: const TextStyle(color: AppColors.fail500),
                    ),
                  ),
                  data: (filteredCatches) {
                    if (filteredCatches.isEmpty) {
                      final allCatches =
                          ref.read(availableCatchesProvider).valueOrNull ?? [];
                      if (allCatches.isNotEmpty) {
                        return const Center(
                          child: Text("No products match your filters."),
                        );
                      } else {
                        return const Center(
                          child: Text("No products available in the market."),
                        );
                      }
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.only(bottom: 100),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            mainAxisExtent: 250,
                          ),
                      itemCount: filteredCatches.length,
                      itemBuilder: (context, index) {
                        final c = filteredCatches[index];
                        return ProductCard(
                          onTap: () {
                            context.go("/buyer/product-details/${c.id}");
                          },
                          catchModel: c,
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

  Widget _buildSearchAndFilterRow(BuildContext context) {
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
            onChanged: _onSearchChanged,
          ),
        ),
        Expanded(
          flex: 1,
          child: Material(
            color: AppColors.white100,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              splashColor: AppColors.blue700.withAlpha(25),
              borderRadius: BorderRadius.circular(16),
              onTap: () => _showSortModal(context),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Icon(CustomIcons.sort, color: AppColors.textBlue),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Consumer(
            builder: (context, ref, child) {
              final filterState = ref.watch(productsFilterProvider);
              final hasFilters = filterState.totalFilters > 0;

              return Badge(
                isLabelVisible: hasFilters,
                label: Text("${filterState.totalFilters}"),
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
                      onTap: () => _showFilterModal(context),
                      child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Icon(
                          CustomIcons.filter,
                          color: AppColors.textBlue,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => const _FilterModalContent(),
    );
  }

  void _showSortModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => const _SortModalContent(),
    );
  }
}

class _FilterModalContent extends ConsumerStatefulWidget {
  const _FilterModalContent();

  @override
  ConsumerState<_FilterModalContent> createState() =>
      _FilterModalContentState();
}

class _FilterModalContentState extends ConsumerState<_FilterModalContent> {
  late List<Species> _selectedSpecies;
  late List<String> _selectedLocations;
  late TextEditingController _weightController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final currentFilters = ref.read(productsFilterProvider);
    _selectedSpecies = List.from(currentFilters.selectedSpecies);
    _selectedLocations = List.from(currentFilters.selectedLocations);
    _weightController = TextEditingController(
      text: currentFilters.minWeightGrams > 0
          ? (currentFilters.minWeightGrams / 1000).toString()
          : '',
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uniqueSpecies = ref.watch(uniqueSpeciesProvider);
    final uniqueLocations = ref.watch(uniqueLocationsProvider);
    final height = MediaQuery.of(context).size.height * 0.45;

    return Form(
      key: _formKey,
      child: Container(
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

            const Text("Species", style: TextStyle(fontSize: 12)),
            MultiSelectDropdown<Species>(
              label: "Species",
              options: uniqueSpecies,
              selectedValues: _selectedSpecies,
              optionLabel: (s) => s.name.capitalize(),
              onChanged: (values) {
                setState(() {
                  _selectedSpecies = values;
                });
              },
            ),

            const Text("Location", style: TextStyle(fontSize: 12)),
            MultiSelectDropdown<String>(
              label: "Location",
              options: uniqueLocations,
              selectedValues: _selectedLocations,
              optionLabel: (s) => s,
              onChanged: (values) {
                setState(() {
                  _selectedLocations = values;
                });
              },
            ),

            NumberInputField(
              label: "Min Weight",
              suffix: "(kg)",
              controller: _weightController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) return null;
                final numValue = double.tryParse(value);
                if (numValue == null || numValue < 0) {
                  return 'Enter a valid number';
                }
                return null;
              },
            ),

            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    // Reset local state
                    setState(() {
                      _selectedSpecies = [];
                      _selectedLocations = [];
                      _weightController.clear();
                    });
                    // Also reset global state immediately or wait for Apply?
                    // User expects "Apply" to confirm. So "Reset All" should probably just clear local form.
                    // But typically Reset All also applies the reset.
                    // Let's clear local state and let user click Apply, OR apply reset immediately.
                    // Usually Reset All applies immediately or clears form.
                    // I'll make it clear form and auto-apply for Reset.
                    ref
                        .read(productsFilterProvider.notifier)
                        .update(
                          (state) => state.copyWith(
                            selectedSpecies: [],
                            selectedLocations: [],
                            minWeightGrams: 0,
                          ),
                        );
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Reset All",
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                ),
                CustomButton(
                  title: "Apply Filters",
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final minWeight = Weight.fromKg(
                        double.tryParse(_weightController.text.trim()) ?? 0.0,
                      );

                      ref
                          .read(productsFilterProvider.notifier)
                          .update(
                            (state) => state.copyWith(
                              selectedSpecies: _selectedSpecies,
                              selectedLocations: _selectedLocations,
                              minWeightGrams: minWeight.grams,
                            ),
                          );
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SortModalContent extends ConsumerStatefulWidget {
  const _SortModalContent();

  @override
  ConsumerState<_SortModalContent> createState() => _SortModalContentState();
}

class _SortModalContentState extends ConsumerState<_SortModalContent> {
  late SortBy _sortByDate;
  late SortBy _sortByPrice;

  @override
  void initState() {
    super.initState();
    final currentFilters = ref.read(productsFilterProvider);
    _sortByDate = currentFilters.sortByDate;
    _sortByPrice = currentFilters.sortByPrice;
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.45;

    return Container(
      height: height,
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          const Text(
            "Sort by:",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          _buildDateSortOptions(),
          const Divider(thickness: 2, color: AppColors.gray200),
          _buildPriceSortOptions(),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  ref
                      .read(productsFilterProvider.notifier)
                      .update(
                        (state) => state.copyWith(
                          sortByDate: SortBy.none,
                          sortByPrice: SortBy.none,
                        ),
                      );
                  Navigator.pop(context);
                },
                child: const Text(
                  "Reset All",
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              ),
              CustomButton(
                title: "Apply",
                onPressed: () {
                  ref
                      .read(productsFilterProvider.notifier)
                      .update(
                        (state) => state.copyWith(
                          sortByDate: _sortByDate,
                          sortByPrice: _sortByPrice,
                        ),
                      );
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateSortOptions() {
    return Column(
      children: [
        RadioListTile<SortBy>(
          dense: true,
          groupValue: _sortByDate,
          title: const Text('Oldest to Newest', style: TextStyle(fontSize: 14)),
          value: SortBy.oldNew,
          onChanged: (v) {
            if (v != null) {
              setState(() => _sortByDate = v);
            }
          },
        ),
        RadioListTile<SortBy>(
          dense: true,
          groupValue: _sortByDate,
          title: const Text('Newest to Oldest', style: TextStyle(fontSize: 14)),
          value: SortBy.newOld,
          onChanged: (v) {
            if (v != null) {
              setState(() => _sortByDate = v);
            }
          },
        ),
      ],
    );
  }

  Widget _buildPriceSortOptions() {
    return Column(
      children: [
        RadioListTile<SortBy>(
          dense: true,
          groupValue: _sortByPrice,
          title: const Text(
            'Price: Low to High',
            style: TextStyle(fontSize: 14),
          ),
          value: SortBy.lowHigh,
          onChanged: (v) {
            if (v != null) {
              setState(() => _sortByPrice = v);
            }
          },
        ),
        RadioListTile<SortBy>(
          dense: true,
          groupValue: _sortByPrice,
          title: const Text(
            'Price: High to Low',
            style: TextStyle(fontSize: 14),
          ),
          value: SortBy.highLow,
          onChanged: (v) {
            if (v != null) {
              setState(() => _sortByPrice = v);
            }
          },
        ),
      ],
    );
  }
}
