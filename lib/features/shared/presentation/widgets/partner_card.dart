import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/domain/entities/user.dart';
import 'package:siren_marketplace/core/domain/enums/user_role.dart';
import 'package:siren_marketplace/core/widgets/error_handling_circle_avatar.dart';
import 'package:siren_marketplace/core/widgets/section_header.dart';

class PartnerCard extends StatelessWidget {
  final User partner;
  final UserRole myRole;

  const PartnerCard({super.key, required this.partner, required this.myRole});

  @override
  Widget build(BuildContext context) {
    final roleTitle = myRole == UserRole.buyer ? "Seller" : "Buyer";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(roleTitle),
        const SizedBox(height: 8),
        Material(
          borderRadius: BorderRadius.circular(16),
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              final prefix = myRole == UserRole.buyer ? 'buyer' : 'fisher';
              context.push("/$prefix/reviews/${partner.id}");
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  ErrorHandlingCircleAvatar(avatarUrl: partner.avatarUrl ?? ""),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          partner.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: AppColors.textBlue,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: AppColors.shellOrange,
                            ),
                            Text(
                              " ${partner.rating.value.toStringAsFixed(1)} ",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "(${partner.reviewCount} Reviews)",
                              style: const TextStyle(
                                color: AppColors.textGray,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.textGray),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
