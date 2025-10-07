import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/components/custom_button.dart';
import 'package:siren_marketplace/components/info_table.dart';
import 'package:siren_marketplace/constants/constants.dart';
import 'package:siren_marketplace/constants/types.dart';
import 'package:siren_marketplace/data/catch_data.dart';

class OrderDetails extends StatefulWidget {
  const OrderDetails({super.key, required this.orderId});

  final String orderId;

  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  late final FisherOffer selectedOffer;
  final FocusNode _buttonFocusNode = FocusNode(debugLabel: 'Repost Menu');

  @override
  void initState() {
    super.initState();
    selectedOffer = sampleCatches
        .expand((c) => c.offers)
        .firstWhere((offer) => offer.offerId == widget.orderId);
  }

  @override
  void dispose() {
    _buttonFocusNode.dispose();
    super.dispose();
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
        actions: [
          MenuAnchor(
            style: MenuStyle(
              backgroundColor: WidgetStateProperty.all(AppColors.white100),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                    showDragHandle: true,
                    builder: (context) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          children: [
                            Text(
                              "Why did this transaction not go through?",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textBlue,
                              ),
                            ),
                            ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: 3,
                              itemBuilder: (context, index) {
                                final isChecked = index % 2 == 0;

                                return InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () {},
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ), // minimal spacing
                                    child: Row(
                                      children: [
                                        Checkbox(
                                          value: isChecked,
                                          onChanged: (checked) {},
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          splashRadius: 5,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                        Expanded(
                                          child: Text(
                                            "Reason ${index + 1}",
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
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
                  "Order #${selectedOffer.offerId}",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppColors.textBlue,
                  ),
                ),
                Text(
                  selectedOffer.dateCreated.toFormattedDate(),
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
                    // Show image viewer
                    showImageViewer(
                      context,
                      AssetImage("assets/images/barracuda.jpg"),
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
                    child: Image.asset(
                      "assets/images/barracuda.jpg",
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
                        selectedOffer.name,
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
                              color: AppColors.blue600,
                            ),
                          ),
                          // Icon(Icons.person, color: AppColors.white100, size: 60),
                          Text(
                            selectedOffer.status.name.capitalize(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.blue600,
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
                InfoRow(label: "Market", value: "Yopwe"),
                InfoRow(label: "Species", value: "Pink Shrimp"),
                InfoRow(label: "Size", value: "Large"),
                InfoRow(label: "Weight", value: "80 Kg"),
                InfoRow(label: "Total Price", value: "10,600 CFA"),
              ],
            ),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage("assets/images/user-profile.png"),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      Text(
                        selectedOffer.name,
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
                            "${selectedOffer.fisherRating}",
                            style: const TextStyle(
                              color: AppColors.textBlue,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          const Text(
                            " (128 Reviews)",
                            style: TextStyle(
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
            selectedOffer.status == OfferStatus.completed
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
            selectedOffer.status == OfferStatus.completed
                ? CustomButton(
                    title: "Rate the buyer",
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
