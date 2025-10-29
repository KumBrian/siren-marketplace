import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/models/offer.dart';
import 'package:siren_marketplace/core/types/extensions.dart';
import 'package:siren_marketplace/core/utils/custom_icons.dart';

class OfferCard extends StatelessWidget {
  const OfferCard({
    super.key,
    required this.offer,
    required this.onPressed,
    required this.fisherName,
    required this.fisherRating,
  });

  final Offer offer;
  final VoidCallback onPressed;

  final String fisherName;
  final double fisherRating;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        // ✅ Use standard withOpacity()
        splashColor: AppColors.blue700.withValues(alpha: 0.1),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.gray200)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _iconBadge(),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _headerRow(),
                    const SizedBox(height: 4),
                    _detailsRow(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Left-hand icon with background
  Widget _iconBadge() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        // ✅ Use standard withOpacity()
        color: AppColors.textBlue.withValues(alpha: 0.1),
      ),
      child: offer.hasUpdateForBuyer
          ? Icon(CustomIcons.moneybag_filled, color: AppColors.textBlue)
          : HugeIcon(
              icon: HugeIconsStrokeRounded.moneyBag01,
              color: AppColors.textBlue,
            ),
    );
  }

  /// Top row: fisher name + fisher rating + date
  Widget _headerRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // 🆕 Use the passed-in fisherName
            _text(
              fisherName,
              offer.hasUpdateForBuyer ? AppColors.textBlue : AppColors.textGray,
              fontWeight: offer.hasUpdateForBuyer
                  ? FontWeight.w600
                  : FontWeight.w400, // Make name prominent
            ),
            const SizedBox(width: 4),
            const Icon(Icons.star, color: AppColors.shellOrange, size: 16),
            // 🆕 Use the passed-in fisherRating
            _text(
              fisherRating.toStringAsFixed(1), // Ensure proper formatting
              offer.hasUpdateForBuyer ? AppColors.textBlue : AppColors.textGray,
              fontWeight: offer.hasUpdateForBuyer
                  ? FontWeight.w500
                  : FontWeight.w300,
            ),
          ],
        ),
        _text(
          offer.dateCreated.toFormattedDate(),
          offer.hasUpdateForBuyer ? AppColors.textBlue : AppColors.textGray,
          fontWeight: offer.hasUpdateForBuyer
              ? FontWeight.w500
              : FontWeight.w300,
          fontSize: 12,
        ),
      ],
    );
  }

  /// Bottom row: pills (weight/price) + status
  Widget _detailsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // ✅ Use toStringAsFixed for double values
            _pill("${offer.weight.toStringAsFixed(1)} kg"),
            const SizedBox(width: 8),
            _pill("${offer.price.toStringAsFixed(0)} CFA"),
          ],
        ),
        Row(
          children: [
            // Status text
            _text(offer.status.name.capitalize(), AppColors.textGray),
            const SizedBox(width: 8),
            // Status circle indicator
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.getStatusColor(offer.status),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Small pill-shaped label
  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.gray100,
      ),
      child: _text(
        text,
        AppColors.textBlue,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );
  }

  /// Centralized text styling
  Widget _text(
    String text,
    Color color, {
    FontWeight fontWeight = FontWeight.normal,
    double fontSize = 14,
  }) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      ),
    );
  }
}
