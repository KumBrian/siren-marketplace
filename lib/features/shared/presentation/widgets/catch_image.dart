import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';

class CatchImage extends StatefulWidget {
  final String? imageUrl;
  final double width;
  final double height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const CatchImage({
    super.key,
    required this.imageUrl,
    this.width = 120,
    this.height = 120,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  State<CatchImage> createState() => _CatchImageState();
}

class _CatchImageState extends State<CatchImage> {
  // Flag to indicate if we should give up loading and show fallback
  bool _shouldShowFallback = false;
  Timer? _fallbackTimer;

  @override
  void initState() {
    super.initState();
    _startFallbackTimer();
  }

  @override
  void didUpdateWidget(CatchImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Restart timer if URL changes
    if (widget.imageUrl != oldWidget.imageUrl) {
      _startFallbackTimer();
    }
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    super.dispose();
  }

  void _startFallbackTimer() {
    // Reset state
    _fallbackTimer?.cancel();
    _shouldShowFallback = false;

    // Only start timer if we have a valid network URL that needs fetching
    if (widget.imageUrl != null &&
        widget.imageUrl!.isNotEmpty &&
        widget.imageUrl!.startsWith('http')) {
      _fallbackTimer = Timer(const Duration(seconds: 4), () {
        if (mounted) {
          setState(() {
            _shouldShowFallback = true;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget imageContent;

    if (_shouldShowFallback) {
      imageContent = _buildFallback();
    } else {
      imageContent = _buildImage(context);
    }

    if (widget.borderRadius != null) {
      return ClipRRect(
        borderRadius: widget.borderRadius!,
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: imageContent,
        ),
      );
    }
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: imageContent,
    );
  }

  Widget _buildImage(BuildContext context) {
    if (widget.imageUrl == null || widget.imageUrl!.isEmpty) {
      _fallbackTimer?.cancel(); // Accessing local resource is instant usually
      return _buildFallback();
    }

    final path = widget.imageUrl!;

    if (path.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: path,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        imageBuilder: (context, imageProvider) {
          // If execution reaches here, image is loaded.
          // We can cancel timer safely (side effect during build is fine for timer cancellation)
          _fallbackTimer?.cancel();
          return Image(image: imageProvider, fit: widget.fit);
        },
        placeholder: (context, url) => Container(
          width: widget.width,
          height: widget.height,
          color: AppColors.blue100,
          child: const Center(
            child: CircularProgressIndicator.adaptive(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.blue700),
            ),
          ),
        ),
        errorWidget: (context, url, error) {
          _fallbackTimer?.cancel();
          return _buildFallback();
        },
      );
    } else if (path.startsWith('assets/')) {
      _fallbackTimer?.cancel();
      return Image.asset(
        path,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      );
    } else {
      _fallbackTimer?.cancel();
      // Local file
      return Image.file(
        File(path),
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      );
    }
  }

  Widget _buildFallback() {
    return Image.asset(
      'assets/images/shrimp.jpg',
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
    );
  }
}
