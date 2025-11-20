import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/models/info_row.dart';
import 'package:siren_marketplace/core/types/converters.dart';
import 'package:siren_marketplace/core/types/enum.dart';
import 'package:siren_marketplace/core/widgets/info_table.dart';
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
  Set<String> _activeSpecies = {};

  Map<String, List<ChartData>> _getFilteredPriceData() {
    final filteredData = filterDataByRange(mockHistoricalPrices, _chartRange);

    final Map<String, List<ChartData>> dataMap = {};
    const speciesKeys = [
      'pink-shrimp',
      'tiger-shrimp',
      'gray-shrimp',
      'small-prawn',
      'large-prawn',
    ];

    for (var key in speciesKeys) {
      final speciesData = filteredData.where((d) => d.species == key).toList();
      final chartData = speciesData.map((d) {
        String xLabel = '';
        switch (_chartRange) {
          case ChartRange.day:
            xLabel = DateFormat('h:mm a').format(d.date);
            break;
          case ChartRange.week:
            xLabel = DateFormat('EEE').format(d.date);
            break;
          case ChartRange.month:
            xLabel = DateFormat('MMM dd').format(d.date);
            break;
          case ChartRange.year:
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
  void initState() {
    super.initState();
    _activeSpecies = {
      'pink-shrimp',
      'tiger-shrimp',
      'gray-shrimp',
      'small-prawn',
      'large-prawn',
    };
  }

  void _toggleSpecies(String key) {
    setState(() {
      if (_activeSpecies.contains(key)) {
        _activeSpecies.remove(key);
      } else {
        _activeSpecies.add(key);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final priceChartData = _getFilteredPriceData();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        scrolledUnderElevation: 0,
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader("Today's Data"),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.gray200),
              ),
              child: InfoTable(
                rows: [
                  InfoRow(label: "Total Catch", value: "50 kg"),
                  InfoRow(label: "Average Price", value: formatPrice(500)),
                  InfoRow(label: "Highest Price", value: formatPrice(700)),
                  InfoRow(label: "Lowest Price", value: formatPrice(300)),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // --- Chart Section ---
            // --- ONLY THE CHART AREA IS MODIFIED BELOW ---
            SectionHeader("Average Sold Price Per Kg"),
            _buildChartContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PillSegmentedButton(
                    selected: _chartRange,
                    onChanged: (value) => setState(() => _chartRange = value),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.35,
                    child: Column(
                      children: [
                        _buildCustomLegend(priceChartData.keys.toList()),
                        const SizedBox(height: 12),
                        Expanded(
                          child: PriceLineChart(
                            chartDataSources: priceChartData,
                            activeSpecies: _activeSpecies,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --- Repeat same structure for the second chart ---
            SectionHeader("Total Catch"),
            _buildChartContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PillSegmentedButton(
                    selected: _chartRange,
                    onChanged: (value) => setState(() => _chartRange = value),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.35,
                    child: Column(
                      children: [
                        _buildCustomLegend(priceChartData.keys.toList()),
                        const SizedBox(height: 12),
                        Expanded(
                          child: PriceLineChart(
                            chartDataSources: priceChartData,
                            activeSpecies: _activeSpecies,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomLegend(List<String> speciesKeys) {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: speciesKeys.map((key) {
        final color = PriceLineChart.speciesColors[key] ?? Colors.grey;
        final label = _getSpeciesDisplayName(key);
        final isActive = _activeSpecies.contains(key);

        return GestureDetector(
          onTap: () => _toggleSpecies(key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            decoration: BoxDecoration(
              color: isActive ? Colors.transparent : AppColors.gray50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isActive ? color : AppColors.gray50,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isActive ? color : Colors.transparent,
                    shape: BoxShape.circle,
                    border: isActive
                        ? null
                        : Border.all(color: color, width: 0.8),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChartContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gray200),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  Widget _buildStatBlock(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              color: AppColors.textGray,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.textBlue,
            ),
          ),
        ],
      ),
    );
  }

  String _getSpeciesDisplayName(String key) {
    switch (key) {
      case 'pink-shrimp':
        return 'Pink Shrimp';
      case 'tiger-shrimp':
        return 'Tiger Shrimp';
      case 'gray-shrimp':
        return 'Grey Shrimp';
      case 'small-prawn':
        return 'Small Prawn';
      case 'large-prawn':
        return 'Large Prawn';
      default:
        return key;
    }
  }
}
