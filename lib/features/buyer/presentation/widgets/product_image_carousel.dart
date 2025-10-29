import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';

class ProductImagesCarousel extends StatefulWidget {
  final List<String> images;

  const ProductImagesCarousel({required this.images, super.key});

  @override
  State<ProductImagesCarousel> createState() => _ProductImagesCarouselState();
}

class _ProductImagesCarouselState extends State<ProductImagesCarousel> {
  late final CarouselController _controller;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = CarouselController();
    _controller.addListener(_onScrollChanged);
  }

  void _onScrollChanged() {
    // Protect from layout not being ready yet
    if (!_controller.hasClients || !_controller.position.hasPixels) return;

    // Estimate which item is currently visible
    final position = _controller.position;
    final viewport = position.viewportDimension;
    if (viewport == 0) return;

    // Approximate index from scroll offset
    final index = (position.pixels / viewport).round();

    if (index != _currentIndex && mounted) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onScrollChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images;

    final int imageCount = images.length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 250,
          child: CarouselView.weighted(
            controller: _controller,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            flexWeights: imageCount > 1 ? const <int>[5, 1] : <int>[6],
            enableSplash: true,
            itemSnapping: true,
            children: images.map((img) {
              return img.contains("http")
                  ? Image.network(img, fit: BoxFit.cover)
                  : Image.asset(img, fit: BoxFit.cover);
            }).toList(),
            onTap: (index) {
              final rotatedImages = [
                ...widget.images.sublist(index),
                ...widget.images.sublist(0, index),
              ];
              final providers = rotatedImages.map<ImageProvider>((img) {
                return img.contains("http")
                    ? NetworkImage(img)
                    : AssetImage(img);
              }).toList();
              showImageViewerPager(
                context,
                MultiImageProvider(providers),
                swipeDismissible: true,
                immersive: true,
                useSafeArea: true,
                doubleTapZoomable: true,
                backgroundColor: Colors.black.withValues(alpha: .4),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        if (images.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(images.length, (index) {
              final isActive = index == _currentIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 20 : 10,
                height: 10,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.textBlue
                      : AppColors.textBlue.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(99),
                ),
              );
            }),
          ),
      ],
    );
  }
}
