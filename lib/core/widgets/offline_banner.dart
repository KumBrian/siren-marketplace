import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/services/connectivity_service.dart';

class OfflineIndicator extends ConsumerStatefulWidget {
  const OfflineIndicator({super.key});

  @override
  ConsumerState<OfflineIndicator> createState() => _OfflineIndicatorState();
}

class _OfflineIndicatorState extends ConsumerState<OfflineIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true); // Blink effect
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = ref.watch(isOnlineProvider);

    if (isOnline) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: 0.5 + (_controller.value * 0.5), // Blink between 0.5 and 1.0
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.fail500, // Red background
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
              ],
            ),
            child: const Icon(Icons.wifi_off, color: Colors.white, size: 20),
          ),
        );
      },
    );
  }
}
