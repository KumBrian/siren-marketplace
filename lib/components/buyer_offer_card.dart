import 'package:flutter/material.dart';
import 'package:siren_marketplace/constants/constants.dart';
// UPDATE: Import the unified Offer type
import 'package:siren_marketplace/constants/types.dart'
    show Offer, DateFormatting, StringExtensions;

class BuyerOfferCard extends StatelessWidget {
  const BuyerOfferCard({
    super.key,
    // UPDATE: Change type to Offer
    required this.offer,
    required this.onPressed,
  });

  // UPDATE: Change type to Offer
  final Offer offer;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        // UPDATE: Use standard withOpacity
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
        // UPDATE: Use standard withOpacity
        color: AppColors.textBlue.withValues(alpha: 0.1),
      ),
      child: const Icon(Icons.local_offer_outlined, color: AppColors.textBlue),
    );
  }

  /// Top row: fisher name + fisher rating + date
  Widget _headerRow() {
    // NOTE: We assume the unified Offer model now contains `offer.fisherName`
    // for direct display in this card, derived from `offer.fisherId`.

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // UPDATE: Display the Fisher's Name (Seller) as the main identifier
            _text(
              offer.fisherName, // ASSUMED new field on Offer model
              AppColors.textGray,
              fontWeight: FontWeight.w600, // Make name prominent
            ),
            const SizedBox(width: 4),
            const Icon(Icons.star, color: AppColors.shellOrange, size: 16),
            // Displaying the rating of the fisher who owns the catch
            _text(
              offer.fisherRating.toStringAsFixed(1),
              AppColors.textGray,
              fontWeight: FontWeight.w300,
            ),
          ],
        ),
        _text(
          offer.dateCreated.toFormattedDate(),
          AppColors.blue800,
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
            _pill("${offer.weight.toInt()} kg"),
            const SizedBox(width: 8),
            _pill("${offer.price.toInt()} CFA"),
          ],
        ),
        Row(
          children: [
            _text(offer.status.name.capitalize(), AppColors.textGray),
            const SizedBox(width: 8),
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
