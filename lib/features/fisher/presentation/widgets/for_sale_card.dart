import 'dart:io';

import 'package:flutter/material.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/domain/entities/product.dart';

class ForSaleCard extends StatelessWidget {
  const ForSaleCard({
    super.key,
    required this.onPressed,
    required this.product,
    required this.hasNotifications, // Includes both offer updates AND unread messages
  });

  final VoidCallback onPressed;
  final Product product;
  final bool hasNotifications;

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
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              // Use species image from Product entity
              child: product.species.image.isNotEmpty
                  ? (product.species.image.contains("http")
                        ? Image.network(
                            product.species.image,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset(
                                  "assets/images/shrimp.jpg",
                                  height: 120,
                                  width: 120,
                                  fit: BoxFit.cover,
                                ),
                          )
                        : (product.species.image.startsWith("assets/")
                              ? Image.asset(
                                  product.species.image,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Image.asset(
                                        "assets/images/shrimp.jpg",
                                        height: 120,
                                        width: 120,
                                        fit: BoxFit.cover,
                                      ),
                                )
                              : Image.file(
                                  File(product.species.image),
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Image.asset(
                                        "assets/images/shrimp.jpg",
                                        height: 120,
                                        width: 120,
                                        fit: BoxFit.cover,
                                      ),
                                )))
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
                        if (hasNotifications) ...[
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
