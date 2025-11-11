import 'package:flutter/material.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/utils/custom_icons.dart';

class RatingCard extends StatelessWidget {
  const RatingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Column(
              spacing: 16,
              children: [
                RatingValue(value: 0.9, rating: 5),
                RatingValue(value: 0.7, rating: 4),
                RatingValue(value: 0.5, rating: 3),
                RatingValue(value: 0.3, rating: 2),
                RatingValue(value: 0.1, rating: 1),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "4.0",
                  style: TextStyle(
                    color: AppColors.textBlue,
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  spacing: 4,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: List.generate(
                    5,
                    (index) => Icon(
                      CustomIcons.star,
                      size: 16,
                      color: index == 4
                          ? AppColors.gray200
                          : AppColors.warning500,
                    ),
                  ),
                ),
                SizedBox(height: 8),

                Text(
                  "52 Reviews",
                  style: TextStyle(
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
      spacing: 4,
      children: [
        SizedBox(
          width: 16,
          child: Text(
            "$rating",
            style: TextStyle(
              color: AppColors.textBlue,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Icon(CustomIcons.star, color: AppColors.warning500, size: 16),
        SizedBox(height: 4),
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
