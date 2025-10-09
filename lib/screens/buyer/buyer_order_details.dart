import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/bloc/cubits/buyer_cubit/buyer_cubit.dart';
import 'package:siren_marketplace/components/custom_button.dart';
import 'package:siren_marketplace/components/info_table.dart';
import 'package:siren_marketplace/constants/constants.dart';
import 'package:siren_marketplace/constants/types.dart';
// REMOVED: import 'package:siren_marketplace/data/order_data.dart';

// --- Helper Extension (For safe retrieval) ---
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
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BuyerCubit, Buyer?>(
      builder: (context, buyerState) {
        // 1. Handle Loading/Null State
        if (buyerState == null) {
          return Scaffold(
            appBar: AppBar(leading: const BackButton()),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Find the specific order from the buyer's list
        final Order? selectedOrder = buyerState.orders.firstWhereOrNull(
          (order) => order.orderId == widget.orderId,
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
                "Order not found.",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        // The simplified Order structure is used here
        final order = selectedOrder;
        final product = order.product;

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
                      "Order #${order.orderId}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: AppColors.textBlue,
                      ),
                    ),
                    Text(
                      // Using offer date for creation date
                      order.offer.dateCreated.toFormattedDate(),
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
                        final providers = product.images.map<ImageProvider>((
                          img,
                        ) {
                          return NetworkImage(img);
                        }).toList();

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
                        child: Image.network(
                          product.images.first,
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
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white),
                                  color: AppColors.getStatusColor(
                                    order.offer.status, // Use offer status
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                order.offer.status.name.capitalize(),
                                // Use offer status
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.getStatusColor(
                                    order.offer.status,
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

                InfoTable(
                  rows: [
                    InfoRow(label: "Market", value: product.market),
                    InfoRow(label: "Species", value: product.species.name),
                    InfoRow(label: "Size", value: product.averageSize),
                    // From Product
                    InfoRow(
                      label: "Weight",
                      value: "${order.offer.weight.toInt()} Kg",
                    ),
                    // From Offer
                    InfoRow(
                      label: "Total Price",
                      value: "${order.offer.price.toInt()} CFA", // From Offer
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Fisher Details (now accessed via the non-nullable order.fisher)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(order.fisher.avatarUrl),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.fisher.name,
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
                                order.fisher.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: AppColors.textBlue,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              Text(
                                " (${order.fisher.reviewCount} Reviews)",
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

                // Action Buttons (status now comes from the offer)
                order.offer.status == OfferStatus.completed
                    ? Container()
                    : Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              title: "Message",
                              onPressed: () {},
                              icon: Icons.chat_bubble_outline_rounded,
                              bordered: true,
                            ),
                          ),
                          const SizedBox(width: 8),
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

                // Final Action Button (status now comes from the offer)
                order.offer.status == OfferStatus.completed
                    ? CustomButton(
                        title: "Rate the fisher",
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 32,
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
                                    const SizedBox(height: 16),

                                    const TextField(
                                      maxLines: 5,
                                      decoration: InputDecoration(
                                        hintText: "Write a review",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(16),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),

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
                      )
                    : CustomButton(
                        title: "Mark as Completed",
                        onPressed: () {},
                      ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}
