import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/models/offer.dart';
import 'package:siren_marketplace/core/types/converters.dart';
import 'package:siren_marketplace/core/types/extensions.dart';
import 'package:siren_marketplace/core/utils/custom_icons.dart';

class OfferCard extends StatelessWidget {
  const OfferCard({
    super.key,
    required this.offer,
    required this.onPressed,
    // 🆕 Add explicit client details
    required this.clientName,
    required this.clientRating,
  });

  final Offer offer;
  final VoidCallback onPressed;

  // 🆕 New required fields
  final String clientName;
  final double clientRating;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        splashColor: AppColors.blue700.withValues(alpha: 0.1),
        // Using .withOpacity
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            // Ensuring the border bottom is applied to the InkWell's child Container
            border: Border(bottom: BorderSide(color: AppColors.gray200)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              _iconBadge(offer),
              Expanded(
                child: Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.center,

                  children: [_headerRow(), _detailsRow()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Left-hand icon with background
  Widget _iconBadge(Offer offer) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        // Used withOpacity for cleaner syntax
        color: AppColors.textBlue.withValues(alpha: 0.1),
      ),
      child: offer.hasUpdateForFisher
          ? Icon(CustomIcons.moneybag, color: AppColors.textBlue)
          : HugeIcon(
              icon: HugeIconsStrokeRounded.moneyBag01,
              color: AppColors.textBlue,
            ),
    );
  }

  /// Top row: client name + client rating + date
  // 🆕 Takes BuildContext to ensure proper use of extensions
  Widget _headerRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // 🆕 Use the passed-in clientName
            _text(
              clientName,
              offer.hasUpdateForFisher
                  ? AppColors.textBlue
                  : AppColors.textGray,
              fontWeight: offer.hasUpdateForFisher
                  ? FontWeight.w500
                  : FontWeight.w300,
            ),
            const SizedBox(width: 4),
            const Icon(Icons.star, color: AppColors.shellOrange, size: 12),
            // 🆕 Use the passed-in clientRating
            Text(
              clientRating.toStringAsFixed(1),
              style: TextStyle(
                color: offer.hasUpdateForFisher
                    ? AppColors.textBlue
                    : AppColors.textGray,
                fontWeight: offer.hasUpdateForFisher
                    ? FontWeight.w500
                    : FontWeight.w300,
                fontSize: 12,
              ),
            ),
          ],
        ),
        // Date created is on the offer
        Text(
          offer.dateCreated.toFormattedDate(),
          style: TextStyle(
            color: offer.hasUpdateForFisher
                ? AppColors.textBlue
                : AppColors.textGray,
            fontWeight: offer.hasUpdateForFisher
                ? FontWeight.w500
                : FontWeight.w300,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  /// Bottom row: pills + status
  Widget _detailsRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // Weight and Price are on the offer
            _pill("${offer.weight.toInt()} kg"),

            const SizedBox(width: 8),
            _pill(formatPrice(offer.price)),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          spacing: 4,
          children: [
            Text(
              offer.status.name.capitalize(),
              style: TextStyle(
                color: AppColors.textGray,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            Container(
              width: 8,
              height: 8,
              // Replaced spacing: 8
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColors.gray100,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.textBlue,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
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
    return SizedBox(
      width: 100,
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        ),
      ),
    );
  }
}
