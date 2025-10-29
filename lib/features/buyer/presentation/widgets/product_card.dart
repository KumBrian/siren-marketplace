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
      borderRadius: BorderRadius.circular(12),
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: AppColors.blue700.withValues(alpha: .1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
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

            SectionHeader(catchModel.name, maxLines: 1, maxWidth: 170),
            
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
                      "$priceDisplay CFA",
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
