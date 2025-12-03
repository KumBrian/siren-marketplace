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
import 'package:siren_marketplace/core/providers/catch_providers.dart';
import 'package:siren_marketplace/core/providers/failed_transaction_provider.dart';
import 'package:siren_marketplace/core/providers/order_providers.dart';
import 'package:siren_marketplace/core/providers/user_providers.dart';
import 'package:siren_marketplace/core/types/converters.dart';
import 'package:siren_marketplace/core/types/extensions.dart';
import 'package:siren_marketplace/core/utils/custom_icons.dart';
import 'package:siren_marketplace/core/utils/phone_launcher.dart';
import 'package:siren_marketplace/core/widgets/custom_button.dart';
import 'package:siren_marketplace/core/widgets/info_table.dart';
import 'package:siren_marketplace/core/widgets/page_title.dart';
import 'package:siren_marketplace/core/widgets/rating_modal_content.dart';
import 'package:siren_marketplace/features/shared/presentation/widgets/partner_card.dart';

class BuyerOrderDetails extends ConsumerWidget {
  const BuyerOrderDetails({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderProvider(orderId));

    // Listen for failed transactions
    ref.listen(failedTransactionProvider, (previous, next) {
      if (next != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next), backgroundColor: Colors.red),
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

        // Watch catch and fisher data using Riverpod providers
        final catchAsync = ref.watch(catchProvider(order.catchId));
        final fisherAsync = ref.watch(userProvider(order.fisherId));

        return catchAsync.when(
          loading: () => Scaffold(
            appBar: AppBar(leading: const BackButton()),
            body: const Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Scaffold(
            appBar: AppBar(leading: const BackButton()),
            body: Center(child: Text("Error loading catch: $error")),
          ),
          data: (catchItem) {
            if (catchItem == null) {
              return Scaffold(
                appBar: AppBar(leading: const BackButton()),
                body: const Center(child: Text("Catch not found")),
              );
            }

            return fisherAsync.when(
              loading: () => Scaffold(
                appBar: AppBar(leading: const BackButton()),
                body: const Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => Scaffold(
                appBar: AppBar(leading: const BackButton()),
                body: Center(child: Text("Error loading fisher: $error")),
              ),
              data: (fisher) {
                if (fisher == null) {
                  return Scaffold(
                    appBar: AppBar(leading: const BackButton()),
                    body: const Center(child: Text("Fisher not found")),
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
                              "Order #${order.id}",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: AppColors.textBlue,
                              ),
                            ),
                            Text(
                              order.dateCreated
                                  .toIso8601String()
                                  .toFormattedDate(),
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
                                final providers = catchItem.images
                                    .map<ImageProvider>((img) {
                                      return img.contains("http")
                                          ? NetworkImage(img)
                                          : AssetImage(img);
                                    })
                                    .toList();

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
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: catchItem.images.first.contains("http")
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
                                                  fit: BoxFit.cover,
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
                                                  fit: BoxFit.cover,
                                                ),
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
                                        order.status.name.capitalize(),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.getStatusColor(
                                            OfferStatus.values.firstWhere(
                                              (e) =>
                                                  e.name == order.status.name,
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
                                          border: Border.all(
                                            color: Colors.white,
                                          ),
                                          color: AppColors.getStatusColor(
                                            OfferStatus.values.firstWhere(
                                              (e) =>
                                                  e.name == order.status.name,
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
                                  value: catchItem.size,
                                ),
                              InfoRow(
                                label: "Weight",
                                value: "${order.terms.weight.kilograms} kg",
                              ),
                              InfoRow(
                                label: "Total Price",
                                value: formatPrice(
                                  order.terms.totalPrice.amount,
                                ),
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
                              onPressed: () =>
                                  makePhoneCall("651204966", context),
                              hugeIcon: HugeIcons.strokeRoundedCall02,
                              bordered: true,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: CustomButton(
                              title: "Message Seller",
                              onPressed: () => context.push("/buyer/chat"),
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
                                              try {
                                                await sl<RatingService>()
                                                    .submitReview(
                                                      orderId: orderId,
                                                      reviewerId: raterId,
                                                      reviewedUserId:
                                                          ratedUserId,
                                                      rating: Rating.fromValue(
                                                        ratingValue,
                                                      ),
                                                      comment: message,
                                                    );

                                                // Invalidate order to refresh UI
                                                ref.invalidate(
                                                  orderProvider(orderId),
                                                );
                                                // Invalidate user to refresh partner card
                                                ref.invalidate(
                                                  userProvider(ratedUserId),
                                                );

                                                // Show success message
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Rating submitted successfully!',
                                                      ),
                                                      backgroundColor:
                                                          AppColors.success500,
                                                    ),
                                                  );
                                                }
                                              } catch (e) {
                                                // Error will be shown by RatingModalContent
                                                rethrow;
                                              }
                                            },
                                      );
                                    },
                                  );
                                },
                              ),
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Row(
                                children: [
                                  const HugeIcon(
                                    icon:
                                        HugeIcons.strokeRoundedCheckmarkBadge01,
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
          },
        );
      },
    );
  }
}
