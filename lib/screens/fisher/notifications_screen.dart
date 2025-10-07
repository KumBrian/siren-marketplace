import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/bloc/cubits/catch_filter_cubit/catch_filter_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/catch_filter_cubit/catch_filter_state.dart';
import 'package:siren_marketplace/components/custom_button.dart';
import 'package:siren_marketplace/components/filter_button.dart';
import 'package:siren_marketplace/components/fisher_offer_card.dart';
import 'package:siren_marketplace/components/message_card.dart';
import 'package:siren_marketplace/constants/constants.dart';
import 'package:siren_marketplace/constants/types.dart';
import 'package:siren_marketplace/data/catch_data.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Catch> catches = sampleCatches;
  late Catch selectedCatch = sampleCatches[0];

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
                  return BlocBuilder<CatchFilterCubit, CatchFilterState>(
                    builder: (context, state) {
                      final cubit = context.read<CatchFilterCubit>();

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
                                    "Pending",
                                  ),
                                  onPressed: () =>
                                      cubit.toggleStatus("Pending"),
                                ),
                                FilterButton(
                                  title: "Accepted",
                                  color: AppColors.blue400,
                                  isSelected: state.selectedStatuses.contains(
                                    "Accepted",
                                  ),
                                  onPressed: () =>
                                      cubit.toggleStatus("Accepted"),
                                ),
                                FilterButton(
                                  title: "Completed",
                                  color: AppColors.textGray,
                                  isSelected: state.selectedStatuses.contains(
                                    "Completed",
                                  ),
                                  onPressed: () =>
                                      cubit.toggleStatus("Completed"),
                                ),
                                FilterButton(
                                  title: "Rejected",
                                  color: AppColors.fail500,
                                  isSelected: state.selectedStatuses.contains(
                                    "Rejected",
                                  ),
                                  onPressed: () =>
                                      cubit.toggleStatus("Rejected"),
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
                              padding: const EdgeInsets.only(
                                bottom: 80,
                                top: 16,
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
                                  selectedCatch.offers.isEmpty
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
                                          children: selectedCatch.offers.map((
                                            offer,
                                          ) {
                                            return FisherOfferCard(
                                              offer: offer,
                                              onPressed: () {
                                                context.push(
                                                  "/fisher/offer-details/${offer.offerId}",
                                                );
                                              },
                                            );
                                          }).toList(),
                                        ),
                                ],
                              ),
                            ),

                            SingleChildScrollView(
                              padding: const EdgeInsets.only(
                                bottom: 80,
                                top: 16,
                              ),
                              child: selectedCatch.messages.isEmpty
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
                                      children: selectedCatch.messages.map((
                                        msg,
                                      ) {
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
