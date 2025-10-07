import 'package:flutter/material.dart';
import 'package:siren_marketplace/constants/constants.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final int? maxLines;

  const SectionHeader(this.title, {super.key, this.maxLines});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: AppColors.textBlue,
      ),
    );
  }
}
