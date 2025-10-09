import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
// --- NEW IMPORTS ---
import 'package:siren_marketplace/bloc/cubits/buyer_cubit/buyer_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/orders_filter_cubit/orders_filter_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/orders_filter_cubit/orders_filter_state.dart';
import 'package:siren_marketplace/components/buyer_offer_card.dart';
import 'package:siren_marketplace/components/custom_button.dart';
import 'package:siren_marketplace/components/filter_button.dart';
import 'package:siren_marketplace/components/message_card.dart';
import 'package:siren_marketplace/constants/constants.dart';
import 'package:siren_marketplace/constants/types.dart';

// REMOVE: import 'package:siren_marketplace/data/messages_data.dart';
// REMOVE: import 'package:siren_marketplace/data/offer_data.dart';

class BuyerNotificationsScreen extends StatefulWidget {
  const BuyerNotificationsScreen({super.key});

  @override
  State<BuyerNotificationsScreen> createState() =>
      _BuyerNotificationsScreenState();
}

class _BuyerNotificationsScreenState extends State<BuyerNotificationsScreen> {
  // 1. UPDATE: Change type from BuyerOffer to Offer
  List<Offer> _applyOfferFilters(List<Offer> offers, OrdersFilterState state) {
    if (state.selectedStatuses.isEmpty) {
      return offers;
    }
    return offers.where((offer) {
      return state.selectedStatuses.contains(offer.status);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BuyerCubit, Buyer?>(
      builder: (context, buyerState) {
        if (buyerState == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. UPDATE: `offers` on Buyer is now a List<Offer>
        final allOffers = buyerState.madeOffers;
        final allMessages = buyerState.messages;

        return Scaffold(
          appBar: AppBar(
            leading: const BackButton(),
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
                              // Replaced spacing: 12
                              children: [
                                const Text(
                                  "Filter by",
                                  style: TextStyle(fontSize: 12),
                                ),
                                const SizedBox(height: 12),
                                const Text("Status"),
                                const SizedBox(height: 12),
                                Text(
                                  "Select all that apply",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textGray,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    FilterButton(
                                      title: "Pending",
                                      color: AppColors.shellOrange,
                                      isSelected: state.selectedStatuses
                                          .contains(OfferStatus.pending),
                                      onPressed: () => cubit.toggleStatus(
                                        OfferStatus.pending,
                                      ),
                                    ),
                                    FilterButton(
                                      title: "Accepted",
                                      color: AppColors.blue400,
                                      isSelected: state.selectedStatuses
                                          .contains(OfferStatus.accepted),
                                      onPressed: () => cubit.toggleStatus(
                                        OfferStatus.accepted,
                                      ),
                                    ),
                                    FilterButton(
                                      title: "Completed",
                                      color: AppColors.textGray,
                                      isSelected: state.selectedStatuses
                                          .contains(OfferStatus.completed),
                                      onPressed: () => cubit.toggleStatus(
                                        OfferStatus.completed,
                                      ),
                                    ),
                                    FilterButton(
                                      title: "Rejected",
                                      color: AppColors.fail500,
                                      isSelected: state.selectedStatuses
                                          .contains(OfferStatus.rejected),
                                      onPressed: () => cubit.toggleStatus(
                                        OfferStatus.rejected,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        cubit.clear();
                                        // Use context.pop() for navigation in the modal context
                                        context.pop();
                                      },
                                      child: const Text(
                                        "Reset All",
                                        style: TextStyle(
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                    CustomButton(
                                      title: "Apply Filters",
                                      // Use context.pop() for navigation in the modal context
                                      onPressed: () => context.pop(),
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
                icon: const Icon(Icons.filter_alt_outlined),
              ),
            ],
            title: const Text(
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
                          const TabBar(
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
                                // --- Offers Tab ---
                                BlocBuilder<
                                  OrdersFilterCubit,
                                  OrdersFilterState
                                >(
                                  builder: (context, filterState) {
                                    final filteredOffers = _applyOfferFilters(
                                      allOffers,
                                      filterState,
                                    );

                                    return SingleChildScrollView(
                                      padding: EdgeInsets.only(
                                        bottom: 80,
                                        top: filteredOffers.isEmpty ? 32 : 0,
                                      ),
                                      child: filteredOffers.isEmpty
                                          ? Column(
                                              children: [
                                                SizedBox(
                                                  height: 120,
                                                  width: 120,
                                                  child: Image.asset(
                                                    "assets/images/no-offers.png",
                                                  ),
                                                ),
                                                const Text(
                                                  "No offers match your filters.",
                                                  style: TextStyle(
                                                    color: AppColors.textGray,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const Text(
                                                  "Try adjusting your filters.",
                                                  style: TextStyle(
                                                    color: AppColors.textGray,
                                                    fontWeight: FontWeight.w300,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Column(
                                              children: filteredOffers.map((
                                                offer,
                                              ) {
                                                // 3. UPDATE: BuyerOfferCard should now accept the unified Offer type
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
                                    );
                                  },
                                ),

                                // --- Messages Tab (No type changes needed here) ---
                                SingleChildScrollView(
                                  padding: EdgeInsets.only(
                                    bottom: 80,
                                    top: allMessages.isEmpty ? 32 : 16,
                                  ),
                                  child: Column(
                                    children: [
                                      SearchBar(
                                        hintText: "Search",
                                        scrollPadding:
                                            const EdgeInsets.symmetric(
                                              vertical: 8,
                                            ),
                                        textStyle: WidgetStateProperty.all(
                                          const TextStyle(
                                            fontSize: 16,
                                            color: AppColors.textBlue,
                                          ),
                                        ),
                                        side: WidgetStateProperty.all(
                                          const BorderSide(
                                            color: AppColors.gray200,
                                          ),
                                        ),
                                        leading: const Icon(
                                          Icons.search,
                                          color: AppColors.textBlue,
                                        ),
                                        elevation: WidgetStateProperty.all(0),
                                      ),
                                      allMessages.isEmpty
                                          ? Column(
                                              children: [
                                                SizedBox(
                                                  height: 120,
                                                  width: 120,
                                                  child: Image.asset(
                                                    "assets/images/no-messages.png",
                                                  ),
                                                ),
                                                const Text(
                                                  "You have no messages yet.",
                                                  style: TextStyle(
                                                    color: AppColors.textGray,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const Text(
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
                                              children: allMessages.map((msg) {
                                                return MessageCard(
                                                  messageId: msg.messageId,
                                                  name: msg.clientName,
                                                  time: msg.lastMessageTime
                                                      .toFormattedDate(),
                                                  message: msg.lastMessage,
                                                  unreadCount: msg.unreadCount,
                                                  avatarPath: msg.avatarPath,
                                                  onPressed: () {
                                                    context.push(
                                                      "/buyer/messages/${msg.messageId}",
                                                    );
                                                  },
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
      },
    );
  }
}
