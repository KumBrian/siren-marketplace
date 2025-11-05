import 'package:flutter/material.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final int? maxLines;
  final double? maxWidth;
  final double? fontSize;

  const SectionHeader(
    this.title, {
    super.key,
    this.maxLines,
    this.maxWidth,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: maxWidth,
      child: Text(
        title,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: fontSize ?? 16,
          color: AppColors.textBlue,
        ),
      ),
    );
  }
}
