import 'dart:convert'; // Required for JSON decoding

import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/models/catch.dart';
import 'package:siren_marketplace/core/models/info_row.dart';
import 'package:siren_marketplace/core/models/offer.dart';
import 'package:siren_marketplace/core/models/order.dart';
import 'package:siren_marketplace/core/types/enum.dart';
import 'package:siren_marketplace/core/types/extensions.dart';
import 'package:siren_marketplace/core/utils/custom_icons.dart';
import 'package:siren_marketplace/core/utils/phone_launcher.dart';
import 'package:siren_marketplace/core/widgets/custom_button.dart';
import 'package:siren_marketplace/core/widgets/error_handling_circle_avatar.dart';
import 'package:siren_marketplace/core/widgets/info_table.dart';
import 'package:siren_marketplace/core/widgets/page_title.dart';
import 'package:siren_marketplace/core/widgets/rating_modal_content.dart';
import 'package:siren_marketplace/core/widgets/section_header.dart';
import 'package:siren_marketplace/features/buyer/logic/buyer_cubit/buyer_cubit.dart';
import 'package:siren_marketplace/features/fisher/data/models/fisher.dart';
import 'package:siren_marketplace/features/fisher/logic/offers_bloc/offers_bloc.dart';

extension IterableExtensions<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}
// ---

class BuyerOrderDetails extends StatefulWidget {
  const BuyerOrderDetails({super.key, required this.orderId});

  final String orderId;

  @override
  State<BuyerOrderDetails> createState() => _BuyerOrderDetailsState();
}

class _BuyerOrderDetailsState extends State<BuyerOrderDetails> {
  bool _hasMarkedAsViewed = false;

  void _markOfferAsViewed(Offer offer, Role role) {
    if (role == Role.buyer && offer.hasUpdateForBuyer && !_hasMarkedAsViewed) {
      context.read<OffersBloc>().add(MarkOfferAsViewed(offer, role));
      _hasMarkedAsViewed = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to BuyerCubit state for proper loading/error handling
    return BlocBuilder<BuyerCubit, BuyerState>(
      builder: (context, buyerState) {
        // 1. Handle Loading/Error States
        if (buyerState is BuyerLoading || buyerState is BuyerInitial) {
          return Scaffold(
            appBar: AppBar(leading: const BackButton()),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (buyerState is BuyerError) {
          return Scaffold(
            appBar: AppBar(leading: const BackButton()),
            body: Center(
              child: Text(
                'Error: ${buyerState.message}',
                style: const TextStyle(color: AppColors.fail500),
              ),
            ),
          );
        }

        // Ensure state is loaded
        final loadedState = buyerState as BuyerLoaded;

        // 2. Find the specific order from the buyer's list
        final Order? selectedOrder = loadedState.orders.firstWhereOrNull(
          (order) => order.id == widget.orderId,
        );

        // 3. Handle Order Not Found
        if (selectedOrder == null) {
          return Scaffold(
            appBar: AppBar(
              leading: const BackButton(),
              title: const Text("Order Details"),
            ),
            body: const Center(
              child: Text(
                "Order not found in your list.",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        // 4. Extract required objects
        final order = selectedOrder;
        // Decode the Catch/Product details from the JSON snapshot
        final Catch catchSnapshot = Catch.fromMap(
          jsonDecode(order.catchSnapshotJson),
        );
        final Fisher fisher = order.fisher;
        final Offer offer = order.offer;

        _markOfferAsViewed(offer, Role.buyer);

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
                      // Using offer date for creation date
                      offer.dateCreated.toFormattedDate(),
                      style: TextStyle(fontSize: 12, color: AppColors.gray650),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Use catchSnapshot.images
                        final providers = catchSnapshot.images
                            .map<ImageProvider>((img) {
                              return img.contains("http")
                                  ? NetworkImage(img)
                                  : AssetImage(img);
                            })
                            .toList();

                        final multiImageProvider = MultiImageProvider(
                          providers,
                        );

                        // Show image viewer
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
                        child: catchSnapshot.images.first.contains("http")
                            ? Image.network(
                                catchSnapshot.images.first,
                                // Use catchSnapshot.images
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Image.asset(
                                      "assets/images/shrimp.jpg",
                                      height: 60,
                                      width: 60,
                                    ),
                              )
                            : Image.asset(
                                catchSnapshot.images.first,
                                // Use catchSnapshot.images
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
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
                            catchSnapshot.name, // Use catchSnapshot.name
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: AppColors.textBlue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            // Added spacing property for Row
                            children: [
                              Text(
                                offer.status.name.capitalize(),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.getStatusColor(offer.status),
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
                                    offer.status, // Use offer status
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
                      // Using catchSnapshot properties
                      InfoRow(
                        label: "Market",
                        value: catchSnapshot.market.capitalize(),
                      ),
                      InfoRow(
                        label: "Species",
                        value: catchSnapshot.species.name.capitalize(),
                      ),
                      InfoRow(
                        label: "Size",
                        value: catchSnapshot.size.capitalize(),
                      ),

                      // From Offer
                      InfoRow(
                        label: "Weight",
                        value: "${offer.weight.toStringAsFixed(1)} Kg",
                      ),
                      InfoRow(
                        label: "Total Price",
                        value: "${offer.price.toStringAsFixed(0)} CFA",
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
                      context.push("/buyer/reviews/${offer.fisherId}");
                    },
                    borderRadius: BorderRadius.circular(16),
                    splashColor: AppColors.blue700.withValues(alpha: 0.1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ErrorHandlingCircleAvatar(
                            avatarUrl: fisher.avatarUrl,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fisher.name, // Use local fisher object
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
                                      fisher.rating.toStringAsFixed(1),
                                      // Use local fisher object
                                      style: const TextStyle(
                                        color: AppColors.textBlue,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                    Text(
                                      " (${fisher.reviewCount} Reviews)",
                                      // Use local fisher object
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
                if (offer.status == OfferStatus.rejected) ...[
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

                if (offer.status == OfferStatus.accepted ||
                    offer.status == OfferStatus.pending) ...[
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
                if (offer.status == OfferStatus.completed) ...[
                  const SizedBox(height: 16),

                  // 1. BUYER RATING STATUS (Has the Buyer rated the Fisher?)
                  if (order.hasRatedFisher == false)
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        title: "Rate the Fisher",
                        onPressed: () {
                          // FIX: Get the existing BuyerCubit instance
                          final buyerCubit = context.read<BuyerCubit>();

                          // Show modal to rate the Fisher
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.white,
                            useSafeArea: true,
                            showDragHandle: true,
                            builder: (context) {
                              // FIX: Provide the BuyerCubit to the modal's new context
                              return BlocProvider.value(
                                value: buyerCubit,
                                child: RatingModalContent(
                                  orderId: selectedOrder.id,
                                  raterId: loadedState.buyer.id,
                                  ratedUserId: fisher.id,
                                  ratedUserName: fisher.name,
                                  onSubmitRating: buyerCubit.submitRating,
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
                            "You rated the Fisher ${order.fisherRatingValue!.toStringAsFixed(1)} stars.",
                            style: const TextStyle(
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
                          icon: order.hasRatedBuyer
                              ? HugeIcons.strokeRoundedCheckmarkBadge01
                              : HugeIcons.strokeRoundedClock01,
                          color: order.hasRatedBuyer
                              ? AppColors.success500
                              : AppColors.shellOrange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          order.hasRatedBuyer
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
