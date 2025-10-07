import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/components/custom_button.dart';
import 'package:siren_marketplace/components/info_table.dart';
import 'package:siren_marketplace/constants/constants.dart';
import 'package:siren_marketplace/constants/types.dart';
import 'package:siren_marketplace/data/order_data.dart';

class BuyerOrderDetails extends StatefulWidget {
  const BuyerOrderDetails({super.key, required this.orderId});

  final String orderId;

  @override
  State<BuyerOrderDetails> createState() => _BuyerOrderDetailsState();
}

class _BuyerOrderDetailsState extends State<BuyerOrderDetails> {
  late final Order selectedOrder;

  @override
  void initState() {
    super.initState();
    selectedOrder = sampleOrders.firstWhere(
      (order) => order.orderId == widget.orderId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text(
          "Order Details",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textBlue,
            fontSize: 24,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,

              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Order #${selectedOrder.orderId}",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppColors.textBlue,
                  ),
                ),
                Text(
                  selectedOrder.dateCreated.toFormattedDate(),
                  style: TextStyle(fontSize: 12, color: AppColors.gray650),
                ),
              ],
            ),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                GestureDetector(
                  onTap: () {
                    final providers = selectedOrder.images.map<ImageProvider>((
                      img,
                    ) {
                      return NetworkImage(img);
                    }).toList();

                    final multiImageProvider = MultiImageProvider(providers);

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

                    // round corners
                    child: Image.network(
                      selectedOrder.images.first,
                      width: 60,
                      height: 60,

                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 8,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        selectedOrder.productName,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: AppColors.textBlue,
                        ),
                      ),
                      Row(
                        spacing: 8,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white),
                              color: AppColors.getStatusColor(
                                selectedOrder.status,
                              ),
                            ),
                          ),
                          // Icon(Icons.person, color: AppColors.white100, size: 60),
                          Text(
                            selectedOrder.status.name.capitalize(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.getStatusColor(
                                selectedOrder.status,
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

            InfoTable(
              rows: [
                InfoRow(label: "Market", value: selectedOrder.market),
                InfoRow(label: "Species", value: selectedOrder.species.name),
                InfoRow(label: "Size", value: selectedOrder.size),
                InfoRow(label: "Weight", value: "${selectedOrder.weight} Kg"),
                InfoRow(
                  label: "Total Price",
                  value: "${selectedOrder.price.toInt()} CFA",
                ),
              ],
            ),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(selectedOrder.fisher.avatarUrl),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      Text(
                        selectedOrder.fisher.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: AppColors.textBlue,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: AppColors.shellOrange,
                            size: 16,
                          ),
                          Text(
                            "${selectedOrder.fisher.rating}",
                            style: const TextStyle(
                              color: AppColors.textBlue,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          Text(
                            " (${selectedOrder.fisher.reviewCount} Reviews)",
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
            selectedOrder.status == OfferStatus.completed
                ? Container()
                : Row(
                    spacing: 8,
                    children: [
                      Expanded(
                        child: CustomButton(
                          title: "Message",
                          onPressed: () {},
                          icon: Icons.chat_bubble_outline_rounded,

                          bordered: true,
                        ),
                      ),
                      Expanded(
                        child: CustomButton(
                          title: "Call",
                          onPressed: () {},
                          icon: Icons.phone_outlined,
                        ),
                      ),
                    ],
                  ),
            Spacer(),
            selectedOrder.status == OfferStatus.completed
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
                              spacing: 16,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: context.pop,
                                      icon: Icon(Icons.close),
                                    ),
                                    Text(
                                      "Give a Review",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 32,
                                        color: AppColors.textBlue,
                                      ),
                                    ),
                                  ],
                                ),

                                Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    spacing: 4,
                                    children: List.generate(5, (index) {
                                      return Icon(
                                        Icons.star,
                                        size: 32,
                                        color: AppColors.shellOrange,
                                      );
                                    }),
                                  ),
                                ),
                                TextField(
                                  maxLines: 5,
                                  decoration: InputDecoration(
                                    hintText: "Write a review",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
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
                : CustomButton(title: "Mark as Completed", onPressed: () {}),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
