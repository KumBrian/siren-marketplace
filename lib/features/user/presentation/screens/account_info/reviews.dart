import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/types/extensions.dart'; // Assuming you have .toFormattedDate()
import 'package:siren_marketplace/features/user/logic/reviews_cubit/reviews_cubit.dart';
import 'package:siren_marketplace/features/user/presentation/widgets/rating_card.dart';
import 'package:siren_marketplace/features/user/presentation/widgets/review_card.dart';

// Removed hardcoded ReviewModel and review_data

class ReviewsScreen extends StatefulWidget {
  // This screen now requires the ID of the user whose reviews are being viewed
  final String userId;
  final String userName; // For title display

  const ReviewsScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  @override
  void initState() {
    super.initState();
    // Start loading reviews when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load data based on the provided userId
      context.read<ReviewsCubit>().loadReviews(userId: widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reviews for ${widget.userName}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        scrolledUnderElevation: 0,
      ),
      body: BlocBuilder<ReviewsCubit, ReviewsState>(
        builder: (context, state) {
          if (state is ReviewsLoading || state is ReviewsInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ReviewsError) {
            return Center(
              child: Text('Failed to load reviews: ${state.message}'),
            );
          }

          if (state is ReviewsLoaded) {
            final data = state;

            if (data.totalReviews == 0) {
              return Center(
                child: Text('No reviews yet for ${widget.userName}.'),
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pass dynamic data to the RatingCard
                  RatingCard(
                    averageRating: data.averageRating,
                    totalReviews: data.totalReviews,
                    ratingDistribution: data.ratingDistribution,
                  ),
                  const SizedBox(height: 24),
                  // Display the list of individual reviews
                  Expanded(
                    child: ListView.separated(
                      itemCount: data.reviews.length,
                      scrollDirection: Axis.vertical,
                      separatorBuilder: (context, index) => const SizedBox(
                        height: 4,
                        child: Divider(color: AppColors.gray200),
                      ),
                      itemBuilder: (context, index) {
                        final review = data.reviews[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ReviewCard(
                            // Round the rating value for the star display
                            rating: review.ratingValue,
                            name: review.raterName,
                            date: review.dateCreated.toShortFormattedDate(),
                            image: review.raterAvatarUrl,
                            message: review.message ?? 'No comment provided.',
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
