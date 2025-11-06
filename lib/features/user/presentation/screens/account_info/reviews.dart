import 'package:flutter/material.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/features/user/presentation/widgets/rating_card.dart';
import 'package:siren_marketplace/features/user/presentation/widgets/review_card.dart';

class ReviewModel {
  final String name;
  final String date;
  final int rating;
  final String image;
  final String message;

  ReviewModel({
    required this.name,
    required this.date,
    required this.rating,
    required this.image,
    required this.message,
  });
}

List<ReviewModel> review_data = [
  ReviewModel(
    name: "Sophia Turner",
    date: "2025-10-12T10:30:00Z",
    rating: 5,
    image: "https://i.pravatar.cc/150?img=1",
    message:
        "The service was beyond expectations. Everything was smooth, and the quality was top-notch. Definitely coming back!",
  ),
  ReviewModel(
    name: "Ethan Ross",
    date: "2025-09-28T14:45:00Z",
    rating: 4,
    image: "https://i.pravatar.cc/150?img=2",
    message:
        "Good overall, but the delivery took a bit longer than expected. Still, the end result made up for it.",
  ),
  ReviewModel(
    name: "Lara Kim",
    date: "2025-09-05T09:10:00Z",
    rating: 3,
    image: "https://i.pravatar.cc/150?img=3",
    message:
        "Decent experience. Some minor issues, but customer support was responsive and resolved them quickly.",
  ),
  ReviewModel(
    name: "Marcus Blake",
    date: "2025-08-17T16:00:00Z",
    rating: 2,
    image: "https://i.pravatar.cc/150?img=4",
    message:
        "The concept is great, but execution needs polish. A few rough edges that need ironing out.",
  ),
  ReviewModel(
    name: "Isabella Grant",
    date: "2025-07-30T11:20:00Z",
    rating: 5,
    image: "https://i.pravatar.cc/150?img=5",
    message:
        "Absolutely love it. Every detail was carefully thought out, and the experience was seamless. Highly recommend!",
  ),
  ReviewModel(
    name: "Daniel Cruz",
    date: "2025-07-02T08:45:00Z",
    rating: 4,
    image: "https://i.pravatar.cc/150?img=6",
    message:
        "UI is slick and performance is solid. Just wish there were more customization options.",
  ),
  ReviewModel(
    name: "Emily Zhao",
    date: "2025-06-18T19:30:00Z",
    rating: 2,
    image: "https://i.pravatar.cc/150?img=7",
    message:
        "I had high hopes, but the support took ages to respond. Not the best experience overall.",
  ),
  ReviewModel(
    name: "Noah Patel",
    date: "2025-05-21T13:50:00Z",
    rating: 5,
    image: "https://i.pravatar.cc/150?img=8",
    message:
        "Had a minor issue but the support team fixed it within minutes. That alone earns five stars in my book.",
  ),
  ReviewModel(
    name: "Ava Rodriguez",
    date: "2025-04-12T17:05:00Z",
    rating: 5,
    image: "https://i.pravatar.cc/150?img=9",
    message:
        "From start to finish, everything just worked beautifully. You can tell real thought went into the design.",
  ),
  ReviewModel(
    name: "Liam O'Connor",
    date: "2025-03-03T12:15:00Z",
    rating: 4,
    image: "https://i.pravatar.cc/150?img=10",
    message:
        "Few bugs here and there, but overall this is a really polished experience. I’ll be sticking around.",
  ),
];

class Reviews extends StatelessWidget {
  const Reviews({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reviews'),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        scrolledUnderElevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
        child: Column(
          spacing: 24,
          children: [
            RatingCard(),
            Expanded(
              child: ListView.separated(
                itemCount: 5,
                scrollDirection: Axis.vertical,
                separatorBuilder: (context, index) => const SizedBox(
                  height: 4,
                  child: Divider(color: AppColors.gray200),
                ),

                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ReviewCard(
                    rating: review_data[index].rating,
                    name: review_data[index].name,
                    date: review_data[index].date,
                    image: review_data[index].image,
                    message: review_data[index].message,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
