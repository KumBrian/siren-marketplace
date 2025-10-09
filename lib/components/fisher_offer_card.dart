import 'package:flutter/material.dart';
import 'package:siren_marketplace/constants/constants.dart';
import 'package:siren_marketplace/constants/types.dart';

class FisherOfferCard extends StatelessWidget {
  const FisherOfferCard({
    super.key,
    required this.offer,
    required this.onPressed,
  });

  // UPDATE: Change type from FisherOffer to the unified Offer
  final Offer offer;
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
        color: AppColors.textBlue.withValues(alpha: 0.1),
      ),
      child: const Icon(Icons.local_offer_outlined, color: AppColors.textBlue),
    );
  }

  /// Top row: client name + client rating + date
  Widget _headerRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // UPDATE: Use clientName instead of name (which refers to catch name)
            _text(
              offer.clientName,
              AppColors.textGray,
              fontWeight: FontWeight.w300,
            ),
            const SizedBox(width: 4),
            const Icon(Icons.star, color: AppColors.shellOrange, size: 16),
            // UPDATE: Use clientRating
            _text(
              offer.clientRating.toStringAsFixed(1),
              AppColors.textGray,
              fontWeight: FontWeight.w300,
            ),
          ],
        ),
        // Date created is on the offer
        _text(
          offer.dateCreated.toFormattedDate(),
          AppColors.blue800,
          fontSize: 12,
        ),
      ],
    );
  }

  /// Bottom row: pills + status
  Widget _detailsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // Weight and Price are on the offer
            _pill("${offer.weight.toInt()} kg"),
            const SizedBox(width: 8),
            _pill("${offer.price.toInt()} CFA"),
          ],
        ),
        Row(
          spacing: 8,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.getStatusColor(offer.status),
              ),
            ),
            _text(offer.status.name.capitalize(), AppColors.textGray),
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
