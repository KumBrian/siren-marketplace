import 'package:flutter/material.dart';
import 'package:siren_marketplace/constants/constants.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.cancel = false,
    this.bordered = false,
    this.icon,
    this.suffixIcon,
    this.disabled = false,
  });

  final String title;
  final VoidCallback onPressed;
  final bool? cancel;
  final bool? bordered;
  final IconData? icon;
  final IconData? suffixIcon;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: cancel == true || bordered == true
          ? Colors.transparent
          : AppColors.textBlue.withValues(alpha: disabled ? 0.6 : 1),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: disabled ? null : onPressed,
        borderRadius: BorderRadius.circular(8),
        splashColor: cancel == true || bordered == true
            ? AppColors.textBlue.withValues(alpha: .1)
            : AppColors.white100.withValues(alpha: 0.1),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),

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
            spacing: 8,
            children: [
              icon != null
                  ? Icon(
                      icon,
                      size: 16,
                      color: cancel == true || bordered == true
                          ? AppColors.textBlue
                          : AppColors.textWhite,
                    )
                  : Container(),

              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: cancel == true || bordered == true
                      ? AppColors.textBlue
                      : AppColors.textWhite,
                  fontWeight: FontWeight.w500,
                ),
              ),
              suffixIcon != null
                  ? Icon(
                      suffixIcon,
                      size: 20,
                      color: cancel == true || bordered == true
                          ? AppColors.textBlue
                          : AppColors.textWhite,
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
