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
import 'package:siren_marketplace/core/utils/custom_icons.dart';
import 'package:siren_marketplace/core/widgets/custom_button.dart';
import 'package:siren_marketplace/core/widgets/multi_select_dropdown.dart';
import 'package:siren_marketplace/core/widgets/number_input_field.dart';
import 'package:siren_marketplace/features/buyer/logic/buyer_market_bloc/buyer_market_bloc.dart';
import 'package:siren_marketplace/features/buyer/presentation/widgets/product_card.dart';
import 'package:siren_marketplace/features/fisher/logic/offers_bloc/offers_bloc.dart';
import 'package:siren_marketplace/features/user/logic/user_bloc/user_bloc.dart';

class BuyerHome extends StatefulWidget {
  const BuyerHome({super.key});

  @override
  State<BuyerHome> createState() => _BuyerHomeState();
}

class _BuyerHomeState extends State<BuyerHome> {
  final TextEditingController _weightController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _hasLoadedOffers = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BuyerMarketBloc>().add(LoadMarketCatches());
    });
  }

  int _calculateNotificationCount(OffersState state) {
    if (state is OffersLoaded) {
      // Filter for offers where the buyer has an update
      return state.offers.where((offer) => offer.hasUpdateForBuyer).length;
    }
    // Return 0 or null if the state is not loaded, loading, or an error
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasLoadedOffers) {
      final userState = context.read<UserBloc>().state;
      if (userState is UserLoaded) {
        context.read<OffersBloc>().add(
          LoadOffersForUser(userId: userState.user!.id, role: userState.role),
        );
        _hasLoadedOffers = true; // Mark as done immediately if already loaded
      }
    }
    return BlocListener<UserBloc, UserState>(
      listenWhen: (prev, current) => !_hasLoadedOffers && current is UserLoaded,
      listener: (context, userState) {
        if (userState is UserLoaded) {
          // This fires if UserBloc loads *after* BuyerHome mounts.
          context.read<OffersBloc>().add(
            LoadOffersForUser(userId: userState.user!.id, role: userState.role),
          );
          _hasLoadedOffers = true; // Mark as done when the listener fires
        }
      },
      child: BlocBuilder<OffersBloc, OffersState>(
        builder: (context, offersState) {
          final notificationCount = _calculateNotificationCount(offersState);
          return BlocListener<BuyerMarketBloc, BuyerMarketState>(
            listener: (context, marketState) {
              if (marketState is BuyerMarketLoaded) {
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
                    centerTitle: true,
                    scrolledUnderElevation: 0,
                    shadowColor: Colors.transparent,
                    title: Image.asset(
                      "assets/icons/siren_logo.png",
                      width: 100,
                      errorBuilder: (context, error, stackTrace) {
                        return Text("SIREN");
                      },
                    ),
                    actions: [
                      IconButton(
                        onPressed: () => context.go("/buyer/notifications"),
                        icon: Badge(
                          label: Text("$notificationCount"),
                          child: Icon(
                            CustomIcons.notificationbell,
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
                            child: _buildSearchAndFilterRow(
                              context,
                              allCatches,
                            ),
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
                                      padding: const EdgeInsets.only(
                                        bottom: 100,
                                      ),
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
                        ],
                      ),
                    ),
                  ),
                );
              },
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
              onTap: () => _showSortModal(context, allCatches),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Icon(CustomIcons.sort, color: AppColors.textBlue),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: BlocBuilder<ProductsFilterCubit, ProductsFilterState>(
            builder: (context, state) {
              final hasFilters = state.totalFilters > 0;

              return Badge(
                isLabelVisible: hasFilters,
                label: Text("${state.totalFilters}"),
                alignment: Alignment.topRight,

                backgroundColor: AppColors.blue800,
                child: SizedBox(
                  width: double.infinity, // locks full width of Expanded
                  child: Material(
                    color: AppColors.white100,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      splashColor: AppColors.blue700.withAlpha(25),
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _showFilterModal(context, allCatches),
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

  void _showFilterModal(BuildContext context, List<Catch> allCatches) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => BlocBuilder<ProductsFilterCubit, ProductsFilterState>(
        builder: (context, filterState) {
          final filterCubit = context.read<ProductsFilterCubit>();
          final filteredState = context.read<FilteredProductsCubit>().state;
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
                    options: filteredState.uniqueSpecies,
                    selectedValues: filterState.selectedSpecies,
                    optionLabel: (s) => s.name.capitalize(),
                    onChanged: filterCubit.setSpecies,
                  ),

                  const Text("Location", style: TextStyle(fontSize: 12)),
                  MultiSelectDropdown<String>(
                    label: "Location",
                    options: filteredState.uniqueLocations,
                    selectedValues: filterState.selectedLocations,
                    optionLabel: (s) => s,
                    onChanged: filterCubit.setLocations,
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
                          filterCubit.clear();
                          filterCubit.applyFilters();
                          _weightController.clear();
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Reset All",
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      CustomButton(
                        title: "Apply Filters",
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final minWeight = double.tryParse(
                              _weightController.text.trim(),
                            );
                            filterCubit.setMinWeight(minWeight);
                            filterCubit.applyFilters();
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
        },
      ),
    );
  }

  void _showSortModal(BuildContext context, List<Catch> allCatches) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => BlocBuilder<ProductsFilterCubit, ProductsFilterState>(
        builder: (context, filterState) {
          final filterCubit = context.read<ProductsFilterCubit>();
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
                _buildDateSortOptions(filterCubit, filterState),
                Divider(thickness: 2, color: AppColors.gray200),
                _buildPriceSortOptions(filterCubit, filterState),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        filterCubit.clear();
                        filterCubit.applyFilters();
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
                        filterCubit.applyFilters();
                        Navigator.pop(context);
                      },
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
      children: [
        RadioListTile<SortBy>(
          dense: true,
          groupValue: state.sortByDate,
          title: const Text('Oldest to Newest', style: TextStyle(fontSize: 14)),
          value: SortBy.oldNew,
          onChanged: (v) {
            if (v != null) cubit.setSortDate(v);
          },
        ),
        RadioListTile<SortBy>(
          dense: true,
          groupValue: state.sortByDate,
          title: const Text('Newest to Oldest', style: TextStyle(fontSize: 14)),
          value: SortBy.newOld,
          onChanged: (v) {
            if (v != null) cubit.setSortDate(v);
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
      children: [
        RadioListTile<SortBy>(
          dense: true,
          groupValue: state.sortByPrice,
          title: const Text(
            'Price: Low to High',
            style: TextStyle(fontSize: 14),
          ),
          value: SortBy.lowHigh,
          onChanged: (v) {
            if (v != null) cubit.setSortPrice(v);
          },
        ),
        RadioListTile<SortBy>(
          dense: true,
          groupValue: state.sortByPrice,
          title: const Text(
            'Price: High to Low',
            style: TextStyle(fontSize: 14),
          ),
          value: SortBy.highLow,
          onChanged: (v) {
            if (v != null) cubit.setSortPrice(v);
          },
        ),
      ],
    );
  }
}
