import 'package:flutter/material.dart';
import 'package:siren_marketplace/components/section_header.dart';
import 'package:siren_marketplace/constants/constants.dart';
import 'package:siren_marketplace/constants/types.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.onTap, required this.product});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: AppColors.blue700.withValues(alpha: .1),
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Container(
                height: 170,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(product.images.first),
                  ),
                ),
              ),
              SectionHeader(product.name, maxLines: 1),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.gray100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.gray500),
                    ),
                    child: Center(
                      child: Text(
                        "${product.pricePerKg.toInt()} CFA",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: AppColors.textBlue,
                        ),
                      ),
                    ),
                  ),
                  Text("/Kg"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
