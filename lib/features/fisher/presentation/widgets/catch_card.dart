import 'dart:io';

import 'package:flutter/material.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/domain/entities/catch.dart';
import 'package:siren_marketplace/core/types/extensions.dart';

class CatchCard extends StatelessWidget {
  final Catch catchItem;
  final VoidCallback onTap;

  const CatchCard({super.key, required this.catchItem, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Determine image provider
    ImageProvider imageProvider;
    if (catchItem.images.isNotEmpty) {
      final imagePath = catchItem.images.first;
      if (imagePath.startsWith('http')) {
        imageProvider = NetworkImage(imagePath);
      } else if (imagePath.startsWith('assets/')) {
        imageProvider = AssetImage(imagePath);
      } else {
        imageProvider = FileImage(File(imagePath));
      }
    } else {
      // Fallback
      imageProvider = const AssetImage('assets/images/shrimp.jpg');
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Species & Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 140,
                              child: Text(
                                catchItem.species.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,

                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textBlue,
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.blue700,
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Text(
                                "Shrimp",
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.white100,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Meta: Location & Obs ID
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: AppColors.textBlue,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            catchItem.locationName.isNotEmpty
                                ? catchItem.locationName
                                : 'Unknown Location',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textGray,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppColors.textBlue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          catchItem.datePosted
                              .toIso8601String()
                              .toFormattedDate(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textGray,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
