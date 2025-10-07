import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/bloc/cubits/products_filter_cubit/products_filter_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/products_filter_cubit/products_filter_state.dart';
import 'package:siren_marketplace/components/custom_button.dart';
import 'package:siren_marketplace/components/multi_select_dropdown.dart';
import 'package:siren_marketplace/components/product_card.dart';
import 'package:siren_marketplace/constants/constants.dart';
import 'package:siren_marketplace/constants/types.dart';
import 'package:siren_marketplace/data/product_data.dart';

class BuyerHome extends StatefulWidget {
  const BuyerHome({super.key});

  @override
  State<BuyerHome> createState() => _BuyerHomeState();
}

class _BuyerHomeState extends State<BuyerHome> {
  final List<Product> products = sampleProducts;

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
            icon: Badge(
              label: Text("5"),
              child: Icon(Icons.notifications_none, color: AppColors.textBlue),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: Column(
          spacing: 8,
          children: [
            Expanded(
              flex: 1,
              child: Row(
                spacing: 16,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 4,
                    child: SearchBar(
                      hintText: "Search...",
                      scrollPadding: EdgeInsets.symmetric(vertical: 4),
                      textStyle: WidgetStateProperty.all(
                        TextStyle(fontSize: 16, color: AppColors.textBlue),
                      ),
                      backgroundColor: WidgetStateProperty.all(
                        AppColors.white100,
                      ),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(16),
                        ),
                      ),

                      trailing: [Icon(Icons.search, color: AppColors.textBlue)],
                      elevation: WidgetStateProperty.all(0),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Material(
                      color: AppColors.white100,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        splashColor: AppColors.blue700.withValues(alpha: .1),
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
                                      MediaQuery.of(context).size.height * 0.65;

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
                                      spacing: 12,
                                      children: [
                                        const Text(
                                          "Filter by:",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const Text(
                                          "Species",
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        MultiSelectDropdown<Species>(
                                          label: "Species",
                                          options: kSpecies,
                                          selectedValues: state.selectedSpecies,
                                          optionLabel: (s) =>
                                              s.name.capitalize(),
                                          // convert enum to string
                                          onChanged: (values) {
                                            context
                                                .read<ProductsFilterCubit>()
                                                .setSpecies(values);
                                          },
                                        ),
                                        const Text(
                                          "Location",
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        MultiSelectDropdown<String>(
                                          label: "Location",
                                          options: [
                                            "Youpwe",
                                            "Limbe",
                                            "Douala",
                                            "Kribi",
                                            "Garoua",
                                          ],
                                          selectedValues:
                                              state.selectedLocations,
                                          optionLabel: (s) => s,
                                          // convert enum to string
                                          onChanged: (values) {
                                            cubit.setLocations(values);
                                          },
                                        ),
                                        const Text(
                                          "Sort by:",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        RadioGroup<SortBy>(
                                          groupValue: state.sortByDate,
                                          onChanged: (val) =>
                                              cubit.setSortDate(val!),
                                          child: Column(
                                            children: [
                                              ListTile(
                                                dense: true,
                                                contentPadding: EdgeInsets.zero,
                                                onTap: () {
                                                  cubit.setSortDate(
                                                    SortBy.oldNew,
                                                  );
                                                },
                                                title: Text(
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
                                                contentPadding: EdgeInsets.zero,
                                                dense: true,
                                                onTap: () {
                                                  cubit.setSortDate(
                                                    SortBy.newOld,
                                                  );
                                                },
                                                title: Text(
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
                                                contentPadding: EdgeInsets.zero,
                                                onTap: () {
                                                  cubit.setSortPrice(
                                                    SortBy.lowHigh,
                                                  );
                                                },
                                                title: Text(
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
                                                contentPadding: EdgeInsets.zero,
                                                onTap: () {
                                                  cubit.setSortPrice(
                                                    SortBy.highLow,
                                                  );
                                                },
                                                title: Text(
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
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,

                                          children: [
                                            TextButton(
                                              onPressed: () {
                                                cubit.clear();
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                "Reset All",
                                                style: TextStyle(
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                              ),
                                            ),
                                            CustomButton(
                                              title: "Apply Filters",
                                              onPressed: () {},
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
                          child: Icon(Icons.filter_alt_outlined),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 12,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: GridView(
                  padding: EdgeInsets.only(bottom: 100),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    mainAxisExtent: 250,
                  ),
                  children: products
                      .map(
                        (p) => ProductCard(
                          product: p,
                          onTap: () {
                            context.go("/buyer/product-details/${p.id}");
                          },
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
