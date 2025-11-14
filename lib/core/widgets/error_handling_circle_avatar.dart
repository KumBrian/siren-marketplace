import 'package:flutter/material.dart';

// NOTE: This assumes you have a model named 'Fisher' available.
// class Fisher { final String avatarUrl; Fisher(this.avatarUrl); }

const String _localErrorAsset = 'assets/images/user-profile.png';

class ErrorHandlingCircleAvatar extends StatelessWidget {
  const ErrorHandlingCircleAvatar({
    super.key,
    required this.avatarUrl,
    this.radius = 30,
  });

  final String avatarUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final isNetworkImage = avatarUrl.contains("http");
    final size = radius * 2;

    if (!isNetworkImage) {
      // Case 1: Local Asset or placeholder (always works if asset is present)
      return CircleAvatar(
        radius: radius,
        backgroundImage: AssetImage(_localErrorAsset),
      );
    }

    // Case 2: Network Image - Use Image.network with errorBuilder
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: Image.network(
          avatarUrl,
          fit: BoxFit.cover,
          // 1. Fallback to the local asset image when the network image fails
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(_localErrorAsset, fit: BoxFit.cover);
          },
          // 2. Optional: Add a simple loading indicator while fetching
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: SizedBox(
                width: radius,
                height: radius,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
        ),
      ),
    );
  }
}
