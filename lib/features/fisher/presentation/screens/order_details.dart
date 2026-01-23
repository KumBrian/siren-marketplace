import 'dart:io';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:siren_marketplace/constants/constants.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/domain/enums/order_status.dart';
import 'package:siren_marketplace/core/domain/enums/user_role.dart';
import 'package:siren_marketplace/core/domain/services/rating_service.dart';
import 'package:siren_marketplace/core/domain/services/negotiation_service.dart';
import 'package:siren_marketplace/core/domain/value_objects/rating.dart';
import 'package:siren_marketplace/core/models/info_row.dart';
import 'package:siren_marketplace/core/providers/catch_providers.dart';
import 'package:siren_marketplace/core/providers/failed_transaction_provider.dart';
import 'package:siren_marketplace/core/providers/offer_providers.dart';
import 'package:siren_marketplace/core/providers/order_providers.dart';
import 'package:siren_marketplace/core/providers/review_providers.dart';
import 'package:siren_marketplace/core/providers/user_providers.dart';
import 'package:siren_marketplace/core/types/converters.dart';
import 'package:siren_marketplace/core/types/extensions.dart';
import 'package:siren_marketplace/core/utils/custom_icons.dart';
import 'package:siren_marketplace/core/utils/phone_launcher.dart';
import 'package:siren_marketplace/core/widgets/custom_button.dart';
import 'package:siren_marketplace/core/widgets/info_table.dart';
import 'package:siren_marketplace/core/widgets/rating_modal_content.dart';
import 'package:siren_marketplace/core/widgets/section_header.dart';
import 'package:siren_marketplace/core/widgets/error_dialog.dart';
import 'package:siren_marketplace/core/di/injector.dart';
import 'package:siren_marketplace/core/services/connectivity_service.dart';
import 'package:siren_marketplace/features/shared/presentation/widgets/partner_card.dart';
import 'package:siren_marketplace/features/chat/presentation/providers/chat_providers.dart';
import 'package:siren_marketplace/core/utils/custom_dialogs.dart';

class OrderDetails extends ConsumerWidget {
  const OrderDetails({super.key, required this.orderId});

  final String orderId;

  Future<void> _markOrderAsCompleted(
    WidgetRef ref,
    BuildContext context,
  ) async {
    final isOnline = ref.read(isOnlineProvider);
    if (!isOnline) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => const ErrorDialog(
            title: "Offline",
            message: "You cannot complete orders while offline.",
          ),
        );
      }
      return;
    }

    try {
      await ref.read(completeOrderProvider(orderId).future);
      ref.invalidate(fisherOffersProvider);
      ref.invalidate(fisherOrdersProvider);
      ref.invalidate(fisherOrdersWithProductProvider);
      ref.invalidate(orderProvider(orderId));
    } catch (e) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => ErrorDialog(
            title: "Error",
            message: "Failed to complete order: $e",
          ),
        );
      }
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderProvider(orderId));

    // Listen for order errors
    ref.listen(orderProvider(orderId), (previous, next) {
      if (next.hasError && !next.isLoading) {
        showDialog(
          context: context,
          builder: (context) => ErrorDialog(
            title: "Action Failed",
            message: next.error.toString(),
          ),
        );
      }
    });

    return orderAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () => context.pop()),
          title: const Text("Order Details"),
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () => context.pop()),
          title: const Text("Order Details"),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Text("Load Error: $error", textAlign: TextAlign.center),
          ),
        ),
      ),
      data: (selectedOrder) {
        if (selectedOrder == null) {
          return Scaffold(
            appBar: AppBar(
              leading: BackButton(onPressed: () => context.pop()),
              title: const Text("Order Details"),
            ),
            body: const Center(child: Text("Order not found")),
          );
        }

        // Check if order has embedded product data
        if (selectedOrder.product == null) {
          return Scaffold(
            appBar: AppBar(
              leading: BackButton(onPressed: () => context.pop()),
              title: const Text("Order Details"),
            ),
            body: const Center(
              child: Text("Product information not available"),
            ),
          );
        }

        // Use embedded product data directly
        final product = selectedOrder.product!;

        final currentUserAsync = ref.watch(currentUserProvider);

        final isOnline = ref.watch(isOnlineProvider);

        return currentUserAsync.when(
          loading: () => Scaffold(
            appBar: AppBar(leading: BackButton(onPressed: () => context.pop())),
            body: const Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Scaffold(
            appBar: AppBar(leading: BackButton(onPressed: () => context.pop())),
            body: Center(child: Text("Error: $error")),
          ),
          data: (user) {
            if (user == null) {
              return Scaffold(
                appBar: AppBar(
                  leading: BackButton(onPressed: () => context.pop()),
                ),
                body: const Center(child: Text("User not found")),
              );
            }

            final int acceptedWeight = selectedOrder.terms.weight.grams;
            final int acceptedPrice = selectedOrder.terms.totalPrice.amount
                .toInt();
            final OrderStatus orderStatus = selectedOrder.status;
            // Use embedded buyer data from order
            final buyerName = selectedOrder.buyer?.name ?? 'Buyer';
            final String imageUrl = product.images.isNotEmpty
                ? product.images.first
                : "assets/images/prawns.jpg";

            return Scaffold(
              appBar: AppBar(
                leading: BackButton(onPressed: () => context.pop()),
                title: const Text(
                  "Order Details",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textBlue,
                    fontSize: 24,
                  ),
                ),
                actions: [
                  // Only show Relist option if online
                  if (orderStatus == OrderStatus.accepted && isOnline)
                    IconButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.white,
                          useSafeArea: true,
                          showDragHandle: true,
                          builder: (context) =>
                              _buildFailedTransactionModal(ref, orderId),
                        );
                      },
                      icon: const Icon(Icons.autorenew),
                    ),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Order ID and Date
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "${selectedOrder.orderNumber}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: AppColors.textBlue,
                          ),
                        ),
                        Text(
                          selectedOrder.dateUpdated
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

                    // ... (Product/Catch Details - unchanged) ...
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            final ImageProvider imageProvider =
                                imageUrl.startsWith('http')
                                ? NetworkImage(imageUrl) as ImageProvider
                                : (imageUrl.startsWith('assets/')
                                      ? AssetImage(imageUrl)
                                      : FileImage(File(imageUrl)));

                            showImageViewer(
                              context,
                              imageProvider,
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
                            child: imageUrl.startsWith('http')
                                ? Image.network(
                                    imageUrl,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Image.asset(
                                              "assets/images/prawns.jpg",
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                            ),
                                  )
                                : (imageUrl.startsWith('assets/')
                                      ? Image.asset(
                                          imageUrl,
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.file(
                                          File(imageUrl),
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Image.asset(
                                                    "assets/images/shrimp.jpg",
                                                    width: 60,
                                                    height: 60,
                                                    fit: BoxFit.cover,
                                                  ),
                                        )),
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
                                    orderStatus.name.capitalize(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.getOrderStatusColor(
                                        orderStatus,
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
                                      color: AppColors.getOrderStatusColor(
                                        orderStatus,
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

                    // Info Table
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.gray200),
                      ),
                      child: InfoTable(
                        rows: [
                          InfoRow(label: "Market", value: product.marketName),
                          InfoRow(
                            label: "Species",
                            value: product.species.name,
                          ),
                          // if (product.size != null)
                          //   InfoRow(
                          //     label: "Size",
                          //     value: product.size!,
                          //   ),
                          InfoRow(
                            label: "Weight",
                            value: formatWeight(acceptedWeight),
                          ),
                          InfoRow(
                            label: "Total Price",
                            value: acceptedPrice.toStringAsFixed(0),
                            suffix: "CFA",
                          ),
                        ].whereType<InfoRow>().toList(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Buyer Details
                    if (selectedOrder.buyer != null)
                      PartnerCard(
                        partner: selectedOrder.buyer!,
                        myRole: UserRole.fisher,
                      ),

                    // Cancellation Reason Display
                    if (orderStatus == OrderStatus.cancelled &&
                        selectedOrder.cancellationReason != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.fail50.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.fail200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: AppColors.fail500,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Order Cancelled",
                                  style: TextStyle(
                                    color: AppColors.fail500,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Reason: ${selectedOrder.cancellationReason}",
                              style: const TextStyle(
                                color: AppColors.fail500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Action Buttons (Complete Order)
                    if (orderStatus == OrderStatus.accepted) ...[
                      const SizedBox(height: 16),
                      Column(
                        spacing: 8,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomButton(
                            title: "Call Buyer",
                            onPressed: () {
                              final phone = selectedOrder.buyer?.phone;
                              if (phone != null && phone.isNotEmpty) {
                                makePhoneCall(phone, context);
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (context) => const ErrorDialog(
                                    title: "Phone Unavailable",
                                    message:
                                        "Phone number not available for this buyer.",
                                  ),
                                );
                              }
                            },
                            bordered: true,
                            hugeIcon: HugeIcons.strokeRoundedCall02,
                          ),
                          CustomButton(
                            title: "Message Buyer",
                            onPressed: () async {
                              if (!isOnline) {
                                showDialog(
                                  context: context,
                                  builder: (context) => const ErrorDialog(
                                    title: "Offline",
                                    message:
                                        "Chat is unavailable while offline.",
                                  ),
                                );
                                return;
                              }
                              try {
                                final conversationId = await ref
                                    .read(chatControllerProvider)
                                    .startConversation(
                                      selectedOrder.buyerId,
                                      productId: product.id,
                                    );
                                if (context.mounted) {
                                  context.push("/fisher/chat/$conversationId");
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => ErrorDialog(
                                      title: "Chat Error",
                                      message: "Failed to open chat: $e",
                                    ),
                                  );
                                }
                              }
                            },
                            bordered: true,
                            icon: CustomIcons.chatbubble,
                          ),
                          const SizedBox(height: 16),

                          // Mark as completed button - disabled/hidden if offline
                          if (isOnline)
                            CustomButton(
                              title: "Mark as Completed",
                              onPressed: () => _showCompleteOrderModal(
                                context,
                                ref,
                                selectedOrder.id,
                              ),
                              icon: Icons.check,
                            )
                          else
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Connect to internet to complete order",
                                style: TextStyle(color: AppColors.gray500),
                              ),
                            ),
                        ],
                      ),
                    ],

                    if (orderStatus == OrderStatus.completed) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          title: "Marketplace",
                          onPressed: () => context.go("/fisher"),
                          icon: Icons.storefront,
                          bordered: true,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Rating Section
                    if (orderStatus == OrderStatus.completed &&
                        !selectedOrder.hasReviewFromFisher) ...[
                      if (isOnline)
                        CustomButton(
                          title: "Rate the buyer",
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.white,
                              useSafeArea: true,
                              showDragHandle: true,
                              builder: (context) {
                                return RatingModalContent(
                                  orderId: selectedOrder.id,
                                  raterId: user.id,
                                  ratedUserId: selectedOrder.buyer?.id ?? '',
                                  ratedUserName: buyerName,
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
                                          comment: message ?? '',
                                        );
                                        ref.invalidate(orderProvider(orderId));
                                        // Invalidate user to refresh partner card
                                        ref.invalidate(
                                          userProvider(ratedUserId),
                                        );
                                        // Invalidate reviews to show new review
                                        ref.invalidate(
                                          reviewsForUserProvider(ratedUserId),
                                        );
                                      },
                                );
                              },
                            );
                          },
                        ),
                    ] else if (orderStatus == OrderStatus.completed &&
                        selectedOrder.hasReviewFromFisher) ...[
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
                              "You rated the Buyer",
                              style: TextStyle(
                                color: AppColors.textBlue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (orderStatus == OrderStatus.completed) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            HugeIcon(
                              icon: selectedOrder.hasReviewFromBuyer
                                  ? HugeIcons.strokeRoundedCheckmarkBadge01
                                  : HugeIcons.strokeRoundedClock01,
                              color: selectedOrder.hasReviewFromBuyer
                                  ? AppColors.success500
                                  : AppColors.shellOrange,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              selectedOrder.hasReviewFromBuyer
                                  ? "The Buyer has rated you."
                                  : "Waiting for Buyer to rate you.",
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
  }

  Widget _buildFailedTransactionModal(WidgetRef ref, String orderId) {
    final customReasonController = TextEditingController();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Padding(
          padding: EdgeInsets.only(
            left: 32,
            right: 32,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: ListView(
            controller: scrollController,
            children: [
              const Text(
                "Why did this transaction not go through?",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlue,
                ),
              ),
              const SizedBox(height: 8),
              Consumer(
                builder: (context, ref, child) {
                  final selectedReason = ref.watch(failedTransactionProvider);
                  return ListView.builder(
                    itemCount: kFailedTransactionReasons.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      final reason = kFailedTransactionReasons[index];
                      final isSelected = selectedReason == reason;
                      return InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          final current = ref.read(failedTransactionProvider);
                          ref.read(failedTransactionProvider.notifier).state =
                              current == reason ? null : reason;
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Checkbox(
                                value: isSelected,
                                onChanged: (_) {
                                  final current = ref.read(
                                    failedTransactionProvider,
                                  );
                                  ref
                                      .read(failedTransactionProvider.notifier)
                                      .state = current == reason
                                      ? null
                                      : reason;
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                visualDensity: VisualDensity.compact,
                                splashRadius: 5,
                              ),
                              Expanded(
                                child: Text(
                                  reason,
                                  style: const TextStyle(fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              const Text(
                "Other reason? Specify",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textBlue,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: customReasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Enter the reason here...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                title: "Confirm & Relist",
                onPressed: () async {
                  final isOnline = ref.read(isOnlineProvider);
                  if (!isOnline) {
                    if (context.mounted) {
                      showDialog(
                        context: context,
                        builder: (context) => const ErrorDialog(
                          title: "Offline",
                          message: "You cannot relist orders while offline.",
                        ),
                      );
                    }
                    return;
                  }

                  final selectedReason = ref.read(failedTransactionProvider);
                  final customReason = customReasonController.text.trim();

                  final reason = customReason.isNotEmpty
                      ? customReason
                      : selectedReason;

                  if (reason == null || reason.isEmpty) {
                    showDialog(
                      context: context,
                      builder: (context) => const ErrorDialog(
                        title: "Required",
                        message: 'Please select or enter a reason',
                      ),
                    );
                    return;
                  }

                  try {
                    final negotiationService = sl<NegotiationService>();
                    await negotiationService.relistOrder(
                      orderId: orderId,
                      reason: reason,
                    );

                    // Reset provider and close modal
                    ref.read(failedTransactionProvider.notifier).state = null;
                    if (context.mounted) {
                      Navigator.of(context).pop();

                      // Refresh order data
                      ref.invalidate(orderProvider(orderId));

                      // Refresh offer data (to show rejected status)
                      // We need to find the offer ID first, but since we don't have it easily here
                      // we can invalidate the shared provider if we knew the ID.
                      // However, the order has the offerId.
                      final order = await ref.read(
                        orderProvider(orderId).future,
                      );
                      if (order != null) {
                        // Invalidate all offers instead of specific one (offerId not available)
                        ref.invalidate(fisherOffersProvider);

                        // Refresh catch data (to show restored weight)
                        ref.invalidate(catchByIdProvider(order.catchId));
                        ref.invalidate(offersByProductProvider(order.catchId));
                      }

                      // Refresh lists
                      ref.invalidate(fisherOrdersProvider);
                      ref.invalidate(fisherOffersProvider);
                      ref.invalidate(fisherCatchesProvider);

                      if (context.mounted) {
                        showActionSuccessDialog(
                          context,
                          message: "Order relisted successfully",
                          autoCloseSeconds: 2,
                        );
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      showDialog(
                        context: context,
                        builder: (context) => ErrorDialog(
                          title: "Error",
                          message: 'Error: ${e.toString()}',
                        ),
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showCompleteOrderModal(
    BuildContext context,
    WidgetRef ref,
    String orderId,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, scrollController) {
            return _OrderCompletionContent(
              scrollController: scrollController,
              onConfirm: () async {
                try {
                  await _markOrderAsCompleted(ref, context);
                  if (context.mounted) {
                    context.pop();
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Container(
                            height: 100,
                            width: 100,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.shell300,
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                "assets/icons/confetti.svg",
                                width: 50,
                              ),
                            ),
                          ),
                          content: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SectionHeader("Well done!"),
                              SectionHeader("You've completed this order."),
                            ],
                          ),
                          actions: [
                            CustomButton(
                              title: "Thanks",
                              onPressed: () => context.pop(),
                            ),
                          ],
                        );
                      },
                    );
                  }
                } catch (_) {
                  rethrow;
                }
              },
              onCancel: () async {
                try {
                  await ref.read(cancelOrderProvider(orderId).future);
                  if (context.mounted) {
                    ref.invalidate(fisherOffersProvider);
                    context.pop();
                  }
                } catch (e) {
                  if (context.mounted) {
                    if (context.mounted) {
                      showDialog(
                        context: context,
                        builder: (context) => ErrorDialog(
                          title: "Cancellation Failed",
                          message: "Failed to cancel: $e",
                        ),
                      );
                    }
                  }
                }
              },
            );
          },
        );
      },
    );
  }
}

class _OrderCompletionContent extends StatefulWidget {
  const _OrderCompletionContent({
    required this.scrollController,
    required this.onConfirm,
    required this.onCancel,
  });

  final ScrollController scrollController;
  final Future<void> Function() onConfirm;
  final Future<void> Function() onCancel;

  @override
  State<_OrderCompletionContent> createState() =>
      _OrderCompletionContentState();
}

class _OrderCompletionContentState extends State<_OrderCompletionContent> {
  bool _isLoading = false;
  bool _isCancelling = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: widget.scrollController,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
              loading: _isLoading,
              disabled: _isCancelling,
              onPressed: () async {
                if (_isLoading || _isCancelling) return;
                setState(() => _isLoading = true);
                try {
                  await widget.onConfirm();
                } finally {
                  if (mounted) {
                    setState(() => _isLoading = false);
                  }
                }
              },
              icon: Icons.check,
            ),
            const SizedBox(height: 8),
            CustomButton(
              title: "Cancel",
              loading: _isCancelling,
              disabled: _isLoading,
              onPressed: () async {
                if (_isLoading || _isCancelling) return;
                setState(() => _isCancelling = true);
                try {
                  await widget.onCancel();
                } finally {
                  if (mounted) {
                    setState(() => _isCancelling = false);
                  }
                }
              },
              bordered: true,
              cancel: true,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
