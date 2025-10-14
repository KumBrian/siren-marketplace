import 'package:flutter/material.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/models/order.dart';
import 'package:siren_marketplace/core/types/extensions.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.onPressed, required this.order});

  final VoidCallback onPressed;
  final Order order; // Assuming Order contains both Catch and Offer objects

  @override
  Widget build(BuildContext context) {
    // 🆕 Use the nested Catch object (assuming Order.catchModel replaces Order.product)
    final catchModel = order.catchModel;
    final offer = order.offer;

    // Determine image URL
    final imageUrl = catchModel.images.isNotEmpty
        ? catchModel.images.first
        : 'https://via.placeholder.com/140'; // Fallback

    return Material(
      color: AppColors.white100,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        splashColor: AppColors.blue700.withValues(alpha: 0.1),
        // Using .withOpacity
        child: Row(
          children: [
            // --- Image ---
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: imageUrl.contains("http")
                  ? Image.network(
                      imageUrl, // 🆕 Use image from catchModel
                      width: 140,
                      height: 140,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      imageUrl, // 🆕 Use image from catchModel
                      width: 140,
                      height: 140,
                      fit: BoxFit.cover,
                    ),
            ),
            // --- Content ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 8.0,
                  right: 16,
                  top: 8,
                  bottom: 8,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Removed non-standard 'spacing: 16'
                    // Title and Status Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 130,
                          child: Text(
                            catchModel.name, // 🆕 Use name from catchModel
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textBlue,
                            ),
                          ),
                        ),
                        // Status Badge
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              margin: const EdgeInsets.only(right: 4),
                              // Replaced spacing: 4
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                // Assuming AppColors.getStatusColor is defined
                                color: AppColors.getStatusColor(offer.status),
                                border: Border.all(color: Colors.white),
                              ),
                            ),
                            Text(
                              offer.status.name.capitalize(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: AppColors.gray300,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16), // Replaced Column spacing
                    // Weight and Market Info
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Removed non-standard 'spacing: 8'
                        RichText(
                          text: TextSpan(
                            text: "Weight: ",
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.gray650,
                            ),
                            children: [
                              TextSpan(
                                text: "${offer.weight.toStringAsFixed(1)} Kg",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4), // Explicit spacing

                        SizedBox(
                          width: 200,
                          child: RichText(
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            text: TextSpan(
                              text: "Market: ",
                              style: const TextStyle(
                                fontSize: 12,
                                overflow: TextOverflow.ellipsis,
                                color: AppColors.gray650,
                              ),
                              children: [
                                TextSpan(
                                  text: catchModel.market,
                                  // 🆕 Use market from catchModel
                                  style: const TextStyle(
                                    fontSize: 12,
                                    overflow: TextOverflow.ellipsis,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textBlue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16), // Final spacing
                    // Price and Notification Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.gray100,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.gray500),
                          ),
                          child: Center(
                            child: Text(
                              "${offer.price.toStringAsFixed(0)} CFA",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: AppColors.textBlue,
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.notifications,
                          color: AppColors.fail500,
                          size: 16,
                        ),
                      ],
                    ),
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
