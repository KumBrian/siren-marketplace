import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:siren_marketplace/bloc/cubits/species_filter_cubit/species_filter_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/species_filter_cubit/species_filter_state.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/models/component_row.dart';
import 'package:siren_marketplace/core/types/enum.dart';
import 'package:siren_marketplace/core/widgets/component_table.dart';
import 'package:siren_marketplace/core/widgets/custom_button.dart';
import 'package:siren_marketplace/core/widgets/filter_button.dart';
import 'package:siren_marketplace/core/widgets/pill_segmented_button.dart';
import 'package:siren_marketplace/core/widgets/section_header.dart';
import 'package:siren_marketplace/data/chart_data.dart';
import 'package:siren_marketplace/features/fisher/presentation/widgets/price_line_chart.dart';

class MarketTrends extends StatefulWidget {
  const MarketTrends({super.key});

  @override
  State<MarketTrends> createState() => _MarketTrendsState();
}

class _MarketTrendsState extends State<MarketTrends> {
  ChartRange _chartRange = ChartRange.month;

  Map<String, List<ChartData>> _getFilteredPriceData() {
    // 1. Filter the data based on the selected time range
    final filteredData = filterDataByRange(mockHistoricalPrices, _chartRange);

    // 2. Group and transform data into the ChartData format expected by the chart
    final Map<String, List<ChartData>> dataMap = {};

    const speciesKeys = ['pink-shrimp', 'tiger-shrimp', 'gray-shrimp'];

    for (var key in speciesKeys) {
      final speciesData = filteredData.where((d) => d.species == key).toList();

      // Transform HistoricalPriceData to ChartData with professional date labels
      final chartData = speciesData.map((d) {
        String xLabel = '';

        switch (_chartRange) {
          case ChartRange.day:
            // Display Hour/Minute for the 'Day' view
            xLabel = DateFormat('h:mm a').format(d.date);
            break;
          case ChartRange.week:
            // Display Day of the week for 'Week' view
            xLabel = DateFormat('EEE').format(d.date);
            break;
          case ChartRange.month:
            // Display Day/Month for 'Month' view
            xLabel = DateFormat('MMM dd').format(d.date);
            break;
          case ChartRange.year:
            // Display Month/Year for 'Year' view
            xLabel = DateFormat('MMM yy').format(d.date);
            break;
        }

        return ChartData(xLabel, d.pricePerKg);
      }).toList();

      dataMap[key] = chartData;
    }

    return dataMap;
  }

  @override
  Widget build(BuildContext context) {
    final priceChartData = _getFilteredPriceData();
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text(
          "Market Trends",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textBlue,
            fontSize: 24,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SectionHeader("Today's Data"),
                  IconButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        showDragHandle: true,
                        builder: (context) {
                          return BlocBuilder<
                            SpeciesFilterCubit,
                            SpeciesFilterState
                          >(
                            builder: (context, state) {
                              final cubit = context.read<SpeciesFilterCubit>();

                              return Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  spacing: 16,
                                  children: [
                                    const Text(
                                      "Filter by:",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    const Text("Species"),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        FilterButton(
                                          title: "Tiger Shrimp",
                                          padding: EdgeInsets.symmetric(
                                            vertical: 12,
                                            horizontal: 8,
                                          ),
                                          isSelected:
                                              state.selectedSpecies ==
                                              "tiger-shrimp",
                                          onPressed: () => cubit.toggleSpecies(
                                            "tiger-shrimp",
                                          ),
                                        ),
                                        FilterButton(
                                          title: "Pink Shrimp",
                                          padding: EdgeInsets.symmetric(
                                            vertical: 12,
                                            horizontal: 8,
                                          ),
                                          isSelected:
                                              state.selectedSpecies ==
                                              "pink-shrimp",
                                          onPressed: () => cubit.toggleSpecies(
                                            "pink-shrimp",
                                          ),
                                        ),
                                        FilterButton(
                                          title: "Gray Shrimp",
                                          padding: EdgeInsets.symmetric(
                                            vertical: 12,
                                            horizontal: 8,
                                          ),
                                          isSelected:
                                              state.selectedSpecies ==
                                              "gray-shrimp",
                                          onPressed: () => cubit.toggleSpecies(
                                            "gray-shrimp",
                                          ),
                                        ),
                                        FilterButton(
                                          title: "Small Prawn",
                                          padding: EdgeInsets.symmetric(
                                            vertical: 12,
                                            horizontal: 8,
                                          ),
                                          isSelected:
                                              state.selectedSpecies ==
                                              "small-prawn",
                                          onPressed: () => cubit.toggleSpecies(
                                            "small-prawn",
                                          ),
                                        ),
                                        FilterButton(
                                          title: "Large Prawn",
                                          padding: EdgeInsets.symmetric(
                                            vertical: 12,
                                            horizontal: 8,
                                          ),
                                          isSelected:
                                              state.selectedSpecies ==
                                              "large-prawn",
                                          onPressed: () => cubit.toggleSpecies(
                                            "large-prawn",
                                          ),
                                        ),
                                      ],
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
                    icon: Icon(Icons.filter_alt_outlined),
                  ),
                ],
              ),
              Divider(color: AppColors.gray200),
              ComponentTable(
                rows: [
                  ComponentRow(
                    firstItem: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        spacing: 8,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Total Catch",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: AppColors.textGray,
                            ),
                          ),
                          Text(
                            "50Kg",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: AppColors.textBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    secondItem: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        spacing: 8,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Average Price",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: AppColors.textGray,
                            ),
                          ),
                          Text(
                            "12.00 CFA",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: AppColors.textBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ComponentRow(
                    firstItem: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        spacing: 8,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Highest Price",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: AppColors.textGray,
                            ),
                          ),
                          Text(
                            "13.50 CFA",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: AppColors.textBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    secondItem: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        spacing: 8,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Lowest Price",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: AppColors.textGray,
                            ),
                          ),
                          Text(
                            "11.00 CFA",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: AppColors.textBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),
              SectionHeader("Average Sold Price Per Kg"),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.gray200),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,

                  children: [
                    PillSegmentedButton(
                      selected: _chartRange,
                      onChanged: (value) {
                        setState(() {
                          _chartRange = value;
                        });
                      },
                    ),
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: PriceLineChart(chartDataSources: priceChartData),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              SectionHeader("Total Catch"),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.gray200),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 16,
                  children: [
                    PillSegmentedButton(
                      selected: _chartRange,
                      onChanged: (value) {
                        setState(() {
                          _chartRange = value;
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      spacing: 16,
                      children: [
                        Row(
                          spacing: 4,
                          children: [
                            Container(
                              width: 11,
                              height: 5,
                              decoration: BoxDecoration(
                                color: AppColors.shellOrange,
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            Text(
                              "Tiger Shrimp",
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        Row(
                          spacing: 4,
                          children: [
                            Container(
                              width: 11,
                              height: 5,
                              decoration: BoxDecoration(
                                color: AppColors.blue400,
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            Text("Pink Shrimp", style: TextStyle(fontSize: 12)),
                          ],
                        ),
                        Row(
                          spacing: 4,
                          children: [
                            Container(
                              width: 11,
                              height: 5,
                              decoration: BoxDecoration(
                                color: AppColors.success500,
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            Text("Grey Shrimp", style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: AppColors.gray100,
                      ),
                      child: PriceLineChart(chartDataSources: priceChartData),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
