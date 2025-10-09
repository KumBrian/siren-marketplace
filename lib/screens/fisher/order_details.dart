import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/bloc/cubits/failed_transaction_cubit/failed_transaction_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/failed_transaction_cubit/failed_transaction_state.dart';
// --- NEW IMPORTS ---
import 'package:siren_marketplace/bloc/cubits/fisher_cubit/fisher_cubit.dart'; // Import the cubit
import 'package:siren_marketplace/components/custom_button.dart';
import 'package:siren_marketplace/components/info_table.dart';
import 'package:siren_marketplace/constants/constants.dart';
import 'package:siren_marketplace/constants/types.dart';

// REMOVE: import 'package:siren_marketplace/data/catch_data.dart';

// --- Helper Extension for finding element in Iterable (if not available in Dart 2.12+) ---
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

class OrderDetails extends StatefulWidget {
  const OrderDetails({super.key, required this.offerId});

  final String offerId;

  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  // Removed local state variables (_isLoading, orderDetails)
  final FocusNode _buttonFocusNode = FocusNode(debugLabel: 'Repost Menu');

  // Removed _fetchOrderDetails and its call in initState.
  // Data fetching will now be handled reactively by the BlocBuilder.

  @override
  void dispose() {
    _buttonFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FisherCubit, Fisher?>(
      builder: (context, fisherState) {
        // --- Data Loading/Error Handling ---
        if (fisherState == null) {
          // Assuming the FisherCubit should eventually load data
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Find the specific Order using the orderId from the loaded Fisher's orders
        final Offer? selectedOffer = fisherState.receivedOffers
            .firstWhereOrNull((o) => o.offerId == widget.offerId);

        // Handle case where the order was not found in the loaded data
        if (selectedOffer == null) {
          return Scaffold(
            appBar: AppBar(
              leading: const BackButton(),
              title: const Text("Order Details"),
            ),
            body: const Center(
              child: Text("Order not found in your sales records."),
            ),
          );
        }

        // --- Data Access (No changes needed, as Order fields are correct) ---
        final buyer = selectedOffer.clientName;
        // The Order status is determined by the Offer status inside the Order
        final offerStatus = selectedOffer.status;

        final order = fisherState.orders.firstWhereOrNull(
          (o) => o.offer.offerId == selectedOffer.offerId,
        );

        // Handle case where the order was not found in the loaded;

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
            actions: [
              MenuAnchor(
                style: MenuStyle(
                  backgroundColor: WidgetStateProperty.all(AppColors.white100),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  padding: WidgetStateProperty.all(EdgeInsets.zero),
                ),
                childFocusNode: _buttonFocusNode,
                alignmentOffset: Offset(-100, 0),
                builder: (_, MenuController controller, Widget? child) {
                  return IconButton(
                    focusNode: _buttonFocusNode,
                    onPressed: () {
                      if (controller.isOpen) {
                        controller.close();
                      } else {
                        controller.open();
                      }
                    },
                    icon: const Icon(Icons.more_vert),
                  );
                },
                menuChildren: [
                  MenuItemButton(
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all(
                        EdgeInsets.only(right: 32, left: 16),
                      ),
                    ),
                    leadingIcon: Icon(Icons.autorenew),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.white,
                        useSafeArea: true,
                        showDragHandle: true,
                        builder: (context) {
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
                                  bottom: MediaQuery.of(
                                    context,
                                  ).viewInsets.bottom,
                                ),
                                child: ListView(
                                  controller: scrollController,
                                  children: [
                                    Text(
                                      "Why did this transaction not go through?",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textBlue,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    BlocBuilder<
                                      FailedTransactionCubit,
                                      FailedTransactionState
                                    >(
                                      builder: (context, state) {
                                        final cubit = context
                                            .read<FailedTransactionCubit>();
                                        return ListView.builder(
                                          itemCount:
                                              kFailedTransactionReasons.length,
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          padding: EdgeInsets.zero,
                                          itemBuilder: (context, index) {
                                            final reason =
                                                kFailedTransactionReasons[index];
                                            final isSelected =
                                                state.selectedReason == reason;
                                            return InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              onTap: () =>
                                                  cubit.toggleReason(reason),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 4,
                                                    ),
                                                child: Row(
                                                  children: [
                                                    Checkbox(
                                                      value: isSelected,
                                                      onChanged: (_) => cubit
                                                          .toggleReason(reason),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              6,
                                                            ),
                                                      ),
                                                      visualDensity:
                                                          VisualDensity.compact,
                                                      splashRadius: 5,
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        reason,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
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
                                    Text(
                                      "Other reason? Specify",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textBlue,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextField(
                                      maxLines: 3,
                                      decoration: InputDecoration(
                                        hintText: "Enter the reason here...",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    CustomButton(
                                      title: "Confirm",
                                      onPressed: () {},
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                    child: Text("Repost"),
                  ),
                ],
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // --- Order ID and Date ---
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Order #${selectedOffer.offerId}", // Use Order ID
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: AppColors.textBlue,
                      ),
                    ),
                    Text(
                      // Use Order date
                      selectedOffer.dateCreated.toFormattedDate(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.gray650,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // --- Product/Catch Details ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        final imageUrl = selectedOffer.catchImages.isNotEmpty
                            ? selectedOffer.catchImages.first
                            : "assets/images/barracuda.jpg"; // Fallback asset

                        final ImageProvider imageProvider =
                            imageUrl.startsWith('http')
                            ? NetworkImage(imageUrl)
                            : const AssetImage("assets/images/barracuda.jpg")
                                  as ImageProvider;

                        showImageViewer(
                          context,
                          imageProvider,
                          swipeDismissible: true,
                          immersive: true,
                          useSafeArea: true,
                          doubleTapZoomable: true,
                          backgroundColor: Colors.black.withValues(alpha: 0.4),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          selectedOffer.catchImages.first,
                          // Use actual image URL
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset(
                                "assets/images/barracuda.jpg",
                                width: 60,
                                height: 60,
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
                            selectedOffer.catchName, // Use actual product name
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
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white),
                                  color: AppColors.getStatusColor(offerStatus),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                offerStatus.name.capitalize(),
                                // Use actual status
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.getStatusColor(offerStatus),
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

                // --- Info Table ---
                InfoTable(
                  rows: [
                    InfoRow(label: "Market", value: order?.product.market),
                    // Use Product market
                    InfoRow(
                      label: "Species",
                      value: order?.product.species.name,
                    ),
                    // Use Product species
                    InfoRow(label: "Size", value: order?.product.averageSize),
                    // Use Product size
                    InfoRow(
                      label: "Weight",
                      value: selectedOffer.weight.toInt(),
                      suffix: "Kg",
                    ),
                    // Use Offer weight
                    InfoRow(
                      label: "Total Price",
                      value: selectedOffer.price.toStringAsFixed(0),
                      suffix: "CFA", // Use Offer price
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // --- Buyer Details ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(selectedOffer.clientAvatar),
                      // Use actual buyer avatar
                      onBackgroundImageError: (exception, stackTrace) =>
                          const AssetImage(
                            "assets/images/user-profile.png",
                          ), // Fallback
                    ),
                    const SizedBox(width: 10), // Replaced spacing: 10
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            buyer, // Use buyer name
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
                                selectedOffer.clientRating.toStringAsFixed(1),
                                // Use buyer rating
                                style: const TextStyle(
                                  color: AppColors.textBlue,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              Text(
                                " (${selectedOffer.clientReviewCount} Reviews)",
                                // Use buyer review count
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

                // --- Action Buttons ---
                if (offerStatus != OfferStatus.completed)
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          title: "Message",
                          onPressed: () {
                            context.push("/fisher/chat");
                          },
                          icon: Icons.chat_bubble_outline_rounded,
                          bordered: true,
                        ),
                      ),
                      const SizedBox(width: 8), // Replaced spacing: 8
                      Expanded(
                        child: CustomButton(
                          title: "Call",
                          onPressed: () {},
                          icon: Icons.phone_outlined,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),

                // --- Primary Action ---
                if (offerStatus == OfferStatus.completed)
                  CustomButton(
                    title: "Rate the buyer",
                    onPressed: () {
                      // --- Rate Buyer Modal Logic (Unchanged) ---
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.white,
                        useSafeArea: true,
                        showDragHandle: true,
                        builder: (context) {
                          return DraggableScrollableSheet(
                            expand: false,
                            initialChildSize: 0.55,
                            minChildSize: 0.5,
                            maxChildSize: 0.95,
                            builder: (context, scrollController) {
                              return Padding(
                                padding: EdgeInsets.only(
                                  left: 16,
                                  right: 16,
                                  bottom: MediaQuery.of(
                                    context,
                                  ).viewInsets.bottom,
                                ),
                                child: ListView(
                                  controller: scrollController,
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
                                            fontSize: 32,
                                            color: AppColors.textBlue,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: List.generate(5, (index) {
                                          return const Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 2,
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
                                    const SizedBox(height: 16),
                                    TextField(
                                      maxLines: 5,
                                      onTapOutside: (e) {
                                        FocusScope.of(context).unfocus();
                                      },

                                      decoration: InputDecoration(
                                        hintText: "Write a review",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    CustomButton(
                                      title: "Submit Review",
                                      onPressed: () {},
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  )
                else
                  CustomButton(title: "Mark as Completed", onPressed: () {}),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}
