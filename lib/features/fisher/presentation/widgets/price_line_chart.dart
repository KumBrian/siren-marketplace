import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final double y;
}

class PriceLineChart extends StatelessWidget {
  const PriceLineChart({
    super.key,
    required this.chartDataSources,
    required this.activeSpecies,
  });

  final Map<String, List<ChartData>> chartDataSources;
  final Set<String> activeSpecies;

  static const Map<String, Color> speciesColors = {
    'pink-shrimp': Color(0xFF188D8D),
    'tiger-shrimp': Color(0xFFE00E8C),
    'gray-shrimp': Color(0xFF9BD267),
    'small-prawn': Color(0xFFFFC42C),
    'large-prawn': Color(0xFF5563DE),
  };

  @override
  Widget build(BuildContext context) {
    final visibleData = chartDataSources.entries
        .where((entry) => activeSpecies.contains(entry.key))
        .expand((entry) => entry.value)
        .toList();

    double? minY, maxY;
    if (visibleData.isNotEmpty) {
      minY = visibleData.map((e) => e.y).reduce(min);
      maxY = visibleData.map((e) => e.y).reduce(max);
      if (minY == maxY) {
        minY = minY * 0.9;
        maxY = maxY * 1.1;
      } else {
        minY = minY > 0 ? minY * 0.9 : 0;
        maxY = maxY * 1.05;
      }
    }

    final activeSeriesList = chartDataSources.entries
        .where((entry) => activeSpecies.contains(entry.key))
        .map((entry) {
          final color = speciesColors[entry.key];
          return LineSeries<ChartData, String>(
            dataSource: entry.value,
            xValueMapper: (ChartData data, _) => data.x,
            yValueMapper: (ChartData data, _) => data.y,
            color: color,
            name: _getSpeciesDisplayName(entry.key),
            width: 3,
            markerSettings: const MarkerSettings(isVisible: false),
          );
        })
        .toList();

    return SfCartesianChart(
      zoomPanBehavior: ZoomPanBehavior(
        enablePinching: true,
        enablePanning: true,
        enableDoubleTapZooming: true,
      ),
      primaryXAxis: const CategoryAxis(isVisible: false),
      primaryYAxis: NumericAxis(
        labelFormat: '{value}',
        numberFormat: NumberFormat.compact(),
        rangePadding: ChartRangePadding.none,
        minimum: minY,
        maximum: maxY,
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: activeSeriesList,
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
