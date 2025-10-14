import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/bloc/cubits/orders_filter_cubit/orders_filter_cubit.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/models/offer.dart';
import 'package:siren_marketplace/core/types/enum.dart';
import 'package:siren_marketplace/core/types/extensions.dart';
import 'package:siren_marketplace/core/widgets/custom_button.dart';
import 'package:siren_marketplace/core/widgets/filter_button.dart';
import 'package:siren_marketplace/core/widgets/message_card.dart';
import 'package:siren_marketplace/features/buyer/logic/buyer_cubit/buyer_cubit.dart';
import 'package:siren_marketplace/features/buyer/presentation/widgets/offer_card.dart';
import 'package:siren_marketplace/features/chat/data/models/conversation_preview.dart';
import 'package:siren_marketplace/features/chat/logic/conversations_bloc/conversations_bloc.dart';

class BuyerNotificationsScreen extends StatefulWidget {
  const BuyerNotificationsScreen({super.key});

  @override
  State<BuyerNotificationsScreen> createState() =>
      _BuyerNotificationsScreenState();
}

class _BuyerNotificationsScreenState extends State<BuyerNotificationsScreen> {
  List<Offer> _applyOfferFilters(List<Offer> offers, OrdersFilterState state) {
    if (state.selectedStatuses.isEmpty) {
      return offers;
    }
    return offers.where((offer) {
      return state.selectedStatuses.contains(offer.status);
    }).toList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final buyerCubit = context.read<BuyerCubit>();
    if (buyerCubit.state is BuyerLoaded) {
      final buyerId = (buyerCubit.state as BuyerLoaded).buyer.id;

      final conversationsBloc = context.read<ConversationsBloc>();
      // Use the correct event parameter name based on the seeder logic
      if (conversationsBloc.state is ConversationsInitial) {
        conversationsBloc.add(LoadConversations(buyerId: buyerId));
      }
    }
  }

  // ----------------------------------------------------------------------
  // 🎯 NEW: Extracted Messages Tab Build Method for clarity
  // ----------------------------------------------------------------------
  Widget _buildMessagesTab() {
    return BlocBuilder<ConversationsBloc, ConversationsState>(
      builder: (context, conversationState) {
        if (conversationState is ConversationsLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 64.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (conversationState is ConversationsError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 64.0),
              child: Text(
                'Error: ${conversationState.message}',
                style: const TextStyle(color: AppColors.fail500),
              ),
            ),
          );
        }

        final allMessages = (conversationState is ConversationsLoaded)
            ? conversationState.conversations
            : <ConversationPreview>[];

        return SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: 80,
            top: allMessages.isEmpty ? 32 : 16,
          ),
          child: Column(
            children: [
              // SearchBar definition
              const SearchBar(
                hintText: "Search",
                scrollPadding: EdgeInsets.symmetric(vertical: 8),
                textStyle: WidgetStatePropertyAll(
                  TextStyle(fontSize: 16, color: AppColors.textBlue),
                ),
                side: WidgetStatePropertyAll(
                  BorderSide(color: AppColors.gray200),
                ),
                leading: Icon(Icons.search, color: AppColors.textBlue),
                elevation: WidgetStatePropertyAll(0),
              ),

              const SizedBox(height: 8),

              // Check if allMessages is empty
              if (allMessages.isEmpty)
                Column(
                  children: [
                    SizedBox(
                      height: 120,
                      width: 120,
                      child: Image.asset("assets/images/no-messages.png"),
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
                      "You can start a chat after an offer is accepted.",
                      style: TextStyle(
                        color: AppColors.textGray,
                        fontWeight: FontWeight.w300,
                        fontSize: 12,
                      ),
                    ),
                  ],
                )
              // 🎯 FIX: Use ListView.separated for efficient list display
              else
                ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  // Prevent scrolling conflict
                  shrinkWrap: true,
                  itemCount: allMessages.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final msg = allMessages[index];
                    return MessageCard(
                      messageId: msg.id,
                      name: msg.contactName,
                      time: msg.lastMessageTime.toFormattedDate(),
                      message: msg.lastMessage,
                      unreadCount: msg.unreadCount,
                      avatarPath: msg.contactAvatarPath,
                      onPressed: () {
                        context.push("/buyer/messages/${msg.id}");
                      },
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BuyerCubit, BuyerState>(
      builder: (context, buyerState) {
        if (buyerState is BuyerLoading || buyerState is BuyerInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (buyerState is BuyerError) {
          return Scaffold(
            body: Center(
              child: Text('Error loading buyer data: ${buyerState.message}'),
            ),
          );
        }

        final loadedState = buyerState as BuyerLoaded;
        final allOffers = loadedState.buyer.madeOffers;

        return Scaffold(
          appBar: AppBar(
            leading: const BackButton(),
            actions: [
              // ... Filter button logic remains the same ...
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
                                    FilterButton(
                                      title: "Countered",
                                      color: AppColors.textBlue,
                                      isSelected: state.selectedStatuses
                                          .contains(OfferStatus.countered),
                                      onPressed: () => cubit.toggleStatus(
                                        OfferStatus.countered,
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
                                                return OfferCard(
                                                  offer: offer,
                                                  fisherRating:
                                                      offer.fisherRating,
                                                  fisherName: offer.fisherName,
                                                  onPressed: () {
                                                    context.push(
                                                      "/buyer/offer-details/${offer.id}",
                                                    );
                                                  },
                                                );
                                              }).toList(),
                                            ),
                                    );
                                  },
                                ),

                                // --- Messages Tab (Now uses extracted method) ---
                                _buildMessagesTab(),
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
