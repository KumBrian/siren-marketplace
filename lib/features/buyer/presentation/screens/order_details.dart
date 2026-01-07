import 'dart:io';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/di/injector.dart';
import 'package:siren_marketplace/core/domain/enums/offer_status.dart';
import 'package:siren_marketplace/core/domain/enums/order_status.dart';
import 'package:siren_marketplace/core/domain/enums/user_role.dart';
import 'package:siren_marketplace/core/domain/services/rating_service.dart';
import 'package:siren_marketplace/core/domain/value_objects/rating.dart';
import 'package:siren_marketplace/core/models/info_row.dart';
import 'package:siren_marketplace/core/services/connectivity_service.dart';
import 'package:siren_marketplace/core/providers/failed_transaction_provider.dart';
import 'package:siren_marketplace/core/providers/order_providers.dart';
import 'package:siren_marketplace/core/providers/review_providers.dart';
import 'package:siren_marketplace/core/providers/user_providers.dart';
import 'package:siren_marketplace/core/types/converters.dart';
import 'package:siren_marketplace/core/types/extensions.dart';
import 'package:siren_marketplace/core/utils/custom_icons.dart';
import 'package:siren_marketplace/core/utils/phone_launcher.dart';
import 'package:siren_marketplace/core/widgets/custom_button.dart';
import 'package:siren_marketplace/core/widgets/info_table.dart';
import 'package:siren_marketplace/core/widgets/error_dialog.dart';
import 'package:siren_marketplace/core/widgets/page_title.dart';
import 'package:siren_marketplace/core/widgets/rating_modal_content.dart';
import 'package:siren_marketplace/features/shared/presentation/widgets/partner_card.dart';

class BuyerOrderDetails extends ConsumerWidget {
  const BuyerOrderDetails({super.key, required this.orderId});

  final String orderId;

  /// Generate conversation ID from buyer and fisher IDs
  String _generateConversationId(String buyerId, String fisherId) {
    final ids = [buyerId, fisherId]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderProvider(orderId));

    // Listen for failed transactions
    ref.listen(failedTransactionProvider, (previous, next) {
      if (next != null) {
        showDialog(
          context: context,
          builder: (context) =>
              ErrorDialog(title: "Transaction Failed", message: next),
        );
        ref.read(failedTransactionProvider.notifier).state = null;
      }
    });

    return orderAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(leading: const BackButton()),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(leading: const BackButton()),
        body: Center(
          child: Text(
            'Error: $error',
            style: const TextStyle(color: AppColors.fail500),
          ),
        ),
      ),
      data: (order) {
        if (order == null) {
          return Scaffold(
            appBar: AppBar(leading: const BackButton()),
            body: const Center(child: Text("Order not found")),
          );
        }

        // Use embedded product data
        final product = order.product;
        if (product == null) {
          return Scaffold(
            appBar: AppBar(leading: const BackButton()),
            body: const Center(
              child: Text("Product information not available"),
            ),
          );
        }

        // Use embedded fisher data from product
        final fisher = product.fisher;
        if (fisher == null) {
          return Scaffold(
            appBar: AppBar(leading: const BackButton()),
            body: const Center(child: Text("Fisher information not available")),
          );
        }

        return Scaffold(
          appBar: AppBar(
            leading: BackButton(onPressed: () => context.pop()),
            title: const PageTitle(title: "Order Details"),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Header
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Order #${order.orderNumber ?? order.id.substring(0, 8)}",
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

                // Catch Image and Status
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        final providers = product.images.map<ImageProvider>((
                          img,
                        ) {
                          if (img.startsWith("http")) {
                            return NetworkImage(img);
                          } else if (img.startsWith("assets/")) {
                            return AssetImage(img);
                          } else {
                            return FileImage(File(img));
                          }
                        }).toList();

                        if (providers.isNotEmpty) {
                          showImageViewerPager(
                            context,
                            MultiImageProvider(providers),
                            swipeDismissible: true,
                            immersive: true,
                            useSafeArea: true,
                            doubleTapZoomable: true,
                            backgroundColor: Colors.black.withValues(
                              alpha: 0.4,
                            ),
                          );
                        }
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: product.images.isNotEmpty
                            ? (product.images.first.contains("http")
                                  ? Image.network(
                                      product.images.first,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Image.asset(
                                                "assets/images/shrimp.jpg",
                                                height: 60,
                                                width: 60,
                                                fit: BoxFit.cover,
                                              ),
                                    )
                                  : (product.images.first.startsWith("assets/")
                                        ? Image.asset(
                                            product.images.first,
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.file(
                                            File(product.images.first),
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (
                                                  context,
                                                  error,
                                                  stackTrace,
                                                ) => Image.asset(
                                                  "assets/images/shrimp.jpg",
                                                  height: 60,
                                                  width: 60,
                                                  fit: BoxFit.cover,
                                                ),
                                          )))
                            : Image.asset(
                                "assets/images/shrimp.jpg",
                                height: 60,
                                width: 60,
                                fit: BoxFit.cover,
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
                            product.name,
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
                                order.status.name.capitalize(),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.getStatusColor(
                                    OfferStatus.values.firstWhere(
                                      (e) => e.name == order.status.name,
                                      orElse: () => OfferStatus.pending,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 10,
                                height: 10,
                                margin: const EdgeInsets.only(left: 4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white),
                                  color: AppColors.getStatusColor(
                                    OfferStatus.values.firstWhere(
                                      (e) => e.name == order.status.name,
                                      orElse: () => OfferStatus.pending,
                                    ),
                                  ),
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

                // Order Details Table
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
                        value: product.marketName.capitalize(),
                      ),
                      InfoRow(
                        label: "Species",
                        value: product.species.name.capitalize(),
                      ),
                      if (product.species.id == "prawns")
                        InfoRow(label: "Size", value: product.size)
                      else
                        InfoRow(label: "Average Size", value: product.size),
                      InfoRow(
                        label: "Weight",
                        value: "${order.terms.weight.kilograms} kg",
                      ),
                      InfoRow(
                        label: "Total Price",
                        value: formatPrice(order.terms.totalPrice.amount),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Fisher Details
                PartnerCard(partner: fisher, myRole: UserRole.buyer),
                const SizedBox(height: 16),

                // Action Buttons
                if (order.status == OrderStatus.cancelled) ...[
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      title: "Marketplace",
                      onPressed: () => context.go("/buyer"),
                      icon: Icons.storefront,
                      bordered: true,
                    ),
                  ),
                ],

                if (order.status == OrderStatus.accepted) ...[
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      title: "Call Seller",
                      onPressed: () => makePhoneCall("651204966", context),
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
                        final conversationId = _generateConversationId(
                          order.buyerId,
                          order.fisherId,
                        );
                        context.push("/buyer/chat/$conversationId");
                      },
                      icon: CustomIcons.chatbubble,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                // Rating Section
                if (order.status == OrderStatus.completed) ...[
                  const SizedBox(height: 16),

                  // Buyer Rating Status
                  if (order.hasReviewFromBuyer == false)
                    // Only allow rating if online
                    if (ref.watch(isOnlineProvider))
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          title: "Rate the Fisher",
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.white,
                              useSafeArea: true,
                              showDragHandle: true,
                              builder: (context) {
                                return RatingModalContent(
                                  orderId: order.id,
                                  raterId: order.buyerId,
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
                                        await sl<RatingService>().submitReview(
                                          orderId: orderId,
                                          reviewerId: raterId,
                                          reviewedUserId: ratedUserId,
                                          rating: Rating.fromValue(ratingValue),
                                          comment: message,
                                        );

                                        // Invalidate order to refresh UI in Details
                                        ref.invalidate(orderProvider(orderId));
                                        // Invalidate user to refresh partner card
                                        ref.invalidate(
                                          userProvider(ratedUserId),
                                        );
                                        // Invalidate reviews
                                        ref.invalidate(
                                          reviewsForUserProvider(ratedUserId),
                                        );
                                        // Invalidate global lists to refresh "everywhere else"
                                        ref.invalidate(fisherOrdersProvider);
                                        ref.invalidate(
                                          fisherOrdersWithProductProvider,
                                        );
                                        ref.invalidate(
                                          buyerOrdersWithProductProvider,
                                        );
                                        ref.invalidate(myOrdersProvider);
                                      },
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
                            const Text(
                              "You rated the Fisher.",
                              style: TextStyle(
                                color: AppColors.textBlue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                  const SizedBox(height: 16),

                  // Fisher Rating Status
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
      },
    );
  }
}
