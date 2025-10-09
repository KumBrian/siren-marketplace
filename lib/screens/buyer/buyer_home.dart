import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/bloc/cubits/product_cubit/product_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/products_filter_cubit/products_filter_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/products_filter_cubit/products_filter_state.dart';
import 'package:siren_marketplace/components/custom_button.dart';
import 'package:siren_marketplace/components/multi_select_dropdown.dart';
import 'package:siren_marketplace/components/product_card.dart';
import 'package:siren_marketplace/constants/constants.dart';
import 'package:siren_marketplace/constants/types.dart';

// --- NEW IMPORTS (We will listen to this Cubit now) ---
// NOTE: We may still need the BuyerCubit for notifications/profile actions, but
// we remove it from the main product listing BLoCBuilder.
// REMOVE: import 'package:siren_marketplace/bloc/cubits/buyer_cubit/buyer_cubit.dart';

// Assume ProductsCubit state is a List<Product> or contains one.
// We will use a dedicated state class (ProductsState) for safety.
// Assuming the following state for ProductsCubit:
// class ProductsState {
//   final List<Product> products;
//   final bool isLoading;
//   ProductsState({this.products = const [], this.isLoading = false});
// }

class BuyerHome extends StatefulWidget {
  const BuyerHome({super.key});

  @override
  State<BuyerHome> createState() => _BuyerHomeState();
}

class _BuyerHomeState extends State<BuyerHome> {
  // Function to apply filtering and sorting logic
  List<Product> _applyFiltersAndSort(
    List<Product> products,
    ProductsFilterState state,
  ) {
    // 1. Filtering
    List<Product> filtered = products.where((product) {
      // Filter by Species
      if (state.selectedSpecies.isNotEmpty &&
          !state.selectedSpecies.contains(product.species)) {
        return false;
      }
      // Filter by Location - Using product.market as property name
      if (state.selectedLocations.isNotEmpty &&
          !state.selectedLocations.contains(product.market)) {
        return false;
      }
      return true;
    }).toList();

    // 2. Sorting (Prioritize Price sort over Date sort if both are active)

    // Sort by Price (Primary Sort)
    filtered.sort((a, b) {
      if (state.sortByPrice == SortBy.lowHigh) {
        // Compare using totalPrice
        return a.totalPrice.compareTo(b.totalPrice);
      } else {
        // Compare using totalPrice
        return b.totalPrice.compareTo(a.totalPrice);
      }
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
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
            onPressed: () {
              context.go("/buyer/notifications");
            },
            icon: const Badge(
              label: Text("5"),
              child: Icon(Icons.notifications_none, color: AppColors.textBlue),
            ),
          ),
        ],
      ),
      // CHANGE: Listen to ProductsCubit state (assuming ProductsState class)
      body: BlocBuilder<ProductCubit, List<Product>>(
        builder: (context, productsState) {
          // Handle Loading State (assuming ProductsState has isLoading property)
          if (productsState.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final availableProducts = productsState;

          // Nested BlocBuilder for filtering remains the same
          return BlocBuilder<ProductsFilterCubit, ProductsFilterState>(
            builder: (context, filterState) {
              final filteredProducts = _applyFiltersAndSort(
                availableProducts,
                filterState,
              );

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8,
                ),
                child: Column(
                  spacing: 8,
                  children: [
                    // --- Search and Filter Row (No Change Here) ---
                    Expanded(
                      flex: 1,
                      child: Row(
                        spacing: 16,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 5,
                            child: SearchBar(
                              hintText: "Search...",
                              scrollPadding: const EdgeInsets.symmetric(
                                vertical: 4,
                              ),
                              textStyle: WidgetStateProperty.all(
                                const TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textBlue,
                                ),
                              ),
                              backgroundColor: WidgetStateProperty.all(
                                AppColors.white100,
                              ),
                              shape: WidgetStateProperty.all(
                                const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(16),
                                  ),
                                ),
                              ),
                              trailing: const [
                                Icon(Icons.search, color: AppColors.textBlue),
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
                                splashColor: AppColors.blue700.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    showDragHandle: true,
                                    isScrollControlled: true,
                                    builder: (context) {
                                      return BlocBuilder<
                                        ProductsFilterCubit,
                                        ProductsFilterState
                                      >(
                                        builder: (context, state) {
                                          final cubit = context
                                              .read<ProductsFilterCubit>();
                                          final height =
                                              MediaQuery.of(
                                                context,
                                              ).size.height *
                                              0.65;

                                          return Container(
                                            height: height,
                                            padding: const EdgeInsets.only(
                                              left: 16,
                                              right: 16,
                                              bottom: 32,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                const Text(
                                                  "Filter by:",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 12),
                                                const Text(
                                                  "Species",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                const SizedBox(height: 12),
                                                MultiSelectDropdown<Species>(
                                                  label: "Species",
                                                  options: kSpecies,
                                                  selectedValues:
                                                      state.selectedSpecies,
                                                  optionLabel: (s) =>
                                                      s.name.capitalize(),
                                                  onChanged: (values) {
                                                    context
                                                        .read<
                                                          ProductsFilterCubit
                                                        >()
                                                        .setSpecies(values);
                                                  },
                                                ),
                                                const SizedBox(height: 12),
                                                const Text(
                                                  "Location",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                const SizedBox(height: 12),
                                                MultiSelectDropdown<String>(
                                                  label: "Location",
                                                  options: const [
                                                    "Youpwe",
                                                    "Limbe",
                                                    "Douala",
                                                    "Kribi",
                                                    "Garoua",
                                                  ],
                                                  selectedValues:
                                                      state.selectedLocations,
                                                  optionLabel: (s) => s,
                                                  onChanged: (values) {
                                                    cubit.setLocations(values);
                                                  },
                                                ),
                                                const SizedBox(height: 12),
                                                const Text(
                                                  "Sort by:",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 12),
                                                RadioGroup<SortBy>(
                                                  groupValue: state.sortByDate,
                                                  onChanged: (val) =>
                                                      cubit.setSortDate(val!),
                                                  child: Column(
                                                    children: [
                                                      ListTile(
                                                        dense: true,
                                                        contentPadding:
                                                            EdgeInsets.zero,
                                                        onTap: () {
                                                          cubit.setSortDate(
                                                            SortBy.oldNew,
                                                          );
                                                        },
                                                        title: const Text(
                                                          'Oldest to Newest',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                        leading: Radio<SortBy>(
                                                          splashRadius: 12,
                                                          materialTapTargetSize:
                                                              MaterialTapTargetSize
                                                                  .shrinkWrap,
                                                          value: SortBy.oldNew,
                                                        ),
                                                      ),
                                                      ListTile(
                                                        contentPadding:
                                                            EdgeInsets.zero,
                                                        dense: true,
                                                        onTap: () {
                                                          cubit.setSortDate(
                                                            SortBy.newOld,
                                                          );
                                                        },
                                                        title: const Text(
                                                          'Newest to Oldest',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                        leading: Radio<SortBy>(
                                                          splashRadius: 12,
                                                          materialTapTargetSize:
                                                              MaterialTapTargetSize
                                                                  .shrinkWrap,
                                                          value: SortBy.newOld,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                RadioGroup<SortBy>(
                                                  groupValue: state.sortByPrice,
                                                  onChanged: (val) =>
                                                      cubit.setSortPrice(val!),
                                                  child: Column(
                                                    children: [
                                                      ListTile(
                                                        dense: true,
                                                        contentPadding:
                                                            EdgeInsets.zero,
                                                        onTap: () {
                                                          cubit.setSortPrice(
                                                            SortBy.lowHigh,
                                                          );
                                                        },
                                                        title: const Text(
                                                          'Price: Low to High',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                        leading: Radio<SortBy>(
                                                          splashRadius: 12,
                                                          materialTapTargetSize:
                                                              MaterialTapTargetSize
                                                                  .shrinkWrap,
                                                          value: SortBy.lowHigh,
                                                        ),
                                                      ),
                                                      ListTile(
                                                        dense: true,
                                                        contentPadding:
                                                            EdgeInsets.zero,
                                                        onTap: () {
                                                          cubit.setSortPrice(
                                                            SortBy.highLow,
                                                          );
                                                        },
                                                        title: const Text(
                                                          'Price: High to Low',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                        leading: Radio<SortBy>(
                                                          splashRadius: 12,
                                                          materialTapTargetSize:
                                                              MaterialTapTargetSize
                                                                  .shrinkWrap,
                                                          value: SortBy.highLow,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    TextButton(
                                                      onPressed: () {
                                                        cubit.clear();
                                                        Navigator.pop(context);
                                                      },
                                                      child: const Text(
                                                        "Reset All",
                                                        style: TextStyle(
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                        ),
                                                      ),
                                                    ),
                                                    CustomButton(
                                                      title: "Apply Filters",
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            context,
                                                          ), // Apply filters and close modal
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(Icons.filter_alt_outlined),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // --- Products Grid (Uses filteredProducts) ---
                    Expanded(
                      flex: 12,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: filteredProducts.isEmpty
                            ? const Center(
                                child: Text("No products match your filters."),
                              )
                            : GridView.builder(
                                padding: const EdgeInsets.only(bottom: 100),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 8,
                                      mainAxisSpacing: 8,
                                      mainAxisExtent: 250,
                                    ),
                                itemCount: filteredProducts.length,
                                itemBuilder: (context, index) {
                                  final p = filteredProducts[index];
                                  return ProductCard(
                                    product: p,
                                    onTap: () {
                                      context.go(
                                        "/buyer/product-details/${p.id}",
                                      );
                                    },
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
