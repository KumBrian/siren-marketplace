import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/bloc/cubits/orders_filter_cubit/orders_filter_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/orders_filter_cubit/orders_filter_state.dart';
import 'package:siren_marketplace/components/buyer_offer_card.dart';
import 'package:siren_marketplace/components/custom_button.dart';
import 'package:siren_marketplace/components/filter_button.dart';
import 'package:siren_marketplace/components/message_card.dart';
import 'package:siren_marketplace/constants/constants.dart';
import 'package:siren_marketplace/constants/types.dart';
import 'package:siren_marketplace/data/messages_data.dart';
import 'package:siren_marketplace/data/offer_data.dart';

class BuyerNotificationsScreen extends StatefulWidget {
  const BuyerNotificationsScreen({super.key});

  @override
  State<BuyerNotificationsScreen> createState() =>
      _BuyerNotificationsScreenState();
}

class _BuyerNotificationsScreenState extends State<BuyerNotificationsScreen> {
  final List<BuyerOffer> offers = mockOffers;
  final List<ConversationPreview> messages = mockMessages;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                showDragHandle: true,
                builder: (context) {
                  return BlocBuilder<OrdersFilterCubit, OrdersFilterState>(
                    builder: (context, state) {
                      final cubit = context.read<OrdersFilterCubit>();

                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 12,
                          children: [
                            const Text(
                              "Filter by",
                              style: TextStyle(fontSize: 12),
                            ),
                            const Text("Status"),
                            Text(
                              "Select all that apply",
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textGray,
                              ),
                            ),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                FilterButton(
                                  title: "Pending",
                                  color: AppColors.shellOrange,
                                  isSelected: state.selectedStatuses.contains(
                                    OfferStatus.pending,
                                  ),
                                  onPressed: () =>
                                      cubit.toggleStatus(OfferStatus.pending),
                                ),
                                FilterButton(
                                  title: "Accepted",
                                  color: AppColors.blue400,
                                  isSelected: state.selectedStatuses.contains(
                                    OfferStatus.accepted,
                                  ),
                                  onPressed: () =>
                                      cubit.toggleStatus(OfferStatus.accepted),
                                ),
                                FilterButton(
                                  title: "Completed",
                                  color: AppColors.textGray,
                                  isSelected: state.selectedStatuses.contains(
                                    OfferStatus.completed,
                                  ),
                                  onPressed: () =>
                                      cubit.toggleStatus(OfferStatus.completed),
                                ),
                                FilterButton(
                                  title: "Rejected",
                                  color: AppColors.fail500,
                                  isSelected: state.selectedStatuses.contains(
                                    OfferStatus.rejected,
                                  ),
                                  onPressed: () =>
                                      cubit.toggleStatus(OfferStatus.rejected),
                                ),
                              ],
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,

                              children: [
                                TextButton(
                                  onPressed: () {
                                    cubit.clear();
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    "Reset All",
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                                CustomButton(
                                  title: "Apply Filters",
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
            icon: Icon(Icons.filter_alt_outlined),
          ),
        ],
        title: Text(
          "Notifications",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textBlue,
            fontSize: 24,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      TabBar(
                        dividerHeight: 0,
                        indicatorSize: TabBarIndicatorSize.tab,
                        tabs: [
                          Tab(text: "Offers"),
                          Tab(text: "Messages"),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          physics: const BouncingScrollPhysics(),
                          children: [
                            SingleChildScrollView(
                              padding: EdgeInsets.only(
                                bottom: 80,
                                top: offers.isEmpty ? 32 : 0,
                              ),
                              child: offers.isEmpty
                                  ? Column(
                                      children: [
                                        SizedBox(
                                          height: 120,
                                          width: 120,
                                          child: Image.asset(
                                            "assets/images/no-offers.png",
                                          ),
                                        ),
                                        Text(
                                          "No offers received yet.",
                                          style: TextStyle(
                                            color: AppColors.textGray,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          "Buyers are reviewing your captures.",
                                          style: TextStyle(
                                            color: AppColors.textGray,
                                            fontWeight: FontWeight.w300,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      children: offers.map((offer) {
                                        return BuyerOfferCard(
                                          offer: offer,
                                          onPressed: () {
                                            context.push(
                                              "/buyer/offer-details/${offer.offerId}",
                                            );
                                          },
                                        );
                                      }).toList(),
                                    ),
                            ),

                            SingleChildScrollView(
                              padding: EdgeInsets.only(
                                bottom: 80,
                                top: messages.isEmpty ? 32 : 16,
                              ),
                              child: Column(
                                children: [
                                  SearchBar(
                                    hintText: "Search",
                                    scrollPadding: EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    textStyle: WidgetStateProperty.all(
                                      TextStyle(
                                        fontSize: 16,
                                        color: AppColors.textBlue,
                                      ),
                                    ),
                                    side: WidgetStateProperty.all(
                                      BorderSide(color: AppColors.gray200),
                                    ),
                                    leading: Icon(
                                      Icons.search,
                                      color: AppColors.textBlue,
                                    ),
                                    elevation: WidgetStateProperty.all(0),
                                  ),
                                  messages.isEmpty
                                      ? Column(
                                          children: [
                                            SizedBox(
                                              height: 120,
                                              width: 120,
                                              child: Image.asset(
                                                "assets/images/no-messages.png",
                                              ),
                                            ),
                                            Text(
                                              "You have no messages yet.",
                                              style: TextStyle(
                                                color: AppColors.textGray,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            Text(
                                              "You will receive messages shortly",
                                              style: TextStyle(
                                                color: AppColors.textGray,
                                                fontWeight: FontWeight.w300,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Column(
                                          children: messages.map((msg) {
                                            return MessageCard(
                                              messageId: msg.messageId,
                                              name: msg.clientName,
                                              time: msg.lastMessageTime
                                                  .toFormattedDate(),
                                              // format as needed
                                              message: msg.lastMessage,
                                              unreadCount: msg.unreadCount,
                                              avatarPath: msg.avatarPath,
                                              onPressed: () {},
                                            );
                                          }).toList(),
                                        ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
