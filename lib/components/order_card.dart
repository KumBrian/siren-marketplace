import 'package:flutter/material.dart';
import 'package:siren_marketplace/constants/constants.dart';
import 'package:siren_marketplace/constants/types.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.onPressed, required this.order});

  final VoidCallback onPressed;
  final Order order;

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
              child: Image.network(
                order.product.images.first,
                width: 140,
                height: 140,
                fit: BoxFit.cover,
              ),
            ),
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
                  spacing: 16,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 130,
                          child: Text(
                            order.product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,

                            style: TextStyle(
                              fontSize: 16,

                              fontWeight: FontWeight.bold,
                              color: AppColors.textBlue,
                            ),
                          ),
                        ),
                        Row(
                          spacing: 4,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white),
                                color: AppColors.getStatusColor(
                                  order.offer.status,
                                ),
                              ),
                            ),
                            // Icon(Icons.person, color: AppColors.white100, size: 60),
                            Text(
                              order.offer.status.name.capitalize(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: AppColors.gray300,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 8,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: "Weight: ",
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.gray650,
                            ),

                            children: [
                              TextSpan(
                                text: "${order.offer.weight.toInt()} Kg",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 200,

                          child: RichText(
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            text: TextSpan(
                              text: "Market: ",
                              style: TextStyle(
                                fontSize: 12,
                                overflow: TextOverflow.ellipsis,
                                color: AppColors.gray650,
                              ),

                              children: [
                                TextSpan(
                                  text: order.product.market,
                                  style: TextStyle(
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
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
                              "${order.offer.price.toInt()} CFA",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: AppColors.textBlue,
                              ),
                            ),
                          ),
                        ),
                        Spacer(),

                        Icon(
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
