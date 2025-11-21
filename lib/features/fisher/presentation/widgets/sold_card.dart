import 'package:flutter/material.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/new_core/domain/entities/order.dart';
import 'package:siren_marketplace/new_core/domain/enums/order_status.dart';

class SoldCard extends StatelessWidget {
  const SoldCard({
    super.key,
    required this.onPressed,
    required this.order,
    required this.catchImageUrl,
    required this.catchTitle,
  });

  final Order order;
  final String catchImageUrl;
  final String catchTitle;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    // Helper to extract the first image or use a placeholder/default
    final imageUrl = catchImageUrl.isNotEmpty
        ? catchImageUrl
        : 'assets/images/placeholder.png';

    return Material(
      color: AppColors.white100,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        splashColor: AppColors.blue700.withValues(alpha: 0.1),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: imageUrl.contains("http")
                  ? Image.network(
                      imageUrl,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        "assets/images/shrimp.jpg",
                        height: 120,
                        width: 120,
                      ),
                    )
                  : Image.asset(
                      imageUrl,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        "assets/images/shrimp.jpg",
                        height: 120,
                        width: 120,
                      ),
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      catchTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: AppColors.textBlue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
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
                                    text: order.terms.weight.toString(),
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
                            RichText(
                              text: TextSpan(
                                text: "Selling Price: ",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.gray650,
                                ),
                                children: [
                                  TextSpan(
                                    text: "${order.terms.totalPrice.amount} CFA",
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
                        if (order.status != OrderStatus.completed) ...[
                          const Icon(
                            Icons.notifications,
                            color: AppColors.fail500,
                            size: 16,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
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
