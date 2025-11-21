import 'package:flutter/material.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/types/converters.dart';
import 'package:siren_marketplace/core/types/extensions.dart';
import 'package:siren_marketplace/new_core/domain/entities/offer.dart';
import 'package:siren_marketplace/new_core/domain/enums/user_role.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.onPressed, required this.offer});

  final VoidCallback onPressed;
  final Offer offer;

  @override
  Widget build(BuildContext context) {
    // Use placeholder image since we don't have catch data loaded
    const imageUrl = 'assets/images/shrimp.jpg';

    return Material(
      color: AppColors.white100,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        splashColor: AppColors.blue700.withValues(alpha: 0.1),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
              child: Image.asset(
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
            // --- Content ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: [
                    // Title and Status Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 140,
                          child: Text(
                            "Offer #${offer.id.substring(0, 8)}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textBlue,
                            ),
                          ),
                        ),
                        // Status Badge
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 4,
                          children: [
                            Text(
                              offer.status.displayName.capitalize(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textGray,
                              ),
                            ),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.getStatusColor(offer.status),
                                border: Border.all(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Weight and Market Info
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 4,
                          children: [
                            RichText(
                              text: TextSpan(
                                text: "Weight: ",
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textGray,
                                  fontWeight: FontWeight.w600,
                                ),
                                children: [
                                  TextSpan(
                                    text: formatWeight(
                                      offer.currentTerms.weight.grams,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textBlue,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                text: "Price: ",
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textGray,
                                  fontWeight: FontWeight.w600,
                                ),
                                children: [
                                  TextSpan(
                                    text: formatPrice(
                                      offer.currentTerms.totalPrice.amount,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textBlue,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (offer.waitingFor == UserRole.buyer) ...[
                          const Icon(
                            Icons.notifications,
                            color: AppColors.fail500,
                            size: 16,
                          ),
                        ],
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
