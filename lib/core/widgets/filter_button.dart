import 'package:flutter/material.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';

class FilterButton extends StatelessWidget {
  const FilterButton({
    super.key,
    this.color,
    this.padding,
    required this.title,
    required this.isSelected,
    required this.onPressed,
  });

  final String title;
  final Color? color;
  final EdgeInsets? padding;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        splashColor: AppColors.blue700.withValues(alpha: 0.1),
        child: Container(
          padding:
              padding ?? EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.blue700 : AppColors.gray300,
              width: 1,
            ),
          ),
          child: Row(
            spacing: 8,
            mainAxisSize: MainAxisSize.min,
            children: [
              color == null
                  ? Container()
                  : Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white),
                        color: color,
                      ),
                    ),
              // Icon(Icons.person, color: AppColors.white100, size: 60),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? AppColors.blue700 : AppColors.gray300,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
