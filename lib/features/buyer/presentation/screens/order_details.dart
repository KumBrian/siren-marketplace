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
import 'package:siren_marketplace/core/widgets/custom_button.dart';
import 'package:siren_marketplace/core/widgets/info_table.dart';
import 'package:siren_marketplace/core/widgets/section_header.dart';
import 'package:siren_marketplace/features/buyer/logic/buyer_cubit/buyer_cubit.dart';
import 'package:siren_marketplace/features/fisher/data/models/fisher.dart';

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
  // ⚠️ Assuming Order's ID property is 'id' not 'orderId' based on typical Flutter models
  // The old code used `order.orderId`, which I will keep for consistency.

  @override
  Widget build(BuildContext context) {
    // 🆕 Listen to BuyerCubit state for proper loading/error handling
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
          (order) => order.id == widget.orderId, // ⚠️ Changed to order.id
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
        // 🆕 Decode the Catch/Product details from the JSON snapshot
        // We assume the BLoC hasn't done this yet, so we do it locally for the view.
        final Catch catchSnapshot = Catch.fromMap(
          jsonDecode(order.catchSnapshotJson),
        );
        final Fisher fisher =
            order.fisher; // 🆕 Assume Fisher is assembled by BLoC
        final Offer offer = order.offer;

        return Scaffold(
          appBar: AppBar(
            leading: BackButton(onPressed: () => context.pop()),
            title: const Text(
              "Order Details",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textBlue,
                fontSize: 24,
              ),
            ),
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
                      "Order #${order.id}", // ⚠️ Changed to order.id
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
                        // 🆕 Use catchSnapshot.images
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
                          backgroundColor: Colors.black.withValues(alpha: .4),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: catchSnapshot.images.first.contains("http")
                            ? Image.network(
                                catchSnapshot.images.first,
                                // 🆕 Use catchSnapshot.images
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                catchSnapshot.images.first,
                                // 🆕 Use catchSnapshot.images
                                width: 60,
                                height: 60,
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
                            catchSnapshot.name, // 🆕 Use catchSnapshot.name
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: AppColors.textBlue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 4,
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

                SectionHeader("Seller"),
                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.gray200),
                  ),
                  child: InfoTable(
                    rows: [
                      // 🆕 Using catchSnapshot properties
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

                // Fisher Details
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: fisher.avatarUrl.contains("http")
                          ? NetworkImage(fisher.avatarUrl)
                          : AssetImage(
                              fisher.avatarUrl,
                            ), // 🆕 Use local fisher object
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fisher.name, // 🆕 Use local fisher object
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
                                // 🆕 Use local fisher object
                                style: const TextStyle(
                                  color: AppColors.textBlue,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              Text(
                                " (${fisher.reviewCount} Reviews)",
                                // 🆕 Use local fisher object
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
                const SizedBox(height: 16),

                // --- ACTION BUTTONS SECTION ---
                if (offer.status == OfferStatus.rejected) ...[
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      title: "Marketplace",
                      onPressed: () {},
                      icon: Icons.storefront,
                      bordered: true,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      title: "Make New Offer",
                      onPressed: () {},
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
                      onPressed: () {},
                      hugeIcon: HugeIcons.strokeRoundedCall02,
                      bordered: true,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      title: "Message Seller",
                      onPressed: () {},
                      icon: CustomIcons.chatbubble,
                    ),
                  ),
                ],

                if (offer.status == OfferStatus.completed) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      title: "Rate the fisher",
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                          ),
                          builder: (context) {
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: MediaQuery.of(
                                  context,
                                ).viewInsets.bottom,
                                left: 16,
                                right: 16,
                                top: 24,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: context.pop,
                                        icon: const Icon(Icons.close),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        "Give a Review",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24,
                                          color: AppColors.textBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: List.generate(5, (index) {
                                        return const Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 4.0,
                                          ),
                                          child: Icon(
                                            Icons.star,
                                            size: 32,
                                            color: AppColors.shellOrange,
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  const TextField(
                                    maxLines: 4,
                                    decoration: InputDecoration(
                                      hintText: "Write a review...",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(16),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: CustomButton(
                                      title: "Submit Review",
                                      onPressed: () {},
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            );
                          },
                        );
                      },
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
