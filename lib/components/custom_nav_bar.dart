import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/constants/constants.dart';
import 'package:siren_marketplace/constants/types.dart';

class CustomNavBar extends StatelessWidget {
  const CustomNavBar({super.key, required this.role});

  final Role role;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.white100,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withValues(alpha: .1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(
              child: IconButton(
                onPressed: () {},
                icon: Icon(Icons.home_outlined, color: AppColors.textBlue),
              ),
            ),
            Flexible(
              child: IconButton(
                onPressed: () {
                  if (role == Role.fisher) {
                    context.replace("/fisher");
                  }
                  if (role == Role.buyer) {
                    context.replace("/buyer");
                  }
                },
                icon: Icon(Icons.storefront_rounded, color: AppColors.textBlue),
              ),
            ),
            Flexible(
              child: IconButton(
                onPressed: () {
                  if (role == Role.buyer) {
                    context.replace("/orders");
                  }
                },
                icon: Icon(
                  role == Role.buyer
                      ? Icons.shopping_bag_outlined
                      : Icons.content_paste_search,
                  color: AppColors.textBlue,
                ),
              ),
            ),
            Flexible(
              child: IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.person_pin_circle_outlined,
                  color: AppColors.textBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
