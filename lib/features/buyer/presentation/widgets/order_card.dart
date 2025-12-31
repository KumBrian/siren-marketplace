import 'dart:io';

import 'package:flutter/material.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/domain/entities/catch.dart';
import 'package:siren_marketplace/core/domain/entities/product.dart';
import 'package:siren_marketplace/core/domain/enums/offer_status.dart';
import 'package:siren_marketplace/core/types/converters.dart';
import 'package:siren_marketplace/core/types/extensions.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.onPressed,
    this.catchItem,
    this.product,
    required this.status,
    required this.weight,
    required this.price,
    this.hasUpdate = false,
  });

  final VoidCallback onPressed;
  final Catch? catchItem;
  final Product? product;
  final OfferStatus status;
  final double weight;
  final int price;
  final bool hasUpdate;

  @override
  Widget build(BuildContext context) {
    final images = product?.images ?? catchItem?.images ?? [];
    final name = product?.name ?? catchItem?.name ?? '';
    final market = product?.marketName ?? catchItem?.market ?? '';

    final imageUrl = images.isNotEmpty
        ? images.first
        : 'https://via.placeholder.com/140';

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
                  : imageUrl.contains("assets")
                  ? Image.asset(
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
                  : Image.file(
                      File(imageUrl),
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        "assets/images/shrimp.jpg",
                        height: 120,
                        width: 120,
                        fit: BoxFit.cover,
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
                            name,
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
                        // Status Badge
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 4,
                          children: [
                            Text(
                              status.name.capitalize(),
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
                                color: AppColors.getStatusColor(status),
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
                                    text: "$weight kg",
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textBlue,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(
                              width: 160,
                              child: RichText(
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                text: TextSpan(
                                  text: "Market: ",
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textGray,
                                    fontWeight: FontWeight.w600,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: market,
                                      style: const TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                        fontSize: 10,
                                        color: AppColors.textBlue,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
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
                                    text: formatPrice(price),
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
                        if (hasUpdate) ...[
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
