import 'package:flutter/material.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/domain/entities/product.dart';
import 'package:siren_marketplace/core/types/converters.dart';
import 'package:siren_marketplace/core/widgets/section_header.dart';
import 'package:siren_marketplace/features/shared/presentation/widgets/catch_image.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.onTap, required this.product});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final priceDisplay = product.pricePerKg.amountPerKg.toInt();
    const double cardImageHeight = 170;

    return Material(
      borderRadius: BorderRadius.circular(12),
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: AppColors.blue700.withOpacity(0.1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Use min size for column
          children: [
            // --- Image Display Block with Error Handling ---
            CatchImage(
              imageUrl: product.images.isNotEmpty ? product.images.first : null,
              width: double.infinity,
              height: cardImageHeight,
              borderRadius: BorderRadius.circular(16),
            ),
            // --- End Image Display Block ---
            const SizedBox(height: 8),

            SectionHeader(product.name, maxLines: 1),

            const SizedBox(height: 4),

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gray100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.gray200),
                  ),
                  child: Center(
                    child: SectionHeader(
                      // Using the price from the Catch model
                      formatPrice(priceDisplay.toDouble()),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const SectionHeader("/kg"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
