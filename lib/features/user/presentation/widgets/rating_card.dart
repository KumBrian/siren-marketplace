import 'package:flutter/material.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/utils/custom_icons.dart';
import 'package:siren_marketplace/core/widgets/animated_rating_stars.dart';

class RatingCard extends StatelessWidget {
  final double averageRating;
  final int totalReviews;
  final Map<int, int>
  ratingDistribution; // {5: count, 4: count, 3: count, 2: count, 1: count}

  const RatingCard({
    super.key,
    this.averageRating = 0.0,
    this.totalReviews = 0,
    required this.ratingDistribution,
  });

  // Helper to calculate the percentage value for the progress bar
  double _getRatingValue(int star) {
    if (totalReviews == 0) return 0.0;
    // Get count for the star level (e.g., 5-star count)
    final count = ratingDistribution[star] ?? 0;
    return count / totalReviews;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (index) {
                // Generate rows for 5, 4, 3, 2, 1 stars
                final rating = 5 - index;
                return Padding(
                  padding: EdgeInsets.only(top: index == 0 ? 0 : 8.0),
                  child: RatingValue(
                    value: _getRatingValue(rating),
                    rating: rating,
                  ),
                );
              }),
            ),
          ),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  averageRating.toStringAsFixed(1),
                  style: const TextStyle(
                    color: AppColors.textBlue,
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 24),
                AnimatedRatingStars(
                  initialRating: averageRating.toDouble(),
                  minRating: 1,
                  maxRating: 5.0,
                  filledColor: AppColors.shellOrange,
                  emptyColor: AppColors.gray100,
                  onChanged: (v) => null,
                  interactiveTooltips: true,
                  customFilledIcon: Icons.star_rounded,
                  customHalfFilledIcon: Icons.star_half_rounded,
                  customEmptyIcon: Icons.star_border_rounded,
                  starSize: 16,
                  readOnly: true,
                ),
                const SizedBox(height: 8),
                Text(
                  "$totalReviews Reviews",
                  style: const TextStyle(
                    color: AppColors.textBlue,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RatingValue extends StatelessWidget {
  const RatingValue({super.key, required this.value, required this.rating});

  final double value;
  final int rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 16,
          child: Text(
            "$rating",
            style: const TextStyle(
              color: AppColors.textBlue,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Icon(CustomIcons.star, color: AppColors.shellOrange, size: 16),
        const SizedBox(width: 4),
        Expanded(
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            color: AppColors.blue800,
            backgroundColor: AppColors.gray100,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ],
    );
  }
}
