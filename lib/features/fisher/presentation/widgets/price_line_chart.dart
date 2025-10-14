import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// Simple model class for chart data
class ChartData {
  ChartData(this.x, this.y);

  final String x;
  final double y;
}

class PriceLineChart extends StatelessWidget {
  const PriceLineChart({super.key, required this.chartDataSources});

  // A list of data sources, where each inner List<ChartData> is one series/line.
  final Map<String, List<ChartData>> chartDataSources;

  // Define colors for consistency
  static const Map<String, Color> speciesColors = {
    'pink-shrimp': Color(0xFF42A5F5), // blue400
    'tiger-shrimp': Color(0xFFFF9800), // shellOrange
    'gray-shrimp': Color(0xFF4CAF50), // success500
  };

  @override
  Widget build(BuildContext context) {
    // Generate the LineSeries dynamically from the provided data Map
    final List<LineSeries<ChartData, String>> seriesList = chartDataSources
        .entries
        .map((entry) {
          final speciesKey = entry.key;
          final data = entry.value;

          return LineSeries<ChartData, String>(
            dataSource: data,
            xValueMapper: (ChartData data, _) => data.x,
            yValueMapper: (ChartData data, _) => data.y,
            // Name and Color are set based on the species key
            name: _getSpeciesDisplayName(speciesKey),
            color: speciesColors[speciesKey],
            width: 4,
            markerSettings: const MarkerSettings(isVisible: false),
          );
        })
        .toList();

    return SfCartesianChart(
      zoomPanBehavior: ZoomPanBehavior(
        enablePinching: true,
        enableDoubleTapZooming: true,
        enablePanning: true,
      ),
      // Set the primaryYAxis to display a currency (CFA) if needed
      primaryYAxis: NumericAxis(
        labelFormat: '{value}', // Format labels as needed
        numberFormat: NumberFormat.compact(),
      ),
      legend: const Legend(
        isVisible: true,
        position: LegendPosition.top,
        textStyle: TextStyle(fontSize: 10, color: AppColors.textGray),
      ),
      primaryXAxis: const CategoryAxis(isVisible: false),
      tooltipBehavior: TooltipBehavior(enable: true),

      // Use the dynamically generated series list
      series: seriesList,
    );
  }

  // Helper to map keys to display names for the legend
  String _getSpeciesDisplayName(String key) {
    switch (key) {
      case 'pink-shrimp':
        return 'Pink Shrimp';
      case 'tiger-shrimp':
        return 'Tiger Shrimp';
      case 'gray-shrimp':
        return 'Grey Shrimp';
      default:
        return key;
    }
  }
}
