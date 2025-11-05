import 'package:flutter/material.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/types/enum.dart';

class CustomNavBarWithTabs extends StatelessWidget {
  const CustomNavBarWithTabs({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.role,
  });

  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final Role role;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.white100,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(blurRadius: 20, color: Colors.black.withValues(alpha: .1)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            selectedIndex == 0 ? Icons.home : Icons.home_outlined,
            0,
          ),
          _buildNavItem(
            selectedIndex == 1 ? Icons.storefront_rounded : Icons.storefront,
            1,
          ),
          if (role == Role.buyer) ...[
            _buildNavItem(
              selectedIndex == 2
                  ? Icons.shopping_bag
                  : Icons.shopping_bag_outlined,
              2,
            ),
          ],
          if (role == Role.fisher) ...[
            _buildNavItem(
              selectedIndex == 2
                  ? Icons.content_paste_search
                  : Icons.content_paste_search_rounded,
              2,
            ),
          ],

          _buildNavItem(
            selectedIndex == 3
                ? Icons.person_pin_circle_rounded
                : Icons.person_pin_circle_outlined,
            3,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isActive = index == selectedIndex;
    return IconButton(
      onPressed: () => onTabSelected(index),
      icon: Icon(
        icon,
        color: isActive ? AppColors.textBlue : AppColors.gray500,
      ),
    );
  }
}
