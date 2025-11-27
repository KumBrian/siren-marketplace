import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/bloc/cubits/orders_filter_cubit/orders_filter_cubit.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/domain/entities/offer.dart';
import 'package:siren_marketplace/core/domain/enums/offer_status.dart';
import 'package:siren_marketplace/core/domain/services/session_service.dart';
import 'package:siren_marketplace/core/types/extensions.dart';
import 'package:siren_marketplace/core/widgets/custom_button.dart';
import 'package:siren_marketplace/core/widgets/filter_button.dart';
import 'package:siren_marketplace/core/widgets/message_card.dart';
import 'package:siren_marketplace/core/widgets/page_title.dart';
import 'package:siren_marketplace/features/buyer/presentation/widgets/offer_card.dart';
import 'package:siren_marketplace/features/chat/data/models/conversation_preview.dart';
import 'package:siren_marketplace/features/chat/logic/conversations_bloc/conversations_bloc.dart';
import 'package:siren_marketplace/features/fisher/new_logic/offers_bloc/offers_cubit.dart';
import 'package:siren_marketplace/features/fisher/new_logic/users_bloc/users_cubit.dart';

class BuyerNotificationsScreen extends StatefulWidget {
  const BuyerNotificationsScreen({super.key});

  @override
  State<BuyerNotificationsScreen> createState() =>
      _BuyerNotificationsScreenState();
}

class _BuyerNotificationsScreenState extends State<BuyerNotificationsScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late TabController _tabController;
  String? _currentBuyerId;

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
    _loadBuyerData();
  }

  Future<void> _loadBuyerData() async {
    final sessionService = context.read<SessionService>();
    final user = await sessionService.getCurrentUser();

    if (user != null && mounted) {
      setState(() {
        _currentBuyerId = user.id;
      });

      // Load buyer-specific offers using OffersCubit
      final offersCubit = context.read<OffersCubit>();
      offersCubit.loadForBuyer(user.id);

      // Load fisher users for the offers
      final usersCubit = context.read<UsersCubit>();
      final fisherIds = offersCubit.state.offers
          .map((offer) => offer.fisherId)
          .toSet()
          .toList();
      if (fisherIds.isNotEmpty) {
        usersCubit.loadByIds(fisherIds);
      }

      // Load conversations
      final conversationsBloc = context.read<ConversationsBloc>();
      if (conversationsBloc.state is ConversationsInitial) {
        conversationsBloc.add(LoadConversations(buyerId: user.id));
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
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
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    conversationState.message,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    title: "Retry",
                    onPressed: () {
                      if (_currentBuyerId != null) {
                        context.read<ConversationsBloc>().add(
                          LoadConversations(buyerId: _currentBuyerId!),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        }

        if (conversationState is ConversationsLoaded) {
          final conversations = conversationState.conversations;

          if (conversations.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 64.0),
                child: Column(
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
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 80, top: 16),
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: conversations.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final msg = conversations[index];
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
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildCountBadge({required int count, required bool isSelected}) {
    return Container(
      key: ValueKey('badge_$count'),
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected
            ? AppColors.textBlue
            : AppColors.textBlue.withOpacity(0.6),
      ),
      child: Text(
        "$count",
        style: const TextStyle(fontSize: 12, color: AppColors.textWhite),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentBuyerId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return BlocBuilder<OffersCubit, OffersState>(
      builder: (context, offersState) {
        if (offersState.loading && offersState.offers.isEmpty) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (offersState.error != null && offersState.offers.isEmpty) {
          return Scaffold(
            body: Center(
              child: Text('Error loading offers: ${offersState.error}'),
            ),
          );
        }

        // Filter offers for this buyer
        final allOffers = offersState.offers
            .where((offer) => offer.buyerId == _currentBuyerId)
            .toList();

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
                                      color: AppColors.getStatusColor(
                                        OfferStatus.pending,
                                      ),
                                      isSelected: state.selectedStatuses
                                          .contains(OfferStatus.pending),
                                      onPressed: () => cubit.toggleStatus(
                                        OfferStatus.pending,
                                      ),
                                    ),
                                    FilterButton(
                                      title: "Accepted",
                                      color: AppColors.getStatusColor(
                                        OfferStatus.accepted,
                                      ),
                                      isSelected: state.selectedStatuses
                                          .contains(OfferStatus.accepted),
                                      onPressed: () => cubit.toggleStatus(
                                        OfferStatus.accepted,
                                      ),
                                    ),
                                    FilterButton(
                                      title: "Rejected",
                                      color: AppColors.getStatusColor(
                                        OfferStatus.rejected,
                                      ),
                                      isSelected: state.selectedStatuses
                                          .contains(OfferStatus.rejected),
                                      onPressed: () => cubit.toggleStatus(
                                        OfferStatus.rejected,
                                      ),
                                    ),
                                    FilterButton(
                                      title: "Completed",
                                      color: AppColors.getStatusColor(
                                        OfferStatus.completed,
                                      ),
                                      isSelected: state.selectedStatuses
                                          .contains(OfferStatus.completed),
                                      onPressed: () => cubit.toggleStatus(
                                        OfferStatus.completed,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: CustomButton(
                                        title: "Clear",
                                        bordered: true,
                                        onPressed: () {
                                          cubit.clear();
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: CustomButton(
                                        title: "Apply",
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
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
                icon: const Icon(Icons.filter_list),
              ),
            ],
            title: const PageTitle(title: "Notifications"),
            centerTitle: true,
            bottom: TabBar(
              controller: _tabController,
              labelColor: AppColors.textBlue,
              unselectedLabelColor: AppColors.textGray,
              indicatorColor: AppColors.textBlue,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Offers"),
                      if (allOffers.isNotEmpty)
                        _buildCountBadge(
                          count: allOffers.length,
                          isSelected: _tabController.index == 0,
                        ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Messages"),
                      BlocBuilder<ConversationsBloc, ConversationsState>(
                        builder: (context, conversationState) {
                          final unreadCount =
                              conversationState is ConversationsLoaded
                              ? conversationState.conversations.fold<int>(
                                  0,
                                  (sum, c) => sum + c.unreadCount,
                                )
                              : 0;
                          if (unreadCount > 0) {
                            return _buildCountBadge(
                              count: unreadCount,
                              isSelected: _tabController.index == 1,
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // Offers Tab
              BlocBuilder<OrdersFilterCubit, OrdersFilterState>(
                builder: (context, filterState) {
                  final filteredOffers = _applyOfferFilters(
                    allOffers,
                    filterState,
                  );

                  if (filteredOffers.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 64.0),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 120,
                              width: 120,
                              child: Image.asset(
                                "assets/images/no-notifications.png",
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
                              "Browse the marketplace and make an offer.",
                              style: TextStyle(
                                color: AppColors.textGray,
                                fontWeight: FontWeight.w300,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _loadBuyerData,
                    child: BlocBuilder<UsersCubit, UsersState>(
                      builder: (context, usersState) {
                        return ListView.separated(
                          padding: const EdgeInsets.only(bottom: 80, top: 16),
                          itemCount: filteredOffers.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final offer = filteredOffers[index];
                            final fisher = usersState.users[offer.fisherId];

                            return OfferCard(
                              offer: offer,
                              onPressed: () {
                                context.push(
                                  "/buyer/offer-details/${offer.id}",
                                );
                              },
                              fisherName: fisher?.name ?? 'Unknown Fisher',
                              fisherRating: fisher?.rating.value ?? 0.0,
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
              // Messages Tab
              _buildMessagesTab(),
            ],
          ),
        );
      },
    );
  }
}
