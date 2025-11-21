import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/models/info_row.dart';
import 'package:siren_marketplace/core/types/extensions.dart';
import 'package:siren_marketplace/core/utils/custom_icons.dart';
import 'package:siren_marketplace/core/utils/phone_launcher.dart';
import 'package:siren_marketplace/core/widgets/custom_button.dart';
import 'package:siren_marketplace/core/widgets/error_handling_circle_avatar.dart';
import 'package:siren_marketplace/core/widgets/info_table.dart';
import 'package:siren_marketplace/core/widgets/rating_modal_content.dart';
import 'package:siren_marketplace/core/widgets/section_header.dart';
import 'package:siren_marketplace/new_core/domain/enums/order_status.dart';
import 'package:siren_marketplace/new_core/domain/value_objects/rating.dart';
import 'package:siren_marketplace/new_core/presentation/cubits/auth/auth_cubit.dart';
import 'package:siren_marketplace/new_core/presentation/cubits/auth/auth_state.dart';
import 'package:siren_marketplace/new_features/fisher/presentation/cubits/order_detail/order_detail_cubit.dart';
import 'package:siren_marketplace/new_features/fisher/presentation/cubits/order_detail/order_detail_state.dart';

class BuyerOrderDetails extends StatefulWidget {
  const BuyerOrderDetails({super.key, required this.orderId});

  final String orderId;

  @override
  State<BuyerOrderDetails> createState() => _BuyerOrderDetailsState();
}

class _BuyerOrderDetailsState extends State<BuyerOrderDetails> {
  Future<void> _submitReview({
    required String reviewedUserId,
    required double ratingValue,
    String? comment,
  }) async {
    final authState = context.read<AuthCubit>().state;
    final userId = authState is AuthAuthenticated ? authState.user.id : '';

    await context.read<OrderDetailCubit>().submitReview(
      reviewerId: userId,
      reviewedUserId: reviewedUserId,
      rating: Rating.fromValue(ratingValue),
      comment: comment,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderDetailCubit, OrderDetailState>(
      builder: (context, state) {
        if (state is OrderDetailLoading || state is OrderDetailInitial) {
          return Scaffold(
            appBar: AppBar(
              leading: BackButton(onPressed: () => context.pop()),
              title: const Text("Order Details"),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is OrderDetailError) {
          return Scaffold(
            appBar: AppBar(
              leading: BackButton(onPressed: () => context.pop()),
              title: const Text("Order Details"),
            ),
            body: Center(
              child: Text(
                'Error: ${state.message}',
                style: const TextStyle(color: AppColors.fail500),
              ),
            ),
          );
        }

        if (state is OrderDetailLoaded) {
          final order = state.order;
          final catchItem = state.catch_;
          final fisher = state.counterparty;

          return Scaffold(
            appBar: AppBar(
              leading: BackButton(onPressed: () => context.pop()),
              title: const Text("Order Details"),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Order #${order.id}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: AppColors.textBlue,
                        ),
                      ),
                      Text(
                        order.dateCreated.toIso8601String().toFormattedDate(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.gray650,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (catchItem.images.isEmpty) return;

                          final providers = catchItem.images.map<ImageProvider>(
                            (img) {
                              return img.contains("http")
                                  ? NetworkImage(img)
                                  : AssetImage(img) as ImageProvider;
                            },
                          ).toList();

                          final multiImageProvider = MultiImageProvider(
                            providers,
                          );

                          showImageViewerPager(
                            context,
                            multiImageProvider,
                            swipeDismissible: true,
                            immersive: true,
                            useSafeArea: true,
                            doubleTapZoomable: true,
                            backgroundColor: Colors.black.withOpacity(0.4),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: catchItem.images.isNotEmpty
                              ? (catchItem.images.first.contains("http")
                                    ? Image.network(
                                        catchItem.images.first,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Image.asset(
                                                  "assets/images/shrimp.jpg",
                                                  height: 60,
                                                  width: 60,
                                                ),
                                      )
                                    : Image.asset(
                                        catchItem.images.first,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Image.asset(
                                                  "assets/images/shrimp.jpg",
                                                  height: 60,
                                                  width: 60,
                                                ),
                                      ))
                              : Image.asset(
                                  "assets/images/shrimp.jpg",
                                  height: 60,
                                  width: 60,
                                ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              catchItem.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: AppColors.textBlue,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  order.status.displayName.capitalize(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: order.status == OrderStatus.active
                                        ? AppColors.shellOrange
                                        : order.status == OrderStatus.completed
                                        ? AppColors.success500
                                        : AppColors.fail500,
                                  ),
                                ),
                                Container(
                                  width: 10,
                                  height: 10,
                                  margin: const EdgeInsets.only(left: 4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white),
                                    color: order.status == OrderStatus.active
                                        ? AppColors.shellOrange
                                        : order.status == OrderStatus.completed
                                        ? AppColors.success500
                                        : AppColors.fail500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.gray200),
                    ),
                    child: InfoTable(
                      rows: [
                        InfoRow(
                          label: "Market",
                          value: catchItem.market.capitalize(),
                        ),
                        InfoRow(
                          label: "Species",
                          value: catchItem.species.name.capitalize(),
                        ),
                        if (catchItem.species.id == "prawns")
                          InfoRow(label: "Size", value: catchItem.size)
                        else
                          InfoRow(
                            label: "Average Size",
                            value: "${catchItem.size} cm",
                          ),
                        InfoRow(
                          label: "Weight",
                          value:
                              "${(order.terms.weight.grams / 1000).toStringAsFixed(2)} Kg",
                        ),
                        InfoRow(
                          label: "Total Price",
                          value:
                              "${order.terms.totalPrice.amount.toStringAsFixed(0)} CFA",
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const SectionHeader("Seller"),
                  const SizedBox(height: 8),

                  // Fisher Details
                  Material(
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: () {
                        context.push("/buyer/reviews/${fisher.id}");
                      },
                      borderRadius: BorderRadius.circular(16),
                      splashColor: AppColors.blue700.withValues(alpha: 0.1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ErrorHandlingCircleAvatar(
                              avatarUrl: fisher.avatarUrl!,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fisher.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: AppColors.textBlue,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: AppColors.shellOrange,
                                        size: 16,
                                      ),
                                      Text(
                                        fisher.rating.value.toStringAsFixed(1),
                                        style: const TextStyle(
                                          color: AppColors.textBlue,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                      Text(
                                        " (${fisher.reviewCount} Reviews)",
                                        style: const TextStyle(
                                          color: AppColors.textBlue,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Action buttons based on order status
                  if (order.status == OrderStatus.active) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        title: "Call Seller",
                        onPressed: () {
                          // TODO: Use fisher's actual phone number
                          makePhoneCall("651204966", context);
                        },
                        hugeIcon: HugeIcons.strokeRoundedCall02,
                        bordered: true,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        title: "Message Seller",
                        onPressed: () {
                          context.push("/buyer/chat");
                        },
                        icon: CustomIcons.chatbubble,
                      ),
                    ),
                  ],

                  // Rating logic for completed orders
                  if (order.status == OrderStatus.completed) ...[
                    const SizedBox(height: 16),

                    // Buyer rating status (Has the Buyer rated the Fisher?)
                    if (!order.hasReviewFromBuyer)
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          title: "Rate the Fisher",
                          onPressed: () {
                            final orderDetailCubit = context
                                .read<OrderDetailCubit>();
                            final authState = context.read<AuthCubit>().state;
                            final buyerId = authState is AuthAuthenticated
                                ? authState.user.id
                                : '';

                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.white,
                              useSafeArea: true,
                              showDragHandle: true,
                              builder: (context) {
                                return BlocProvider.value(
                                  value: orderDetailCubit,
                                  child: RatingModalContent(
                                    orderId: order.id,
                                    raterId: buyerId,
                                    ratedUserId: fisher.id,
                                    ratedUserName: fisher.name,
                                    onSubmitRating:
                                        ({
                                          required String orderId,
                                          required String raterId,
                                          required String ratedUserId,
                                          required double ratingValue,
                                          String? message,
                                        }) async {
                                          await _submitReview(
                                            reviewedUserId: ratedUserId,
                                            ratingValue: ratingValue,
                                            comment: message,
                                          );
                                        },
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            const HugeIcon(
                              icon: HugeIcons.strokeRoundedCheckmarkBadge01,
                              color: AppColors.success500,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "You rated the Fisher.",
                              style: const TextStyle(
                                color: AppColors.textBlue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Fisher rating status (Has the Fisher rated the Buyer?)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          HugeIcon(
                            icon: order.hasReviewFromFisher
                                ? HugeIcons.strokeRoundedCheckmarkBadge01
                                : HugeIcons.strokeRoundedClock01,
                            color: order.hasReviewFromFisher
                                ? AppColors.success500
                                : AppColors.shellOrange,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            order.hasReviewFromFisher
                                ? "The Fisher has rated you."
                                : "Waiting for Fisher to rate you.",
                            style: const TextStyle(
                              color: AppColors.textBlue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }

        return const Scaffold(body: Center(child: Text("Unexpected state")));
      },
    );
  }
}
