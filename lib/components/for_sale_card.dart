import 'package:flutter/material.dart';
import 'package:siren_marketplace/constants/constants.dart';
import 'package:siren_marketplace/constants/types.dart';

class ForSaleCard extends StatelessWidget {
  const ForSaleCard({
    super.key,
    required this.onPressed,
    required this.catchData,
  });

  final VoidCallback onPressed;
  final Catch catchData;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white100,

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
              child: Image.asset(
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
                          child: Text(
                            catchData.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: AppColors.textBlue,
                            ),
                            softWrap: true,
                            overflow: TextOverflow.visible,
                          ),
                        ),

                        Row(
                          spacing: 4,
                          children: [
                            Icon(Icons.access_time, size: 16),
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
                            RichText(
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
                            ),
                            RichText(
                              text: TextSpan(
                                text: "Weight: ",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.gray650,
                                ),

                                children: [
                                  TextSpan(
                                    text: "${catchData.initialWeight} Kg",
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
                        Icon(
                          Icons.notifications_active,
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
