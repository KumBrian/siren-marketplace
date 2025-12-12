import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/features/shared/presentation/widgets/catch_image.dart';

class ProductImagesCarousel extends StatefulWidget {
  const ProductImagesCarousel({
    super.key,
    required this.images,
    this.height = 250,
  });

  final List<String> images;
  final double height;

  @override
  State<ProductImagesCarousel> createState() => _ProductImagesCarouselState();
}

class _ProductImagesCarouselState extends State<ProductImagesCarousel> {
  int _current = 0;
  final CarouselSliderController _controller = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    // Handle empty images list
    if (widget.images.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          'assets/images/shrimp.jpg',
          width: double.infinity,
          height: widget.height,
          fit: BoxFit.cover,
        ),
      );
    }

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            final providers = widget.images.map<ImageProvider>((img) {
              if (img.startsWith("http")) {
                return NetworkImage(img);
              } else if (img.startsWith("assets/")) {
                return AssetImage(img);
              } else {
                return FileImage(File(img));
              }
            }).toList();

            final multiImageProvider = MultiImageProvider(
              providers,
              initialIndex: _current,
            );
            showImageViewerPager(
              context,
              multiImageProvider,
              swipeDismissible: true,
              immersive: true,
              useSafeArea: true,
              doubleTapZoomable: true,
              backgroundColor: Colors.black.withValues(alpha: 0.4),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CarouselSlider(
              items: widget.images.map((item) {
                return Builder(
                  builder: (BuildContext context) {
                    return SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: CatchImage(
                        imageUrl: item,
                        width: MediaQuery.of(context).size.width,
                        height: widget.height,
                        fit: BoxFit.cover,
                        borderRadius: BorderRadius.zero,
                      ),
                    );
                  },
                );
              }).toList(),
              carouselController: _controller,
              options: CarouselOptions(
                height: widget.height,
                enableInfiniteScroll: widget.images.length > 1,
                autoPlay: widget.images.length > 1,
                viewportFraction: 1.0,
                onPageChanged: (index, reason) {
                  setState(() {
                    _current = index;
                  });
                },
              ),
            ),
          ),
        ),
        if (widget.images.length > 1) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.images.asMap().entries.map((entry) {
              return GestureDetector(
                onTap: () => _controller.animateToPage(entry.key),
                child: Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 4.0,
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _current == entry.key
                        ? AppColors.textBlue
                        : AppColors.gray300,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
