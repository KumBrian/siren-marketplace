import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/utils/custom_icons.dart';

class ReviewCard extends StatelessWidget {
  const ReviewCard({
    super.key,
    required this.rating,
    required this.name,
    required this.date,
    required this.image,
    required this.message,
  });

  final int rating;
  final String name;
  final String date;
  final String image;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Row(
            spacing: 8,
            children: [
              CircleAvatar(radius: 30, backgroundImage: NetworkImage(image)),
              Column(
                spacing: 8,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textBlue,
                    ),
                  ),
                  Row(
                    spacing: 8,
                    children: [
                      Row(
                        spacing: 4,
                        children: List.generate(
                          5,
                          (index) => Icon(
                            size: 16,
                            CustomIcons.star,
                            color: index < rating
                                ? AppColors.warning500
                                : AppColors.gray200,
                          ),
                        ),
                      ),
                      Text(DateFormat.yMMMd().format(DateTime.parse(date))),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Text(
            message,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.textBlue,
            ),
          ),
        ],
      ),
    );
  }
}
