import 'package:animated_rating_stars/animated_rating_stars.dart';
import 'package:flutter/material.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/widgets/error_handling_circle_avatar.dart';

class ReviewCard extends StatelessWidget {
  final String name;
  final String date;
  final double rating;
  final String image;
  final String message;

  const ReviewCard({
    super.key,
    required this.name,
    required this.date,
    required this.rating,
    required this.image,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ErrorHandlingCircleAvatar(avatarUrl: image),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textBlue,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      // Star Icons
                      AnimatedRatingStars(
                        initialRating: rating,
                        minRating: 1,
                        maxRating: 5.0,

                        filledColor: AppColors.shellOrange,
                        emptyColor: AppColors.gray100,
                        onChanged: (v) => null,
                        interactiveTooltips: true,
                        customFilledIcon: Icons.star_rounded,
                        customHalfFilledIcon: Icons.star_half_rounded,
                        customEmptyIcon: Icons.star_rounded,
                        starSize: 12,
                        readOnly: true,
                      ),
                      const SizedBox(width: 8),
                      // Date
                      Text(
                        date,
                        style: const TextStyle(
                          color: AppColors.gray650,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Review Message
        Text(
          message,
          style: const TextStyle(
            color: AppColors.textBlue,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
