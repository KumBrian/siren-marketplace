import 'package:flutter/material.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/models/offer.dart';

class SoldCard extends StatelessWidget {
  const SoldCard({
    super.key,
    required this.onPressed,
    required this.offer,
    required this.catchImageUrl, // 🆕 The primary image URL, derived from the Catch
    required this.catchTitle, // 🆕 The catch name/title, derived from the Catch
  });

  final Offer offer;
  final String catchImageUrl; // New required field
  final String catchTitle; // New required field
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    // Helper to extract the first image or use a placeholder/default
    final imageUrl = catchImageUrl.isNotEmpty
        ? catchImageUrl
        : 'assets/images/placeholder.png'; // Use a placeholder if image is missing

    return Material(
      color: AppColors.white100,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        splashColor: AppColors.blue700.withValues(alpha: 0.1),
        // Used withOpacity for cleaner syntax
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: imageUrl.contains("http")
                  ? Image.network(
                      // Assuming Image.network is correct for the URL
                      imageUrl,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      // Assuming Image.network is correct for the URL
                      imageUrl,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Removed the unused 'spacing' property here
                    Text(
                      catchTitle, // 🆕 Using the passed-in catchTitle
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: AppColors.textBlue,
                      ),
                    ),
                    const SizedBox(height: 16), // Added spacing explicitly
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Removed the unused 'spacing' property here
                            RichText(
                              text: TextSpan(
                                text: "Weight: ",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.gray650,
                                ),
                                children: [
                                  TextSpan(
                                    text:
                                        "${offer.weight.toStringAsFixed(1)} Kg",
                                    // Use toStringAsFixed
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Added spacing
                            RichText(
                              text: TextSpan(
                                text: "Selling Price: ",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.gray650,
                                ),
                                children: [
                                  TextSpan(
                                    text:
                                        "${offer.price.toStringAsFixed(0)} CFA",
                                    // Use toStringAsFixed
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // Assuming this notification icon indicates a new/unhandled status
                        const Icon(
                          Icons.notifications,
                          color: AppColors.fail500,
                          size: 16,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8), // Final padding
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
