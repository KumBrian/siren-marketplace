import 'package:flutter/material.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/models/catch.dart';

class ForSaleCard extends StatelessWidget {
  const ForSaleCard({
    super.key,
    required this.onPressed,
    required this.catchData,
    required this.hasPendingOffers,
  });

  final VoidCallback onPressed;
  final Catch catchData;
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
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              // round corners
              child: catchData.images[0].contains("http")
                  ? Image.network(
                      catchData.images[0],
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
                      catchData.images[0],
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
                  spacing: 24,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        Expanded(
                          child: SizedBox(
                            width: 150,
                            child: Text(
                              catchData.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
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
                              size: 16,
                              color: catchData.daysLeftLabel == "1 day left"
                                  ? AppColors.fail500
                                  : AppColors.textBlue,
                            ),
                            Text(
                              catchData.daysLeftLabel,
                              style: TextStyle(fontSize: 12),
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
                            catchData.species.id == "prawns"
                                ? RichText(
                                    text: TextSpan(
                                      text: "Size: ",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.gray650,
                                      ),

                                      children: [
                                        TextSpan(
                                          text: catchData.size,
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
                            catchData.species.id != "prawns"
                                ? RichText(
                                    text: TextSpan(
                                      text: "Size: ",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.gray650,
                                      ),

                                      children: [
                                        TextSpan(
                                          text: "${catchData.size} cm",
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
                                        "${catchData.initialWeight.toInt()} Kg",
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
