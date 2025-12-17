import 'package:siren_marketplace/features/shared/presentation/widgets/catch_image.dart';

import 'package:flutter/material.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/domain/entities/product.dart';

class ForSaleCard extends StatelessWidget {
  const ForSaleCard({
    super.key,
    required this.onPressed,
    required this.product,
    required this.hasPendingOffers,
  });

  final VoidCallback onPressed;
  final Product product;
  final bool hasPendingOffers;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white100,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        splashColor: AppColors.blue700.withValues(alpha: 0.1),
        child: Row(
          children: [
            // Assuming Product doesn't have images list yet in entity definition based on previous step
            // But if it mimics Catch, it should? Wait, user JSON sample didn't have images array explicitly shown as "images": [...].
            // It had "specie" ... wait.
            // Catch entity has images. Product entity I defined didn't have images field because JSON schema provided by user didn't show it.
            // JSON had: id, name, market, status, rejectReason, price_per_kg, final_price, published_weight_in_grams, expire_at, location_name, latitude, longitude, size, date_posted, isSold, soldAt, initial_weight, available_weight, created_at, updated_at, deleted_at, uid, gear..., specie.
            // NO IMAGES array in user provided JSON.
            // So we might need to use species image or placeholder.
            // For now, let's use a placeholder or species image if available via specie relation.
            CatchImage(
              imageUrl: '', // No images in product response yet?
              // The Product entity has "species" field. Species has "image".
              // Let's try to use species image.
              // product.species.image
              width: 120,
              height: 120,
              fit: BoxFit.cover,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  spacing: 24,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        Expanded(
                          child: SizedBox(
                            width: 140,
                            child: Text(
                              product.name,
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
                        ),

                        Row(
                          spacing: 4,
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 12,
                              color: product.daysLeftLabel == "1 day left"
                                  ? AppColors.fail500
                                  : AppColors.textBlue,
                            ),
                            Text(
                              product.daysLeftLabel,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 8,
                          children: [
                            product.species.id == "prawns"
                                ? RichText(
                                    text: TextSpan(
                                      text: "Size: ",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.gray650,
                                      ),

                                      children: [
                                        TextSpan(
                                          text: product.size,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textBlue,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(),
                            product.species.id != "prawns"
                                ? RichText(
                                    text: TextSpan(
                                      text: "Size: ",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.gray650,
                                      ),

                                      children: [
                                        TextSpan(
                                          text: product.size,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textBlue,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(),
                            RichText(
                              text: TextSpan(
                                text: "Weight: ",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.gray650,
                                ),

                                children: [
                                  TextSpan(
                                    text:
                                        "${product.availableWeight.kilograms} kg",
                                    style: TextStyle(
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
                        if (hasPendingOffers) ...[
                          Icon(
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
