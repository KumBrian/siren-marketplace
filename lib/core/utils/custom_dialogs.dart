import 'package:flutter/material.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/widgets/custom_button.dart';

Future<void> showActionSuccessDialog(
  BuildContext context, {
  required String message,
  String? actionTitle,
  VoidCallback? onAction,
  int autoCloseSeconds = 3,
}) async {
  if (!context.mounted) return;
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      if (autoCloseSeconds > 0 && actionTitle == null) {
        Future.delayed(Duration(seconds: autoCloseSeconds), () {
          if (ctx.mounted) Navigator.of(ctx).pop();
        });
      }

      return AlertDialog(
        title: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.textBlue,
            border: Border.all(color: AppColors.textBlue, width: 2),
          ),
          child: const Icon(Icons.check, color: AppColors.textWhite),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.textBlue,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            if (actionTitle != null && onAction != null)
              CustomButton(
                title: actionTitle,
                onPressed: () {
                  if (ctx.mounted) {
                    Navigator.of(ctx).pop();
                    onAction();
                  }
                },
              ),
          ],
        ),
      );
    },
  );
}
