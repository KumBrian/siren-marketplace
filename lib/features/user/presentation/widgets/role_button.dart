import 'package:flutter/material.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';

class RoleButton extends StatelessWidget {
  const RoleButton({
    super.key,
    required this.title,
    required this.icon,
    required this.isActive,
    required this.onPressed,
  });

  final String title;
  final String icon;
  final bool isActive;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? AppColors.blue700 : AppColors.white100,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        splashColor: isActive
            ? AppColors.white100.withValues(alpha: 0.1)
            : AppColors.blue700.withValues(alpha: 0.1),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 24),
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.blue700, width: 2),
          ),
          child: Column(
            children: [
              Image(
                image: AssetImage(icon),
                width: 60,
                color: isActive ? AppColors.white100 : AppColors.blue700,
              ),
              // Icon(Icons.person, color: AppColors.white100, size: 60),
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isActive ? AppColors.textWhite : AppColors.blue700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
