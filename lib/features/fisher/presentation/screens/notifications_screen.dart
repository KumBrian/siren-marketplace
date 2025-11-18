import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/bloc/cubits/catch_filter_cubit/catch_filter_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/catch_filter_cubit/catch_filter_state.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/models/offer.dart';
import 'package:siren_marketplace/core/types/enum.dart';
import 'package:siren_marketplace/core/types/extensions.dart';
import 'package:siren_marketplace/core/utils/custom_icons.dart';
import 'package:siren_marketplace/core/widgets/custom_button.dart';
import 'package:siren_marketplace/core/widgets/filter_button.dart';
import 'package:siren_marketplace/core/widgets/message_card.dart';
import 'package:siren_marketplace/core/widgets/page_title.dart';
import 'package:siren_marketplace/features/chat/data/models/conversation_preview.dart';
import 'package:siren_marketplace/features/chat/logic/conversations_bloc/conversations_bloc.dart';
import 'package:siren_marketplace/features/fisher/logic/offers_bloc/offers_bloc.dart';
import 'package:siren_marketplace/features/fisher/presentation/widgets/offer_card.dart';

const String CURRENT_FISHER_ID = 'fisher_id_1';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with TickerProviderStateMixin {
  Widget _buildOffersTab(BuildContext context, CatchFilterState filterState) {
    return BlocBuilder<OffersBloc, OffersState>(
      builder: (context, offersState) {
        if (offersState is OffersLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final List<Offer> allOffers = offersState is OffersLoaded
            ? offersState.offers
            : [];

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
          final dateA = DateTime.parse(a.dateCreated);
          final dateB = DateTime.parse(b.dateCreated);

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
              // SearchBar component
              // Padding(
              //   padding: EdgeInsets.only(bottom: 8.0),
              //   child: SearchBar(
              //     hintText: "Search",
              //     textStyle: WidgetStatePropertyAll(
              //       TextStyle(fontSize: 16, color: AppColors.textBlue),
              //     ),
              //     shape: WidgetStateProperty.all(
              //       RoundedRectangleBorder(
              //         borderRadius: BorderRadius.all(Radius.circular(12)),
              //       ),
              //     ),
              //     leading: Icon(Icons.search, color: AppColors.textBlue),
              //     elevation: WidgetStatePropertyAll(0),
              //   ),
              // ),

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
                    if (offersState is OffersError)
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
                    return OfferCard(
                      offer: offer,
                      clientName: offer.buyerName,
                      clientRating: offer.buyerRating,

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
                    // Padding(
                    //   padding: EdgeInsets.only(bottom: 8.0),
                    //   child: SearchBar(
                    //     hintText: "Search",
                    //     textStyle: WidgetStatePropertyAll(
                    //       TextStyle(fontSize: 16, color: AppColors.textBlue),
                    //     ),
                    //     shape: WidgetStateProperty.all(
                    //       RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.all(Radius.circular(12)),
                    //       ),
                    //     ),
                    //
                    //     leading: Icon(Icons.search, color: AppColors.textBlue),
                    //     elevation: WidgetStatePropertyAll(0),
                    //   ),
                    // ),
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
    // ✅ NEW: Load offers specifically for the current Fisher user
    context.read<OffersBloc>().add(
      LoadOffersForUser(userId: CURRENT_FISHER_ID, role: Role.fisher),
    );
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
                        BlocBuilder<OffersBloc, OffersState>(
                          builder: (context, offersState) {
                            if (offersState is OffersLoaded) {
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
                                                padding: const EdgeInsets.all(
                                                  6,
                                                ),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color:
                                                      _tabController.index == 0
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
                                                          .withValues(
                                                            alpha: .6,
                                                          ),
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
                            }
                            return Container();
                          },
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            physics: const BouncingScrollPhysics(),
                            children: [
                              // Uses the OffersBloc for aggregated offers
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
