import 'package:flutter/material.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/types/enum.dart';

class PillSegmentedButton extends StatelessWidget {
  final ChartRange selected;
  final ValueChanged<ChartRange> onChanged;

  const PillSegmentedButton({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final segments = {
      ChartRange.day: "Today",
      ChartRange.week: "Week",
      ChartRange.month: "Month",
      ChartRange.year: "Year",
    };

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(16),
      ),
      height: 48,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segmentCount = segments.length;
          final segmentWidth = constraints.maxWidth / segmentCount;
          final index = segments.keys.toList().indexOf(selected);

          return Stack(
            alignment: Alignment.center,
            children: [
              // 🔹 Sliding pill
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                left: index * segmentWidth,
                top: 0,
                bottom: 0,
                width: segmentWidth,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 4, // 🔹 pill spacing inside cell
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white100,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),

              // 🔹 Labels row
              Row(
                children: segments.entries.map((entry) {
                  final isSelected = entry.key == selected;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onChanged(entry.key),
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: Text(
                          entry.value,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: isSelected
                                ? const Color(0xFF0A2A45)
                                : Colors.blueGrey,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}
