import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.cancel = false,
    this.bordered = false,
    this.icon,
    this.hugeIcon,
    this.suffixIcon,
    this.disabled = false,
  });

  final String title;
  final VoidCallback onPressed;
  final bool? cancel;
  final bool? bordered;
  final IconData? icon;
  final dynamic hugeIcon; // fix type later, not List<List<dynamic>>
  final IconData? suffixIcon;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final textColor = (cancel == true || bordered == true)
        ? AppColors.textBlue
        : AppColors.textWhite;
    final bgColor = (cancel == true || bordered == true)
        ? Colors.transparent
        : AppColors.textBlue.withValues(alpha: disabled ? 0.6 : 1);

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: disabled ? null : onPressed,
        borderRadius: BorderRadius.circular(8),
        splashColor: (cancel == true || bordered == true)
            ? AppColors.textBlue.withValues(alpha: .1)
            : AppColors.white100.withValues(alpha: 0.1),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: bordered == true
                ? Border.all(color: AppColors.textBlue, width: 1)
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (icon != null) Icon(icon, size: 16, color: textColor),
              if (hugeIcon != null)
                HugeIcon(icon: hugeIcon!, size: 16, color: textColor),
              if (icon != null || hugeIcon != null) const SizedBox(width: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (suffixIcon != null) ...[
                const SizedBox(width: 8),
                Icon(suffixIcon, size: 20, color: textColor),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
