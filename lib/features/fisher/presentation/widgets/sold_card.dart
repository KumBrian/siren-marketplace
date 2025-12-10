import 'package:flutter/material.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/domain/entities/offer.dart';
import 'package:siren_marketplace/core/domain/enums/offer_status.dart';
import 'package:siren_marketplace/core/domain/enums/order_status.dart';
import 'package:siren_marketplace/core/types/converters.dart';

class SoldCard extends StatelessWidget {
  const SoldCard({
    super.key,
    required this.onPressed,
    required this.offer,
    required this.catchImageUrl, // 🆕 The primary image URL, derived from the Catch
    required this.catchTitle, // 🆕 The catch name/title, derived from the Catch
    this.orderStatus,
  });

  final Offer offer;
  final String catchImageUrl; // New required field
  final String catchTitle; // New required field
  final OrderStatus? orderStatus;
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
        // Simplified usage of withOpacity
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
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        "assets/images/shrimp.jpg",
                        height: 120,
                        width: 120,
                        fit: BoxFit.cover,
                      ),
                    )
                  : (imageUrl.length < 500)
                  ? Image.asset(
                      // Assuming Image.network is correct for the URL
                      imageUrl,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        "assets/images/shrimp.jpg",
                        height: 120,
                        width: 120,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset(
                      "assets/images/shrimp.jpg",
                      height: 120,
                      width: 120,
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
                    // FIX: Removed fixed width SizedBox to prevent overflow.
                    // The text will now use the space provided by the surrounding Expanded widget.
                    SizedBox(
                      width: 140,
                      child: Text(
                        catchTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.textBlue,
                        ),
                        softWrap: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Column holding the RichText widgets (Price and Weight)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                                        "${offer.currentTerms.weight.kilograms} kg",
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
                                    text: formatPrice(
                                      offer.currentTerms.totalPrice.amount,
                                    ),
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
                        // Status Icon
                        if (orderStatus != null) ...[
                          if (orderStatus == OrderStatus.accepted)
                            const Icon(
                              Icons.notifications,
                              color:
                                  AppColors.fail500, // Kept as requested (Bell)
                              size: 16,
                            )
                          else if (orderStatus == OrderStatus.completed)
                            const Icon(
                              Icons.check_circle_outline,
                              color: AppColors.success500,
                              size: 16,
                            )
                          else if (orderStatus == OrderStatus.cancelled)
                            const Icon(
                              Icons.cancel_outlined,
                              color: AppColors.fail500,
                              size: 16,
                            ),
                        ] else if (offer.status != OfferStatus.completed) ...[
                          // Fallback for legacy usage if any
                          const Icon(
                            Icons.notifications,
                            color: AppColors.fail500,
                            size: 16,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Final padding
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
