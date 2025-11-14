import 'package:flutter/material.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/utils/custom_icons.dart';
import 'package:siren_marketplace/core/widgets/error_handling_circle_avatar.dart';

class ReviewCard extends StatelessWidget {
  final String name;
  final String date;
  final int rating;
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
                      ...List.generate(
                        5,
                        (index) => Icon(
                          CustomIcons.star,
                          size: 14,
                          color: index < rating
                              ? AppColors.warning500
                              : AppColors.gray200,
                        ),
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
