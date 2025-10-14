import 'package:flutter/material.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/models/catch.dart';
import 'package:siren_marketplace/core/widgets/section_header.dart'; // Assumed to contain Catch

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.onTap, required this.catchModel});

  final Catch catchModel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final priceDisplay = catchModel.pricePerKg.toInt();
    // 💡 Provide a better, non-placeholder fallback image or asset
    final imageUrl = catchModel.images.isNotEmpty
        ? catchModel.images.first
        : 'https://via.placeholder.com/170/88AAFF/FFFFFF?text=Fish';

    return Material(
      borderRadius: BorderRadius.circular(16),
      color: AppColors.white100, // Explicit background color helps
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: AppColors.blue700.withValues(alpha: .1),
        // FIX: Removed the redundant inner Container that previously wrapped the Column,
        // simplifying the widget tree and reducing layout complexity.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Image ---
            Container(
              height: 170,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: imageUrl.contains("http")
                      ? NetworkImage(imageUrl)
                      : AssetImage(imageUrl),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // --- Title ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: SectionHeader(catchModel.name, maxLines: 1),
            ),
            const SizedBox(height: 4),

            // --- Price Badge ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gray100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.gray500),
                    ),
                    child: Center(
                      child: Text(
                        // Using the price from the Catch model
                        "$priceDisplay CFA",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: AppColors.textBlue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text("/Kg"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
