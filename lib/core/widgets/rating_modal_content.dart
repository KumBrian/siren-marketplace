import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';

import 'animated_rating_stars.dart';
import 'custom_button.dart';

class RatingModalContent extends StatefulWidget {
  final String orderId;
  final String raterId;
  final String ratedUserId;
  final String ratedUserName;

  // 🌟 NEW: Submission function abstracting the Bloc/Cubit call 🌟
  final Future<void> Function({
    required String orderId,
    required String raterId,
    required String ratedUserId,
    required double ratingValue,
    String? message,
  })
  onSubmitRating;

  const RatingModalContent({
    super.key,
    required this.orderId,
    required this.raterId,
    required this.ratedUserId,
    required this.ratedUserName,
    required this.onSubmitRating, // Must be provided by the parent
  });

  @override
  State<RatingModalContent> createState() => _RatingModalContentState();
}

class _RatingModalContentState extends State<RatingModalContent> {
  num _currentRating = 0;
  final TextEditingController _messageController = TextEditingController();
  bool _isSubmitting = false;

  static const Color _activeColor = AppColors.shellOrange;
  static const Color _inactiveColor = AppColors.gray100;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _rate(num rating) {
    setState(() {
      _currentRating = rating;
    });
  }

  // 🌟 UPDATED: Calls the provided onSubmitRating function 🌟
  Future<void> _submitRating(BuildContext context) async {
    if (_currentRating == 0 || _isSubmitting) {
      if (_currentRating == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a star rating.')),
        );
      }
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await widget.onSubmitRating(
        orderId: widget.orderId,
        raterId: widget.raterId,
        ratedUserId: widget.ratedUserId,
        ratingValue: _currentRating.toDouble(),
        message: _messageController.text.trim(),
      );

      // Close modal after successful submission
      if (context.mounted) {
        context.pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: ListView(
            controller: scrollController,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: context.pop,
                    icon: const Icon(Icons.close),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Give a Review", // Contextual title
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                      color: AppColors.textBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // RATING WIDGET
              Center(
                child: AnimatedRatingStars(
                  initialRating: 0,
                  minRating: 1,
                  maxRating: 5,
                  filledColor: _activeColor,
                  emptyColor: _inactiveColor,
                  onChanged: (num rating) {
                    _rate(rating);
                  },
                  interactiveTooltips: true,
                  customFilledIcon: Icons.star_rounded,
                  customHalfFilledIcon: Icons.star_half_rounded,
                  customEmptyIcon: Icons.star_border_rounded,
                  starSize: 32.0,
                  animationDuration: Duration(milliseconds: 300),
                  animationCurve: Curves.easeInOut,
                  readOnly: false,
                ),
              ),
              const SizedBox(height: 16),
              // REVIEW TEXT FIELD
              TextField(
                controller: _messageController,
                maxLines: 5,
                onTapOutside: (e) {
                  FocusScope.of(context).unfocus();
                },
                decoration: InputDecoration(
                  hintText:
                      "Write a detailed review for ${widget.ratedUserName}",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // SUBMIT BUTTON
              CustomButton(
                title: _isSubmitting
                    ? "Submitting..."
                    : "Submit Review (${_currentRating.toStringAsFixed(1)} Stars)",
                disabled: _currentRating == 0 || _isSubmitting,
                onPressed: () => _submitRating(context),
              ),
            ],
          ),
        );
      },
    );
  }
}
