import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/bloc/cubits/catch_filter_cubit/catch_filter_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/catch_filter_cubit/catch_filter_state.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/domain/entities/offer.dart';
import 'package:siren_marketplace/core/domain/enums/offer_status.dart';
import 'package:siren_marketplace/core/types/extensions.dart';
import 'package:siren_marketplace/core/utils/custom_icons.dart';
import 'package:siren_marketplace/core/widgets/custom_button.dart';
import 'package:siren_marketplace/core/widgets/filter_button.dart';
import 'package:siren_marketplace/core/widgets/message_card.dart';
import 'package:siren_marketplace/core/widgets/page_title.dart';
import 'package:siren_marketplace/features/chat/data/models/conversation_preview.dart';
import 'package:siren_marketplace/features/chat/logic/conversations_bloc/conversations_bloc.dart';
import 'package:siren_marketplace/features/fisher/logic/offers_bloc/offers_cubit.dart';
import 'package:siren_marketplace/features/fisher/presentation/widgets/offer_card.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key, required this.fisherId});

  final String fisherId;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with TickerProviderStateMixin {
  Widget _buildOffersTab(BuildContext context, CatchFilterState filterState) {
    return BlocBuilder<OffersCubit, OffersState>(
      builder: (context, offersState) {
        if (offersState.loading && offersState.offers.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final List<Offer> allOffers = offersState.offers
            .where((offer) => offer.fisherId == widget.fisherId)
            .toList();

        // 1. Apply Filtering Logic
        final filteredOffers = allOffers.where((offer) {
          if (filterState.activeStatuses.isEmpty) {
            return true;
          }
          return filterState.activeStatuses.contains(
            offer.status.name.capitalize(),
          );
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
                    if (offersState.error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          "Error loading offers: ${offersState.error}",
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
                    return OfferCard(
                      offer: offer,
                      clientName: "Buyer", // TODO: Load buyer name
                      clientRating: 0.0, // TODO: Load buyer rating

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
      builder: (context, messagesState) {
        if (messagesState is ConversationsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final List<ConversationPreview> allMessages =
            messagesState is ConversationsLoaded
            ? messagesState.conversations
            : [];

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 80, top: 16),
          child: allMessages.isEmpty
              ? Column(
                  children: [
                    const SizedBox(height: 32),
                    SizedBox(
                      height: 120,
                      width: 120,
                      child: Image.asset("assets/images/no-messages.png"),
                    ),
                    const Text(
                      "You have no messages yet.",
                      style: TextStyle(
                        color: AppColors.textGray,
                        fontWeight: FontWeight.w300,
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
                    if (messagesState is ConversationsError)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          "Error loading messages: ${messagesState.message}",
                          style: const TextStyle(
                            color: AppColors.fail500,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                )
              : Column(
                  children: [
                    ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
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
                            context.push("/fisher/chat/${msg.id}");
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
  void initState() {
    super.initState();
    // Load offers for the current Fisher user
    context.read<OffersCubit>().loadForFisher(widget.fisherId);
    _tabController = TabController(length: 2, vsync: this);
  }

  late TabController _tabController;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CatchFilterCubit, CatchFilterState>(
      builder: (context, filterState) {
        return Scaffold(
          appBar: AppBar(
            leading: const BackButton(),
            actions: [
              BlocBuilder<CatchFilterCubit, CatchFilterState>(
                builder: (context, state) {
                  return IconButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        showDragHandle: true,
                        builder: (context) {
                          return BlocBuilder<
                            CatchFilterCubit,
                            CatchFilterState
                          >(
                            builder: (innerContext, innerState) {
                              final innerCubit = innerContext
                                  .read<CatchFilterCubit>();
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
                                      children: OfferStatus.values.map((
                                        status,
                                      ) {
                                        final title =
                                            status.name
                                                .substring(0, 1)
                                                .toUpperCase() +
                                            status.name.substring(1);

                                        return FilterButton(
                                          title: title,
                                          color: AppColors.getStatusColor(
                                            status,
                                          ),
                                          isSelected: innerState.pendingStatuses
                                              .contains(title),
                                          onPressed: () =>
                                              innerCubit.toggleStatus(title),
                                        );
                                      }).toList(),
                                    ),
                                    const Divider(),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            innerCubit.clearAllFilters();
                                            innerContext.pop();
                                          },
                                          child: const Text(
                                            "Reset All",
                                            style: TextStyle(
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                        CustomButton(
                                          title: "Apply Filters",
                                          onPressed: () {
                                            innerCubit.applyFilters();
                                            innerContext.pop();
                                          },
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
                    icon: state.activeStatuses.isEmpty
                        ? const Icon(CustomIcons.filter)
                        : Badge(
                            label: Text(state.activeStatuses.length.toString()),
                            child: const Icon(CustomIcons.filter),
                          ),
                  );
                },
              ),
            ],
            title: PageTitle(title: "Notifications"),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Expanded(
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        BlocBuilder<OffersCubit, OffersState>(
                          builder: (context, offersState) {
                            final offers = offersState.offers;
                            final offersWithUpdateCount = offers
                                .where((offer) => offer.hasUpdateForFisher)
                                .length;

                            return AnimatedBuilder(
                              animation: _tabController,
                              builder: (context, _) {
                                return TabBar(
                                  controller: _tabController,
                                  dividerHeight: 0,
                                  indicatorSize: TabBarIndicatorSize.tab,
                                  indicatorColor: AppColors.textBlue,
                                  labelColor: AppColors.textBlue,
                                  unselectedLabelColor: AppColors.textGray,
                                  tabs: [
                                    Tab(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Text("Offers"),
                                          if (offersWithUpdateCount > 0)
                                            Container(
                                              margin: const EdgeInsets.only(
                                                left: 8,
                                              ),
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: _tabController.index == 0
                                                    ? AppColors.textBlue
                                                    : AppColors.textBlue
                                                          .withValues(
                                                            alpha: .6,
                                                          ),
                                              ),
                                              child: Text(
                                                "$offersWithUpdateCount",
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.textWhite,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Tab(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Text("Messages"),

                                          Container(
                                            margin: const EdgeInsets.only(
                                              left: 8,
                                            ),
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: _tabController.index == 1
                                                  ? AppColors.textBlue
                                                  : AppColors.textBlue
                                                        .withValues(alpha: .6),
                                            ),
                                            child: Text(
                                              "2",
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textWhite,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            physics: const BouncingScrollPhysics(),
                            children: [
                              // Uses the OffersCubit for aggregated offers
                              _buildOffersTab(context, filterState),
                              // Uses the ConversationsBloc for messages
                              _buildMessagesTab(context),
                            ],
                          ),
                        ),
                      ],
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
