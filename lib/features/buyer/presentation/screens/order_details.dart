import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/domain/enums/offer_status.dart';
import 'package:siren_marketplace/core/domain/enums/order_status.dart';
import 'package:siren_marketplace/core/models/info_row.dart'; // Added to ensure InfoRow is defined
import 'package:siren_marketplace/core/types/converters.dart';
import 'package:siren_marketplace/core/types/extensions.dart';
import 'package:siren_marketplace/core/utils/custom_icons.dart';
import 'package:siren_marketplace/core/utils/phone_launcher.dart';
import 'package:siren_marketplace/core/widgets/custom_button.dart';
import 'package:siren_marketplace/core/widgets/error_handling_circle_avatar.dart';
import 'package:siren_marketplace/core/widgets/info_table.dart';
import 'package:siren_marketplace/core/widgets/page_title.dart';
import 'package:siren_marketplace/core/widgets/rating_modal_content.dart';
import 'package:siren_marketplace/core/widgets/section_header.dart';
import 'package:siren_marketplace/features/fisher/new_logic/catches_bloc/catches_cubit.dart';
import 'package:siren_marketplace/features/fisher/new_logic/orders_bloc/orders_cubit.dart';
import 'package:siren_marketplace/features/fisher/new_logic/users_bloc/users_cubit.dart';

class BuyerOrderDetails extends StatefulWidget {
  const BuyerOrderDetails({super.key, required this.orderId});

  final String orderId;

  @override
  State<BuyerOrderDetails> createState() => _BuyerOrderDetailsState();
}

class _BuyerOrderDetailsState extends State<BuyerOrderDetails> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<OrdersCubit>().loadById(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrdersCubit, OrdersState>(
      listener: (context, state) {
        if (state.selectedOrder != null) {
          final order = state.selectedOrder!;
          context.read<CatchesCubit>().loadById(order.catchId);
          context.read<UsersCubit>().loadById(order.fisherId);
        }
      },
      builder: (context, ordersState) {
        if (ordersState.loading) {
          return Scaffold(
            appBar: AppBar(leading: const BackButton()),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (ordersState.error != null) {
          return Scaffold(
            appBar: AppBar(leading: const BackButton()),
            body: Center(
              child: Text(
                'Error: ${ordersState.error}',
                style: const TextStyle(color: AppColors.fail500),
              ),
            ),
          );
        }

        final order = ordersState.selectedOrder;

        if (order == null) {
          return Scaffold(
            appBar: AppBar(
              leading: const BackButton(),
              title: const Text("Order Details"),
            ),
            body: const Center(
              child: Text(
                "Order not found.",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        return BlocBuilder<CatchesCubit, CatchesState>(
          builder: (context, catchesState) {
            final catchItem = catchesState.catches
                .where((c) => c.id == order.catchId)
                .firstOrNull;

            return BlocBuilder<UsersCubit, UsersState>(
              builder: (context, usersState) {
                final fisher = usersState.users[order.fisherId];

                if (catchItem == null || fisher == null) {
                  return Scaffold(
                    appBar: AppBar(leading: const BackButton()),
                    body: const Center(child: CircularProgressIndicator()),
                  );
                }

                return Scaffold(
                  appBar: AppBar(
                    leading: BackButton(onPressed: () => context.pop()),
                    title: PageTitle(title: "Order Details"),
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
                              order.dateCreated
                                  .toIso8601String()
                                  .toFormattedDate(),
                              style: TextStyle(
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
                                final providers = catchItem.images
                                    .map<ImageProvider>((img) {
                                      return img.contains("http")
                                          ? NetworkImage(img)
                                          : AssetImage(img);
                                    })
                                    .toList();

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
                                  backgroundColor: Colors.black.withOpacity(
                                    0.4,
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
                                                  height: 120,
                                                  width: 120,
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
                                value: order.terms.weight.kilograms,
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
                        const SectionHeader("Seller"),
                        const SizedBox(height: 8),

                        // Fisher Details
                        Material(
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            onTap: () {
                              context.push("/buyer/reviews/${order.fisherId}");
                            },
                            borderRadius: BorderRadius.circular(16),
                            splashColor: AppColors.blue700.withValues(
                              alpha: 0.1,
                            ),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                              fisher.rating.value
                                                  .toStringAsFixed(1),
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

                        // --- ACTION BUTTONS SECTION ---
                        if (order.status == OrderStatus.cancelled) ...[
                          SizedBox(
                            width: double.infinity,
                            child: CustomButton(
                              title: "Marketplace",
                              onPressed: () {
                                // Implement navigation to marketplace
                              },
                              icon: Icons.storefront,
                              bordered: true,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: CustomButton(
                              title: "Make New Offer",
                              onPressed: () {
                                // Implement navigation to make a new offer
                              },
                            ),
                          ),
                        ],

                        if (order.status == OrderStatus.active) ...[
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: CustomButton(
                              title: "Call Seller",
                              onPressed: () {
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

                        // 🌟 RATING LOGIC FOR COMPLETED ORDERS 🌟
                        if (order.status == OrderStatus.completed) ...[
                          const SizedBox(height: 16),

                          // 1. BUYER RATING STATUS (Has the Buyer rated the Fisher?)
                          if (order.hasReviewFromBuyer == false)
                            SizedBox(
                              width: double.infinity,
                              child: CustomButton(
                                title: "Rate the Fisher",
                                onPressed: () {
                                  final ordersCubit = context
                                      .read<OrdersCubit>();

                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.white,
                                    useSafeArea: true,
                                    showDragHandle: true,
                                    builder: (context) {
                                      return BlocProvider.value(
                                        value: ordersCubit,
                                        child: RatingModalContent(
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
                                                ordersCubit.submitRating(
                                                  orderId: orderId,
                                                  reviewerId: order.buyerId,
                                                  reviewedUserId: fisher.id,
                                                  ratingValue: ratingValue
                                                      .floor(),
                                                  comment: message ?? "",
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

                          // 2. FISHER RATING STATUS (Has the Fisher rated the Buyer?)
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
