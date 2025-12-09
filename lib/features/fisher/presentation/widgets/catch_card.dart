import 'dart:io';

import 'package:flutter/material.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/domain/entities/catch.dart';
import 'package:intl/intl.dart';

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
      imageProvider = const AssetImage('assets/images/placeholder.png');
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white100,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
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
                              Text(
                                catchItem.species.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textBlue,
                                ),
                              ),
                              if (catchItem.species.scientificName.isNotEmpty)
                                Text(
                                  catchItem.species.scientificName,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textGray,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                            ],
                          ),
                          _buildStatusChip(catchItem.status.name),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Meta: Location & Obs ID
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: AppColors.textGray,
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
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${catchItem.observationId} • ${DateFormat.yMMMd().format(catchItem.datePosted)}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textGray,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color = AppColors.gray200;
    Color textColor = AppColors.textBlue;

    if (status.toLowerCase() == 'available') {
      color = AppColors.success100;
      textColor = AppColors.success700;
    } else if (status.toLowerCase() == 'soldout' ||
        status.toLowerCase() == 'sold') {
      color = AppColors.blue100;
      textColor = AppColors.blue700;
    } else if (status.toLowerCase() == 'expired') {
      color = AppColors.fail100;
      textColor = AppColors.fail700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}
