import 'package:siren_marketplace/features/shared/presentation/widgets/catch_image.dart';

import 'package:flutter/material.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/domain/entities/catch.dart';
import 'package:siren_marketplace/core/types/extensions.dart';
import 'package:siren_marketplace/core/domain/enums/catch_status.dart';

class CatchCard extends StatelessWidget {
  final Catch catchItem;
  final VoidCallback onTap;

  const CatchCard({super.key, required this.catchItem, required this.onTap});

  @override
  Widget build(BuildContext context) {
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
              SizedBox(
                width: 120,
                height: 120,
                child: CatchImage(
                  imageUrl: catchItem.images.isNotEmpty
                      ? catchItem.images.first
                      : null,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
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
                                "Catch #${catchItem.id}",
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
                                color: catchItem.status == CatchStatus.draft
                                    ? AppColors.gray500
                                    : (catchItem.status == CatchStatus.soldOut
                                          ? AppColors.blue500
                                          : AppColors.blue700),
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Text(
                                catchItem.status == CatchStatus.draft
                                    ? "Draft"
                                    : (catchItem.status == CatchStatus.soldOut
                                          ? "Sold Out"
                                          : "Shrimp"),
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
