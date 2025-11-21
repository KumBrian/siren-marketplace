import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/models/info_row.dart';
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

class OrderDetails extends StatefulWidget {
  const OrderDetails({super.key, required this.orderId});

  final String orderId;

  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  final FocusNode _buttonFocusNode = FocusNode(debugLabel: 'Repost Menu');

  Future<void> _markOrderAsCompleted() async {
    // Get current user ID from AuthCubit
    final authState = context.read<AuthCubit>().state;
    final userId = authState is AuthAuthenticated ? authState.user.id : '';

    await context.read<OrderDetailCubit>().completeOrder(userId);
  }

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
  void dispose() {
    _buttonFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderDetailCubit, OrderDetailState>(
      builder: (context, state) {
        if (state is OrderDetailLoading) {
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        if (state is! OrderDetailLoaded) {
          return Scaffold(
            appBar: AppBar(
              leading: BackButton(onPressed: () => context.pop()),
              title: const Text("Order Details"),
            ),
            body: const Center(child: Text("No order data available")),
          );
        }

        // Extract data from loaded state
        final order = state.order;
        final catch_ = state.catch_;
        final buyer = state.counterparty;
        final canSubmitReview = state.canSubmitReview;

        // Extract values using new architecture
        final weightGrams = order.terms.weight.grams;
        final totalPrice = order.terms.totalPrice.amount;
        final pricePerKg = order.terms.pricePerKg.amountPerKg;

        final buyerName = buyer.name;
        final buyerAvatar = buyer.avatarUrl ?? "assets/images/user-profile.png";
        final buyerRating = buyer.rating.value;
        final buyerReviewCount = buyer.reviewCount;
        final String imageUrl = catch_.images.isNotEmpty
            ? catch_.images.first
            : "assets/images/prawns.jpg";

        return Scaffold(
          appBar: AppBar(
            leading: BackButton(onPressed: () => context.pop()),
            title: const Text(
              "Order Details",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textBlue,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Status Badge
                _buildStatusBadge(order.status),
                const SizedBox(height: 16),

                // Catch Image
                GestureDetector(
                  onTap: () {
                    final imageProvider = Image.network(imageUrl).image;
                    showImageViewer(
                      context,
                      imageProvider,
                      swipeDismissible: true,
                      doubleTapZoomable: true,
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 64,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Catch Details Section
                const SectionHeader("Catch Details"),
                const SizedBox(height: 12),
                InfoTable(
                  rows: [
                    InfoRow(label: "Species", value: catch_.species.name),
                    InfoRow(label: "Market", value: catch_.market),
                    InfoRow(
                      label: "Weight",
                      value: "${(weightGrams / 1000).toStringAsFixed(2)} kg",
                    ),
                    InfoRow(
                      label: "Price",
                      value: "KES ${totalPrice.toStringAsFixed(2)}",
                    ),
                    InfoRow(
                      label: "Price/kg",
                      value: "KES ${pricePerKg.toStringAsFixed(2)}",
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Buyer Information Section
                const SectionHeader("Buyer Information"),
                const SizedBox(height: 12),
                _buildBuyerInfo(
                  buyerName: buyerName,
                  buyerAvatar: buyerAvatar,
                  buyerRating: buyerRating,
                  buyerReviewCount: buyerReviewCount,
                  buyerId: buyer.id,
                ),
                const SizedBox(height: 24),

                // Action Buttons
                if (order.isActive) ...[
                  CustomButton(
                    title: "Mark as Completed",
                    onPressed: () => _showCompletionConfirmation(context),
                  ),
                  const SizedBox(height: 12),
                ],

                // Review Section (if order is completed and can submit review)
                if (order.isCompleted && canSubmitReview) ...[
                  CustomButton(
                    title: "Submit Review for $buyerName",
                    onPressed: () => _showReviewModal(
                      context,
                      reviewedUserId: buyer.id,
                      reviewedUserName: buyerName,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Contact Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Implement call functionality with buyer contact
                        },
                        icon: const Icon(Icons.phone),
                        label: const Text("Call Buyer"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          context.push(
                            '/fisher/chat',
                            extra: {'userId': buyer.id, 'userName': buyerName},
                          );
                        },
                        icon: const Icon(Icons.message),
                        label: const Text("Message"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color badgeColor;
    String statusText;

    switch (status) {
      case OrderStatus.active:
        badgeColor = Colors.blue;
        statusText = "Active";
        break;
      case OrderStatus.completed:
        badgeColor = Colors.green;
        statusText = "Completed";
        break;
      case OrderStatus.cancelled:
        badgeColor = Colors.red;
        statusText = "Cancelled";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: badgeColor,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildBuyerInfo({
    required String buyerName,
    required String buyerAvatar,
    required double buyerRating,
    required int buyerReviewCount,
    required String buyerId,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          ErrorHandlingCircleAvatar(avatarUrl: buyerAvatar, radius: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  buyerName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      "${buyerRating.toStringAsFixed(1)} ($buyerReviewCount reviews)",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              context.push('/fisher/reviews/$buyerId');
            },
            icon: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
        ],
      ),
    );
  }

  void _showCompletionConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Confirm Order Completion",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                "Are you sure you want to mark this order as completed? This action cannot be undone.",
                style: TextStyle(fontSize: 14, color: AppColors.gray650),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              CustomButton(
                title: "Confirm",
                onPressed: () {
                  context.pop(); // Dismiss modal
                  _markOrderAsCompleted();
                },
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text("Cancel"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showReviewModal(
    BuildContext context, {
    required String reviewedUserId,
    required String reviewedUserName,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (modalContext) {
        return RatingModalContent(
          orderId: widget.orderId,
          raterId: context.read<AuthCubit>().state is AuthAuthenticated
              ? (context.read<AuthCubit>().state as AuthAuthenticated).user.id
              : '',
          ratedUserId: reviewedUserId,
          ratedUserName: reviewedUserName,
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
        );
      },
    );
  }
}
