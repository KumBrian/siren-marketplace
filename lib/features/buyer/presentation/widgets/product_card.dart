import 'package:flutter/material.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/models/catch.dart';
import 'package:siren_marketplace/core/types/converters.dart';
import 'package:siren_marketplace/core/widgets/section_header.dart';

// IMPORTANT: Ensure you have this local asset file in your project:
// For example: 'assets/images/fish_placeholder.png'
const String _localErrorAsset = 'assets/images/shrimp.jpg';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.onTap, required this.catchModel});

  final Catch catchModel;
  final VoidCallback onTap;

  // Helper method to display the local placeholder image
  Widget _buildLocalPlaceholder(double height) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Image.asset(
        _localErrorAsset,
        fit: BoxFit.cover,
        // Fallback color for the container if the asset itself fails to load (very rare)
        color: AppColors.gray200,
        colorBlendMode: BlendMode.dstATop,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final priceDisplay = catchModel.pricePerKg.toInt();
    final imageUrl = catchModel.images.isNotEmpty
        ? catchModel.images.first
        // Use the local placeholder path if no image URL is provided initially
        : _localErrorAsset;

    final isNetworkImage = imageUrl.contains("http");
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
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: isNetworkImage
                  ? SizedBox(
                      height: cardImageHeight,
                      width: double.infinity,
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        // 1. Display the local asset if the network image fails
                        errorBuilder: (context, error, stackTrace) {
                          // Optionally print(error) for debugging purposes
                          return _buildLocalPlaceholder(cardImageHeight);
                        },
                        // 2. Display a loading indicator while fetching the network image
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }
                          return Container(
                            height: cardImageHeight,
                            color: AppColors.gray100,
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.blue700,
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  // 3. If the URL was a local asset path to begin with, use Image.asset directly
                  : _buildLocalPlaceholder(cardImageHeight),
            ),

            // --- End Image Display Block ---
            const SizedBox(height: 8),

            SectionHeader(catchModel.name, maxLines: 1),

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
