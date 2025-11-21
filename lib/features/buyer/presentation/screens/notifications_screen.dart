import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/bloc/cubits/orders_filter_cubit/orders_filter_cubit.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/widgets/custom_button.dart';
import 'package:siren_marketplace/core/widgets/filter_button.dart';
import 'package:siren_marketplace/core/widgets/message_card.dart';
import 'package:siren_marketplace/core/widgets/page_title.dart';
import 'package:siren_marketplace/features/buyer/presentation/widgets/offer_card.dart';
import 'package:siren_marketplace/features/chat/data/models/conversation_preview.dart';
import 'package:siren_marketplace/features/chat/logic/conversations_bloc/conversations_bloc.dart';
import 'package:siren_marketplace/new_core/domain/entities/offer.dart';
import 'package:siren_marketplace/new_core/domain/enums/offer_status.dart';
import 'package:siren_marketplace/new_core/domain/enums/user_role.dart';
import 'package:siren_marketplace/new_features/fisher/presentation/cubits/offer_list/offer_list_cubit.dart';
import 'package:siren_marketplace/new_features/fisher/presentation/cubits/offer_list/offer_list_state.dart';
import 'package:siren_marketplace/new_core/presentation/cubits/auth/auth_cubit.dart';
import 'package:siren_marketplace/new_core/presentation/cubits/auth/auth_state.dart';

class BuyerNotificationsScreen extends StatefulWidget {
  const BuyerNotificationsScreen({super.key});

  @override
  State<BuyerNotificationsScreen> createState() =>
      _BuyerNotificationsScreenState();
}

class _BuyerNotificationsScreenState extends State<BuyerNotificationsScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late TabController _tabController;

  List<Offer> _applyOfferFilters(List<Offer> offers, OrdersFilterState state) {
    if (state.selectedStatuses.isEmpty) {
      return offers;
    }
    return offers.where((offer) {
      return state.selectedStatuses.contains(offer.status);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get buyer ID from AuthCubit
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      final buyerId = authState.user.id;

      // Load conversations for messages tab
      final conversationsBloc = context.read<ConversationsBloc>();
      if (conversationsBloc.state is ConversationsInitial) {
        conversationsBloc.add(LoadConversations(buyerId: buyerId));
      }
    }
  }

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
          padding: const EdgeInsets.only(bottom: 80, top: 16),
          child: Column(
            children: [
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
              else
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
                      time: msg.lastMessageTime,
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
    return BlocBuilder<OfferListCubit, OfferListState>(
      builder: (context, offersState) {
        if (offersState is OfferListLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (offersState is OfferListError) {
          return Scaffold(
            body: Center(
              child: Text('Error loading offers: ${offersState.message}'),
            ),
          );
        }

        final allOffers = offersState is OfferListLoaded
            ? offersState.offers
            : <Offer>[];

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
                              children: [
                                const Text(
                                  "Filter by",
                                  style: TextStyle(fontSize: 12),
                                ),
                                const SizedBox(height: 12),
                                const Text("Status"),
                                const SizedBox(height: 12),
                                const Text(
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
            title: const PageTitle(title: "Notifications"),
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
                          AnimatedBuilder(
                            animation: _tabController,
                            builder: (context, __) {
                              // Count offers waiting for buyer action
                              int offersWithUpdateCount = allOffers
                                  .where(
                                    (offer) =>
                                        offer.waitingFor == UserRole.buyer,
                                  )
                                  .length;

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
                                                        .withValues(alpha: .6),
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
                                                : AppColors.textBlue.withValues(
                                                    alpha: .6,
                                                  ),
                                          ),
                                          child: const Text(
                                            "0",
                                            style: TextStyle(
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
                          ),
                          Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              physics: const BouncingScrollPhysics(),
                              children: [
                                // Offers Tab
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
                                                  "You have no offers yet.",
                                                  style: TextStyle(
                                                    color: AppColors.textGray,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const Text(
                                                  "Make an offer on a product.",
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
                                                // TODO: Load fisher data from repository
                                                final fisherName =
                                                    'Fisher ${offer.fisherId.substring(0, 8)}';
                                                final fisherRating = 0.0;

                                                return OfferCard(
                                                  offer: offer,
                                                  fisherRating: fisherRating,
                                                  fisherName: fisherName,
                                                  onPressed: () {
                                                    offer.status ==
                                                                OfferStatus
                                                                    .pending ||
                                                            offer.status ==
                                                                OfferStatus
                                                                    .rejected
                                                        ? context.push(
                                                            "/buyer/offer-details/${offer.id}",
                                                          )
                                                        : context.push(
                                                            "/buyer/order-details/${offer.id}",
                                                          );
                                                  },
                                                );
                                              }).toList(),
                                            ),
                                    );
                                  },
                                ),
                                // Messages Tab
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
