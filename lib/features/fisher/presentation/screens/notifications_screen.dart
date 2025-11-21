import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/bloc/cubits/catch_filter_cubit/catch_filter_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/catch_filter_cubit/catch_filter_state.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/widgets/filter_button.dart';
import 'package:siren_marketplace/core/widgets/message_card.dart';
import 'package:siren_marketplace/core/widgets/page_title.dart';
import 'package:siren_marketplace/features/chat/data/models/conversation_preview.dart';
import 'package:siren_marketplace/features/chat/logic/conversations_bloc/conversations_bloc.dart';
import 'package:siren_marketplace/features/fisher/presentation/widgets/offer_card.dart';
import 'package:siren_marketplace/new_features/fisher/presentation/cubits/offer_list/offer_list_cubit.dart';
import 'package:siren_marketplace/new_features/fisher/presentation/cubits/offer_list/offer_list_state.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key, required this.fisherId});

  final String fisherId;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with TickerProviderStateMixin {
  Widget _buildOffersTab(BuildContext context, CatchFilterState filterState) {
    return BlocBuilder<OfferListCubit, OfferListState>(
      builder: (context, offersState) {
        if (offersState is OfferListLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final allOffers = offersState is OfferListLoaded
            ? offersState.offers
            : [];

        // 1. Apply Filtering Logic
        final filteredOffers = allOffers.where((offer) {
          if (filterState.activeStatuses.isEmpty) {
            return true;
          }
          return filterState.activeStatuses.contains(offer.status.displayName);
        }).toList();

        // 2. Apply Sorting Logic
        filteredOffers.sort((a, b) {
          final dateA = a.dateCreated;
          final dateB = b.dateCreated;

          if (filterState.activeSortBy == "ascending") {
            return dateA.compareTo(dateB);
          } else {
            return dateB.compareTo(dateA);
          }
        });

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            children: [
              // 3. Display offers or placeholder
              if (filteredOffers.isEmpty)
                Column(
                  children: [
                    const SizedBox(height: 32),
                    SizedBox(
                      height: 120,
                      width: 120,
                      child: Image.asset("assets/images/no-offers.png"),
                    ),
                    const Text(
                      "No offers found.",
                      style: TextStyle(
                        color: AppColors.textGray,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const Text(
                      "Try adjusting your filters or wait for new bids.",
                      style: TextStyle(
                        color: AppColors.textGray,
                        fontWeight: FontWeight.w300,
                        fontSize: 12,
                      ),
                    ),
                    if (offersState is OfferListError)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          "Error loading offers: ${offersState.message}",
                          style: const TextStyle(
                            color: AppColors.fail500,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                )
              else
                ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: filteredOffers.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final offer = filteredOffers[index];

                    // TODO: Load buyer data from repository
                    // For now, using placeholder values
                    final clientName = 'Buyer ${offer.buyerId.substring(0, 8)}';
                    final clientRating = 0.0;

                    return OfferCard(
                      offer: offer,
                      clientName: clientName,
                      clientRating: clientRating,
                      onPressed: () {
                        context.push("/fisher/offer-details/${offer.id}");
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

  Widget _buildMessagesTab(BuildContext context) {
    return BlocBuilder<ConversationsBloc, ConversationsState>(
      builder: (context, state) {
        if (state is ConversationsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ConversationsError) {
          return Center(
            child: Text(
              "Error loading messages: ${state.message}",
              style: const TextStyle(color: AppColors.fail500),
            ),
          );
        }

        final List<ConversationPreview> conversations =
            state is ConversationsLoaded ? state.conversations : [];

        if (conversations.isEmpty) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 120,
                width: 120,
                child: Image.asset("assets/images/no-messages.png"),
              ),
              const Text(
                "No messages yet.",
                style: TextStyle(
                  color: AppColors.textGray,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const Text(
                "Start a conversation with a buyer.",
                style: TextStyle(
                  color: AppColors.textGray,
                  fontWeight: FontWeight.w300,
                  fontSize: 12,
                ),
              ),
            ],
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: conversations.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final conversation = conversations[index];

            // Determine other user ID based on current user
            final otherUserId = conversation.buyerId != widget.fisherId
                ? conversation.buyerId
                : conversation.fisherId;

            return MessageCard(
              messageId: conversation.id,
              name: conversation.contactName,
              time: conversation.lastMessageTime,
              message: conversation.lastMessage,
              unreadCount: conversation.unreadCount,
              avatarPath: conversation.contactAvatarPath,
              onPressed: () {
                context.push(
                  "/fisher/chat",
                  extra: {
                    'conversationId': conversation.id,
                    'otherUserId': otherUserId,
                    'otherUserName': conversation.contactName,
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const PageTitle(title: "Notifications"),
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: TabBar(
            labelColor: AppColors.textBlue,
            unselectedLabelColor: AppColors.textGray,
            indicatorColor: AppColors.blue700,
            tabs: const [
              Tab(text: "Offers"),
              Tab(text: "Messages"),
            ],
          ),
        ),
        body: BlocBuilder<CatchFilterCubit, CatchFilterState>(
          builder: (context, filterState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Filter buttons (only show on Offers tab)
                  Row(
                    children: [
                      Expanded(
                        child: FilterButton(
                          title: "Status",
                          isSelected: filterState.activeStatuses.isNotEmpty,
                          onPressed: () {
                            // Show status filter dialog
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilterButton(
                          title: filterState.activeSortBy == "ascending"
                              ? "Oldest First"
                              : "Newest First",
                          isSelected: false,
                          onPressed: () {
                            // TODO: Implement sort toggle
                            // context.read<CatchFilterCubit>().toggleSortBy();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tab content
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildOffersTab(context, filterState),
                        _buildMessagesTab(context),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
