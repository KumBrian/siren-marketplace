import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/bloc/cubits/filtered_products_cubit/filtered_products_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/products_filter_cubit/products_filter_cubit.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/models/catch.dart';
import 'package:siren_marketplace/core/models/species.dart';
import 'package:siren_marketplace/core/types/enum.dart';
import 'package:siren_marketplace/core/types/extensions.dart';
import 'package:siren_marketplace/core/widgets/custom_button.dart';
import 'package:siren_marketplace/core/widgets/multi_select_dropdown.dart';
import 'package:siren_marketplace/features/buyer/logic/buyer_market_bloc/buyer_market_bloc.dart';
import 'package:siren_marketplace/features/buyer/presentation/widgets/product_card.dart';

class BuyerHome extends StatefulWidget {
  const BuyerHome({super.key});

  @override
  State<BuyerHome> createState() => _BuyerHomeState();
}

class _BuyerHomeState extends State<BuyerHome> {
  @override
  void initState() {
    super.initState();
    // Trigger market load once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BuyerMarketBloc>().add(LoadMarketCatches());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BuyerMarketBloc, BuyerMarketState>(
      listener: (context, marketState) {
        if (marketState is BuyerMarketLoaded) {
          // Feed the filtered cubit safely after data loads
          context.read<FilteredProductsCubit>().setAllCatches(
            marketState.catches,
          );
        }
      },
      child: BlocBuilder<BuyerMarketBloc, BuyerMarketState>(
        builder: (context, marketState) {
          if (marketState is BuyerMarketLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (marketState is BuyerMarketError) {
            return Scaffold(
              body: Center(
                child: Text(
                  'Error loading products: ${marketState.message}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.fail500),
                ),
              ),
            );
          }

          final allCatches = marketState is BuyerMarketLoaded
              ? marketState.catches
              : <Catch>[];

          return Scaffold(
            backgroundColor: AppColors.gray50,
            appBar: AppBar(
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: true,
              title: Image.asset(
                "assets/icons/siren_logo.png",
                width: 100,
                height: 50,
              ),
              actions: [
                IconButton(
                  onPressed: () => context.go("/buyer/notifications"),
                  icon: const Badge(
                    label: Text("5"),
                    child: Icon(
                      Icons.notifications_none,
                      color: AppColors.textBlue,
                    ),
                  ),
                ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                context.read<BuyerMarketBloc>().add(LoadMarketCatches());
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 56,
                      child: _buildSearchAndFilterRow(context, allCatches),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child:
                          BlocBuilder<
                            FilteredProductsCubit,
                            FilteredProductsState
                          >(
                            builder: (context, filteredState) {
                              final filteredCatches =
                                  filteredState.displayedCatches;
                              if (filteredCatches.isEmpty &&
                                  allCatches.isNotEmpty) {
                                return const Center(
                                  child: Text(
                                    "No products match your filters.",
                                  ),
                                );
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
                                    onTap: () => context.go(
                                      "/buyer/product-details/${c.id}",
                                    ),
                                    catchModel: c,
                                  );
                                },
                              );
                            },
                          ),
                    ),
                    if (allCatches.isNotEmpty &&
                        marketState is BuyerMarketLoading)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchAndFilterRow(
    BuildContext context,
    List<Catch> allCatches,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 5,
          child: SearchBar(
            hintText: "Search...",
            scrollPadding: const EdgeInsets.symmetric(vertical: 4),
            textStyle: WidgetStateProperty.all(
              const TextStyle(fontSize: 16, color: AppColors.textBlue),
            ),
            backgroundColor: WidgetStateProperty.all(AppColors.white100),
            shape: WidgetStateProperty.all(
              const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
            trailing: const [Icon(Icons.search, color: AppColors.textBlue)],
            elevation: WidgetStateProperty.all(0),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: Material(
            color: AppColors.white100,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              splashColor: AppColors.blue700.withAlpha(25),
              borderRadius: BorderRadius.circular(16),
              onTap: () => _showFilterModal(context, allCatches),
              child: const Icon(Icons.filter_alt_outlined),
            ),
          ),
        ),
      ],
    );
  }

  void _showFilterModal(BuildContext context, List<Catch> allCatches) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => BlocBuilder<ProductsFilterCubit, ProductsFilterState>(
        builder: (context, filterState) {
          final filterCubit = context.read<ProductsFilterCubit>();
          final filteredState = context.read<FilteredProductsCubit>().state;

          final height = MediaQuery.of(context).size.height * 0.65;

          return Container(
            height: height,
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Filter by:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                const Text("Species", style: TextStyle(fontSize: 12)),
                const SizedBox(height: 12),
                MultiSelectDropdown<Species>(
                  label: "Species",
                  options: filteredState.uniqueSpecies,
                  selectedValues: filterState.selectedSpecies,
                  optionLabel: (s) => s.name.capitalize(),
                  onChanged: filterCubit.setSpecies,
                ),
                const SizedBox(height: 12),
                const Text("Location", style: TextStyle(fontSize: 12)),
                const SizedBox(height: 12),
                MultiSelectDropdown<String>(
                  label: "Location",
                  options: filteredState.uniqueLocations,
                  selectedValues: filterState.selectedLocations,
                  optionLabel: (s) => s,
                  onChanged: filterCubit.setLocations,
                ),
                const SizedBox(height: 12),
                const Text(
                  "Sort by:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                _buildDateSortOptions(filterCubit, filterState),
                const SizedBox(height: 8),
                _buildPriceSortOptions(filterCubit, filterState),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        filterCubit.clear();
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Reset All",
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                    ),
                    CustomButton(
                      title: "Apply Filters",
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateSortOptions(
    ProductsFilterCubit cubit,
    ProductsFilterState state,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RadioListTile<SortBy>(
          contentPadding: EdgeInsets.zero,
          dense: true,
          groupValue: state.sortByPrice == SortBy.none
              ? state.sortByDate
              : null,
          title: const Text('Oldest to Newest', style: TextStyle(fontSize: 14)),
          value: SortBy.oldNew,
          onChanged: (v) {
            if (v != null) {
              cubit.setSortDate(v);
              cubit.setSortPrice(SortBy.none);
            }
          },
        ),
        RadioListTile<SortBy>(
          contentPadding: EdgeInsets.zero,
          dense: true,
          groupValue: state.sortByPrice == SortBy.none
              ? state.sortByDate
              : null,
          title: const Text('Newest to Oldest', style: TextStyle(fontSize: 14)),
          value: SortBy.newOld,
          onChanged: (v) {
            if (v != null) {
              cubit.setSortDate(v);
              cubit.setSortPrice(SortBy.none);
            }
          },
        ),
      ],
    );
  }

  Widget _buildPriceSortOptions(
    ProductsFilterCubit cubit,
    ProductsFilterState state,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RadioListTile<SortBy>(
          contentPadding: EdgeInsets.zero,
          dense: true,
          groupValue: state.sortByDate == SortBy.none
              ? state.sortByPrice
              : null,
          title: const Text(
            'Price: Low to High',
            style: TextStyle(fontSize: 14),
          ),
          value: SortBy.lowHigh,
          onChanged: (v) {
            if (v != null) {
              cubit.setSortPrice(v);
              cubit.setSortDate(SortBy.none);
            }
          },
        ),
        RadioListTile<SortBy>(
          contentPadding: EdgeInsets.zero,
          dense: true,
          groupValue: state.sortByDate == SortBy.none
              ? state.sortByPrice
              : null,
          title: const Text(
            'Price: High to Low',
            style: TextStyle(fontSize: 14),
          ),
          value: SortBy.highLow,
          onChanged: (v) {
            if (v != null) {
              cubit.setSortPrice(v);
              cubit.setSortDate(SortBy.none);
            }
          },
        ),
      ],
    );
  }
}
